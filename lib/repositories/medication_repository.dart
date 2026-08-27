import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pet_app/models/medication_model.dart';

/// Medicamentos do pet, gravados em `pets/{petId}.medications` (array de mapas).
///
/// **Por que não uma coleção própria?** As rules em vigor (Website/
/// firestore.rules) têm um catch-all `allow read, write: if false` — uma
/// coleção `medications` nova nasceria negada. E `pets/{petId}/{record=**}`
/// (o prontuário) só aceita escrita do **vet vinculado**; o tutor lê e nada
/// mais. O único ponto que o dono pode escrever hoje é o próprio doc do pet
/// (`allow update: if uid == ownerId`).
///
/// Medicamento informado pelo tutor **não é** prontuário clínico, então mora
/// junto do cadastro do pet e não vira registro com validação de veterinário.
/// Se um dia a rule ganhar uma coleção `medications` (com o eixo de status do
/// vet), a migração é ler este array e escrever nos documentos — a UI já fala
/// em [Medicamento].
///
/// Compare com o peso, que seguiu o caminho oposto: a rule de
/// `pets/{petId}/pesos` foi aberta ao dono (`source: 'tutor'`), então lá o
/// auto-relato é documento de verdade e aparece também na web.
///
/// O array é read-modify-write dentro de uma transação: duas telas abertas no
/// mesmo pet não podem sobrescrever uma à outra.
class MedicationRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static const String _field = 'medications';

  DocumentReference<Map<String, dynamic>> _petRef(String petId) =>
      _firestore.collection('pets').doc(petId);

  List<Medicamento> _parse(Map<String, dynamic>? data) {
    final raw = data?[_field];
    if (raw is! List) return const <Medicamento>[];
    final list = <Medicamento>[];
    for (final item in raw) {
      if (item is! Map) continue;
      final med = Medicamento.fromMap(Map<String, dynamic>.from(item));
      if (med.id.isEmpty || !med.active) continue; // arquivados não aparecem
      list.add(med);
    }
    // Mais recentes primeiro, pelo início do tratamento (sem data por último).
    list.sort((a, b) {
      final da = a.startDate;
      final db = b.startDate;
      if (da == null && db == null) return 0;
      if (da == null) return 1;
      if (db == null) return -1;
      return db.compareTo(da);
    });
    return list;
  }

  /// Medicamentos ativos do pet, em tempo real.
  Stream<List<Medicamento>> medicationsStream(String petId) {
    return _petRef(petId).snapshots().map((snap) => _parse(snap.data()));
  }

  Future<List<Medicamento>> fetchMedications(String petId) async {
    final snap = await _petRef(petId).get();
    return _parse(snap.data());
  }

  /// Aplica [mutate] sobre a lista bruta (inclusive arquivados) e regrava.
  Future<void> _mutate(
    String petId,
    List<Map<String, dynamic>> Function(List<Map<String, dynamic>> current)
        mutate,
  ) async {
    final ref = _petRef(petId);
    await _firestore.runTransaction((tx) async {
      final snap = await tx.get(ref);
      final raw = snap.data()?[_field];
      final current = <Map<String, dynamic>>[
        if (raw is List)
          for (final item in raw)
            if (item is Map) Map<String, dynamic>.from(item),
      ];
      tx.update(ref, {
        _field: mutate(current),
        'updatedAt': Timestamp.now(),
      });
    });
  }

  Future<void> addMedication(String petId, Medicamento medication) {
    final now = DateTime.now();
    final toSave = medication.copyWith(updatedAt: now);
    return _mutate(petId, (current) {
      return [
        ...current,
        Medicamento(
          id: toSave.id,
          name: toSave.name,
          dosage: toSave.dosage,
          frequency: toSave.frequency,
          route: toSave.route,
          startDate: toSave.startDate,
          endDate: toSave.endDate,
          prescribedBy: toSave.prescribedBy,
          notes: toSave.notes,
          active: true,
          createdAt: now,
          updatedAt: now,
        ).toMap(),
      ];
    });
  }

  Future<void> updateMedication(String petId, Medicamento medication) {
    final updated = medication.copyWith(updatedAt: DateTime.now()).toMap();
    return _mutate(petId, (current) {
      return [
        for (final item in current)
          if ((item['id'] ?? '').toString() == medication.id) updated else item,
      ];
    });
  }

  /// Exclusão LÓGICA (`active: false`), como em vaccines/deworming: o histórico
  /// do pet não some da base, só deixa de ser listado.
  Future<void> archiveMedication(String petId, String medicationId) {
    final now = Timestamp.now();
    return _mutate(petId, (current) {
      return [
        for (final item in current)
          if ((item['id'] ?? '').toString() == medicationId)
            {...item, 'active': false, 'updatedAt': now}
          else
            item,
      ];
    });
  }
}
