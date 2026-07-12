/// Seam isolado e TROCÁVEL para resolver QUAL veterinário aprovará um registro
/// clínico (vacina/vermífugo) criado pelo tutor. — §13.1 (decisão pendente).
///
/// Contexto: a Cloud Function de aprovação (`updateVaccineStatus`) exige
/// `veterinarianId == caller`. Logo, um registro criado pelo TUTOR precisa
/// carregar o `veterinarianId` do vet que irá aprová-lo, senão nenhum vet
/// consegue vê-lo/validá-lo pela web.
///
/// COMO o tutor escolhe/associa esse vet é DECISÃO DE PRODUTO PENDENTE e
/// provavelmente exige backend (ex.: diretório de vets legível ao tutor, ou uma
/// CF nova `submitVaccineByTutor` que atribua o vet). Enquanto isso não for
/// definido, o seam retorna `null` (não configurado) e o app **não** grava um
/// `veterinarianId` arbitrário.
///
/// Para plugar a solução real depois, basta trocar [VetApproverProvider.instance]
/// por uma implementação concreta — nenhuma tela precisa mudar.
abstract class VetApprover {
  /// Resolve o `veterinarianId` aprovador para um pet. Retorna `null` enquanto
  /// o mecanismo (backend) não estiver definido.
  Future<String?> resolveApproverVetId({
    required String petId,
    String? ownerId,
  });

  /// Indica se há um mecanismo configurado (para a UI gatear o fluxo de criação).
  bool get isConfigured;
}

/// Stub padrão: nenhum mecanismo configurado ainda (§13.1 pendente).
class UnconfiguredVetApprover implements VetApprover {
  const UnconfiguredVetApprover();

  @override
  bool get isConfigured => false;

  @override
  Future<String?> resolveApproverVetId({
    required String petId,
    String? ownerId,
  }) async =>
      null;
}

/// Ponto único de acesso ao seam. Troque [instance] quando o backend do §13.1
/// for definido.
class VetApproverProvider {
  VetApproverProvider._();
  static VetApprover instance = const UnconfiguredVetApprover();
}
