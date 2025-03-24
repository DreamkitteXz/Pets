import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pet_app/models/pets.dart';
import 'package:pet_app/screens/add_pet.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:pet_app/screens/login.dart';
import 'package:pet_app/screens/pet_information.dart' as pet_info;

class HomeScreenPage extends StatefulWidget {
  final User user;
  const HomeScreenPage({
    super.key,
    required this.user,
  });

  @override
  State<HomeScreenPage> createState() => _HomeScreenPageState();
}

class _HomeScreenPageState extends State<HomeScreenPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String userName = "";

  @override
  void initState() {
    super.initState();
    _getUserData();
  }

  Future<void> _getUserData() async {
    try {
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(widget.user.uid).get();

      if (userDoc.exists) {
        setState(() {
          userName = userDoc['name'] ?? widget.user.displayName ?? "Pet Lover";
        });
      }
    } catch (e) {
      debugPrint("Error getting user data: $e");
    }
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: WillPopScope(
        onWillPop: () async => false,
        child: Scaffold(
          backgroundColor: Colors.white,
          floatingActionButton: const FloatingActionPets(),
          body: Column(
            children: [
              _buildAppBar(),
              _buildSearchBar(),
              Expanded(
                child: PetsListView(userId: widget.user.uid),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 30, 24, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Olá, ${userName.split(" ")[0]}!',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF062D3E),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Veja como seus pets estão hoje',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          _buildProfileMenu(),
        ],
      ),
    );
  }

  Widget _buildProfileMenu() {
    return DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        icon: CircleAvatar(
          radius: 24,
          backgroundColor: const Color(0xFF041A23),
          child: widget.user.photoURL != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: CachedNetworkImage(
                    imageUrl: widget.user.photoURL!,
                    width: 48,
                    height: 48,
                    fit: BoxFit.cover,
                    placeholder: (context, url) =>
                        const CircularProgressIndicator(),
                    errorWidget: (context, url, error) =>
                        const Icon(Icons.person, color: Colors.white),
                  ),
                )
              : const Icon(Icons.person, color: Colors.white),
        ),
        items: [
          DropdownMenuItem<String>(
            value: 'logout',
            child: Row(
              children: const [
                Icon(Icons.logout, color: Color(0xFF041A23)),
                SizedBox(width: 8),
                Text('Logout'),
              ],
            ),
          ),
        ],
        onChanged: (value) {
          if (value == 'logout') {
            _logout();
          }
        },
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Procurar pet...',
          prefixIcon: const Icon(Icons.search, color: Color(0xFF041A23)),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 0),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide(color: Colors.grey.shade200),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: const BorderSide(color: Color(0xFF041A23)),
          ),
        ),
      ),
    );
  }
}

class PetsListView extends StatelessWidget {
  final String userId;

  const PetsListView({
    Key? key,
    required this.userId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('pets')
          .where('ownerId',
              isEqualTo:
                  userId) // changed from userId to ownerId to match the model
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Erro: ${snapshot.error}'));
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/empty_pets.png',
                  height: 150,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Nenhum pet cadastrado',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Toque no + para adicionar um pet',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            var petData =
                snapshot.data!.docs[index].data() as Map<String, dynamic>;
            petData['id'] =
                snapshot.data!.docs[index].id; // add the document ID to the map
            Pets pet = Pets.fromMap(petData);

            return PetCard(pet: pet);
          },
        );
      },
    );
  }
}

class PetCard extends StatelessWidget {
  final Pets pet;

  const PetCard({
    Key? key,
    required this.pet,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Calculate age from birthDate
    int age = pet.birthDate != null
        ? DateTime.now().difference(pet.birthDate!).inDays ~/ 365
        : 0;

    // Determine the image based on species and gender
    String imagePath;
    if (pet.species?.toLowerCase() == 'gato') {
      imagePath = pet.gender?.toLowerCase() == 'female'
          ? 'lib/assets/catfemea-removebg-preview.png'
          : 'lib/assets/cat-removebg-preview.png';
    } else if (pet.species?.toLowerCase() == 'cachorro') {
      imagePath = pet.gender?.toLowerCase() == 'female'
          ? 'lib/assets/dogfemea-removebg-preview.png'
          : 'lib/assets/dog-removebg-preview.png';
    } else {
      imagePath = 'lib/assets/pet.png';
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => pet_info.PetInformation(pet: pet),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Hero(
                tag: 'pet-${pet.id}',
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 3,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                      imagePath,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      pet.name ?? 'Sem nome',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      pet.breed ?? 'Raça não especificada',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          pet.species?.toLowerCase() == 'cachorro'
                              ? Icons.pets
                              : Icons.catching_pokemon,
                          size: 16,
                          color: const Color(0xFF041A23),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          pet.species ?? 'Não especificado',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF041A23),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Icon(
                          Icons.cake,
                          size: 16,
                          color: Colors.orange[700],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '$age ${age == 1 ? 'ano' : 'anos'}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.orange[700],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Color(0xFF041A23),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class FloatingActionPets extends StatelessWidget {
  const FloatingActionPets({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const AddPetScreen(),
          ),
        );
      },
      backgroundColor: const Color(0xFF041A23),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Icon(
        Icons.add,
        color: Colors.white,
        size: 28,
      ),
    );
  }
}
