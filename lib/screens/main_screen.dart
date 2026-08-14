import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pet_app/models/pet_model.dart';
import 'package:pet_app/screens/add/add_screen.dart';
import 'package:pet_app/screens/auth/login_screen.dart';
import 'package:pet_app/screens/pets/add_pet.dart';
import 'package:pet_app/screens/home/home_screen.dart';
import 'package:pet_app/screens/pets/pets_screen.dart';
import 'package:pet_app/screens/vaccines/vaccines_screen.dart';
import 'package:pet_app/screens/profile/profile_screen.dart';
import 'package:pet_app/controllers/home/home_screen_controller.dart';
import 'package:pet_app/controllers/user_controller.dart'; // Adicione esta linha
import 'package:pet_app/design/design.dart';

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
    _pages[1] = const VacinasScreen();
    _pages[2] = const AddScreen();
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
      debugPrint('Erro ao carregar dados do usuário: $e');
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
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: context.colors.surfaceGrouped,
        body: SafeArea(
          bottom: false,
          child: IndexedStack(index: _selectedIndex, children: _pages),
        ),
        bottomNavigationBar: _buildBottomNavigationBar(context),
      ),
    );
  }

  /// Tab bar estilo iOS: superfície agrupada secundária, hairline no topo e
  /// botão central de ação. Cores vêm do tema (funciona no dark mode).
  Widget _buildBottomNavigationBar(BuildContext context) {
    final c = context.colors;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: c.surfaceGroupedSecondary,
        border: Border(top: BorderSide(color: c.separator, width: 1)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md, vertical: AppSpacing.sm),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavBarItem(
                  context, 0, Icons.home_outlined, Icons.home_rounded, 'Home'),
              _buildNavBarItem(context, 1, Icons.vaccines_outlined,
                  Icons.vaccines_rounded, 'Vacinas'),
              _buildAddButton(context),
              _buildNavBarItem(
                  context, 3, Icons.pets_outlined, Icons.pets_rounded, 'Pets'),
              _buildNavBarItem(context, 4, Icons.person_outline_rounded,
                  Icons.person_rounded, 'Perfil'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAddButton(BuildContext context) {
    final c = context.colors;
    return Material(
      color: c.accentBlue,
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute<void>(builder: (_) => const AddPetScreen()),
        ),
        child: const SizedBox(
          width: 48,
          height: 48,
          child: Icon(Icons.add_rounded, color: Colors.white, size: 26),
        ),
      ),
    );
  }

  Widget _buildNavBarItem(BuildContext context, int index,
      IconData outlinedIcon, IconData filledIcon, String label) {
    final c = context.colors;
    final isSelected = _selectedIndex == index;
    final color = isSelected ? c.accentBlue : c.textTertiary;

    return InkWell(
      borderRadius: AppRadius.button_,
      onTap: () async {
        // A aba de Pets recarrega a lista; as demais só trocam o índice.
        if (index == 3) {
          final userPets = await _controller.fetchPets();
          if (!mounted) return;
          setState(() {
            _pages[3] = PetsScreen(pets: userPets);
            _selectedIndex = index;
          });
          return;
        }
        setState(() => _selectedIndex = index);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md, vertical: AppSpacing.xs),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(isSelected ? filledIcon : outlinedIcon, color: color, size: 24),
            const SizedBox(height: 3),
            Text(label,
                style: AppTypography.caption.copyWith(
                  color: color,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                )),
          ],
        ),
      ),
    );
  }
}
