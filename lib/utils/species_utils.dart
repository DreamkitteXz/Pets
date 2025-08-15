class SpeciesUtils {
  static String toFirestore(String value) {
    switch (value.toLowerCase()) {
      case 'cachorro':
        return 'dog';
      case 'gato':
        return 'cat';
      default:
        return value.toLowerCase();
    }
  }

  static String toDisplay(String value) {
    switch (value.toLowerCase()) {
      case 'dog':
        return 'Cachorro';
      case 'cat':
        return 'Gato';
      default:
        return value;
    }
  }
}
