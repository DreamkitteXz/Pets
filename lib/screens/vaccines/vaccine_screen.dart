import 'package:flutter/material.dart';
import 'package:pet_app/controllers/validacao_controller.dart';
import 'package:pet_app/models/vaccine_model.dart';
import 'package:pet_app/design/design.dart';

/// Detalhe da vacina (tutor) — repaginado sobre o design system.
/// Status como 1ª classe, validação do veterinário em modo somente-leitura e
/// "ciência" do tutor (rule tutorAckOnly). O tutor NÃO aprova/rejeita.
class VaccineScreen extends StatefulWidget {
  final Vacinas vacina;
  final String petId;
  const VaccineScreen({super.key, required this.vacina, required this.petId});

  @override
  State<VaccineScreen> createState() => _VaccineScreenState();
}

class _VaccineScreenState extends State<VaccineScreen> {
  // Marca a ciência localmente (otimista) após o tap, para esconder o botão
  // sem depender de recarregar o documento.
  bool _ackedLocally = false;

  Vacinas get v => widget.vacina;

  String _fmt(DateTime? d) => d == null
      ? 'N/D'
      : '${d.day.toString().padLeft(2, '0')}/'
          '${d.month.toString().padLeft(2, '0')}/${d.year}';

  @override
  Widget build(BuildContext context) {
    final status = appStatusFromString(v.status);
    final vet = (v.validationDetails is Map)
        ? (v.validationDetails!['vetValidation'] as Map?)
        : null;
    final acknowledged = _ackedLocally || v.tutorAcknowledged == true;

    return AppScaffold(
      title: v.name ?? 'Vacina',
      showBack: true,
      bodyPadding: false,
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: AppSpacing.lg),
          child: StatusChip(status: status, compact: true),
        ),
      ],
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg, AppSpacing.sm, AppSpacing.lg, AppSpacing.xxxl),
        children: [
          _StatusCard(status: status, vetValidation: vet),
          const SizedBox(height: AppSpacing.lg),

          if (v.labelImage?.isNotEmpty ?? false) ...[
            AppCard(
              padding: EdgeInsets.zero,
              child: ClipRRect(
                borderRadius: AppRadius.card_,
                child: Image.network(
                  v.labelImage!,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _imgPlaceholder(context),
                  loadingBuilder: (ctx, child, prog) =>
                      prog == null ? child : const SizedBox(
                          height: 200, child: AppLoading()),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
          ],

          _InfoGroup(header: 'Dados da vacina', rows: {
            'Aplicada em': _fmt(v.administrationDate),
            'Próxima dose': _fmt(v.nextDueDate),
            'Lote': v.batchNumber ?? 'N/D',
            'Fabricante': v.manufacturer ?? 'N/D',
            'Validade': _fmt(v.expirationDate),
            if ((v.petWeight ?? 0) > 0) 'Peso do pet': '${v.petWeight} kg',
            if ((v.notes ?? '').isNotEmpty) 'Observações': v.notes!,
          }),
          const SizedBox(height: AppSpacing.lg),

          _InfoGroup(header: 'Veterinário', rows: {
            'Nome': v.veterinarianName ?? 'N/D',
            'CRMV': v.crmvNumber ?? 'N/D',
          }),

          if ((v.clinicName ?? '').isNotEmpty) ...[
            const SizedBox(height: AppSpacing.lg),
            _InfoGroup(header: 'Clínica', rows: {
              'Nome': v.clinicName ?? 'N/D',
              if ((v.clinicCnpj ?? '').isNotEmpty) 'CNPJ': v.clinicCnpj!,
              if ((v.clinicAddress?['street'] ?? '').isNotEmpty)
                'Rua': v.clinicAddress!['street']!,
              if ((v.clinicAddress?['city'] ?? '').isNotEmpty)
                'Cidade': v.clinicAddress!['city']!,
            }),
          ],

          // Ciência do tutor: só quando aprovada e ainda sem ciência.
          if (status == AppStatus.approved && !acknowledged) ...[
            const SizedBox(height: AppSpacing.xl),
            Text('Confirme o recebimento',
                style: AppTypography.title2
                    .copyWith(color: context.colors.textPrimary)),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'O veterinário já validou esta vacina. Confirme que você está '
              'ciente para ela constar na carteira do seu pet.',
              style: AppTypography.callout
                  .copyWith(color: context.colors.textSecondary),
            ),
            const SizedBox(height: AppSpacing.lg),
            AppButton(
              label: 'Estou ciente',
              icon: Icons.check_rounded,
              variant: AppButtonVariant.primary,
              onPressed: _darCiencia,
            ),
          ],

          if (acknowledged) ...[
            const SizedBox(height: AppSpacing.xl),
            _AckConfirmation(),
          ],
        ],
      ),
    );
  }

  void _darCiencia() {
    final id = v.id;
    if (id == null) return;
    ValidacaoController().darCiencia(id);
    setState(() => _ackedLocally = true);
  }

  Widget _imgPlaceholder(BuildContext context) => Container(
        height: 200,
        color: context.colors.surfaceSecondary,
        child: Icon(Icons.broken_image_rounded,
            color: context.colors.textTertiary, size: 40),
      );
}

