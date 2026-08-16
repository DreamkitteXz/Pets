import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'package:pet_app/design/design.dart';

class LabelStep extends StatefulWidget {
  final String imageURL;
  final Function(String) onImageUploaded;
  final TextEditingController rotuloController;

  const LabelStep({
    super.key,
    required this.imageURL,
    required this.onImageUploaded,
    required this.rotuloController,
  });

  @override
  State<LabelStep> createState() => _LabelStepState();
}

class _LabelStepState extends State<LabelStep> {
  bool _uploading = false;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final hasImage = widget.imageURL.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: c.tint(c.accentBlue, 0.08),
            borderRadius: const BorderRadius.all(Radius.circular(AppRadius.md)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.lightbulb_outline_rounded,
                  size: 18, color: c.accentBlue),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  'Fotografe o rótulo com o selo da vacina, a assinatura e o '
                  'carimbo do veterinário. É essa foto que o vet usa para '
                  'validar o registro.',
                  style:
                      AppTypography.footnote.copyWith(color: c.textSecondary),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        AspectRatio(
          aspectRatio: 3 / 2,
          child: ClipRRect(
            borderRadius: AppRadius.card_,
            child: hasImage
                ? Image.network(
                    widget.imageURL,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _placeholder(c, error: true),
                  )
                : _placeholder(c),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        AppButton(
          label: hasImage ? 'Tirar outra foto' : 'Tirar foto do rótulo',
          icon: Icons.photo_camera_rounded,
          variant:
              hasImage ? AppButtonVariant.secondary : AppButtonVariant.primary,
          loading: _uploading,
          onPressed: _pickAndUpload,
        ),
      ],
    );
  }

  Widget _placeholder(AppColors c, {bool error = false}) {
    return DecoratedBox(
      decoration: BoxDecoration(color: c.surfaceSecondary),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
              error
                  ? Icons.broken_image_outlined
                  : Icons.add_a_photo_outlined,
              size: 28,
              color: c.textTertiary),
          const SizedBox(height: AppSpacing.sm),
          Text(error ? 'Não foi possível carregar a foto' : 'Sem foto ainda',
              style: AppTypography.footnote.copyWith(color: c.textTertiary)),
        ],
      ),
    );
  }

  Future<void> _pickAndUpload() async {
    if (_uploading) return;

    final messenger = ScaffoldMessenger.of(context);
    final file = await ImagePicker().pickImage(source: ImageSource.camera);
    if (file == null) return;

    setState(() => _uploading = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('Sessão expirada');

      // Path canônico do rótulo de vacina. A storage.rule só libera escrita em
      // 'vaccine-labels/'; 'images/' é negado. F1.2/§6.
      final ref = FirebaseStorage.instance
          .ref()
          .child('vaccine-labels')
          .child(DateTime.now().microsecondsSinceEpoch.toString());

      await ref.putFile(File(file.path));
      final imageUrl = await ref.getDownloadURL();

      widget.onImageUploaded(imageUrl);
      if (mounted) setState(() => _uploading = false);
    } catch (error) {
      // Antes o erro só ia para o console: o usuário ficava travado no passo
      // sem entender por quê.
      if (mounted) setState(() => _uploading = false);
      messenger.showSnackBar(SnackBar(
        content: Text('Não foi possível enviar a foto: $error'),
        behavior: SnackBarBehavior.floating,
      ));
    }
  }
}
