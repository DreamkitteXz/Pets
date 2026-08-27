import 'package:flutter/material.dart';

import 'package:pet_app/design/design.dart';
import 'package:pet_app/models/pet_model.dart';
import 'package:pet_app/services/pet_assets_service.dart';

/// Miniatura do pet nas listas.
///
/// Cascata de fallback, nesta ordem:
///  1. foto enviada pelo tutor (`pets/{petId}.imageUrl`);
///  2. ilustração local por espécie/raça/sexo ([PetAssetsService]);
///  3. ícone da espécie, quando nem o asset existe.
///
/// Sem isto a foto só aparecia na capa da tela do pet — as listas ficavam com
/// a ilustração genérica mesmo depois do upload.
class PetAvatar extends StatelessWidget {
  final Pets pet;
  final double size;
  final double radius;

  const PetAvatar({
    super.key,
    required this.pet,
    this.size = 64,
    this.radius = AppRadius.md,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final photoUrl = pet.imageUrl;
    final hasPhoto = photoUrl != null && photoUrl.isNotEmpty;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: c.surfaceSecondary,
        borderRadius: BorderRadius.all(Radius.circular(radius)),
      ),
      clipBehavior: Clip.antiAlias,
      child: hasPhoto
          ? Image.network(
              photoUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _illustration(context),
              loadingBuilder: (_, child, progress) =>
                  progress == null ? child : _illustration(context),
            )
          : _illustration(context),
    );
  }

  Widget _illustration(BuildContext context) {
    // `PetAssetsService` LANÇA se não estiver inicializado — e o main.dart
    // engole a falha ao carregar `assets/config/pet_assets.json`. Sem este
    // try/catch, um config ausente derruba a lista inteira de dentro do
    // build(), onde nenhum errorBuilder alcança.
    String? assetPath;
    try {
      assetPath = PetAssetsService.getImagePath(pet.species, pet.breed, pet.gender);
    } catch (_) {
      assetPath = null;
    }

    if (assetPath == null) return _speciesIcon(context);

    return Image.asset(
      assetPath,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => _speciesIcon(context),
    );
  }

  Widget _speciesIcon(BuildContext context) {
    IconData icon;
    try {
      icon = PetAssetsService.getSpeciesIcon(pet.species);
    } catch (_) {
      icon = Icons.pets_rounded;
    }
    return Icon(icon, color: context.colors.textTertiary, size: size * 0.44);
  }
}
