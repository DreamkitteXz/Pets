import 'package:flutter/material.dart';
import 'package:pet_app/models/pet_model.dart';
import 'package:pet_app/screens/pets/weight/pet_weight_tracker.dart';
import 'package:pet_app/screens/vaccines/pets_vaccines_screen.dart';
import 'package:pet_app/screens/deworming/pet_dewormings_screen.dart';
import 'package:intl/intl.dart';
import 'package:pet_app/services/pet_assets_service.dart';
import 'package:pet_app/utils/gender_utils.dart';
import 'package:pet_app/utils/species_utils.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:pet_app/controllers/validacao_controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PetInformation extends StatelessWidget {
  final Pets pet;

  const PetInformation({super.key, required this.pet});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: CustomScrollView(
        slivers: [
          // App Bar with Pet Image
          SliverAppBar(
            expandedHeight: 200.0,
            floating: false,
            pinned: true,
            backgroundColor: Theme.of(context).primaryColor,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                pet.name ?? 'Desconhecido',
                style: const TextStyle(
                  fontFamily: 'Outfit',
                  fontWeight: FontWeight.w600,
                  fontSize: 20,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      blurRadius: 10.0,
                      color: Colors.black38,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Hero Image Background
                  pet.imageUrl != null && pet.imageUrl!.isNotEmpty
                      ? Image.network(
                          pet.imageUrl!,
                          fit: BoxFit.cover,
                        )
                      : Image.asset(
                          PetAssetsService.getImagePath(
                            pet.species,
                            pet.breed,
                            pet.gender,
                          ),
                          fit: BoxFit.cover,
                        ),
                  // Gradient overlay for better text visibility
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.5),
                        ],
                      ),
                    ),
                  ),
                  // Camera icon button for uploading/changing photo
                  Positioned(
                    right: 16,
                    bottom: 16,
                    child: GestureDetector(
                      onTap: () async {
                        // Show dialog for image source selection
                        showModalBottomSheet(
                          context: context,
                          builder: (context) {
                            return SafeArea(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  ListTile(
                                    leading: const Icon(Icons.camera_alt),
                                    title: const Text('Tirar foto'),
                                    onTap: () async {
                                      Navigator.pop(context);
                                      final picker = ImagePicker();
                                      final XFile? pickedFile =
                                          await picker.pickImage(
                                              source: ImageSource.camera);
                                      if (pickedFile != null) {
                                        await _uploadPetImage(
                                            context, pickedFile);
                                      }
                                    },
                                  ),
                                  ListTile(
                                    leading: const Icon(Icons.photo_library),
                                    title: const Text('Escolher da galeria'),
                                    onTap: () async {
                                      Navigator.pop(context);
                                      final picker = ImagePicker();
                                      final XFile? pickedFile =
                                          await picker.pickImage(
                                              source: ImageSource.gallery);
                                      if (pickedFile != null) {
                                        await _uploadPetImage(
                                            context, pickedFile);
                                      }
                                    },
                                  ),
                                  ListTile(
                                    leading: const Icon(Icons.close),
                                    title: const Text('Cancelar'),
                                    onTap: () => Navigator.pop(context),
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.black45,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            leading: IconButton(
              icon: const CircleAvatar(
                backgroundColor: Colors.white,
                radius: 15,
                child: Icon(
                  Icons.arrow_back_rounded,
                  size: 20,
                  color: Color(0xFF212121),
                ),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: const CircleAvatar(
                  backgroundColor: Colors.white,
                  radius: 15,
                  child: Icon(
                    Icons.edit_outlined,
                    size: 20,
                    color: Color(0xFF212121),
                  ),
                ),
                onPressed: () {
                  // Add edit functionality
                },
              ),
              const SizedBox(width: 8),
            ],
          ),

          // Content
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Basic Info Card
                Container(
                  margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 30,
                            backgroundColor: const Color(0xFFEEF1F8),
                            backgroundImage: AssetImage(
                              PetAssetsService.getImagePath(
                                pet.species,
                                pet.breed,
                                pet.gender,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  pet.name ?? 'Desconhecido',
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF212121),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  pet.breed ?? 'Raça desconhecida',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Color(0xFF707070),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    _buildInfoTag(
                                      GenderUtils.toDisplay(
                                          pet.gender ?? 'Desconhecido'),
                                      _getGenderIcon(),
                                      pet.gender?.toLowerCase() == 'male'
                                          ? const Color(0xFF4A80F0)
                                          : const Color(0xFFFF7D7D),
                                    ),
                                    const SizedBox(width: 8),
                                    _buildInfoTag(
                                      pet.isNeutered ?? false
                                          ? 'Castrado'
                                          : 'Não castrado',
                                      Icons.check_circle_outline,
                                      const Color(0xFF7EC8B3),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildQuickInfoItem(
                            Icons.cake_outlined,
                            pet.birthDate != null
                                ? '${_calculateAge(pet.birthDate!)}'
                                : 'Idade desconhecida',
                            'Idade',
                          ),
                          _buildQuickInfoItem(
                            Icons.scale_outlined,
                            '${pet.weight ?? '?'} kg',
                            'Peso atual',
                          ),
                          _buildQuickInfoItem(
                            Icons.pets_outlined,
                            SpeciesUtils.toDisplay(
                                pet.species ?? 'Desconhecido'),
                            'Espécie',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Care Services
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color:
                              Theme.of(context).primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.medical_services_outlined,
                          color: Theme.of(context).primaryColor,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Cuidados com seu Pet',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF041A23),
                        ),
                      ),
                    ],
                  ),
                ),

                // Care Services Cards
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildCareCard(
                          context: context,
                          title: 'Vacinas',
                          description: 'Mantenha as vacinas em dia',
                          iconData: Icons.vaccines_outlined,
                          color: const Color(0xFF154E77),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    PetsVaccinesScreen(pet: pet),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildCareCard(
                          context: context,
                          title: 'Vermífugos',
                          description: 'Proteção contra parasitas',
                          iconData: Icons.medication_outlined,
                          color: const Color(0xFFE95B47),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => VermifugosPage(pet: pet),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),

                // Additional Care Cards
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildCareCard(
                          context: context,
                          title: 'Peso',
                          description: 'Histórico de pesagem',
                          iconData: Icons.line_weight_outlined,
                          color: const Color(0xFF6B4EFF),
                          onTap: () {
                            // Navigate to appointments page
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PetWeightTrackingPage(
                                  pet: pet,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildCareCard(
                          context: context,
                          title: 'Medicamentos',
                          description: 'Tratamentos atuais',
                          iconData: Icons.medication_liquid_outlined,
                          color: const Color(0xFF00A86B),
                          onTap: () {
                            // Navigate to medications page
                          },
                        ),
                      ),
                    ],
                  ),
                ),

                // Detailed Information
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color:
                              Theme.of(context).primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.info_outline,
                          color: Theme.of(context).primaryColor,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Informações Detalhadas',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF041A23),
                        ),
                      ),
                    ],
                  ),
                ),

                // Details List
                Container(
                  margin: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      _buildDetailItem(
                          'Nome', pet.name ?? 'Desconhecido', Icons.pets),
                      _buildDetailItem(
                          'Cor', pet.color ?? 'Desconhecido', Icons.color_lens),
                      _buildDetailItem(
                          'Raça', pet.breed ?? 'Desconhecido', Icons.pets),
                      _buildDetailItem(
                        'Espécie',
                        SpeciesUtils.toDisplay(pet.species ?? 'Desconhecido'),
                        Icons.category,
                      ),
                      _buildDetailItem(
                        'Sexo',
                        GenderUtils.toDisplay(pet.gender ?? 'Desconhecido'),
                        Icons.transgender,
                      ),
                      _buildDetailItem(
                        'Castrado',
                        pet.isNeutered ?? false ? 'Sim' : 'Não',
                        Icons.check_circle,
                      ),
                      _buildDetailItem(
                        'Número do Chip',
                        pet.chipNumber ?? 'Não registrado',
                        Icons.confirmation_number,
                      ),
                      if (pet.birthDate != null)
                        _buildDetailItem(
                          'Data de Nascimento',
                          DateFormat('dd/MM/yyyy').format(pet.birthDate!),
                          Icons.calendar_today,
                        ),
                    ],
                  ),
                ),

                // Add Additional Sections (like Health Reminders, Recent Activities)
                _buildUpcomingReminders(context),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUpcomingReminders(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.notifications_outlined,
                color: Theme.of(context).primaryColor,
                size: 24,
              ),
              const SizedBox(width: 12),
              const Text(
                'Próximos Cuidados',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF041A23),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildReminderItem(
            context,
            'Vacina Anual',
            DateTime.now().add(const Duration(days: 15)),
            Icons.vaccines_outlined,
            const Color(0xFF154E77),
          ),
          const SizedBox(height: 12),
          _buildReminderItem(
            context,
            'Vermífugo',
            DateTime.now().add(const Duration(days: 5)),
            Icons.medication_outlined,
            const Color(0xFFE95B47),
          ),
        ],
      ),
    );
  }

  Widget _buildReminderItem(
    BuildContext context,
    String title,
    DateTime date,
    IconData icon,
    Color color,
  ) {
    final daysRemaining = date.difference(DateTime.now()).inDays;
    final isUrgent = daysRemaining <= 7;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: color,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF212121),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  DateFormat('dd/MM/yyyy').format(date),
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF707070),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: isUrgent
                  ? Colors.red.withOpacity(0.1)
                  : Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '$daysRemaining dias',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isUrgent ? Colors.red : Colors.green,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCareCard({
    required BuildContext context,
    required String title,
    required String description,
    required IconData iconData,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 140,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                iconData,
                color: color,
                size: 32,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              description,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF707070),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickInfoItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFFEEF1F8),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: const Color(0xFF707070),
            size: 24,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF212121),
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF707070),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoTag(String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w500,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFF5F7FA),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: 20,
              color: const Color(0xFF707070),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF707070),
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF212121),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getGenderIcon() {
    return (pet.gender?.toLowerCase() == 'male') ? Icons.male : Icons.female;
  }

  String _calculateAge(DateTime birthDate) {
    final DateTime today = DateTime.now();
    int years = today.year - birthDate.year;
    int months = today.month - birthDate.month;
    int days = today.day - birthDate.day;

    if (days < 0) {
      months--;
      final prevMonth = DateTime(today.year, today.month, 0);
      days += prevMonth.day;
    }
    if (months < 0) {
      years--;
      months += 12;
    }

    if (years > 0) {
      return years == 1 ? '1 ano' : '$years anos';
    } else if (months > 0) {
      return months == 1 ? '1 mês' : '$months meses';
    } else {
      return days == 1 ? '1 dia' : '$days dias';
    }
  }

  Future<void> _uploadPetImage(BuildContext context, XFile pickedFile) async {
    try {
      final storageRef = FirebaseStorage.instance.ref().child(
          'images/pets/${DateTime.now().millisecondsSinceEpoch}_${pickedFile.name}');
      final uploadTask = storageRef.putFile(File(pickedFile.path));
      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();
      // Update the pet's imageUrl in Firestore
      if (pet.id != null) {
        await FirebaseFirestore.instance
            .collection('pets')
            .doc(pet.id)
            .update({'imageUrl': downloadUrl});
      }
      if (NavigationService.navigatorKey.currentContext != null) {
        ScaffoldMessenger.of(NavigationService.navigatorKey.currentContext!)
            .showSnackBar(
          const SnackBar(content: Text('Imagem enviada com sucesso!')),
        );
      }
    } catch (e) {
      if (NavigationService.navigatorKey.currentContext != null) {
        ScaffoldMessenger.of(NavigationService.navigatorKey.currentContext!)
            .showSnackBar(
          SnackBar(content: Text('Erro ao enviar imagem: $e')),
        );
      }
    }
  }
}
