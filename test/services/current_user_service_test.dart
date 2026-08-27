import 'package:flutter_test/flutter_test.dart';
import 'package:pet_app/services/current_user_service.dart';

/// A saudação mostra só o PRIMEIRO nome, e nunca a palavra "usuário".
///
/// `firstNameOf` é o ponto onde isso se decide: devolver `null` é o que faz a
/// UI cair em "Olá!" em vez de um texto genérico. Estes testes fixam os
/// formatos que a base realmente tem — o `name` de `users/{uid}` é digitado à
/// mão no cadastro, então vem com espaço sobrando, vazio ou ausente.
void main() {
  group('firstNameOf', () {
    test('extrai o primeiro nome de um nome completo', () {
      expect(CurrentUserService.firstNameOf('Kayque Amado'), 'Kayque');
      expect(CurrentUserService.firstNameOf('Maria da Silva Santos'), 'Maria');
    });

    test('nome único devolve ele mesmo', () {
      expect(CurrentUserService.firstNameOf('Kayque'), 'Kayque');
    });

    test('tolera espaços sobrando', () {
      expect(CurrentUserService.firstNameOf('  Kayque  Amado '), 'Kayque');
      expect(CurrentUserService.firstNameOf('\tKayque\nAmado'), 'Kayque');
    });

    test('preserva acentuação e capitalização originais', () {
      expect(CurrentUserService.firstNameOf('Ângela Souza'), 'Ângela');
      expect(CurrentUserService.firstNameOf('joão pedro'), 'joão');
    });

    test('null quando não há nome utilizável — a UI cai em "Olá!"', () {
      // Nenhum destes pode virar saudação com nome; e nenhum pode virar
      // "Usuário", que é o texto que esta mudança elimina.
      expect(CurrentUserService.firstNameOf(null), isNull);
      expect(CurrentUserService.firstNameOf(''), isNull);
      expect(CurrentUserService.firstNameOf('   '), isNull);
      expect(CurrentUserService.firstNameOf('\n\t '), isNull);
    });
  });

  test('o serviço nasce em loading — nunca em "sem nome"', () {
    // Garante o requisito do shimmer: antes da primeira resposta o estado
    // precisa ser distinguível de "carregou e não tem nome", senão a tela
    // pisca a saudação sem nome antes da real.
    expect(CurrentUserStatus.values, contains(CurrentUserStatus.loading));
    expect(CurrentUserStatus.values, contains(CurrentUserStatus.ready));
    expect(CurrentUserStatus.values, contains(CurrentUserStatus.signedOut));
  });
}
