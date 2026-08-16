import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pet_app/models/pet_model.dart';
import 'package:pet_app/models/deworming_model.dart';
import 'package:pet_app/screens/deworming/add_deworming_screen.dart';
import 'package:pet_app/screens/deworming/deworming_screen.dart';
import 'package:pet_app/design/design.dart';

/// Rótulos de status no masculino (vermífugo).
const Map<AppStatus, String> _vermStatusLabels = {
  AppStatus.pending: 'Aguardando validação',
  AppStatus.approved: 'Aprovado',
  AppStatus.rejected: 'Rejeitado',
};

class VermifugosPage extends StatelessWidget {
  final Pets pet;

  const VermifugosPage({super.key, required this.pet});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Vermífugos',
      showBack: true,
      bodyPadding: false,
      floatingActionButton: FloatingActionVermifugo(petId: pet.id),
      body: StreamBuilder<QuerySnapshot>(
        // Coleção canônica 'deworming' (singular) — alinhada às rules/web.
        // O `ownerId` é obrigatório na query: a rule libera com
        // `isVet() || isOwner()` e o Firestore valida rules de query contra a
        // QUERY. Só com `petId` a consulta é recusada por inteiro.
        stream: FirebaseFirestore.instance
            .collection('deworming')
            .where('ownerId',
                isEqualTo: FirebaseAuth.instance.currentUser?.uid)
            .where('petId', isEqualTo: pet.id)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const AppErrorState(
                message: 'Não foi possível carregar os vermífugos deste pet.');
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const AppLoading();
          }
          final docs = snapshot.data?.docs ?? [];
          if (docs.isEmpty) {
            return const AppEmptyState(
              icon: Icons.medication_rounded,
              title: 'Nenhum vermífugo',
              message: 'Toque em + para registrar um vermífugo deste pet.',
            );
          }
          final items = docs
              .map((d) => Vermifugo.fromMap(d.data() as Map<String, dynamic>))
              .toList();
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg, AppSpacing.sm, AppSpacing.lg, AppSpacing.xxxl),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
            itemBuilder: (context, i) {
              final model = items[i];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          VermifugoPage(vermifugo: model, petId: pet.id),
                    ),
                  );
                },
                child: CardVermifugo(pet: pet, model: model),
              );
            },
          );
        },
      ),
    );
  }
}

class CardVermifugo extends StatelessWidget {
  const CardVermifugo({super.key, required this.pet, required this.model});

  final Pets pet;
  final Vermifugo model;

  String _fmt(DateTime? d) => d == null
      ? 'N/D'
      : '${d.day.toString().padLeft(2, '0')}/'
          '${d.month.toString().padLeft(2, '0')}/${d.year}';

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

    return AppCard(
      padding: EdgeInsets.zero,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
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
                          child: Icon(Icons.medication_rounded,
                              color: statusColor, size: 22),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(model.name ?? 'Vermífugo',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTypography.headline
                                      .copyWith(color: c.textPrimary)),
                              const SizedBox(height: 2),
                              Text(model.manufacturer ?? '—',
                                  style: AppTypography.footnote
                                      .copyWith(color: c.textSecondary)),
                            ],
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        StatusChip(
                            status: status,
                            compact: true,
                            labels: _vermStatusLabels),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Row(
                      children: [
                        Icon(Icons.event_available_rounded,
                            size: 14, color: c.textTertiary),
                        const SizedBox(width: 4),
                        Text('Aplicado: ${_fmt(model.administrationDate)}',
                            style: AppTypography.caption
                                .copyWith(color: c.textSecondary)),
                        if (model.isReinforcementNeeded == true) ...[
                          const SizedBox(width: AppSpacing.lg),
                          Icon(Icons.event_repeat_rounded,
                              size: 14, color: c.textTertiary),
                          const SizedBox(width: 4),
                          Text('Reforço: ${_fmt(model.reinforcementDate)}',
                              style: AppTypography.caption
                                  .copyWith(color: c.textSecondary)),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FloatingActionVermifugo extends StatelessWidget {
  final String petId;
  const FloatingActionVermifugo({super.key, required this.petId});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AddVermifugoPage(petId: petId),
          ),
        );
      },
      backgroundColor: context.colors.accentBlue,
      foregroundColor: Colors.white,
      elevation: 2,
      child: const Icon(Icons.add_rounded, size: 28),
    );
  }
}
