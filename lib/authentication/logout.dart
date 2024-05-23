//==========================================
// Descrição: Código para requisição de logout
// Autor: Kayque Amado
// Data: 09/03/2024
//==========================================
import 'package:firebase_auth/firebase_auth.dart';

Future<String?> deslogar() async {
  try {
    await FirebaseAuth.instance.signOut();
  } on FirebaseAuthException catch (e) {
    return e.code;
  }
  return null;
}
