//==========================================
// Descrição: Componente de snackbar
// Autor: Kayque Amado
// Data: 09/03/2024
//==========================================
import 'package:flutter/material.dart';

showSnackBar({
  required BuildContext context,
  required String texto,
  bool isError = true,
}) {
  SnackBar snackBar = SnackBar(
    content: Text(texto),
  );

  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}
