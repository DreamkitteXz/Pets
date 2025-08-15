import 'dart:convert';
import 'package:http/http.dart' as http;

class BreedUtils {
  static Future<List<String>> fetchDogBreeds() async {
    final response =
        await http.get(Uri.parse('https://dog.ceo/api/breeds/list/all'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final breeds = data['message'] as Map<String, dynamic>;
      return breeds.keys.map((e) => _capitalize(e)).toList()..sort();
    }
    return [];
  }

  static Future<List<String>> fetchCatBreeds() async {
    // TheCatAPI requires an API key for full breed info, but you can use a static list or fetch from their API.
    // For demo, here's a static list:
    return [
      'Siamese',
      'Persian',
      'Maine Coon',
      'Ragdoll',
      'Sphynx',
      'Somali',
      'Bengal',
      'British Shorthair'
    ];
  }

  static String _capitalize(String s) => s[0].toUpperCase() + s.substring(1);
}
