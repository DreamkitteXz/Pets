class GenderUtils {
  static String toFirestore(String value) {
    switch (value.toLowerCase()) {
      case 'macho':
        return 'male';
      case 'fêmea':
      case 'femea':
        return 'female';
      default:
        return value.toLowerCase();
    }
  }

  static String toDisplay(String value) {
    switch (value.toLowerCase()) {
      case 'male':
        return 'Macho';
      case 'female':
        return 'Fêmea';
      default:
        return value;
    }
  }
}
