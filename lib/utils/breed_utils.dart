import 'dart:convert';
import 'package:http/http.dart' as http;

/// Catálogo de raças para o cadastro de pet.
///
/// As raças de cachorro vêm da API pública dog.ceo, que responde em INGLÊS.
/// Isso é um problema conhecido e não resolvido aqui — ver a nota em
/// [fetchDogBreeds].
class BreedUtils {
  /// Rótulo de "sem raça definida".
  ///
  /// Vira a primeira opção das duas listas: é de longe a resposta mais comum
  /// num app de tutor brasileiro, e sem ela o usuário era obrigado a escolher
  /// uma raça errada ou deixar o campo travado — o validador exige seleção.
  static const String semRacaDefinida = 'SRD (sem raça definida)';

  /// Raças de cachorro, com SRD à frente e o resto em ordem alfabética.
  ///
  /// LIMITAÇÃO CONHECIDA: a dog.ceo devolve os nomes em inglês ("hound",
  /// "germanshepherd"), então a lista aparece em inglês num app em português.
  /// Corrigir isso exige trocar a fonte por um catálogo próprio em
  /// português — mudança de dados, não de código, e maior do que o ajuste
  /// pedido aqui.
  static Future<List<String>> fetchDogBreeds() async {
    try {
      final response =
          await http.get(Uri.parse('https://dog.ceo/api/breeds/list/all'));
      if (response.statusCode != 200) return const [semRacaDefinida];

      final data = json.decode(response.body);
      final breeds = data['message'] as Map<String, dynamic>;
      return _comSrd(breeds.keys.map(_capitalize));
    } catch (_) {
      // Rede fora não pode esvaziar o campo: sem opção alguma o cadastro
      // trava no validador de raça. SRD sozinho ainda permite salvar.
      return const [semRacaDefinida];
    }
  }

  /// Raças de gato.
  ///
  /// Lista fixa — a TheCatAPI exige chave para o catálogo completo. Também em
  /// inglês, pela mesma razão das de cachorro.
  static Future<List<String>> fetchCatBreeds() async {
    return _comSrd(const [
      'Siamese',
      'Persian',
      'Maine Coon',
      'Ragdoll',
      'Sphynx',
      'Somali',
      'Bengal',
      'British Shorthair',
    ]);
  }

  /// SRD primeiro, o resto ordenado.
  ///
  /// A ordenação não vem de graça: as raças de gato eram devolvidas na ordem
  /// em que alguém as digitou no código, e as de cachorro vinham ordenadas
  /// por acaso da API. Aqui as duas passam pela mesma regra.
  ///
  /// SRD fica FORA da ordenação de propósito — ancorada no topo, é a opção
  /// que mais gente procura, e alfabeticamente cairia no meio da lista.
  static List<String> _comSrd(Iterable<String> racas) {
    final ordenadas = racas.where((r) => r != semRacaDefinida).toList()
      ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    return [semRacaDefinida, ...ordenadas];
  }

  static String _capitalize(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
}
