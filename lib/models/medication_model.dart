import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pet_app/utils/firestore_date.dart';

//==========================================================================
// Descrição: Medicamento em uso pelo pet, registrado pelo próprio tutor.
//==========================================================================

/// Fase do tratamento — DERIVADA das datas, não um campo gravado.
///
/// Medicamento é auto-relato do tutor: não passa pelo eixo
/// `pending/approved/rejected`, que existe para registro clínico com autoridade
/// do veterinário (vacina/vermífugo). Misturar os dois faria o app sugerir que
/// um vet validou o que o tutor digitou. Ver [AppStatus] em design/widgets.
enum MedicationStage {
  /// Início ainda no futuro.
  scheduled,

  /// Em curso hoje (ou contínuo, sem data de término).
  ongoing,

  /// Término já passou.
  finished,
}

class Medicamento {
  /// Id local (a lista vive num array do doc do pet, não em documentos
  /// próprios — ver [MedicationRepository]). Gerado no cadastro.
  final String id;
  final String? name;

  /// Ex.: "1 comprimido", "5 ml".
  final String? dosage;

  /// Ex.: "A cada 12 horas", "1x ao dia".
  final String? frequency;

  /// Via de administração (oral, tópica, injetável...). Mesmo conceito do
  /// campo `route` da vacina na web.
  final String? route;

  final DateTime? startDate;

  /// `null` = tratamento contínuo (sem previsão de término).
  final DateTime? endDate;

  /// Quem prescreveu (texto livre — o tutor pode não ter o vet cadastrado).
  final String? prescribedBy;

  final String? notes;

  /// Soft-delete, mesma convenção de vaccines/deworming: `false` = arquivado.
  final bool active;

  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Medicamento({
    required this.id,
    this.name,
    this.dosage,
    this.frequency,
    this.route,
    this.startDate,
    this.endDate,
    this.prescribedBy,
    this.notes,
    this.active = true,
    this.createdAt,
    this.updatedAt,
  });

  factory Medicamento.fromMap(Map<String, dynamic> map) {
    return Medicamento(
      id: (map['id'] ?? '').toString(),
      name: map['name'],
      dosage: map['dosage'],
      frequency: map['frequency'],
      route: map['route'],
      // Leitura tolerante (Timestamp / DateTime / dd-MM-yyyy / ISO), igual ao
      // resto do app: um registro com data ilegível não pode derrubar a lista.
      startDate: readFirestoreDate(map['startDate']),
      endDate: readFirestoreDate(map['endDate']),
      prescribedBy: map['prescribedBy'],
      notes: map['notes'],
      active: map['active'] != false,
      createdAt: readFirestoreDate(map['createdAt']),
      updatedAt: readFirestoreDate(map['updatedAt']),
    );
  }

  /// Formato de gravação. Datas viram [Timestamp] — `FieldValue.serverTimestamp`
  /// NÃO é aceito dentro de array, então o carimbo é do cliente.
  Map<String, dynamic> toMap() {
    Timestamp? ts(DateTime? d) => d == null ? null : Timestamp.fromDate(d);
    return {
      'id': id,
      'name': name,
      'dosage': dosage,
      'frequency': frequency,
      'route': route,
      'startDate': ts(startDate),
      'endDate': ts(endDate),
      'prescribedBy': prescribedBy,
      'notes': notes,
      'active': active,
      'createdAt': ts(createdAt),
      'updatedAt': ts(updatedAt),
    };
  }

  Medicamento copyWith({
    String? name,
    String? dosage,
    String? frequency,
    String? route,
    DateTime? startDate,
    DateTime? endDate,
    String? prescribedBy,
    String? notes,
    bool? active,
    DateTime? updatedAt,
    bool clearEndDate = false,
  }) {
    return Medicamento(
      id: id,
      name: name ?? this.name,
      dosage: dosage ?? this.dosage,
      frequency: frequency ?? this.frequency,
      route: route ?? this.route,
      startDate: startDate ?? this.startDate,
      endDate: clearEndDate ? null : (endDate ?? this.endDate),
      prescribedBy: prescribedBy ?? this.prescribedBy,
      notes: notes ?? this.notes,
      active: active ?? this.active,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Fase do tratamento hoje. Comparações por DIA, não por instante.
  ///
  /// Término em HOJE já conta como encerrado: a ação "Encerrar tratamento hoje"
  /// grava a data de hoje, e ficar "Em uso" até a virada do dia faria o botão
  /// parecer que não funcionou.
  MedicationStage get stage {
    final today = _dayOf(DateTime.now());
    final end = endDate;
    if (end != null && !_dayOf(end).isAfter(today)) {
      return MedicationStage.finished;
    }
    final start = startDate;
    if (start != null && _dayOf(start).isAfter(today)) {
      return MedicationStage.scheduled;
    }
    return MedicationStage.ongoing;
  }

  /// Tratamento sem data de término — "uso contínuo".
  bool get isContinuous => endDate == null;

  static DateTime _dayOf(DateTime d) => DateTime(d.year, d.month, d.day);
}

const Map<MedicationStage, String> medicationStageLabels = {
  MedicationStage.scheduled: 'Agendado',
  MedicationStage.ongoing: 'Em uso',
  MedicationStage.finished: 'Encerrado',
};
