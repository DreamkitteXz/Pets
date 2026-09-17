import 'package:flutter/material.dart';
import 'package:pet_app/constants/asset_paths.dart';

class PetAssetsService {
  static Map<String, dynamic>? _configuration;
  static bool _isInitialized = false;

  static void initialize(Map<String, dynamic> configuration) {
    _configuration = configuration;
    _isInitialized = true;
  }

  static void _checkInitialization() {
    if (!_isInitialized) {
      throw Exception(
          'PetAssetsService not initialized. Call PetAssetsService.initialize() in your main.dart');
    }
  }

  /// Caminho da ilustração para a combinação espécie/raça/sexo, ou `null`
  /// quando não existe uma.
  ///
  /// Devolver `null` é o ponto todo: antes o fallback era `beagleMaleImage` —
  /// um CACHORRO. Como o catálogo só cobre um punhado de raças, qualquer gato
  /// fora dessa lista aparecia ilustrado como beagle. Quem chama trata o nulo
  /// caindo no ícone da espécie, que é genérico mas não mente.
  static String? getImagePath(String? species, String? race, String? gender) {
    _checkInitialization();
    if (_configuration == null) {
      throw Exception('PetAssetsService not initialized');
    }

    final speciesKey = species?.toLowerCase() ?? '';
    final raceKey = race?.toLowerCase() ?? '';
    final genderKey = gender?.toLowerCase() ?? 'male';

    final imageKey = _configuration!["types"][speciesKey]?["races"]?[raceKey]
        ?["gender"]?[genderKey]?["imageKey"] as String?;

    if (imageKey == null) return null;

    return getImagePathFromKey(imageKey);
  }

  static String getImagePathFromKey(String imageKey) {
    _checkInitialization();
    switch (imageKey) {
      case 'beagleMaleImage':
        return AssetPaths.beagleMaleImage;
      case 'beagleFemaleImage':
        return AssetPaths.beagleFemaleImage;
      case 'daschshundMaleImage':
        return AssetPaths.dachshundMaleImage;
      case 'goldenRetrieverMaleImage':
        return AssetPaths.goldenMaleImage;
      case 'goldenRetrieverFemaleImage':
        return AssetPaths.goldenFemaleImage;
      case 'pinscherMaleImage':
        return AssetPaths.pinscherMaleImage;
      case 'pinscherFemaleImage':
        return AssetPaths.pinscherFemaleImage;
      case 'somaliMaleImage':
        return AssetPaths.somaliMaleImage;
      case 'somaliFemaleImage':
        return AssetPaths.somaliFemaleImage;
      case 'bulldogMaleImage':
        return AssetPaths.bulldogMaleImage;
      default:
        return AssetPaths.beagleMaleImage; // default fallback
    }
  }

  static Color getSpeciesColor(String? species) {
    _checkInitialization();
    if (_configuration == null) {
      throw Exception('PetAssetsService not initialized');
    }

    final speciesKey = species?.toLowerCase() ?? '';
    final colorName =
        _configuration!["types"][speciesKey]?["color"] as String? ?? "grey";

    switch (colorName) {
      case "blue":
        return Colors.blue;
      case "brown":
        return Colors.brown;
      case "black":
        return Colors.black87;
      case "orange":
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  static IconData getSpeciesIcon(String? species) {
    _checkInitialization();
    if (_configuration == null) {
      throw Exception('PetAssetsService not initialized');
    }

    final speciesKey = species?.toLowerCase() ?? '';
    final iconName =
        _configuration!["types"][speciesKey]?["icon"] as String? ?? "pets";

    switch (iconName) {
      case "pets":
        return Icons.pets;
      case "catching_pokemon":
        return Icons.catching_pokemon;
      default:
        return Icons.help_outline;
    }
  }

  static IconData getVaccineIcon(
      String? species, String? race, String? gender) {
    _checkInitialization();
    if (_configuration == null) {
      throw Exception('PetAssetsService not initialized');
    }

    final speciesKey = species?.toLowerCase() ?? '';
    final raceKey = race?.toLowerCase() ?? '';
    final genderKey = gender?.toLowerCase() ?? 'male';

    final vaccineIconName = _configuration!["types"][speciesKey]?["races"]
            ?[raceKey]?["gender"]?[genderKey]?["vaccineIcon"] as String? ??
        "medical_services";

    switch (vaccineIconName) {
      case "medical_services":
        return Icons.medical_services;
      case "vaccines":
        return Icons.vaccines;
      default:
        return Icons.medical_services;
    }
  }

  static Map<String, dynamic>? getRaceInfo(String? species, String? race) {
    _checkInitialization();
    if (_configuration == null) {
      throw Exception('PetAssetsService not initialized');
    }

    final speciesKey = species?.toLowerCase() ?? '';
    final raceKey = race?.toLowerCase() ?? '';

    return _configuration!["types"][speciesKey]?["races"]?[raceKey]
        as Map<String, dynamic>?;
  }
}
