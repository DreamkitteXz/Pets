import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';

import 'package:pet_app/controllers/vaccines/vaccine_controller.dart';
import 'package:pet_app/design/design.dart';
import 'package:pet_app/models/deworming_model.dart';
import 'package:pet_app/models/pet_model.dart';
import 'package:pet_app/models/vaccine_model.dart';
import 'package:pet_app/screens/vaccines/add_vaccine_screen.dart';
import 'package:pet_app/screens/vaccines/vaccine_screen.dart';
import 'package:pet_app/services/vaccine_card_generator.dart';

/// Carteira de vacinas do pet. Status é cidadão de 1ª classe: o card mostra o
/// chip e um acento lateral enquanto a vacina aguarda validação do vet.
class PetsVaccinesScreen extends StatelessWidget {
  final Pets? pet;

  const PetsVaccinesScreen({super.key, this.pet});

  @override
  Widget build(BuildContext context) {
    final currentPet = pet;
    if (currentPet == null) {
      return const AppScaffold(
        title: 'Vacinas',
        showBack: true,
        body: AppErrorState(
          message: 'Não foi possível identificar o pet desta carteira.',
        ),
      );
    }

    final vaccineController = VaccineController();

    return AppScaffold(
      title: 'Vacinas',
      subtitle: currentPet.name,
      showBack: true,
      bodyPadding: false,
      actions: [
        IconButton(
          onPressed: () => _exportCard(context, currentPet),
          icon: const Icon(Icons.ios_share_rounded),
          color: context.colors.accentBlue,
          tooltip: 'Carteira em PDF',
        ),
      ],
      floatingActionButton: FloatingActionVac(petId: currentPet.id),
      body: StreamBuilder<List<Vacinas>>(
        stream: vaccineController.vaccinesStreamForPet(currentPet.id),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const AppErrorState(
                message: 'Não foi possível carregar as vacinas deste pet.');
          }
          if (!snapshot.hasData) return const AppLoading();

          final vaccines = snapshot.data!;
          if (vaccines.isEmpty) {
            return const AppEmptyState(
              icon: Icons.vaccines_rounded,
              title: 'Nenhuma vacina',
              message: 'Toque em + para registrar a primeira vacina. Ela fica '
                  'aguardando validação até um veterinário conferir.',
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.only(
                top: AppSpacing.sm, bottom: AppSpacing.xxxl + 56),
            itemCount: vaccines.length,
            itemBuilder: (context, index) =>
                CardVacinas(pet: currentPet, model: vaccines[index]),
          );
        },
      ),
    );
  }

  Future<void> _exportCard(BuildContext context, Pets currentPet) async {
    final messenger = ScaffoldMessenger.of(context);
    final uid = FirebaseAuth.instance.currentUser?.uid;
    try {
      final db = FirebaseFirestore.instance;
      // `ownerId` é exigido pela rule de query (ver VaccineRepository).
      // A carteira cobre vacinas E vermífugos, igual à da web.
      final results = await Future.wait([
        db
            .collection('vaccines')
            .where('ownerId', isEqualTo: uid)
            .where('petId', isEqualTo: currentPet.id)
            .get(),
        db
            .collection('deworming')
            .where('ownerId', isEqualTo: uid)
            .where('petId', isEqualTo: currentPet.id)
            .get(),
      ]);

      final vaccines = results[0].docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return Vacinas.fromMap(data);
      }).toList();

      final dewormings = results[1].docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return Vermifugo.fromMap(data);
      }).toList();

      final path = await VaccineCardGenerator.generateVaccineCard(
        currentPet,
        vaccines,
        dewormings: dewormings,
      );
      final result = await OpenFile.open(path, type: 'application/pdf');
      if (result.type != ResultType.done) throw Exception(result.message);
    } catch (e) {
      messenger.showSnackBar(SnackBar(
        content: Text('Erro ao gerar a carteira: $e'),
        behavior: SnackBarBehavior.floating,
      ));
    }
  }
}

class CardVacinas extends StatelessWidget {
  const CardVacinas({
    super.key,
    required this.pet,
    required this.model,
  });

  final Pets pet;
  final Vacinas model;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final status = appStatusFromString(model.status);
    final bool pending = status == AppStatus.pending;

    Color statusColor;
    switch (status) {
      case AppStatus.approved:
        statusColor = c.statusApproved;
        break;
      case AppStatus.rejected:
        statusColor = c.statusRejected;
        break;
      case AppStatus.pending:
        statusColor = c.statusPending;
        break;
    }

    String fmt(DateTime? d) => d == null
        ? 'N/D'
        : '${d.day.toString().padLeft(2, '0')}/'
            '${d.month.toString().padLeft(2, '0')}/${d.year}';

    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.md),
      child: AppCard(
        padding: EdgeInsets.zero,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute<void>(
              builder: (context) =>
                  VaccineScreen(vacina: model, petId: pet.id),
            ),
          );
        },
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Acento lateral quando "aguardando validação" do vet.
              if (pending) Container(width: 4, color: statusColor),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: c.tint(statusColor, 0.12),
                              borderRadius: const BorderRadius.all(
                                  Radius.circular(AppRadius.md)),
                            ),
                            child: Icon(Icons.vaccines_rounded,
                                color: statusColor, size: 22),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  model.name ?? 'Vacina',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTypography.headline
                                      .copyWith(color: c.textPrimary),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Lote ${model.batchNumber ?? 'N/D'}',
                                  style: AppTypography.footnote
                                      .copyWith(color: c.textSecondary),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          StatusChip(status: status, compact: true),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Row(
                        children: [
                          _DateBit(
                              icon: Icons.event_available_rounded,
                              label: 'Aplicada',
                              value: fmt(model.administrationDate)),
                          const SizedBox(width: AppSpacing.lg),
                          _DateBit(
                              icon: Icons.event_repeat_rounded,
                              label: 'Próxima',
                              value: fmt(model.nextDueDate)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DateBit extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _DateBit(
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: c.textTertiary),
        const SizedBox(width: 4),
        Text('$label: $value',
            style: AppTypography.caption.copyWith(color: c.textSecondary)),
      ],
    );
  }
}

class FloatingActionVac extends StatelessWidget {
  final String petId;

  const FloatingActionVac({super.key, required this.petId});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () => Navigator.push(
        context,
        MaterialPageRoute<void>(builder: (context) => AddVacPage(petId: petId)),
      ),
      backgroundColor: context.colors.accentBlue,
      foregroundColor: Colors.white,
      elevation: 2,
      child: const Icon(Icons.add_rounded, size: 28),
    );
  }
}

// [F2.3/§5] deleteVac (diálogo de confirmação de exclusão) removido junto com
// o swipe-to-delete: o tutor não exclui registro clínico de vacina.
