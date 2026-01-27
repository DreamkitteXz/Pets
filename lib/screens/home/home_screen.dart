import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pet_app/controllers/pets/pet_controller.dart';
import 'package:pet_app/models/pet_model.dart';
import 'package:pet_app/screens/pets/add_pet.dart';
import 'package:intl/intl.dart';

import 'package:pet_app/services/pet_assets_service.dart';
import 'package:pet_app/controllers/home/home_controller.dart';
import 'package:pet_app/models/user_model.dart'; // novo import

class HomeScreenMainTab extends StatelessWidget {
  final Users? userData; // novo campo opcional com o model completo
  final TabController Function(TabController) tabControllerBuilder;
  final void Function(List<Pets> pets)? onShowAllPets;

  HomeScreenMainTab({
    required this.tabControllerBuilder,
    this.onShowAllPets,
    this.userData, // aceite o Users vindo de fora
    super.key,
  });

  final HomeController _controller = HomeController();
  final PetController _petController = PetController();

  @override
  Widget build(BuildContext context) {
    // usa userData.name com fallback para user.displayName
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // CustomAppBar espera um username — mantenha compatível
          CustomAppBar(username: userData?.name ?? 'Usuário'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 28),
                _buildQuickActionsSection(context),
                const SizedBox(height: 24),
                _buildActivitySection(context), // Moved to top
                const SizedBox(height: 28),
                _buildPetsSection(context),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivitySection(BuildContext context) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _controller.getUpcomingActivities(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final activities = snapshot.data!;
        if (activities.isEmpty) {
          // Improved empty state design
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Próximas Atividades',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF041A23),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/activities');
                    },
                    child: const Text(
                      'Ver todas',
                      style: TextStyle(
                        color: Color(0xFF4A80F0),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                padding:
                    const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.event_note,
                        size: 48,
                        color: Color(0xFF7EC8B3),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Nenhuma atividade futura',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF041A23),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Agende consultas, vacinas ou vermífugos para seus pets',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          // Navigate to add activity screen
                          Navigator.pushNamed(context, '/add-activity');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF4A80F0),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 12),
                        ),
                        child: const Text(
                          'Adicionar Atividade',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Próximas Atividades',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF041A23),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/activities');
                  },
                  child: const Text(
                    'Ver todas',
                    style: TextStyle(
                      color: Color(0xFF4A80F0),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: List.generate(activities.length, (index) {
                  final activity = activities[index];
                  return Column(
                    children: [
                      _buildActivityItem(
                        activity['type'] as String,
                        activity['title'] as String,
                        _formatDateTime(activity['time'] as DateTime),
                        activity['color'] as Color,
                        activity['icon'] as IconData,
                        index == 0,
                        () {},
                      ),
                      if (index < activities.length - 1)
                        const Divider(
                          height: 1,
                          thickness: 1,
                          indent: 70,
                          endIndent: 20,
                        ),
                    ],
                  );
                }),
              ),
            ),
          ],
        );
      },
    );
  }

  // Função auxiliar para formatar data/hora
  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    if (dateTime.day == now.day &&
        dateTime.month == now.month &&
        dateTime.year == now.year) {
      return 'Hoje, ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    }
    return '${dateTime.day}/${dateTime.month}, ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  Widget _buildActivityItem(
    String type,
    String title,
    String time,
    Color color,
    IconData icon,
    bool isHighlighted,
    VoidCallback onTap,
  ) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: color.withOpacity(isHighlighted ? 0.25 : 0.12),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color, size: 24),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: isHighlighted ? FontWeight.bold : FontWeight.w600,
          color: const Color(0xFF041A23),
          fontSize: 16,
        ),
      ),
      subtitle: Text(
        time,
        style: TextStyle(
          color: isHighlighted ? color : Colors.grey[600],
          fontWeight: isHighlighted ? FontWeight.w600 : FontWeight.normal,
          fontSize: 13,
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: color,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  Widget _buildQuickActionsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Ações Rápidas',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF041A23),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 100,
          child: ListView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            children: [
              _buildActionCard(
                context,
                'Novo Pet',
                Icons.pets,
                const Color(0xFF4A80F0),
                const Color(0xFFE6EFFF),
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AddPetScreen()),
                ),
              ),
              _buildActionCard(
                context,
                'Vacina',
                Icons.medical_services_outlined,
                const Color(0xFF7EC8B3),
                const Color(0xFFE4F7F3),
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AddPetScreen()),
                ),
              ),
              _buildActionCard(
                context,
                'Vermífugo',
                Icons.calendar_today,
                const Color(0xFFF0A35E),
                const Color(0xFFFFF4E8),
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AddPetScreen()),
                ),
              ),
              _buildActionCard(
                context,
                'Peso',
                Icons.medication_outlined,
                const Color(0xFFFF7D7D),
                const Color(0xFFFFEBEB),
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AddPetScreen()),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionCard(BuildContext context, String title, IconData icon,
      Color color, Color bgColor, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(right: 16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: 90,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.2),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.3),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(height: 10),
              Text(
                title,
                style: TextStyle(
                  color: color.withOpacity(0.8),
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPetsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Seus Pets',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF041A23),
              ),
            ),
            TextButton(
              onPressed: () async {
                final pets = await _controller.getUserPets(limit: 100).first;
                if (onShowAllPets != null) {
                  onShowAllPets!(pets);
                }
              },
              child: const Text(
                'Ver todos',
                style: TextStyle(
                  color: Color(0xFF4A80F0),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        StreamBuilder<List<Pets>>(
          stream: _controller.getUserPets(limit: 3),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: CircularProgressIndicator(),
                ),
              );
            }

            final pets = snapshot.data!;
            if (pets.isEmpty) {
              return _buildEmptyPetsCard(context);
            }

            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: pets.length,
              itemBuilder: (context, index) {
                final pet = pets[index];
                return _buildPetCard(context, pet);
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildEmptyPetsCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        children: [
          Icon(
            Icons.pets,
            size: 48,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          const Text(
            'Nenhum pet cadastrado',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF041A23),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Adicione seu primeiro pet para começar',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => Navigator.pushNamed(context, '/add-pet'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4A80F0),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Adicionar Pet'),
          ),
        ],
      ),
    );
  }

  Widget _buildPetCard(BuildContext context, Pets pet) {
    final String petType = pet.species?.toLowerCase() ?? 'outro';
    final IconData petIcon = petType == 'cat'
        ? Icons.pets
        : petType == 'dog'
            ? Icons.pets
            : Icons.pets;

    final Map<String, Color> petColors = {
      'dog': const Color(0xFF4A80F0),
      'cat': const Color(0xFFF0A35E),
      'bird': const Color(0xFF7EC8B3),
      'fish': const Color(0xFF5B8DEF),
      'rabbit': const Color(0xFFAD7BEF),
    };

    final Color petColor = petColors[petType] ?? const Color(0xFF4A80F0);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () {
            Navigator.pushNamed(context, '/pet-details', arguments: pet);
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: petColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(30),
                      child: Image.asset(
                        PetAssetsService.getImagePath(
                          pet.species,
                          pet.breed,
                          pet.gender,
                        ),
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Center(
                          child: Icon(
                            petIcon,
                            size: 30,
                            color: petColor,
                          ),
                        ),
                      ),
                    )),
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
                          color: Color(0xFF041A23),
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
                          _buildPetDetail(
                            Icons.cake_outlined,
                            pet.birthDate != null
                                ? _petController
                                    .calculateAgeString(pet.birthDate!)
                                : 'Idade N/A',
                          ),
                          const SizedBox(width: 16),
                          _buildPetDetail(
                            pet.gender?.toLowerCase() == 'male'
                                ? Icons.male
                                : Icons.female,
                            pet.gender?.toLowerCase() == 'male'
                                ? 'Macho'
                                : 'Fêmea',
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
                    color: petColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: petColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPetDetail(IconData icon, String text) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: Colors.grey[600],
        ),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String username;
  final VoidCallback? onNotificationTap;
  final VoidCallback? onProfileTap;
  final String? profileImageUrl; // opcional, se quiser usar imagem no perfil

  const CustomAppBar({
    super.key,
    required this.username,
    this.onNotificationTap,
    this.onProfileTap,
    this.profileImageUrl,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final formattedDate = DateFormat(
      "EEE, d MMMM",
    ).format(now); // ex: Fri, 15 November

    return Container(
      padding: const EdgeInsets.only(top: 40, left: 20, right: 20, bottom: 20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFEDE7F6), // Roxinho bem leve (claro)
            Color(0xFFFAF7F8), // Branco
          ],
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          /// Parte esquerda (Data + Saudação)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                formattedDate,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 6),
              Text(
                "Olá, $username",
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          Row(
            children: [
              /// Notificação
              InkWell(
                onTap: onNotificationTap,
                borderRadius: BorderRadius.circular(30),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    const Icon(
                      Icons.notifications_none,
                      size: 28,
                      color: Colors.black87,
                    ),
                    Positioned(
                      right: -2,
                      top: -2,
                      child: Container(
                        height: 14,
                        width: 14,
                        decoration: BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 1.5),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),

              /// Perfil
              InkWell(
                onTap: onProfileTap,
                borderRadius: BorderRadius.circular(25),
                child: CircleAvatar(
                  radius: 18,
                  backgroundColor: Colors.grey[300],
                  backgroundImage: profileImageUrl != null
                      ? NetworkImage(profileImageUrl!)
                      : null,
                  child: profileImageUrl == null
                      ? Text(
                          username.isNotEmpty ? username[0].toUpperCase() : "?",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        )
                      : null,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(100);
}
