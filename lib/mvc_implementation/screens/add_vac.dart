import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pet_app/mvc_implementation/controllers/id_controller.dart';
import 'package:pet_app/mvc_implementation/controllers/vac_controller.dart';
import 'package:pet_app/mvc_implementation/screens/components/subtitle.dart';
import 'package:pet_app/mvc_implementation/screens/components/text_input_auth.dart';
import 'package:pet_app/mvc_implementation/screens/components/titles.dart';

class AddVacPage extends StatefulWidget {
  String petId;
  AddVacPage({super.key, required this.petId});

  @override
  State<AddVacPage> createState() => _AddVacPageState();
}

class _AddVacPageState extends State<AddVacPage> {
  final TextEditingController _vacinaController = TextEditingController();

  final TextEditingController _dataAplicadaController = TextEditingController();

  final TextEditingController _proximaAplicacaoController =
      TextEditingController();

  final TextEditingController _pesoController = TextEditingController();

  final TextEditingController _loteController = TextEditingController();

  final TextEditingController _farmaceuticaController = TextEditingController();

  final TextEditingController _dataValidadeController = TextEditingController();

  final TextEditingController _observacoesController = TextEditingController();

  final TextEditingController _rotuloVacController = TextEditingController();

  final TextEditingController _nomeVetController = TextEditingController();

  final TextEditingController _crmvController = TextEditingController();

  final TextEditingController _cnpjController = TextEditingController();

  final TextEditingController _clinicaController = TextEditingController();

  final TextEditingController _ruaController = TextEditingController();

  final TextEditingController _bairroController = TextEditingController();

  final TextEditingController _numeroController = TextEditingController();

  final TextEditingController _cidadeController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  String imageURL = '';
  File? _selectedImage;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        leading: GestureDetector(
          child: const Icon(
            Icons.arrow_back_rounded,
            color: Color(0xFF212121),
            size: 30,
          ),
          onTap: () {
            Navigator.pop(context);
          },
        ),

