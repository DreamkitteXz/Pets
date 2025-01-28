//=================================================================================================
// Descrição: Código para gerenciamento e atribuiçao de identificação de usuario e elementos únicos.
// Autor: Kayque Amado
// Data: 09/03/2024
//=================================================================================================
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// ADD User details - used in Login
Future addUserdatalhes(
    String nome,
    String email,
    String cpf,
    String telefone,
    String senha,
    String rua,
    String bairro,
    String cep,
    String estado,
    String numero,
    String complemento) async {
  await FirebaseFirestore.instance
      .collection("Users")
      .doc(FirebaseAuth.instance.currentUser!.uid)
      .set({
    "Id": FirebaseAuth.instance.currentUser!.uid,
    "Nome": nome,
    "Email": email,
    "CPF": cpf,
    "Telefone": telefone,
    "Senha": senha,
    "Rua": rua,
    "Bairro": bairro,
    "CEP": cep,
    "Estado": estado,
    "Numero": numero,
    "Complemento": complemento,
  });
}

// EDIT User details - used in Profile
Future editUserdatalhes(
    String nome,
    String cpf,
    String telefone,
    String rua,
    String bairro,
    String cep,
    String estado,
    String numero,
    String complemento) async {
  await FirebaseFirestore.instance
      .collection("Users")
      .doc(FirebaseAuth.instance.currentUser!.uid)
      .set({
    "Id": FirebaseAuth.instance.currentUser!.uid,
    "Nome": nome,
    "CPF": cpf,
    "Telefone": telefone,
    "Rua": rua,
    "Bairro": bairro,
    "CEP": cep,
    "Estado": estado,
    "Numero": numero,
    "Complemento": complemento,
  });
}

//  Create Pet - used in Homescreen
Future cadastroPet(
    String idPet,
    String name,
    String tipo,
    String raca,
    String sexo,
    String cor,
    String dataNasc,
    String isInteiro,
    String chip) async {
  await FirebaseFirestore.instance
      .collection("Users")
      .doc(FirebaseAuth.instance.currentUser!.uid)
      .collection("Pets")
      .doc(idPet)
      .set({
    "Pet Id": idPet,
    "Nome do pet": name,
    "Tipo": tipo,
    "Raca": raca,
    "Sexo": sexo,
    "Cor": cor,
    "Data de Nascimento": dataNasc,
    "Inteiro ou Castrado": isInteiro,
    "Numero do Chip": chip,
  });
}
