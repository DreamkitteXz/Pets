import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:pet_app/controllers/validacao_controller.dart';
import 'package:pet_app/screens/auth/auth_flow.dart';
import 'package:pet_app/screens/main_screen.dart';
import 'package:pet_app/screens/update/update_gate.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:pet_app/services/current_user_service.dart';
import 'package:pet_app/services/pet_assets_service.dart';
import 'package:pet_app/design/design.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Storage: o padrão de retry de upload é 10 MINUTOS. Qualquer falha de rede
  // fica girando o spinner todo esse tempo antes de virar erro — parece
  // travado, sem printar nada. 45s é tempo de sobra para uma foto de <5 MB e
  // devolve o erro enquanto o usuário ainda está olhando.
  FirebaseStorage.instance.setMaxUploadRetryTime(const Duration(seconds: 45));
  FirebaseStorage.instance.setMaxOperationRetryTime(const Duration(seconds: 20));

  // Force portrait orientation
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Load pet assets configuration
  try {
    final String jsonContent =
        await rootBundle.loadString('assets/config/pet_assets.json');
    final configuration = json.decode(jsonContent);
    PetAssetsService.initialize(configuration);
  } catch (e) {
    print('Error loading pet assets configuration: $e');
  }

  // Tema: honra o sistema por padrão + override persistido.
  final themeController = ThemeController();
  await themeController.load();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<ThemeController>.value(value: themeController),
        // Ponto único de leitura de `users/{uid}`. Fica na raiz para
        // sobreviver à troca de telas: assina uma vez e serve o app inteiro,
        // em vez de cada tela instanciar UserController e reler o documento.
        ChangeNotifierProvider<CurrentUserService>(
          create: (_) => CurrentUserService(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeController>();
    return MaterialApp(
      navigatorKey: NavigationService.navigatorKey,
      title: 'Tutor App',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: theme.mode,
      home: const RoteadorTelas(),
    );
  }
}

/// Decide a tela raiz a partir do [CurrentUserService].
///
/// Antes olhava só `hasData` do `authStateChanges`: bastava existir usuário no
/// Auth para ir à home. Isso deixava dois buracos:
///
///  • **Corrida no cadastro.** `createUserWithEmailAndPassword` já autentica e
///    dispara o stream ANTES de o `set()` em `users/{uid}` terminar. A home
///    abria sem documento.
///  • **Estado indefinido.** "Autenticado, documento ainda carregando" não
///    existia como caso — caía direto na home.
///
/// Agora a decisão usa auth + documento juntos, e cada estado tem uma tela:
/// carregando → spinner; sem documento → erro visível (nunca tela em branco);
/// pronto → home; deslogado → [AuthFlow].
class RoteadorTelas extends StatelessWidget {
  const RoteadorTelas({super.key});

  @override
  Widget build(BuildContext context) {
    final session = context.watch<CurrentUserService>();

    switch (session.status) {
      case CurrentUserStatus.loading:
        // Cobre tanto "ainda não sei se tem sessão" quanto "autenticado, mas
        // users/{uid} não respondeu" — inclusive a janela do cadastro entre
        // autenticar e gravar o documento.
        return const Scaffold(body: AppLoading(message: 'Carregando...'));

      case CurrentUserStatus.signedOut:
        return const AuthFlow();

      case CurrentUserStatus.ready:
        final authUser = session.authUser;
        if (authUser == null) return const AuthFlow();
        if (session.user == null) {
          return PerfilIndisponivel(session: session);
        }
        // A checagem de versao entra AQUI: depois do login (so chegamos neste
        // ramo com sessao e documento prontos) e antes da home ser usavel.
        return UpdateGate(child: HomeScreenPage(user: authUser));
    }
  }
}

/// Autenticado, mas `users/{uid}` não veio.
///
/// Ou a gravação do cadastro falhou, ou a leitura falhou. Nos dois casos a
/// home ficaria sem os dados do tutor — melhor dizer o que houve e oferecer
/// saída do que abrir uma tela pela metade.
class PerfilIndisponivel extends StatelessWidget {
  final CurrentUserService session;

  const PerfilIndisponivel({super.key, required this.session});

  @override
  Widget build(BuildContext context) {
    final falhouLeitura = session.error != null;

    return Scaffold(
      backgroundColor: context.colors.surfaceGrouped,
      body: SafeArea(
        child: AppErrorState(
          message: falhouLeitura
              ? 'Não foi possível carregar seu perfil. Verifique sua conexão '
                  'e tente de novo.'
              : 'Sua conta foi criada, mas o perfil não foi encontrado. '
                  'Tente novamente ou entre outra vez.',
          onRetry: session.retry,
        ),
      ),
    );
  }
}
  