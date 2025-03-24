import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:pet_app/controllers/validacao_controller.dart';
import 'package:pet_app/screens/home_screen.dart';
import 'package:pet_app/screens/onboarding.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());

  //FirebaseFirestore firestore = FirebaseFirestore.instance;
  //firestore.collection('Só para testar').doc('Estou testando!').set({
  //  'funcionou?': true,
  //});
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: NavigationService.navigatorKey,
      title: 'Tutor App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const RoteadorTelas(),
    );
  }
}

class RoteadorTelas extends StatelessWidget {
  const RoteadorTelas({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseAuth.instance.userChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasData) {
          return HomeScreenPage(user: snapshot.data as User);
        } else {
          return const OnBoarding();
        }
      },
    );
  }
}
