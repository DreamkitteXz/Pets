import 'package:flutter/foundation.dart' show ValueListenable;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:pet_app/design/design.dart';
import 'package:pet_app/models/user_model.dart';
import 'package:pet_app/screens/home/greeting.dart';
import 'package:pet_app/services/current_user_service.dart';

/// Dublê do serviço: expõe os mesmos estados sem tocar em Firebase.
///
/// Herda de [CurrentUserService] para o `context.watch<CurrentUserService>()`
/// da saudação encontrá-lo pelo tipo. Não chama o construtor real (que assina
/// authStateChanges) — daí o `super.new` não ser usado aqui... o que exige o
/// construtor da base rodar; por isso a base aceita injeção e este dublê
/// sobrescreve apenas os getters lidos pela UI.
class _FakeUserService extends ChangeNotifier implements CurrentUserService {
  _FakeUserService(this._status, this._name);

  CurrentUserStatus _status;
  String? _name;

  void emit(CurrentUserStatus status, String? name) {
    _status = status;
    _name = name;
    notifyListeners();
  }

  @override
  CurrentUserStatus get status => _status;

  @override
  bool get isLoading => _status == CurrentUserStatus.loading;

  @override
  String? get firstName => CurrentUserService.firstNameOf(_name);

  @override
  Users? get user =>
      _name == null ? null : Users(email: '', password: '', name: _name);

  @override
  String? get uid => 'uid';

  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  Widget wrap(_FakeUserService service, {ValueListenable<int>? trigger}) {
    return ChangeNotifierProvider<CurrentUserService>.value(
      value: service,
      child: MaterialApp(
        theme: AppTheme.light(),
        home: Scaffold(body: HomeGreeting(replayTrigger: trigger)),
      ),
    );
  }

  testWidgets('carregando: mostra placeholder e NUNCA a palavra "usuário"',
      (tester) async {
    final service = _FakeUserService(CurrentUserStatus.loading, null);
    await tester.pumpWidget(wrap(service));
    await tester.pump();

    expect(find.textContaining('suário'), findsNothing);
    expect(find.textContaining('Olá'), findsNothing);
    // O placeholder se anuncia para leitor de tela.
    expect(find.bySemanticsLabel('Carregando sua saudação'), findsOneWidget);
  });

  testWidgets('com nome: mostra só o primeiro nome', (tester) async {
    final service =
        _FakeUserService(CurrentUserStatus.ready, 'Kayque Amado');
    await tester.pumpWidget(wrap(service));
    await tester.pumpAndSettle();

    expect(find.text('Olá, Kayque'), findsOneWidget);
  });

  testWidgets('sem nome: cai em "Olá!" — não em texto genérico',
      (tester) async {
    final service = _FakeUserService(CurrentUserStatus.ready, null);
    await tester.pumpWidget(wrap(service));
    await tester.pumpAndSettle();

    expect(find.text('Olá!'), findsOneWidget);
    expect(find.textContaining('suário'), findsNothing);
  });

  testWidgets('loading -> pronto: o nome genérico não aparece no meio',
      (tester) async {
    final service = _FakeUserService(CurrentUserStatus.loading, null);
    await tester.pumpWidget(wrap(service));
    await tester.pump();
    expect(find.textContaining('Olá'), findsNothing);

    service.emit(CurrentUserStatus.ready, 'Ana Paula');
    await tester.pump();
    // Assim que sai do shimmer, já é o nome real — sem passar por "Usuário".
    expect(find.text('Olá, Ana'), findsOneWidget);
    await tester.pumpAndSettle();
    expect(find.text('Olá, Ana'), findsOneWidget);
  });

  testWidgets('anima da esquerda para a direita ao aparecer', (tester) async {
    final service = _FakeUserService(CurrentUserStatus.ready, 'Kayque');
    await tester.pumpWidget(wrap(service));
    await tester.pump(); // agenda o postFrame
    await tester.pump(); // dispara o forward
    await tester.pump(const Duration(milliseconds: 60));

    final slide =
        tester.widget<SlideTransition>(find.byKey(kGreetingSlideKey));
    // No meio da animação ainda está deslocado para a ESQUERDA (dx negativo).
    expect(slide.position.value.dx, lessThan(0));

    await tester.pumpAndSettle();
    final settled =
        tester.widget<SlideTransition>(find.byKey(kGreetingSlideKey));
    expect(settled.position.value.dx, 0);
  });

  testWidgets('replayTrigger reanima ao voltar para a aba Home',
      (tester) async {
    final trigger = ValueNotifier<int>(0);
    final service = _FakeUserService(CurrentUserStatus.ready, 'Kayque');
    await tester.pumpWidget(wrap(service, trigger: trigger));
    await tester.pumpAndSettle();

    SlideTransition current() =>
        tester.widget<SlideTransition>(find.byKey(kGreetingSlideKey));

    expect(current().position.value.dx, 0); // parado

    trigger.value++; // volta para a Home
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 60));
    expect(current().position.value.dx, lessThan(0)); // deslizando de novo

    await tester.pumpAndSettle();
    expect(current().position.value.dx, 0);
    trigger.dispose();
  });
}
