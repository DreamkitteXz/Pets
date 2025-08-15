import 'package:pet_app/models/pet_model.dart';
import 'package:pet_app/repositories/pet_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PetController {
  final PetRepository _repository = PetRepository();

  Future<void> createPet(Pets pet) async {
    await _repository.createPet(pet);
  }

  Future<void> removePet(Pets pet) async {
    await _repository.removePet(pet);
  }

  Future<List<Pets>> fetchPetsForCurrentUser() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return [];
    return await _repository.fetchPetsByOwner(user.uid);
  }

  Stream<List<Pets>> petsStreamForCurrentUser() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const Stream.empty();
    return _repository.petsStreamByOwner(user.uid);
  }

  String calculateAgeString(DateTime? birthDate) {
    if (birthDate == null) return 'Idade desconhecida';
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
}
