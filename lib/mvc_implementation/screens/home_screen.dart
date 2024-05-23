import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pet_app/models/Pet.dart';
import 'package:pet_app/mvc_implementation/controllers/user_controller.dart';
import 'package:pet_app/mvc_implementation/models/pets.dart';
import 'package:pet_app/mvc_implementation/models/user.dart';
import 'package:pet_app/mvc_implementation/screens/add_pet.dart';
import 'package:pet_app/mvc_implementation/screens/add_vac.dart';
import 'package:pet_app/mvc_implementation/screens/components/list_view.dart';
import 'package:pet_app/mvc_implementation/screens/components/titles.dart';
import 'package:pet_app/mvc_implementation/screens/login.dart';

class HomeScreenPage extends StatefulWidget {
  //Users user;
  HomeScreenPage({
    super.key,
    /*TODO: required this.user*/
  });

  @override
  State<HomeScreenPage> createState() => _HomeScreenPageState();
}

class _HomeScreenPageState extends State<HomeScreenPage> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: WillPopScope(
          onWillPop: () async {
            return false;
          },
          child: Scaffold(
            backgroundColor: Colors.white,
            floatingActionButton: FloatingActionPets(),
            body: Column(
              // mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 44),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Titles(
                        title: 'Olá Kayque!',
                        fontSize: 32.0,
                        paddingL: 30.0,
                      ),
                      const Padding(
                        padding: EdgeInsets.only(right: 22.0),
                        child: InkWell(
                          child: Icon(
                            Icons.menu_rounded,
                            size: 32,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                const PetsList(),
              ],
            ),
          )),
    );
  }
}

class FloatingActionPets extends StatelessWidget {
  FloatingActionPets({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddPetScreen(),
            ),
          );
        },
        backgroundColor: const Color(0xFF212121),
        elevation: 8,
        child: const Icon(
          Icons.add,
          color: Colors.white,
          size: 32,
        ),
      ),
    );
  }
}
