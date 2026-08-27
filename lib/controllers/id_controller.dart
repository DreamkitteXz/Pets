import 'package:uuid/uuid.dart';

String petIDs = '';
String vacIDs = '';
String verIDs = '';
String medIDs = '';

String gerarPetsID() {
  return petIDs = const Uuid().v4().trim();
}

String gerarVacsID() {
  return vacIDs = const Uuid().v1().trim();
}

String gerarVersID() {
  return verIDs = const Uuid().v1().trim();
}

String gerarMedID() {
  return medIDs = const Uuid().v4().trim();
}
