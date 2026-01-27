import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pet_app/models/pet_model.dart';
import 'package:pet_app/screens/add/add_screen.dart';
import 'package:pet_app/screens/auth/login_screen.dart';
import 'package:pet_app/screens/pets/add_pet.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:pet_app/screens/home/home_screen.dart';
import 'package:pet_app/models/vaccine_model.dart';
import 'package:pet_app/screens/pets/pets_screen.dart';
import 'package:pet_app/screens/vaccines/vaccines_screen.dart';
import 'package:pet_app/screens/profile/profile_screen.dart';
import 'package:pet_app/controllers/home/home_screen_controller.dart';
import 'package:pet_app/controllers/user_controller.dart'; // Adicione esta linha
import 'package:pet_app/models/user_model.dart'; // adicione o import do model

class HomeScreenPage extends StatefulWidget {
  final User user;
  const HomeScreenPage({
    super.key,
    required this.user,
  });

  @override
  State<HomeScreenPage> createState() => _HomeScreenPageState();
}

class _HomeScreenPageState extends State<HomeScreenPage>
    with SingleTickerProviderStateMixin {
  late HomeScreenController _controller;
  late UserController _userController; // Adicione esta linha
  late TabController _tabController;
  int _selectedIndex = 0;
  late List<Widget> _pages;
  String userName = '';

  @override
  void initState() {
    super.initState();
    _userController = UserController();
    _controller = HomeScreenController(
        user: widget.user, onLogout: _logout, onUserData: _onUserData);
    _tabController = TabController(length: 2, vsync: this);
    _pages = List<Widget>.filled(
      5,
      Container(),
      growable: false,
    );

    // inicializa sem os dados completos do Firestore (será atualizado em _loadUserData)
    _pages[0] = HomeScreenMainTab(
      tabControllerBuilder: (controller) => _tabController,
      onShowAllPets: (List<Pets> pets) {
        setState(() {
          _pages[3] = PetsScreen(pets: pets);
          _selectedIndex = 3;
        });
      },
      userData: null, // agora passa Users? (null inicialmente)
    );
    _pages[1] = VacinasScreen();
    _pages[2] = AddScreen();
    _pages[3] = const PetsScreen(pets: []);
    _pages[4] = ProfileScreen(
      user: widget.user,
      onLogout: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
      },
    );
    _loadUserData(); // Adicione esta linha
  }

  // Adicione este método
  Future<void> _loadUserData() async {
    try {
      final users = await _userController.getCurrentUser();
      if (users != null) {
        // Atualiza displayName no Auth (opcional)
        await widget.user.updateDisplayName(users.name);
        await widget.user.reload();
      }

      setState(() {
        // Recria a página principal passando o objeto Users (pode ser null)
        _pages[0] = HomeScreenMainTab(
          tabControllerBuilder: (controller) => _tabController,
          onShowAllPets: (List<Pets> pets) {
            setState(() {
              _pages[3] = PetsScreen(pets: pets);
              _selectedIndex = 3;
            });
          },
          userData: users, // aqui vai o Users completo do Firestore
        );
      });
    } catch (e) {
      print('Erro ao carregar dados do usuário: $e');
    }
  }

  void _onUserData(String name) {
    setState(() {
      userName = name;
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _logout() async {
    await _controller.logout(context);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: WillPopScope(
        onWillPop: () async => false,
        child: Scaffold(
          backgroundColor: Colors.grey[50],
          body: IndexedStack(
            index: _selectedIndex,
            children: _pages,
          ),
          bottomNavigationBar: _buildBottomNavigationBar(),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildUserAvatar(),
          const Padding(
            padding: EdgeInsets.only(left: 8.0),
            child: Icon(Icons.notifications_outlined),
          ),
        ],
      ),
    );
  }

  Widget _buildUserAvatar() {
    return InkWell(
      onTap: _showProfileMenu,
      child: CircleAvatar(
        radius: 20,
        backgroundColor: const Color(0xFF041A23),
        child: widget.user.photoURL != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: CachedNetworkImage(
                  imageUrl: widget.user.photoURL!,
                  width: 40,
                  height: 40,
                  fit: BoxFit.cover,
                  placeholder: (context, url) =>
                      const CircularProgressIndicator(),
                  errorWidget: (context, url, error) =>
                      const Icon(Icons.person, color: Colors.white),
                ),
              )
            : const Icon(Icons.person, color: Colors.white),
      ),
    );
  }

  void _showProfileMenu() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.logout),
                title: const Text('Logout'),
                onTap: () {
                  Navigator.pop(context);
                  _logout();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            spreadRadius: 1,
            blurRadius: 10,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavBarItem(0, Icons.home_outlined, Icons.home, "Home"),
            _buildNavBarItem(
                1, Icons.assignment_outlined, Icons.assignment, "Vacinas"),
            FloatingActionButton(
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AddPetScreen()),
                );
              },
              backgroundColor: const Color(0xFF041A23),
              elevation: 8,
              child: const Icon(Icons.add, color: Colors.white, size: 24),
            ),
            _buildNavBarItem(3, Icons.pets_outlined, Icons.pets, "Pets"),
            _buildNavBarItem(
                4, Icons.grid_view_outlined, Icons.grid_view, "Perfil"),
          ],
        ),
      ),
    );
  }

  Widget _buildAddNavBarItem() {
    bool isSelected = _selectedIndex == 2;
    return Container(
      height: 56,
      width: 56,
      margin: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: isSelected ? const Color(0xFF041A23) : Colors.white,
        elevation: isSelected ? 6 : 2,
        shape: const CircleBorder(),
        shadowColor: Colors.black.withOpacity(0.18),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: () {
            setState(() {
              _selectedIndex = 2;
            });
          },
          child: Center(
            child: Icon(
              Icons.add,
              color: isSelected ? Colors.white : const Color(0xFF041A23),
              size: 28,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavBarItem(
      int index, IconData outlinedIcon, IconData filledIcon, String label) {
    bool isSelected = _selectedIndex == index;
    return InkWell(
      onTap: () async {
        if (index == 1) {
          List<Vacinas> userVacinas = await _controller.fetchVaccinesList();
          setState(() {
            if (_pages.length > 1) {
              _pages[1] = VacinasScreen();
            }
            _selectedIndex = index;
          });
        } else if (index == 3) {
          List<Pets> userPets = await _controller.fetchPets();
          setState(() {
            if (_pages.length > 3) {
              _pages[3] = PetsScreen(pets: userPets);
            }
            _selectedIndex = index;
          });
        } else {
          setState(() {
            _selectedIndex = index;
          });
        }
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isSelected ? filledIcon : outlinedIcon,
            color: isSelected ? const Color(0xFF041A23) : Colors.grey,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isSelected ? const Color(0xFF041A23) : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
