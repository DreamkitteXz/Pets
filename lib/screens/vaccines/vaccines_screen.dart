import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:pet_app/design/design.dart';
import 'package:pet_app/models/pet_model.dart';
import 'package:pet_app/models/vaccine_model.dart';
import 'package:pet_app/screens/vaccines/pets_vaccines_screen.dart'
    show CardVacinas;

/// Aba "Vacinas": todas as vacinas do tutor, agrupadas por pet.
///
/// Reaproveita o [CardVacinas] da carteira do pet — antes esta tela tinha uma
/// cópia própria do card, com o eixo de status ANTIGO (vetApproved /
/// tutorApproved / vetRejected / tutorRejected), que a F2.1/§3.1 aposentou.
class VacinasScreen extends StatelessWidget {
  const VacinasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const AppScaffold(
        title: 'Vacinas',
        body: AppErrorState(message: 'Sessão expirada. Entre novamente.'),
      );
    }

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      // ownerId é campo único: sem índice composto. A ordenação é no cliente.
      stream: FirebaseFirestore.instance
          .collection('vaccines')
          .where('ownerId', isEqualTo: user.uid)
          .snapshots(),
      builder: (context, snapshot) {
        List<Vacinas> vaccines = const [];
        int pending = 0;

        if (snapshot.hasData) {
          vaccines = snapshot.data!.docs.map((doc) {
            final data = doc.data();
            data['id'] = doc.id;
            return Vacinas.fromMap(data);
          }).toList();
          vaccines.sort((a, b) {
            final da = a.administrationDate;
            final db = b.administrationDate;
            if (da == null && db == null) return 0;
            if (da == null) return 1;
            if (db == null) return -1;
            return db.compareTo(da);
          });
          pending = vaccines
              .where((v) => appStatusFromString(v.status) == AppStatus.pending)
              .length;
        }

        return AppScaffold(
          title: 'Vacinas',
          subtitle: pending > 0
              ? '$pending aguardando validação'
              : 'Todas as vacinas dos seus pets',
          bodyPadding: false,
          body: _buildBody(context, snapshot, vaccines),
        );
      },
    );
  }

  Widget _buildBody(
    BuildContext context,
    AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot,
    List<Vacinas> vaccines,
  ) {
    if (snapshot.hasError) {
      return const AppErrorState(
          message: 'Não foi possível carregar suas vacinas.');
    }
    if (!snapshot.hasData) return const AppLoading();
    if (vaccines.isEmpty) {
      return const AppEmptyState(
        icon: Icons.vaccines_rounded,
        title: 'Nenhuma vacina',
        message: 'Abra um pet e registre a primeira vacina da carteira dele.',
      );
    }

    // Agrupa por pet preservando a ordem (mais recente primeiro).
    final groups = <String, List<Vacinas>>{};
    final names = <String, String>{};
    for (final v in vaccines) {
      final key = v.petId ?? '—';
      groups.putIfAbsent(key, () => <Vacinas>[]).add(v);
      names[key] = v.petName ?? 'Pet sem nome';
    }

    final children = <Widget>[];
    groups.forEach((petId, list) {
      children.add(Padding(
        padding: const EdgeInsets.fromLTRB(
            AppSpacing.xl, AppSpacing.lg, AppSpacing.xl, AppSpacing.sm),
        child: Text(
          names[petId]!.toUpperCase(),
          style: AppTypography.caption.copyWith(
              color: context.colors.textTertiary, letterSpacing: 0.5),
        ),
      ));
      for (final v in list) {
        children.add(CardVacinas(
          pet: Pets(id: petId, name: names[petId]),
          model: v,
        ));
      }
    });

    return ListView(
      padding: const EdgeInsets.only(bottom: AppSpacing.xxxl),
      children: children,
    );
  }
}
