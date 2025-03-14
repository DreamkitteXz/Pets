//==========================================================================
// Descrição: Classe com atributos das Vacinas para melhor manipulação delas.
// Autor: Kayque Amado
// Data: 09/03/2024
//==========================================================================

class Vacinas {
  String id;
  String vacina;
  String dataAplicada;
  String proximaAplicacao;
  String pesoDataAplicacao;
  String imageRotulo;
  String lote;
  String farmaceutica;
  String dataValidade;
  String nomeVet;
  String crmv;
  String observacoes;
  String? cnpj;
  String? clinica;
  String? rua;
  String? bairro;
  String? numero;
  String? cidade;
  String isValidadoVet;
  String isValidadoTutor;
  Vacinas(
      {required this.id,
      required this.vacina,
      required this.dataAplicada,
      required this.proximaAplicacao,
      required this.pesoDataAplicacao,
      required this.imageRotulo,
      required this.lote,
      required this.farmaceutica,
      required this.dataValidade,
      required this.nomeVet,
      required this.crmv,
      required this.observacoes,
      required this.isValidadoVet,
      required this.isValidadoTutor,
      this.cnpj,
      this.clinica,
      this.rua,
      this.bairro,
      this.numero,
      this.cidade});

  Vacinas.fromMap(Map<String, dynamic> map)
      : id = map["Id"] ?? '',
        vacina = map["Vacina"] ?? '',
        dataAplicada = map["Data Aplicada"] ?? '',
        pesoDataAplicacao = map["Peso do Pet"] ?? '',
        proximaAplicacao = map["Próxima aplicação"] ?? '',
        imageRotulo = map["Imagem do Rótulo"] ?? '',
        lote = map["Lote"] ?? '',
        farmaceutica = map["Farmaceutica"] ?? '',
        dataValidade = map["Data de Validade"] ?? '',
        nomeVet = map["Nome do Veterinário(a)"] ?? '',
        crmv = map["CRMV do Veterinário(a)"] ?? '',
        observacoes = map["Observações"] ?? '',
        cnpj = map["CNPJ"] ?? '',
        clinica = map["Clínica"] ?? '',
        rua = map["Rua"] ?? '',
        bairro = map["Bairro"] ?? '',
        numero = map["Número"] ?? '',
        cidade = map["Cidade"] ?? '',
        isValidadoVet = map["isValidadoVet"] ?? '',
        isValidadoTutor = map["isValidadoTutor"] ?? '';

  Map<String, dynamic> toMap() {
    return {
      "Id": id,
      "Vacina": vacina,
      "Data Aplicada": dataAplicada,
      "Peso do Pet": pesoDataAplicacao,
      "Próxima aplicação": proximaAplicacao,
      "Imagem do Rótulo": imageRotulo,
      "Lote": lote,
      "Farmaceutica": farmaceutica,
      "Data de Validade": dataValidade,
      "Nome do Veterinário(a)": nomeVet,
      "CRMV do Veterinário(a)": crmv,
      "Observações": observacoes,
      "CNPJ": cnpj,
      "Clínica": clinica,
      "Rua": rua,
      "Bairro": bairro,
      "Número": numero,
      "Cidade": cidade,
      "isValidadoVet": isValidadoVet,
      "isValidadoTutor": isValidadoTutor,
    };
  }
}
