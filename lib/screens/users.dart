import 'package:flutter/material.dart';
import 'package:pet_app/authentication/logout.dart';
import 'package:pet_app/screens/create_account/regitro_page.dart';

class UsersDetails extends StatelessWidget {
  const UsersDetails({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Informações do Usuário"),
        ),
        body: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ElevatedButton(
                        onPressed: () {
                          deslogar();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => RegistroPage(),
                            ),
                          );
                        },
                        child: const Text("Sair")),
                  ],
                )
              ],
            ),
          ),
        ));
  }
}