        // ignore: prefer_const_literals_to_create_immutables
        actions: [],
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.disabled,
          child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 36),
                Titles(
                  title: 'Adicione uma Vacina',
                  fontSize: 32.0,
                  paddingL: 30.0,
                ),
                const SizedBox(height: 20),
                SubTitle(
                  subtitle:
                      'Preencha os campos abaixo para adicionar uma vacina.',
                  fontSize: 14.0,
                ),
                const SizedBox(height: 40),
                TextInput(
                  inputTitle: 'Vacina',
                  controller: _vacinaController,
                  textInputType: TextInputType.name,
                ),
                const SizedBox(height: 20),
                TextInput(
                  inputTitle: 'Data aplicada',
                  controller: _dataAplicadaController,
                  dataPicker: true,
                  textInputType: TextInputType.none,
                ),
                const SizedBox(height: 20.0),
                TextInput(
                  inputTitle: 'Próxima aplicação',
                  controller: _proximaAplicacaoController,
                  dataPicker: true,
                  textInputType: TextInputType.none,
                ),
                const SizedBox(height: 20),
                TextInput(
                    inputTitle: 'Peso',
                    controller: _pesoController,
                    textInputType: TextInputType.number),
                const SizedBox(height: 30),
                Titles(
                  title: 'Dados da Vacina',
                  fontSize: 30.0,
                  paddingL: 30.0,
                ),
                const SizedBox(height: 30.0),
                TextInput(
                  inputTitle: 'Lote',
                  controller: _loteController,
                  textInputType: TextInputType.name,
                ),
                const SizedBox(height: 20.0),
                TextInput(
                  inputTitle: 'Farmacêutica',
                  controller: _farmaceuticaController,
                  textInputType: TextInputType.name,
                ),
                const SizedBox(height: 20.0),
                TextInput(
                  inputTitle: 'Data de Validade',
                  controller: _dataValidadeController,
                  dataPicker: true,
                  textInputType: TextInputType.none,
                ),
                const SizedBox(height: 20.0),
                TextInput(
                  inputTitle: 'Observações',
                  controller: _observacoesController,
                  textInputType: TextInputType.name,
                ),
                const SizedBox(height: 30),
                Titles(
                  title: 'Rótulo da Vacina',
                  fontSize: 30.0,
                  paddingL: 30.0,
                ),
                const SizedBox(height: 15),
                SubTitle(
                    subtitle: '',
                    fontSize: 1,
                    isObservacoes: true,
                    titleObservacoes: 'Orientações:',
                    textObservacoes:
                        'Tire a foto do Rótulo da vacina com o selo da vacina, assinatura e carimbo do veteriário(a).'),
                const SizedBox(height: 20),
                if (imageURL.isNotEmpty)
                  Center(
                    child: Padding(
                      padding:
                          const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 30),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          imageURL,
                          width: 300,
                          height: 200,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  )
                else
                  const SizedBox(),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 30.0, right: 30.0),
                    child: SizedBox(
                      height: 60,
                      width: MediaQuery.of(context).size.width,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF041A23),
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                          side: const BorderSide(
                            color: Colors.black,
                            width: 2,
                          ),
                        ),
                        child: const Text(
                          'Imagem do rótulo',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 24,
                          ),
                        ),
                        onPressed: () async {
                          //==============================================================
                          //Abrir a camera
                          ImagePicker imagePicker = ImagePicker();
                          XFile? file = await imagePicker.pickImage(
                              source: ImageSource.camera);

                          if (file == null) return;

                          String uniqueFileName =
                              DateTime.now().microsecondsSinceEpoch.toString();

                          //==============================================================
                          //Upload para o Firebase Storage

                          Reference referenceRoot =
                              FirebaseStorage.instance.ref();
                          Reference referenceDirRoot =
                              referenceRoot.child('images');
                          Reference referenceImageToUpload =
                              referenceDirRoot.child(uniqueFileName);

                          //==============================================================
                          //Tratando os erros

                          try {
                            //Guardar a imagem

                            await referenceImageToUpload
                                .putFile(File(file.path));

                            //download url

                            imageURL =
                                await referenceImageToUpload.getDownloadURL();

                            setState(() {
                              _rotuloVacController.text = imageURL;
                            });
                          } catch (error) {
                            print(
                                "Erro ao enviar a imagem para o Firebase: $error");
                          }

                          //==============================================================
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                Titles(
                  title: 'Dados do Veterinário(a)',
                  fontSize: 30.0,
                  paddingL: 30.0,
                ),
                const SizedBox(height: 30),
                TextInput(
                    inputTitle: 'Nome',
                    controller: _nomeVetController,
                    textInputType: TextInputType.name),
                const SizedBox(height: 20.0),
                TextInput(
                    inputTitle: 'CRMV',
                    controller: _crmvController,
                    textInputType: TextInputType.number),
                const SizedBox(height: 30),
                Titles(
                  title: 'Dados da Clínica',
                  fontSize: 30.0,
                  paddingL: 30.0,
                ),
                const SizedBox(height: 30),
                TextInput(
                    inputTitle: 'CNPJ',
                    controller: _cnpjController,
                    textInputType: TextInputType.number),
                const SizedBox(height: 20.0),
                TextInput(
                    inputTitle: 'Clínica',
                    controller: _clinicaController,
                    textInputType: TextInputType.name),
                const SizedBox(height: 20.0),
                TextInput(
                    inputTitle: 'Rua',
                    controller: _ruaController,
                    textInputType: TextInputType.streetAddress),
                const SizedBox(height: 20.0),
                TextInput(
                    inputTitle: 'Bairro',
                    controller: _bairroController,
                    textInputType: TextInputType.name),
                const SizedBox(height: 20.0),
                TextInput(
                    inputTitle: 'Número',
                    controller: _numeroController,
                    textInputType: TextInputType.number),
                const SizedBox(height: 20.0),
                TextInput(
                    inputTitle: 'Cidade',
                    controller: _cidadeController,
                    textInputType: TextInputType.name),
                const SizedBox(height: 20.0),
                AddVacButton(
                  formKey: _formKey,
                  imageURL: imageURL,
                  petId: widget.petId,
                  vacinaController: _vacinaController,
                  dataAplicadaController: _dataAplicadaController,
                  proximaAplicacaoController: _proximaAplicacaoController,
                  pesoController: _pesoController,
                  loteController: _loteController,
                  farmaceuticaController: _farmaceuticaController,
                  dataValidadeController: _dataValidadeController,
                  rotuloVacController: _rotuloVacController,
                  observacoesController: _observacoesController,
                  nomeVetController: _nomeVetController,
                  crmvController: _crmvController,
                  clinicaController: _clinicaController,
                  ruaController: _ruaController,
                  bairroController: _bairroController,
                  numeroController: _numeroController,
                  cidadeController: _cidadeController,
                  cnpjController: _cnpjController,
                )
              ]),
        ),
      ),
    ));
  }
}

