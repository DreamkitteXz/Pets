//==========================================================================
// Descrição: Classe com atributos das Vacinas para melhor manipulação delas.
// Autor: Kayque Amado
// Data: 09/03/2024
//==========================================================================

class VacinasPendentes {
  // Pet
  String pet;
  String cor_pet;
  String raca_pet;
  String sexo_pet;
  String tipo_pet;
  // Vacina
  String id_vac;
  String vacina;
  String data_aplicacao;
  String proxima_aplicacao;
  String imagem_rotulo;
  String lote;
  String farmaceutica;
  String peso_pet_vac;
  String data_validade;
  String is_vac_validada;
  // Veterinario(a)
  String nome_vet;
  String crmv;
  String is_vet_validado;
  String observacoes;
  String? cnpj;
  String? clinica;
  String? endereco;

  VacinasPendentes({
    required this.pet,
    required this.cor_pet,
    required this.raca_pet,
    required this.sexo_pet,
    required this.tipo_pet,
    required this.id_vac,
    required this.vacina,
    required this.data_aplicacao,
    required this.proxima_aplicacao,
    required this.imagem_rotulo,
    required this.lote,
    required this.farmaceutica,
    required this.peso_pet_vac,
    required this.data_validade,
    required this.is_vac_validada,
    required this.nome_vet,
    required this.crmv,
    required this.is_vet_validado,
    required this.observacoes,
    this.cnpj,
    this.clinica,
    this.endereco,
  });

  VacinasPendentes.fromMap(Map<String, dynamic> map)
      : pet = map["pet"] ?? '',
        cor_pet = map["cor_pet"] ?? '',
        raca_pet = map["raca_pet"] ?? '',
        sexo_pet = map["sexo_pet"] ?? '',
        tipo_pet = map["tipo_pet"] ?? '',
        id_vac = map["id_vac"] ?? '',
        lote = map["Lote"] ?? '',
        farmaceutica = map["Farmaceutica"] ?? '',
        vacina = map["vacina"] ?? '',
        data_aplicacao = map["data_aplicacao"] ?? '',
        proxima_aplicacao = map["proxima_aplicacao"] ?? '',
        imagem_rotulo = map["imagem_rotulo"] ?? '',
        peso_pet_vac = map["peso_pet_vac"] ?? '',
        data_validade = map["data_validade"] ?? '',
        is_vac_validada = map["is_vac_validada"] ?? '',
        nome_vet = map["nome_vet"] ?? '',
        crmv = map["crmv"] ?? '',
        is_vet_validado = map["is_vet_validado"] ?? '',
        observacoes = map["observacoes"] ?? '',
        cnpj = map["cnpj"] ?? '',
        clinica = map["clinica"] ?? '',
        endereco = map["endereco"] ?? '';

  Map<String, dynamic> toMap() {
    return {
      "pet": pet,
      "cor_pet": cor_pet,
      "raca_pet": raca_pet,
      "sexo_pet": sexo_pet,
      "tipo_pet": tipo_pet,
      "id_vac": id_vac,
      "vacina": vacina,
      "data_aplicacao": data_aplicacao,
      "proxima_aplicacao": proxima_aplicacao,
      "imagem_rotulo": imagem_rotulo,
      "lote": lote,
      "farmaceutica": farmaceutica,
      "peso_pet_vac": peso_pet_vac,
      "data_validade": data_validade,
      "is_vac_validada": is_vac_validada,
      "nome_vet": nome_vet,
      "crmv": crmv,
      "is_vet_validado": is_vet_validado,
      "observacoes": observacoes,
      "cnpj": cnpj,
      "clinica": clinica,
      "endereco": endereco,
    };
  }
}
