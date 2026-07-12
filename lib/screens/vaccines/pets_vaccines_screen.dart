import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:open_file/open_file.dart';
import 'package:pet_app/models/pet_model.dart';
import 'package:pet_app/models/vaccine_model.dart';
import 'package:pet_app/screens/vaccines/add_vaccine_screen.dart';
import 'package:pet_app/screens/vaccines/vaccine_screen.dart';
import 'package:pet_app/services/vaccine_card_generator.dart';
import 'package:pet_app/controllers/vaccines/vaccine_controller.dart';
import 'package:pet_app/design/design.dart';

class PetsVaccinesScreen extends StatelessWidget {
  final Pets? pet;
  final List<Vacinas>? userVacinas;

  const PetsVaccinesScreen({super.key, this.pet, this.userVacinas});

  @override
  Widget build(BuildContext context) {
    final vaccineController = VaccineController();
    print("VacinasPage - Pet received: $pet"); // Add this debug print
    print("VacinasPage - Pet ID: ${pet?.id}"); // Add this debug print
    print("VacinasPage - Pet name: ${pet?.name}"); // Add this debug print

    if (pet?.id == null) {
      print("VacinasPage - Pet ID is null!"); // Add this debug print
      // Return a more informative error screen
      return Scaffold(
        appBar: AppBar(
          title: const Text('Vacinas'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('ID do Pet não encontrado'),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Voltar'),
              ),
            ],
          ),
        ),
      );
    }

    if (userVacinas != null) {
      // Show all vaccines for the user
      return SafeArea(
        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            title: const Text(
              'Vacinas',
              style: TextStyle(
                  fontFamily: 'Outfit',
                  fontWeight: FontWeight.w600,
                  fontSize: 24,
                  color: Color(0xFF080809)),
            ),
            backgroundColor: Colors.white,
            automaticallyImplyLeading: true,
            leading: IconButton(
              onPressed: () async {
                Navigator.pop(context);
              },
              icon: const Icon(
                Icons.arrow_back_rounded,
                size: 30,
                color: Color(0xFF212121),
              ),
            ),
            centerTitle: true,
            elevation: 0,
          ),
          body: ListView.builder(
            itemCount: userVacinas!.length,
            itemBuilder: (context, index) {
              Vacinas model = userVacinas![index];
              return CardVacinas(
                pet: pet ?? Pets(id: model.petId ?? ''),
                model: model,
              );
            },
          ),
        ),
      );
    }

    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text(
            'Vacinas',
            style: TextStyle(
                fontFamily: 'Outfit',
                fontWeight: FontWeight.w600,
                fontSize: 24,
                color: Color(0xFF080809)),
          ),
          actions: <Widget>[
            Padding(
              padding: const EdgeInsets.only(right: 22.0),
              child: GestureDetector(
                onTap: () async {
                  try {
                    final snapshot = await FirebaseFirestore.instance
                        .collection('vaccines')
                        .where('petId', isEqualTo: pet!.id)
                        .get();

                    List<Vacinas> vaccines = snapshot.docs.map((doc) {
                      Map<String, dynamic> data = doc.data();
                      data['id'] = doc.id;
                      return Vacinas.fromMap(data);
                    }).toList();

                    final path = await VaccineCardGenerator.generateVaccineCard(
                        pet!, vaccines);
                    final result = await OpenFile.open(
                      path,
                      type: 'application/pdf',
                    );

                    if (result.type != ResultType.done) {
                      throw Exception(result.message);
                    }
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Erro ao abrir PDF: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                child: SvgPicture.asset(
                  'lib/screens/assets/docs.svg',
                  width: 25,
                  height: 25,
                ),
              ),
            )
          ],
          backgroundColor: Colors.white,
          automaticallyImplyLeading: false,
          leading: IconButton(
            onPressed: () async {
              Navigator.pop(context);
            },
            icon: const Icon(
              Icons.arrow_back_rounded,
              size: 30,
              color: Color(0xFF212121),
            ),
          ),
          centerTitle: true,
          elevation: 0,
        ),
        floatingActionButton: FloatingActionVac(petId: pet!.id!),
        body: StreamBuilder<List<Vacinas>>(
          stream: vaccineController.vaccinesStreamForPet(pet!.id!),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            List<Vacinas> listVac = snapshot.data!;
            return ListView.builder(
              itemCount: listVac.length,
              itemBuilder: (context, index) {
                Vacinas model = listVac[index];
                // [F2.3/§5] Sem swipe-to-delete: hard delete de registro
                // clínico é negado por rule (allow delete: if false) e o tutor
                // não exclui vacina.
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            VaccineScreen(vacina: model, petId: pet!.id),
                      ),
                    );
                  },
                  child: CardVacinas(
                    pet: pet!,
                    model: model,
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class CardVacinas extends StatelessWidget {
  const CardVacinas({
    super.key,
    required this.pet,
    required this.model,
  });

  final Pets pet;
  final Vacinas model;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final status = appStatusFromString(model.status);
    final bool pending = status == AppStatus.pending;

    Color statusColor;
    switch (status) {
      case AppStatus.approved:
        statusColor = c.statusApproved;
        break;
      case AppStatus.rejected:
        statusColor = c.statusRejected;
        break;
      case AppStatus.pending:
        statusColor = c.statusPending;
        break;
    }

    String fmt(DateTime? d) => d == null
        ? 'N/D'
        : '${d.day.toString().padLeft(2, '0')}/'
            '${d.month.toString().padLeft(2, '0')}/${d.year}';

    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.md),
      child: AppCard(
        padding: EdgeInsets.zero,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  VaccineScreen(vacina: model, petId: pet.id),
            ),
          );
        },
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Acento lateral quando "aguardando validação" do vet.
              if (pending) Container(width: 4, color: statusColor),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: c.tint(statusColor, 0.12),
                              borderRadius: const BorderRadius.all(
                                  Radius.circular(AppRadius.md)),
                            ),
                            child: Icon(Icons.vaccines_rounded,
                                color: statusColor, size: 22),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  model.name ?? 'Vacina',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTypography.headline
                                      .copyWith(color: c.textPrimary),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Lote ${model.batchNumber ?? 'N/D'}',
                                  style: AppTypography.footnote
                                      .copyWith(color: c.textSecondary),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          StatusChip(status: status, compact: true),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Row(
                        children: [
                          _DateBit(
                              icon: Icons.event_available_rounded,
                              label: 'Aplicada',
                              value: fmt(model.administrationDate)),
                          const SizedBox(width: AppSpacing.lg),
                          _DateBit(
                              icon: Icons.event_repeat_rounded,
                              label: 'Próxima',
                              value: fmt(model.nextDueDate)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DateBit extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _DateBit(
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: c.textTertiary),
        const SizedBox(width: 4),
        Text('$label: $value',
            style: AppTypography.caption.copyWith(color: c.textSecondary)),
      ],
    );
  }
}

class FloatingActionVac extends StatelessWidget {
  final String petId;

  const FloatingActionVac({
    Key? key,
    required this.petId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AddVacPage(petId: petId),
          ),
        );
      },
      backgroundColor: const Color(0xFF4B39EF),
      elevation: 8,
      child: const Icon(
        Icons.add_rounded,
        color: Colors.white,
        size: 28,
      ),
    );
  }
}

// [F2.3/§5] deleteVac (diálogo de confirmação de exclusão) removido junto com
// o swipe-to-delete: o tutor não exclui registro clínico de vacina.
