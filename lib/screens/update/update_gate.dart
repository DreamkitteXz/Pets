import 'package:flutter/material.dart';

import 'package:pet_app/controllers/update_controller.dart';
import 'package:pet_app/models/app_release_info.dart';
import 'package:pet_app/screens/update/update_dialog.dart';

/// Roda a checagem de versão UMA vez, entre o login e a home.
///
/// Fica entre os dois de propósito: depois do login (o roteador só chega aqui
/// com sessão e documento prontos) e antes da home aparecer, para o caso
/// obrigatório não deixar o tutor usar uma versão incompatível.
///
/// O [child] é renderizado normalmente durante a checagem — ela é rápida e
/// segurar a home atrás de um spinner por causa de uma leitura opcional seria
/// pior. No caso obrigatório o diálogo cobre a tela e não fecha.
///
/// Fora do Android o gate é inerte: [UpdateController.checkOnStartup] devolve
/// `null` e nada acontece.
class UpdateGate extends StatefulWidget {
  final Widget child;

  /// Injetável para teste; em produção usa o padrão.
  final UpdateController? controller;

  const UpdateGate({super.key, required this.child, this.controller});

  @override
  State<UpdateGate> createState() => _UpdateGateState();
}

class _UpdateGateState extends State<UpdateGate> {
  late final UpdateController _controller =
      widget.controller ?? UpdateController();

  /// Uma checagem por sessão: o roteador reconstrói a cada notificação do
  /// CurrentUserService, e sem esta guarda o diálogo reabriria sozinho.
  bool _checked = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _run());
  }

  @override
  void dispose() {
    if (widget.controller == null) _controller.dispose();
    super.dispose();
  }

  Future<void> _run() async {
    if (_checked || !mounted) return;
    _checked = true;

    // APKs de instalações anteriores que ficaram no cache. Roda antes da
    // checagem para nunca competir com um download em curso.
    await _controller.cleanupStaleDownloads();

    AppUpdateCheck? check;
    try {
      check = await _controller.checkOnStartup();
    } catch (e) {
      debugPrint('[update] checagem falhou: $e');
      return; // fail open: nunca impede o uso do app
    }

    if (check == null || !mounted) return;
    await showUpdateDialog(
      context: context,
      controller: _controller,
      check: check,
    );
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
