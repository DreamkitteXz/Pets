import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Quem registrou a pesagem.
///
/// Espelha o campo `source` do documento. Pesagem sem `source` é do
/// veterinário: a web (usePetRecord.js → addPeso) não grava o campo, e só o vet
/// escrevia lá antes desta rule.
enum WeightSource { vet, tutor }

class PetWeightRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Subcoleção canônica de pesagens: `pets/{petId}/pesos`.
  ///
  /// O app lia `weights` (inglês) e a web grava/lê `pesos`
  /// (usePetRecord.js → addPeso, WeightChart.jsx). Eram DOIS históricos
  /// desconectados: pesagem lançada pelo vet no site não aparecia no app, e
  /// vice-versa. `pesos` é o nome que a web e o schema usam.
  CollectionReference<Map<String, dynamic>> _weightsRef(String petId) {
    return _firestore.collection('pets').doc(petId).collection('pesos');
  }

  /// Registra uma pesagem informada pelo TUTOR e atualiza o peso atual do pet,
  /// em lote (ou entram os dois, ou nenhum).
  ///
  /// São duas gravações porque são dois papéis distintos do mesmo número:
  ///  • `pets/{petId}/pesos/{id}` — ponto na linha do tempo. É o que alimenta o
  ///    gráfico aqui e o WeightChart da web.
  ///  • `pets/{petId}.weight` — peso ATUAL, exibido na ficha do pet e copiado
  ///    para `vaccines.petWeight` no cadastro de aplicação da web.
  ///
  /// `source: 'tutor'` + `registeredBy` são exigidos pela rule de `pesos`: o
  /// dono só cria auto-relato identificado, nunca uma pesagem que se passe por
  /// clínica.
  Future<void> registerTutorWeight(
    String petId,
    double weight, {
    String? notes,
    DateTime? date,
  }) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      throw StateError('Sessão expirada — entre novamente para registrar.');
    }

    final now = Timestamp.now();
    final batch = _firestore.batch();

    batch.set(_weightsRef(petId).doc(), {
      'weight': weight,
      'date': date == null ? now : Timestamp.fromDate(date),
      'notes': notes ?? '',
      'source': 'tutor',
      'registeredBy': uid,
      // Mesma trilha de auditoria da web (usePetRecord.js → addPeso).
      'createdBy': uid,
      'updatedBy': uid,
      'createdAt': now,
      'updatedAt': now,
    });

    batch.update(_firestore.collection('pets').doc(petId), {
      // Number, não String: o schema da web é `pets.weight: Number` e a
      // NewApplicationModal copia esse valor para `vaccines.petWeight`
      // (também Number). O app gravava String e sujava o registro clínico.
      'weight': weight,
      'weightUpdatedAt': now,
      'updatedAt': now,
    });

    await batch.commit();
  }

  Stream<List<WeightEntry>> weightsStream(String petId) {
    return _weightsRef(petId)
        .orderBy('date', descending: false)
        .snapshots()
        .map((snapshot) {
      // Uma pesagem com data ou peso ilegíveis é descartada em vez de derrubar
      // o stream inteiro — há documentos antigos com formatos variados.
      final entries = <WeightEntry>[];
      for (final doc in snapshot.docs) {
        final entry = WeightEntry.fromDoc(doc);
        if (entry != null) entries.add(entry);
      }
      return entries;
    });
  }
}

/// Uma pesagem: data, peso em kg e de quem veio.
class WeightEntry {
  final String id;
  final DateTime date;
  final double weight;
  final WeightSource source;
  final String notes;

  const WeightEntry({
    required this.id,
    required this.date,
    required this.weight,
    required this.source,
    this.notes = '',
  });

  /// `null` quando data ou peso não são legíveis.
  static WeightEntry? fromDoc(
      QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();

    final rawDate = data['date'];
    DateTime? date;
    if (rawDate is Timestamp) {
      date = rawDate.toDate();
    } else if (rawDate is DateTime) {
      date = rawDate;
    } else if (rawDate is String) {
      date = DateTime.tryParse(rawDate);
    }
    if (date == null) return null;

    final rawWeight = data['weight'];
    final weight = rawWeight is num
        ? rawWeight.toDouble()
        : double.tryParse(
            (rawWeight ?? '').toString().replaceAll(',', '.'));
    if (weight == null || weight <= 0) return null;

    return WeightEntry(
      id: doc.id,
      date: date,
      weight: weight,
      // Sem `source` = pesagem do vet (formato da web, anterior a este campo).
      source: data['source'] == 'tutor' ? WeightSource.tutor : WeightSource.vet,
      notes: (data['notes'] ?? '').toString(),
    );
  }
}
