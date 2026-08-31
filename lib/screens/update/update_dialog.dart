import 'package:flutter/material.dart';

import 'package:pet_app/controllers/update_controller.dart';
import 'package:pet_app/design/design.dart';
import 'package:pet_app/models/app_release_info.dart';

/// Diálogo de atualização. Bloqueante ou dispensável conforme [check].
///
/// Devolve `true` quando o instalador do sistema chegou a abrir.
Future<bool?> showUpdateDialog({
  required BuildContext context,
  required UpdateController controller,
  required AppUpdateCheck check,
}) {
  final blocking = check.isBlocking;
  return showDialog<bool>(
    context: context,
    // Bloqueante = sem toque fora e sem back. O app não é utilizável nessa
    // versão, entao fechar o dialogo so devolveria uma tela quebrada.
    barrierDismissible: !blocking,
    builder: (_) => PopScope(
      canPop: !blocking,
      child: _UpdateDialog(controller: controller, check: check),
    ),
  );
}

class _UpdateDialog extends StatefulWidget {
  final UpdateController controller;
  final AppUpdateCheck check;

  const _UpdateDialog({required this.controller, required this.check});

  @override
  State<_UpdateDialog> createState() => _UpdateDialogState();
}

class _UpdateDialogState extends State<_UpdateDialog> {
  UpdateController get controller => widget.controller;
  AppUpdateCheck get check => widget.check;
  AppReleaseInfo? get release => check.release;
  bool get blocking => check.isBlocking;

  @override
  void initState() {
    super.initState();
    controller.addListener(_onChanged);
  }

  @override
  void dispose() {
    controller.removeListener(_onChanged);
    super.dispose();
  }

  void _onChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final info = release;

    return AlertDialog(
      backgroundColor: c.surfaceGroupedSecondary,
      shape: const RoundedRectangleBorder(borderRadius: AppRadius.card_),
      title: Row(
        children: [
          Icon(
            blocking ? Icons.lock_rounded : Icons.system_update_rounded,
            color: blocking ? c.accentRed : c.accentBlue,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              blocking ? 'Atualização obrigatória' : 'Nova versão disponível',
              style: AppTypography.headline.copyWith(color: c.textPrimary),
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(child: _content(context, info)),
      actionsPadding: const EdgeInsets.fromLTRB(
          AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.lg),
      actions: _actions(context, info),
    );
  }

  Widget _content(BuildContext context, AppReleaseInfo? info) {
    final c = context.colors;
    final stage = controller.stage;

    if (stage == UpdateStage.needsPermission) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Para instalar a atualização, o Android precisa da sua '
            'autorização para este app instalar aplicativos.',
            style: AppTypography.callout.copyWith(color: c.textPrimary),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Toque em "Abrir configuração", ligue a opção de instalar '
            'aplicativos desconhecidos e volte para cá.',
            style: AppTypography.footnote.copyWith(color: c.textSecondary),
          ),
        ],
      );
    }

    if (stage == UpdateStage.downloading) {
      final progress = controller.progress;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Baixando a atualização...',
              style: AppTypography.callout.copyWith(color: c.textPrimary)),
          const SizedBox(height: AppSpacing.lg),
          ClipRRect(
            borderRadius: AppRadius.pill_,
            child: LinearProgressIndicator(
              // Sem Content-Length a barra fica indeterminada, em vez de
              // mostrar uma porcentagem inventada.
              value: progress?.fraction,
              minHeight: 8,
              backgroundColor: c.surfaceSecondary,
              valueColor: AlwaysStoppedAnimation<Color>(c.accentBlue),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(progress?.label ?? '',
                  style:
                      AppTypography.caption.copyWith(color: c.textSecondary)),
              if (progress?.fraction != null)
                Text('${((progress!.fraction ?? 0) * 100).round()}%',
                    style: AppTypography.caption
                        .copyWith(color: c.textSecondary)),
            ],
          ),
        ],
      );
    }

    if (stage == UpdateStage.installing) {
      return Row(
        children: [
          SizedBox(
            height: 18,
            width: 18,
            child:
                CircularProgressIndicator(strokeWidth: 2, color: c.accentBlue),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text('Arquivo verificado. Abrindo o instalador...',
                style: AppTypography.callout.copyWith(color: c.textPrimary)),
          ),
        ],
      );
    }

    // idle ou failed
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (blocking) ...[
          Text(
            'Esta versão do app não é mais compatível e precisa ser '
            'atualizada para continuar.',
            style: AppTypography.callout.copyWith(color: c.textPrimary),
          ),
          const SizedBox(height: AppSpacing.md),
        ],
        Row(
          children: [
            Text('Versão ${info?.latestVersionName ?? '—'}',
                style: AppTypography.subhead.copyWith(color: c.textPrimary)),
            if (info?.readableSize != null) ...[
              Text(' · ', style: TextStyle(color: c.textTertiary)),
              Text(info!.readableSize!,
                  style:
                      AppTypography.subhead.copyWith(color: c.textSecondary)),
            ],
          ],
        ),
        if ((info?.changelog ?? '').isNotEmpty) ...[
          const SizedBox(height: AppSpacing.md),
          Text(info!.changelog!,
              style: AppTypography.callout.copyWith(color: c.textSecondary)),
        ],
        if (controller.errorMessage != null) ...[
          const SizedBox(height: AppSpacing.lg),
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: c.tint(c.accentRed, 0.10),
              borderRadius: AppRadius.button_,
            ),
            child: Text(controller.errorMessage!,
                style: AppTypography.footnote.copyWith(color: c.accentRed)),
          ),
        ],
      ],
    );
  }

  List<Widget> _actions(BuildContext context, AppReleaseInfo? info) {
    final stage = controller.stage;

    if (stage == UpdateStage.downloading) {
      return [
        TextButton(
          onPressed: controller.cancelDownload,
          child: const Text('Cancelar'),
        ),
      ];
    }

    if (stage == UpdateStage.installing) return const [];

    if (stage == UpdateStage.needsPermission) {
      return [
        if (!blocking)
          TextButton(
            onPressed: () => _dismiss(context),
            child: const Text('Agora não'),
          ),
        FilledButton(
          onPressed: () async {
            await controller.openInstallPermissionSettings();
            controller.reset();
          },
          child: const Text('Abrir configuração'),
        ),
      ];
    }

    final retry = stage == UpdateStage.failed;
    return [
      if (!blocking)
        TextButton(
          onPressed: () => _dismiss(context),
          child: const Text('Agora não'),
        ),
      FilledButton(
        onPressed: info == null
            ? null
            : () async {
                final ok = await controller.downloadAndInstall(info);
                if (ok && context.mounted) Navigator.of(context).pop(true);
              },
        child: Text(retry ? 'Tentar de novo' : 'Atualizar agora'),
      ),
    ];
  }

  Future<void> _dismiss(BuildContext context) async {
    await controller.dismissForToday(check);
    if (context.mounted) Navigator.of(context).pop(false);
  }
}
