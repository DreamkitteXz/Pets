import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:pet_app/screens/components/subtitle.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LabelStep extends StatelessWidget {
  final String imageURL;
  final Function(String) onImageUploaded;
  final TextEditingController rotuloController;

  const LabelStep({
    Key? key,
    required this.imageURL,
    required this.onImageUploaded,
    required this.rotuloController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        children: [
          SubTitle(
            subtitle: '',
            fontSize: 1,
            isObservacoes: true,
            titleObservacoes: 'Orientações:',
            textObservacoes:
                'Tire a foto do Rótulo da vacina com o selo da vacina, assinatura e carimbo do veteriário(a).',
          ),
          const SizedBox(height: 20),
          if (imageURL.isNotEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 30),
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
              padding: const EdgeInsets.symmetric(horizontal: 30.0),
              child: SizedBox(
                height: 60,
                width: double.infinity,
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
                    final imagePicker = ImagePicker();
                    final XFile? file = await imagePicker.pickImage(
                      source: ImageSource.camera,
                    );

                    if (file == null) return;

                    try {
                      final user = FirebaseAuth.instance.currentUser;
                      if (user == null) {
                        throw Exception('User not authenticated');
                      }

                      final uniqueFileName =
                          DateTime.now().microsecondsSinceEpoch.toString();
                      final referenceRoot = FirebaseStorage.instance.ref();
                      final referenceDirRoot = referenceRoot.child('images');
                      final referenceImageToUpload =
                          referenceDirRoot.child(uniqueFileName);

                      await referenceImageToUpload.putFile(File(file.path));
                      final imageUrl =
                          await referenceImageToUpload.getDownloadURL();

                      onImageUploaded(imageUrl);
                    } catch (error) {
                      print("Erro ao enviar a imagem para o Firebase: $error");
                    }
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
