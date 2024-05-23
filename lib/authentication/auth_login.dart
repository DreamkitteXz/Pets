//==========================================
// Descrição: Código para requisição de login
// Autor: Kayque Amado
// Data: 09/03/2024
//==========================================

import 'package:firebase_auth/firebase_auth.dart';

Future<String?> entrarUsuario(
    {required String email, required String senha}) async {
  try {
    await FirebaseAuth.instance
        .signInWithEmailAndPassword(email: email, password: senha);
  } on FirebaseAuthException catch (e) {
    switch (e.code) {
      case 'user-not-found':
        return 'O e-mail não esta cadastrado.';
      case 'wrong-password':
        return 'Senha incorreta';
    }
    return e.code;
  }
  return null;
}
