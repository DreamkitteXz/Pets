import 'functions_service.dart';

/// Submissão de vacina pelo TUTOR (§13.1 — decisão de produto: **CF nova
/// `submitVaccineByTutor`**).
///
/// Seam ISOLADO e trocável: a tela de criação chama [submit]; TODA a regra de
/// "qual vet aprova" fica server-side na Cloud Function, então nenhuma tela
/// precisa conhecer vets nem gravar `veterinarianId` arbitrário (a rule/CF de
/// aprovação exige `veterinarianId == caller`).
///
/// ───────────────────────────────────────────────────────────────────────────
/// 🔴 DEPENDÊNCIA DE BACKEND (a implementar na branch `Website` / Firebase —
/// NÃO faço aqui). Contrato esperado da callable, região `southamerica-east1`:
///
///   nome:   submitVaccineByTutor  (onCall)
///   input:  { petId: String, vaccineData: { ...campos clínicos... } }
///   passos: exige auth; confirma que o caller é o ownerId do pet; resolve o
///           veterinarianId aprovador a partir de pets.veterinarians[] /
///           preferredVetId; cria doc em `vaccines` com esse veterinarianId,
///           ownerId=caller, status:'pending', createdBy=caller e
///           serverTimestamp; (opcional) notifica o vet.
///   output: { id: String }
///   erros:  failed-precondition se o pet não tiver vet vinculado.
/// ───────────────────────────────────────────────────────────────────────────
///
/// Enquanto a CF NÃO estiver publicada, [enabled] = false: o app não tenta
/// criar (evita quebrar / criar registros órfãos) e a UI trata como
/// indisponível. Ao publicar a CF, vire [enabled] para true — nenhuma outra
/// mudança de tela é necessária.
class TutorVaccineSubmission {
  TutorVaccineSubmission._();
  static final TutorVaccineSubmission instance = TutorVaccineSubmission._();

  /// Feature-flag: só ligar quando `submitVaccineByTutor` estiver deployada.
  static const bool enabled = false;

  static const String _functionName = 'submitVaccineByTutor';

  /// Cria uma vacina "aguardando validação" via Cloud Function.
  /// Retorna o id do documento criado. Lança se [enabled] for false ou se a
  /// CF falhar (ex.: `not-found` enquanto não publicada).
  Future<String> submit({
    required String petId,
    required Map<String, dynamic> vaccineData,
  }) async {
    if (!enabled) {
      throw const TutorSubmissionUnavailable();
    }
    final callable =
        FunctionsService.instance.httpsCallable(_functionName);
    final result = await callable.call<dynamic>({
      'petId': petId,
      'vaccineData': vaccineData,
    });
    final data = result.data;
    final id = (data is Map) ? data['id'] : null;
    return (id ?? '').toString();
  }
}

/// Sinaliza que a submissão via CF ainda não está disponível (flag desligada
/// ou CF não publicada) — a UI deve mostrar o fluxo como "em breve/indisponível".
class TutorSubmissionUnavailable implements Exception {
  const TutorSubmissionUnavailable();
  @override
  String toString() =>
      'Submissão de vacina pelo tutor ainda não está disponível '
      '(Cloud Function submitVaccineByTutor pendente).';
}
