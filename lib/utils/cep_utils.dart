import 'dart:convert';
import 'package:http/http.dart' as http;

/// Endereço devolvido por uma consulta de CEP.
class EnderecoCep {
  final String street;
  final String neighborhood;
  final String city;
  final String state;

  const EnderecoCep({
    required this.street,
    required this.neighborhood,
    required this.city,
    required this.state,
  });
}

/// Consulta de CEP nos Correios via ViaCEP.
///
/// Existe para o cadastro não exigir que o usuário digite rua, bairro, cidade
/// e estado que o CEP já determina — eram quatro campos de digitação livre, e
/// cada um deles um jeito de escrever a cidade errado e desalinhar o endereço
/// do que o site grava.
class CepUtils {
  /// Só os 8 dígitos, sem máscara.
  static String apenasDigitos(String cep) =>
      cep.replaceAll(RegExp(r'[^0-9]'), '');

  static bool estaCompleto(String cep) => apenasDigitos(cep).length == 8;

  /// Busca o endereço, ou `null` se o CEP não existir ou a consulta falhar.
  ///
  /// Falha vira `null` em vez de exceção: o preenchimento automático é
  /// conveniência, e sem rede o usuário ainda tem que conseguir digitar o
  /// endereço à mão e concluir o cadastro.
  static Future<EnderecoCep?> buscar(String cep) async {
    final digitos = apenasDigitos(cep);
    if (digitos.length != 8) return null;

    try {
      final res = await http
          .get(Uri.parse('https://viacep.com.br/ws/$digitos/json/'))
          .timeout(const Duration(seconds: 6));
      if (res.statusCode != 200) return null;

      final dados = json.decode(res.body) as Map<String, dynamic>;
      // ViaCEP responde 200 com `{"erro": true}` para CEP inexistente — não
      // um 404. Sem esta checagem o endereço viria todo vazio e pareceria ter
      // funcionado.
      if (dados['erro'] == true || dados['erro'] == 'true') return null;

      return EnderecoCep(
        street: dados['logradouro'] as String? ?? '',
        neighborhood: dados['bairro'] as String? ?? '',
        city: dados['localidade'] as String? ?? '',
        state: dados['uf'] as String? ?? '',
      );
    } catch (_) {
      return null;
    }
  }

  /// Unidades da federação, para a lista suspensa de estado.
  ///
  /// Campo livre aceitava "MG", "Minas", "minas gerais" e erro de digitação
  /// para o mesmo estado, e nada disso casa entre app e site.
  static const List<String> ufs = [
    'AC',
    'AL',
    'AP',
    'AM',
    'BA',
    'CE',
    'DF',
    'ES',
    'GO',
    'MA',
    'MT',
    'MS',
    'MG',
    'PA',
    'PB',
    'PR',
    'PE',
    'PI',
    'RJ',
    'RN',
    'RS',
    'RO',
    'RR',
    'SC',
    'SP',
    'SE',
    'TO',
  ];
}
