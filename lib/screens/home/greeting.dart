import 'package:flutter/foundation.dart' show ValueListenable;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:pet_app/design/design.dart';
import 'package:pet_app/services/current_user_service.dart';

/// Saudação da home: "Olá, {primeiro nome}".
///
/// Três estados, deliberadamente distintos:
///  • carregando  → shimmer (NUNCA um nome genérico piscando antes do real);
///  • com nome    → "Olá, Kayque", deslizando da esquerda;
///  • sem nome    → "Olá!" — a palavra "Usuário" não aparece em nenhum caso.
///
/// Reanima quando [replayTrigger] muda, o que cobre a volta para a aba Home:
/// a home vive num IndexedStack e nunca desmonta, então não há `initState`
/// para reagir à troca de aba.
class HomeGreeting extends StatefulWidget {
  /// Incrementado pelo main_screen ao selecionar a aba Home. `null` desliga o
  /// replay (a animação roda só na primeira vez que o nome chega).
  final ValueListenable<int>? replayTrigger;

  const HomeGreeting({super.key, this.replayTrigger});

  @override
  State<HomeGreeting> createState() => _HomeGreetingState();
}

/// Chave do SlideTransition da saudação — dá aos testes um alvo exato, já que
/// MaterialApp/Scaffold também usam SlideTransition nas transições de rota.
const Key kGreetingSlideKey = Key('home-greeting-slide');

class _HomeGreetingState extends State<HomeGreeting>
    with SingleTickerProviderStateMixin {
  // Criados em initState, NÃO como `late final` inicializado na primeira
  // leitura: no caminho do shimmer o build nunca toca no controller, e aí o
  // `_controller.dispose()` seria a primeira leitura — construindo um
  // AnimationController já durante o dispose, o que faz lookup de ancestral
  // num elemento desativado e quebra. Acontecia ao sair da home antes de o
  // nome chegar.
  late final AnimationController _controller;
  late final Animation<Offset> _slide;
  late final Animation<double> _fade;

  /// Evita repetir a animação a cada notificação do serviço: ela só roda
  /// quando o texto realmente muda ou quando o replay é pedido.
  String? _animatedFor;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 520),
    );
    _slide = Tween<Offset>(
      // Começa deslocado para a ESQUERDA e entra para a direita.
      begin: const Offset(-0.35, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);

    widget.replayTrigger?.addListener(_replay);
  }

  @override
  void didUpdateWidget(covariant HomeGreeting oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.replayTrigger != widget.replayTrigger) {
      oldWidget.replayTrigger?.removeListener(_replay);
      widget.replayTrigger?.addListener(_replay);
    }
  }

  void _replay() {
    // Só faz sentido reanimar o que já está visível; durante o shimmer não há
    // texto para deslizar.
    if (!mounted || _animatedFor == null) return;
    _controller.forward(from: 0);
  }

  @override
  void dispose() {
    widget.replayTrigger?.removeListener(_replay);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final service = context.watch<CurrentUserService>();

    if (service.isLoading) {
      return const _GreetingShimmer();
    }

    final firstName = service.firstName;
    final text = firstName == null ? 'Olá!' : 'Olá, $firstName';

    // Dispara na primeira vez que este texto aparece. Feito no build porque é
    // aqui que o dado chega; o guard impede repetição em rebuilds.
    if (_animatedFor != text) {
      _animatedFor = text;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _controller.forward(from: 0);
      });
    }

    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        key: kGreetingSlideKey,
        position: _slide,
        child: Text(
          text,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTypography.largeTitle.copyWith(color: c.textPrimary),
        ),
      ),
    );
  }
}

/// Placeholder do nome enquanto `users/{uid}` não respondeu.
///
/// Ocupa a mesma altura da linha real para o cabeçalho não "pular" quando o
/// nome chega.
class _GreetingShimmer extends StatefulWidget {
  const _GreetingShimmer();

  @override
  State<_GreetingShimmer> createState() => _GreetingShimmerState();
}

class _GreetingShimmerState extends State<_GreetingShimmer>
    with SingleTickerProviderStateMixin {
  // Eager pelo mesmo motivo do controller da saudação: `late final` só
  // inicializa na primeira leitura, e se essa leitura cair no dispose o
  // AnimationController nasce num elemento já desativado.
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final height = (AppTypography.largeTitle.fontSize ?? 28) * 0.82;

    return Semantics(
      label: 'Carregando sua saudação',
      child: SizedBox(
        height: (AppTypography.largeTitle.fontSize ?? 28) *
            (AppTypography.largeTitle.height ?? 1.2),
        child: Align(
          alignment: Alignment.centerLeft,
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              return ShaderMask(
                blendMode: BlendMode.srcATop,
                shaderCallback: (bounds) {
                  // Faixa clara varrendo da esquerda para a direita.
                  final t = _controller.value * 2 - 1;
                  return LinearGradient(
                    begin: Alignment(t - 0.3, 0),
                    end: Alignment(t + 0.3, 0),
                    colors: [
                      c.surfaceSecondary,
                      c.separator,
                      c.surfaceSecondary,
                    ],
                  ).createShader(bounds);
                },
                child: Container(
                  width: 168,
                  height: height,
                  decoration: BoxDecoration(
                    color: c.surfaceSecondary,
                    borderRadius: AppRadius.pill_,
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
