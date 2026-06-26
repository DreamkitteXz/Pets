import 'package:flutter/material.dart';
import 'package:pet_app/models/pet_model.dart';
import 'package:pet_app/screens/pets/pet_information.dart' as pet_info;
import 'package:pet_app/services/pet_assets_service.dart';
import 'package:pet_app/controllers/pets/pet_controller.dart';
import 'package:pet_app/design/design.dart';

/// Lista de pets do tutor — repaginada sobre o design system (amostra da FASE A).
/// Mantém o contrato existente (recebe a lista já carregada pelo parent).
class PetsScreen extends StatelessWidget {
  final List<Pets> pets;

  const PetsScreen({Key? key, required this.pets}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (pets.isEmpty) {
      return const AppEmptyState(
        icon: Icons.pets_rounded,
        title: 'Nenhum pet cadastrado',
        message:
            'Adicione seu primeiro pet para acompanhar vacinas, vermífugos e peso.',
      );
    }

    final c = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg, AppSpacing.md, AppSpacing.lg, AppSpacing.xs),
          child: Text(
            'Meus Pets',
            style: AppTypography.largeTitle.copyWith(color: c.textPrimary),
          ),
        ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg, AppSpacing.sm, AppSpacing.lg, AppSpacing.xxl),
            itemCount: pets.length,
            separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
            itemBuilder: (context, index) => PetCard(pet: pets[index]),
          ),
        ),
      ],
    );
  }
}

class PetCard extends StatelessWidget {
  final Pets pet;

  const PetCard({Key? key, required this.pet}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final imagePath =
        PetAssetsService.getImagePath(pet.species, pet.breed, pet.gender);
    final speciesIcon = PetAssetsService.getSpeciesIcon(pet.species);
    final ageString = PetController().calculateAgeString(pet.birthDate);

    return AppCard(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => pet_info.PetInformation(pet: pet),
          ),
        );
      },
      child: Row(
        children: [
          Hero(
            tag: 'pet-${pet.id}',
            child: Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: c.surfaceSecondary,
                borderRadius:
                    const BorderRadius.all(Radius.circular(AppRadius.md)),
              ),
              clipBehavior: Clip.antiAlias,
              child: Image.asset(
                imagePath,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    Icon(speciesIcon, color: c.textTertiary, size: 28),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  pet.name ?? 'Sem nome',
                  style: AppTypography.headline.copyWith(color: c.textPrimary),
                ),
                const SizedBox(height: 2),
                Text(
                  pet.breed ?? 'Raça não especificada',
                  style:
                      AppTypography.footnote.copyWith(color: c.textSecondary),
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    _MetaChip(
                      icon: speciesIcon,
                      label: pet.species ?? '—',
                      color: c.accentBlue,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    _MetaChip(
                      icon: Icons.cake_rounded,
                      label: ageString,
                      color: c.accentOrange,
                    ),
                  ],
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded, color: c.textTertiary, size: 22),
        ],
      ),
    );
  }
}

/// Mini-chip de metadado (espécie, idade) com ícone e cor tonalizada.
class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _MetaChip(
      {required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 3),
      decoration: BoxDecoration(
        color: c.tint(color, 0.12),
        borderRadius: AppRadius.pill_,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppTypography.caption.copyWith(color: color),
          ),
        ],
      ),
    );
  }
}
