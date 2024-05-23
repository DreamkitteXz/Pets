import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pet_app/models/Pet.dart';
import 'package:pet_app/mvc_implementation/models/vacinas.dart';

Future<void> adicionarDadosVacinaPendente(String? petId, String? vacId) async {
  try {
    var userId = FirebaseAuth.instance.currentUser!.uid;

    // Busca os dados do tutor
    DocumentSnapshot userSnapshot =
        await FirebaseFirestore.instance.collection('Users').doc(userId).get();
    if (!userSnapshot.exists) {
      print(userId);
      print('O tutor não foi encontrado.');
      return;
    }
    Map<String, dynamic> userData = userSnapshot.data() as Map<String, dynamic>;
    String tutorNome = userData['Nome'];
    String tutorCpf = userData['CPF'];
    String tutorTelefone = userData['Telefone'];
    String tutorRua = userData['Rua'];

    // Busca os dados do pet
    DocumentSnapshot petSnapshot = await FirebaseFirestore.instance
        .collection('Users')
        .doc(userId)
        .collection('Pets')
        .doc(petId)
        .get();
    if (!petSnapshot.exists) {
      print(userId);
      print('O pet não foi encontrado.');
      return;
    }
    Map<String, dynamic> petData = petSnapshot.data() as Map<String, dynamic>;
    Pet pet = Pet.fromMap(petData);

    // Busca os dados da vacina
    DocumentSnapshot vacinaSnapshot = await FirebaseFirestore.instance
        .collection('Users')
        .doc(userId)
        .collection('Pets')
        .doc(petId)
        .collection('Vacinas')
        .doc(vacId)
        .get();
    if (!vacinaSnapshot.exists) {
      print(vacId);
      print('A vacina não foi encontrada.');
      return;
    }
    Map<String, dynamic> vacinaData =
        vacinaSnapshot.data() as Map<String, dynamic>;
    Vacinas vacina = Vacinas.fromMap(vacinaData);

    // Adiciona os dados no documento Vacinas_Pendentes
    await FirebaseFirestore.instance
        .collection('Vacinas_Pendentes')
        .doc(vacId)
        .set({
      'tutor': tutorNome,
      'cpf': tutorCpf,
      'telefone': tutorTelefone,
      'endereco_tutor': tutorRua,
      "pet": pet.name,
      "tipo_pet": pet.tipo,
      "raca_pet": pet.raca,
      "cor_pet": pet.cor,
      "sexo_pet": pet.sexo,
      "data_nasc_pet": pet.dataNasc,
      "interio_castrado": pet.isInteiro,
      "chip": pet.chip,
      "id_vac": vacina.id,
      "vacina": vacina.vacina,
      "clinica": vacina.clinica,
      "data_aplicacao": vacina.dataAplicada,
      "proxima_aplicacao": vacina.proximaAplicacao,
      "peso_pet": vacina.pesoDataAplicacao,
      "lote": vacina.lote,
      "farmaceutica": vacina.farmaceutica,
      "data_validade": vacina.dataValidade,
      "observacoes": vacina.observacoes,
      "imagem_rotulo": vacina.imageRotulo,
      "nome_vet": vacina.nomeVet,
      "crmv": vacina.crmv,
      "cnpj": vacina.cnpj,
      "Rua_Clinica": vacina.rua,
      "Bairro_Clinica": vacina.bairro,
      "Numero_Clinica": vacina.numero,
      "Cidade_Clinica": vacina.cidade,
      "is_vac_validada_vet": vacina.isValidadoVet,
      "is_vac_validada_tutor": vacina.isValidadoTutor
    });
  } catch (e) {
    print('Erro ao adicionar dados: $e');
  }
}
