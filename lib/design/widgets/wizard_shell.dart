import 'package:flutter/material.dart';
import '../app_colors.dart';
import '../app_typography.dart';
import '../app_spacing.dart';
import 'app_button.dart';

/// Moldura dos cadastros em etapas (vacina, vermífugo).
///
/// Cabeçalho com fechar + progresso, conteúdo da etapa num card e barra
/// inferior com voltar/avançar. Substitui as duas cópias que existiam nos
/// wizards, cada uma com suas cores hardcoded.
class WizardShell extends StatelessWidget {
  final String title;
  final String stepTitle;
  final int currentStep;
  final int totalSteps;

  /// `null` na primeira etapa — o botão de voltar some.
  final VoidCallback? onBack;
  final VoidCallback onNext;
  final bool isLastStep;
  final bool busy;
  final GlobalKey<FormState>? formKey;
  final Widget child;

  const WizardShell({
    super.key,
    required this.title,
    required this.stepTitle,
    required this.currentStep,
    required this.totalSteps,
    required this.onNext,
    required this.child,
    this.onBack,
    this.isLastStep = false,
    this.busy = false,
    this.formKey,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final progress = (currentStep + 1) / totalSteps;

    Widget body = ListView(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg, AppSpacing.md, AppSpacing.lg, AppSpacing.xxl),
      children: [
        Text(stepTitle,
            style: AppTypography.title2.copyWith(color: c.textPrimary)),
        const SizedBox(height: AppSpacing.lg),
        Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: c.surfaceGroupedSecondary,
            borderRadius: AppRadius.card_,
          ),
          child: child,
        ),
      ],
    );

    if (formKey != null) {
      body = Form(key: formKey, child: body);
    }

    return Scaffold(
      backgroundColor: c.surfaceGrouped,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.sm, AppSpacing.sm, AppSpacing.lg, AppSpacing.md),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.maybePop(context),
                    icon: const Icon(Icons.close_rounded, size: 22),
                    color: c.textSecondary,
                    tooltip: 'Fechar',
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title,
                            style: AppTypography.headline
                                .copyWith(color: c.textPrimary)),
                        const SizedBox(height: 1),
                        Text('Passo ${currentStep + 1} de $totalSteps',
                            style: AppTypography.caption
                                .copyWith(color: c.textTertiary)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: ClipRRect(
                borderRadius: AppRadius.pill_,
                child: TweenAnimationBuilder<double>(
                  duration: AppDurations.normal,
                  curve: Curves.easeOut,
                  tween: Tween<double>(begin: 0, end: progress),
                  builder: (context, value, _) => LinearProgressIndicator(
                    value: value,
                    minHeight: 6,
                    backgroundColor: c.surfaceSecondary,
                    valueColor: AlwaysStoppedAnimation<Color>(c.accentBlue),
                  ),
                ),
              ),
            ),
            Expanded(child: body),
            _bottomBar(context),
          ],
        ),
      ),
    );
  }

  Widget _bottomBar(BuildContext context) {
    final c = context.colors;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: c.surfaceGroupedSecondary,
        border: Border(top: BorderSide(color: c.separator, width: 1)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg, AppSpacing.md, AppSpacing.lg, AppSpacing.md),
        child: Row(
          children: [
            if (onBack != null) ...[
              // Tooltip dá o nome acessível que um botão só de ícone não
              // tem (leitor de tela + toque longo).
              Tooltip(
                message: 'Voltar',
                child: SizedBox(
                  width: 56,
                  child: AppButton(
                    label: '',
                    icon: Icons.arrow_back_rounded,
                    variant: AppButtonVariant.secondary,
                    fullWidth: false,
                    onPressed: busy ? null : onBack,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
            ],
            Expanded(
              child: AppButton(
                label: isLastStep ? 'Finalizar' : 'Continuar',
                loading: busy,
                onPressed: onNext,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
