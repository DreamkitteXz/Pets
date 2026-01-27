import 'package:flutter/material.dart';
import 'package:pet_app/models/pet_model.dart';
import 'package:pet_app/screens/pets/pet_information.dart' as pet_info;
import 'package:pet_app/services/pet_assets_service.dart';
import 'package:pet_app/controllers/pets/pet_controller.dart';

class PetsScreen extends StatelessWidget {
  final List<Pets> pets;

  const PetsScreen({Key? key, required this.pets}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return pets.isEmpty
        ? const Center(child: Text('Nenhum pet cadastrado'))
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.all(20.0),
                child: Text(
                  'Meus Pets',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: pets.length,
                  itemBuilder: (context, index) {
                    return PetCard(pet: pets[index]);
                  },
                ),
              ),
            ],
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
    final imagePath = PetAssetsService.getImagePath(
      pet.species,
      pet.breed,
      pet.gender,
    );

    final speciesColor = PetAssetsService.getSpeciesColor(pet.species);
    final speciesIcon = PetAssetsService.getSpeciesIcon(pet.species);
    final vaccineIcon = PetAssetsService.getVaccineIcon(
      pet.species,
      pet.breed,
      pet.gender,
    );

    final petController = PetController();
    final ageString = petController.calculateAgeString(pet.birthDate);

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
                    color: Colors.white,
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
                          speciesIcon,
                          size: 16,
                          color: speciesColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          pet.species ?? 'Não especificado',
                          style: TextStyle(
                            fontSize: 12,
                            color: speciesColor,
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
                          ageString,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.orange[700],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Icon(
                          vaccineIcon,
                          size: 16,
                          color: Colors.green[700],
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
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.blue,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
