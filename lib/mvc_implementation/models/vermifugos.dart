//==============================================================================
// Descrição: Classe com atributos dos Vermifugos para melhor manipulação deles.
// Autor: Kayque Amado
// Data: 09/03/2024
//==============================================================================

class Vermifugo {
  String id;
  String vermifugo;
  String primeiraDose;
  String doseReforco;
  String kilograma;
  String peso;

  Vermifugo({
    required this.id,
    required this.vermifugo,
    required this.primeiraDose,
    required this.doseReforco,
    required this.kilograma,
    required this.peso,
  });

  Vermifugo.fromMap(Map<String, dynamic> map)
      : id = map["Id"] ?? '',
        vermifugo = map["Vermifugo"] ?? '',
        primeiraDose = map["Primeira Dose"] ?? '',
        doseReforco = map["Dose de Reforço"] ?? '',
        kilograma = map["Kilogramas"] ?? '',
        peso = map["Peso"] ?? '';

  Map<String, dynamic> toMap() {
    return {
      "Id": id,
      "Vermifugo": vermifugo,
      "Primeira Dose": primeiraDose,
      "Dose de Reforço": doseReforco,
      "Kilogramas": kilograma,
      "Peso": peso,
    };
  }
}