/// Card proeminente do status + validação do vet (somente-leitura).
class _StatusCard extends StatelessWidget {
  final AppStatus status;
  final Map? vetValidation;
  const _StatusCard({required this.status, this.vetValidation});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    Color color;
    IconData icon;
    String title;
    String subtitle;
    switch (status) {
      case AppStatus.approved:
        color = c.statusApproved;
        icon = Icons.check_circle_rounded;
        title = 'Vacina aprovada';
        subtitle = 'Validada pelo veterinário responsável.';
        break;
      case AppStatus.rejected:
        color = c.statusRejected;
        icon = Icons.cancel_rounded;
        title = 'Vacina rejeitada';
        subtitle = 'O veterinário não validou este registro.';
        break;
      case AppStatus.pending:
        color = c.statusPending;
        icon = Icons.schedule_rounded;
        title = 'Aguardando validação';
        subtitle = 'O veterinário responsável ainda não revisou este registro.';
        break;
    }

    final notes = (vetValidation?['notes'] ?? '').toString();
    final rejection = (vetValidation?['rejectionReason'] ?? '').toString();

    return AppCard(
      color: c.tint(color, 0.10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: AppTypography.headline.copyWith(color: color)),
                    const SizedBox(height: 2),
                    Text(subtitle,
                        style: AppTypography.footnote
                            .copyWith(color: c.textSecondary)),
                  ],
                ),
              ),
            ],
          ),
          if (rejection.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            _vetNote(context, 'Motivo da rejeição', rejection),
          ],
          if (notes.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            _vetNote(context, 'Observações do veterinário', notes),
          ],
        ],
      ),
    );
  }

  Widget _vetNote(BuildContext context, String label, String value) {
    final c = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: AppTypography.caption.copyWith(color: c.textTertiary)),
        const SizedBox(height: 2),
        Text(value,
            style: AppTypography.callout.copyWith(color: c.textPrimary)),
      ],
    );
  }
}

/// Grupo de informações (label → valor) em card agrupado.
class _InfoGroup extends StatelessWidget {
  final String header;
  final Map<String, String> rows;
  const _InfoGroup({required this.header, required this.rows});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final entries = rows.entries.toList();
    final children = <Widget>[];
    for (var i = 0; i < entries.length; i++) {
      children.add(Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg, vertical: AppSpacing.md),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(entries[i].key,
                style: AppTypography.callout.copyWith(color: c.textSecondary)),
            const SizedBox(width: AppSpacing.lg),
            Expanded(
              child: Text(entries[i].value,
                  textAlign: TextAlign.right,
                  style: AppTypography.callout.copyWith(color: c.textPrimary)),
            ),
          ],
        ),
      ));
      if (i != entries.length - 1) {
        children.add(Padding(
          padding: const EdgeInsets.only(left: AppSpacing.lg),
          child: Divider(height: 1, thickness: 1, color: c.separator),
        ));
      }
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
              AppSpacing.xs, 0, AppSpacing.xs, AppSpacing.sm),
          child: Text(header.toUpperCase(),
              style: AppTypography.caption
                  .copyWith(color: c.textTertiary, letterSpacing: 0.5)),
        ),
        AppCard(padding: EdgeInsets.zero, child: Column(children: children)),
      ],
    );
  }
}

class _AckConfirmation extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return AppCard(
      color: c.tint(c.accentGreen, 0.10),
      child: Row(
        children: [
          Icon(Icons.verified_rounded, color: c.accentGreen),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text('Ciência registrada — obrigado!',
                style: AppTypography.callout.copyWith(color: c.textPrimary)),
          ),
        ],
      ),
    );
  }
}