class AddVacButton extends StatelessWidget {
  String petId;
  String imageURL;
  GlobalKey<FormState> formKey;

  AddVacButton(
      {super.key,
      required TextEditingController vacinaController,
      required TextEditingController dataAplicadaController,
      required TextEditingController proximaAplicacaoController,
      required TextEditingController pesoController,
      required TextEditingController loteController,
      required TextEditingController farmaceuticaController,
      required TextEditingController dataValidadeController,
      required TextEditingController observacoesController,
      required TextEditingController rotuloVacController,
      required TextEditingController nomeVetController,
      required TextEditingController crmvController,
      required TextEditingController cnpjController,
      required TextEditingController clinicaController,
      required TextEditingController ruaController,
      required TextEditingController bairroController,
      required TextEditingController numeroController,
      required TextEditingController cidadeController,
      required this.petId,
      required this.imageURL,
      required this.formKey})
      : _vacinaController = vacinaController,
        _dataAplicadaController = dataAplicadaController,
        _proximaAplicacaoController = proximaAplicacaoController,
        _pesoController = pesoController,
        _loteController = loteController,
        _farmaceuticaController = farmaceuticaController,
        _dataValidadeController = dataValidadeController,
        _observacoesController = observacoesController,
        _rotuloVacController = rotuloVacController,
        _nomeVetController = nomeVetController,
        _crmvController = crmvController,
        _cnpjController = cnpjController,
        _clinicaController = clinicaController,
        _ruaController = ruaController,
        _bairroController = bairroController,
        _numeroController = numeroController,
        _cidadeController = cidadeController;

  final TextEditingController _vacinaController;
  final TextEditingController _dataAplicadaController;
  final TextEditingController _proximaAplicacaoController;
  final TextEditingController _pesoController;
  final TextEditingController _loteController;
  final TextEditingController _farmaceuticaController;
  final TextEditingController _dataValidadeController;
  final TextEditingController _observacoesController;
  final TextEditingController _rotuloVacController;
  final TextEditingController _nomeVetController;
  final TextEditingController _crmvController;
  final TextEditingController _cnpjController;
  final TextEditingController _clinicaController;
  final TextEditingController _ruaController;
  final TextEditingController _bairroController;
  final TextEditingController _numeroController;
  final TextEditingController _cidadeController;

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 16),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.only(left: 30.0, right: 30.0),
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.06,
              width: MediaQuery.of(context).size.width,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF041A23),
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  side: const BorderSide(
                    color: Colors.black,
                    width: 2,
                  ),
                ),
                child: const Text(
                  'Adicionar',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                onPressed: () async {
                  print('imageURL:');
                  print(imageURL);
                  //getUserData();
                  //getPetData(widget.petId);
                  if (formKey.currentState!.validate()) {
                    if (imageURL.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Faça o upload da imagem')),
                      );
                    } else {
                      try {
                        VacController vacController = VacController();

                        vacController.cadastroVacinas(
                            _vacinaController.text,
                            gerarVacsID(),
                            _dataAplicadaController.text,
                            _proximaAplicacaoController.text,
                            _pesoController.text,
                            _loteController.text,
                            _farmaceuticaController.text,
                            _dataValidadeController.text,
                            _nomeVetController.text,
                            _crmvController.text,
                            _rotuloVacController.text,
                            _observacoesController.text,
                            _cnpjController.text,
                            _clinicaController.text,
                            _ruaController.text,
                            _bairroController.text,
                            _numeroController.text,
                            _cidadeController.text,
                            'false',
                            'false',
                            petId);

                        vacController.addVacInQueue(petId);
                        Navigator.pop(context);
                      } catch (e) {
                        print('Erro: $e');
                      }
                    }
                  }
                },
              ),
            ),
          ),
        ));
  }
}
