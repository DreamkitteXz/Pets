import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'design.dart';

/// Tela de demonstração (Storybook) do design system — usada só para revisão
/// visual no CHECKPOINT 1. Não faz parte do fluxo do app.
class DesignGallery extends StatelessWidget {
  const DesignGallery({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final theme = context.watch<ThemeController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AppScaffold(
      title: 'Design System',
      subtitle: 'Amostra de componentes — light/dark',
      actions: [
        IconButton(
          tooltip: 'Alternar tema',
          onPressed: () => theme.toggle(context),
          icon: Icon(isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded),
          color: c.textPrimary,
        ),
      ],
      body: ListView(
        padding: const EdgeInsets.only(bottom: AppSpacing.xxxl),
        children: [
          _section('Status (eixo único)'),
          Wrap(spacing: AppSpacing.sm, runSpacing: AppSpacing.sm, children: const [
            StatusChip(status: AppStatus.pending),
            StatusChip(status: AppStatus.approved),
            StatusChip(status: AppStatus.rejected),
          ]),
          const SizedBox(height: AppSpacing.md),
          // Card de item "aguardando validação" (preview da FASE C)
          AppCard(
            onTap: () {},
            child: Row(children: [
              Container(
                width: 44, height: 44,
                decoration: BoxDecoration(
                    color: c.tint(c.statusPending, 0.12), shape: BoxShape.circle),
                child: Icon(Icons.vaccines_rounded, color: c.statusPending),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('V10 Polivalente',
                      style: AppTypography.headline.copyWith(color: c.textPrimary)),
                  const SizedBox(height: 4),
                  const StatusChip(status: AppStatus.pending, compact: true),
                ]),
              ),
              Icon(Icons.chevron_right_rounded, color: c.textTertiary),
            ]),
          ),

          _section('Botões'),
          AppButton(label: 'Primário', onPressed: () {}),
          const SizedBox(height: AppSpacing.sm),
          AppButton(
              label: 'Secundário',
              onPressed: () {},
              variant: AppButtonVariant.secondary,
              icon: Icons.add_rounded),
          const SizedBox(height: AppSpacing.sm),
          AppButton(
              label: 'Destrutivo',
              onPressed: () {},
              variant: AppButtonVariant.destructive),
          const SizedBox(height: AppSpacing.sm),
          const AppButton(label: 'Carregando', onPressed: null, loading: true),

          _section('Inputs'),
          const AppTextField(label: 'Nome do pet', hint: 'Ex.: Rex'),
          const SizedBox(height: AppSpacing.md),
          const AppTextField(
              label: 'Senha', hint: '••••••', obscureText: true),

          _section('Lista agrupada'),
          AppListSection(
            header: 'Conta',
            children: [
              AppListTile(
                  leadingIcon: Icons.person_rounded,
                  title: 'Perfil',
                  subtitle: 'Seus dados',
                  onTap: () {}),
              AppListTile(
                  leadingIcon: Icons.dark_mode_rounded,
                  leadingColor: c.accentIndigo,
                  title: 'Tema escuro',
                  trailing: Switch(
                      value: isDark, onChanged: (_) => theme.toggle(context))),
              AppListTile(
                  leadingIcon: Icons.logout_rounded,
                  leadingColor: c.accentRed,
                  title: 'Sair',
                  onTap: () {}),
            ],
          ),

          _section('Estados'),
          AppCard(
            padding: EdgeInsets.zero,
            child: SizedBox(
              height: 180,
              child: AppEmptyState(
                  icon: Icons.pets_rounded,
                  title: 'Nenhum pet cadastrado',
                  message: 'Adicione seu primeiro pet.',
                  actionLabel: 'Adicionar',
                  onAction: () {}),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          AppCard(
            padding: EdgeInsets.zero,
            child: SizedBox(
                height: 160,
                child: AppErrorState(
                    message: 'Erro ao carregar.', onRetry: () {})),
          ),
          const SizedBox(height: AppSpacing.md),
          const AppCard(
              child: Row(children: [
            AppSkeleton(height: 44, width: 44, radius: AppRadius.card_),
            SizedBox(width: AppSpacing.md),
            Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              AppSkeleton(height: 14, width: 140),
              SizedBox(height: 8),
              AppSkeleton(height: 12, width: 90),
            ])),
          ])),

          _section('Tipografia'),
          AppCard(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Large title', style: AppTypography.largeTitle.copyWith(color: c.textPrimary)),
              Text('Title', style: AppTypography.title2.copyWith(color: c.textPrimary)),
              Text('Headline', style: AppTypography.headline.copyWith(color: c.textPrimary)),
              Text('Body — o cão saudável é um cão feliz.',
                  style: AppTypography.body.copyWith(color: c.textSecondary)),
              Text('Caption / footnote',
                  style: AppTypography.footnote.copyWith(color: c.textTertiary)),
            ]),
          ),

          _section('Cores'),
          Wrap(spacing: AppSpacing.sm, runSpacing: AppSpacing.sm, children: [
            _swatch('blue', c.accentBlue),
            _swatch('green', c.accentGreen),
            _swatch('red', c.accentRed),
            _swatch('orange', c.accentOrange),
            _swatch('indigo', c.accentIndigo),
            _swatch('purple', c.accentPurple),
          ]),
        ],
      ),
    );
  }

  Widget _section(String t) => Padding(
        padding: const EdgeInsets.fromLTRB(0, AppSpacing.xl, 0, AppSpacing.sm),
        child: Builder(builder: (context) {
          return Text(t.toUpperCase(),
              style: AppTypography.caption.copyWith(
                  color: context.colors.textTertiary, letterSpacing: 0.6));
        }),
      );

  Widget _swatch(String name, Color color) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 48, height: 48,
            decoration: BoxDecoration(
                color: color,
                borderRadius:
                    const BorderRadius.all(Radius.circular(AppRadius.md))),
          ),
          const SizedBox(height: 4),
          Text(name, style: AppTypography.caption.copyWith(color: color)),
        ],
      );
}
