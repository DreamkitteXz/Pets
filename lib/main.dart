import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:pet_app/controllers/validacao_controller.dart';
import 'package:pet_app/screens/main_screen.dart';
import 'package:pet_app/screens/onboarding_screen.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:pet_app/services/pet_assets_service.dart';
import 'package:pet_app/design/design.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

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
    ChangeNotifierProvider<ThemeController>.value(
      value: themeController,
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

class RoteadorTelas extends StatelessWidget {
  const RoteadorTelas({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: AppLoading());
        }

        if (snapshot.hasData && snapshot.data != null) {
          return HomeScreenPage(user: snapshot.data!);
        }

        return const OnBoarding();
      },
    );
  }
}
