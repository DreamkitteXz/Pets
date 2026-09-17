import 'package:flutter/services.dart';

/// Leitura e escrita de peso digitado pelo usuário.
///
/// Existe porque a conversão estava espalhada e divergente: algumas telas
/// faziam `replaceAll(',', '.')` antes do parse e outras chamavam
/// `double.tryParse` direto. Nas que não convertiam, digitar "10,5" — a
/// notação usada no Brasil, e a que o próprio hint do campo sugeria —
/// resultava em `null`, que virava **0.0** no `?? 0.0` e era gravado como se
/// fosse o peso do animal. Perda silenciosa de dado, sem erro na tela.
class WeightUtils {
  /// Converte texto em quilos, aceitando vírgula ou ponto.
  ///
  /// Devolve `null` — e nunca `0.0` — quando não dá para ler. Zero é um peso
  /// possível de digitar, então usá-lo como sinal de falha apaga a diferença
  /// entre "não entendi" e "o usuário escreveu 0".
  ///
  /// Recusa valores não positivos e não finitos: nenhum animal pesa zero,
  /// negativo ou infinito, e deixar isso passar contamina o gráfico de peso.
  static double? parse(String? raw) {
    if (raw == null) return null;
    final limpo = raw.trim().replaceAll(',', '.');
    if (limpo.isEmpty) return null;

    final valor = double.tryParse(limpo);
    if (valor == null || !valor.isFinite || valor <= 0) return null;
    return valor;
  }

  /// Formata quilos para exibição em português (vírgula decimal).
  ///
  /// Uma casa decimal: é a precisão das balanças de clínica, e mostrar
  /// "10.4300000000000001" seria ruído de ponto flutuante, não informação.
  static String format(double? kg) {
    if (kg == null) return '';
    return kg.toStringAsFixed(1).replaceAll('.', ',');
  }

  /// Formatadores para o campo de peso.
  ///
  /// Deixa passar dígitos e UM separador, vírgula ou ponto. Sem isto o teclado
  /// decimal do Android ainda aceita letras coladas via sugestão e colagem, e
  /// o campo ficava com texto que só falhava no parse na hora de salvar.
  static List<TextInputFormatter> get inputFormatters => [
        FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
        _UmSeparadorApenas(),
      ];
}

/// Impede um segundo separador decimal ("10,5,3").
class _UmSeparadorApenas extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue anterior, TextEditingValue novo) {
    final separadores =
        novo.text.split('').where((c) => c == ',' || c == '.').length;
    return separadores > 1 ? anterior : novo;
  }
}
