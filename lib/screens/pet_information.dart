import 'package:flutter/material.dart';
import 'package:pet_app/models/pets.dart';
import 'package:pet_app/screens/vacinas.dart';
import 'package:pet_app/screens/vermifugos.dart';
import 'package:intl/intl.dart';

class PetInformation extends StatelessWidget {
  final Pets pet;

  const PetInformation({super.key, required this.pet});

  @override
  Widget build(BuildContext context) {
    print("PetInformation - Pet ID: ${pet.id}"); // Add this debug print
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text(
            pet.name ?? 'Desconhecido',
            style: const TextStyle(
                fontFamily: 'Outfit',
                fontWeight: FontWeight.w600,
                fontSize: 24,
                color: Color(0xFF080809)),
          ),
          backgroundColor: Colors.white,
          automaticallyImplyLeading: false,
          leading: IconButton(
            onPressed: () async {
              Navigator.pop(context);
              print(pet.id);
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
        body: SafeArea(
          top: true,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: InfoText(text: 'Informações do seu Pet:'),
                ),
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(20, 20, 20, 20),
                  child: GridView(
                    padding: EdgeInsets.zero,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 1,
                    ),
                    primary: false,
                    shrinkWrap: true,
                    scrollDirection: Axis.vertical,
                    children: [
                      Card(
                        cardTitle: 'Vacinas',
                        cardIcon: 'lib/assets/vacinabk.png',
                        cardColor: const Color(0xFF154E77),
                        pet: pet,
                      ),

                      //=================================================================================
                      //Vermifugos
                      Card(
                        cardIcon: 'lib/assets/vermifugo.png',
                        cardTitle: 'Vermífugos',
                        cardColor: const Color(0xFFE95B47),
                        pet: pet,
                      )
                    ],
                  ),
                ),
                InfoText(text: 'Detalhes:'),
                const SizedBox(height: 20),
                //============================================================================
                //Informação Nome

                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
                  child: ListView(
                    padding: EdgeInsets.zero,
                    primary: false,
                    shrinkWrap: true,
                    scrollDirection: Axis.vertical,
                    children: [
                      InfoCard(
                        pet: pet.name ?? 'Desconhecido',
                        label: 'Nome',
                        iconPath: Icons.pets,
                      ),
                      InfoCard(
                        pet: pet.color ?? 'Desconhecido',
                        label: 'Cor',
                        iconPath: Icons.color_lens,
                      ),
                      InfoCard(
                        pet: pet.breed ?? 'Desconhecido',
                        label: 'Raça',
                        iconPath: Icons.pets,
                      ),
                      InfoCard(
                          pet: pet.species ?? 'Desconhecido',
                          label: 'Espécie',
                          iconPath: Icons.category),
                      InfoCard(
                        pet: pet.gender ?? 'Desconhecido',
                        label: 'Sexo',
                        iconPath: Icons.transgender,
                      ),
                      InfoCard(
                        pet: pet.isNeutered ?? false ? 'Sim' : 'Não',
                        label: 'Castrado',
                        iconPath: Icons.check_circle,
                      ),
                      InfoCard(
                        pet: pet.chipNumber ?? 'Não registrado',
                        label: 'Número do Chip',
                        iconPath: Icons.confirmation_number,
                      ),
                      if (pet.birthDate != null)
                        InfoCard(
                          pet: DateFormat('dd/MM/yyyy').format(pet.birthDate!),
                          label: 'Data de Nascimento',
                          iconPath: Icons.calendar_today,
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class Card extends StatelessWidget {
  String cardTitle;
  String cardIcon;
  final Pets pet;
  Color cardColor;
  Card(
      {super.key,
      required this.cardTitle,
      required this.cardIcon,
      required this.pet,
      required this.cardColor});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (cardTitle == 'Vacinas') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => VacinasPage(pet: pet),
            ),
          );
        } else if (cardTitle == 'Vermífugos') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => VermifugosPage(
                pet: pet,
              ),
            ),
          );
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(12, 0, 12, 0),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    cardTitle,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset(
                      cardIcon,
                      height: 100,
                      fit: BoxFit.cover,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class InfoCard extends StatelessWidget {
  String label;
  IconData iconPath; // Changed from String to IconData
  String pet;
  InfoCard(
      {super.key,
      required this.pet,
      required this.label,
      required this.iconPath});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(20, 0, 20, 20),
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(
          maxWidth: 570,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: const [
            //OK
            BoxShadow(
              blurRadius: 2,
              color: Color(0x411D2429),
              offset: Offset(0, 2),
            )
          ],
          borderRadius: BorderRadius.circular(8), //O
          border: Border.all(
            color: const Color(0xFFE3E3E3),
            width: 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(16, 12, 16, 12),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 12, 0),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                          color: Color(0xFF707070),
                          fontSize: 17,
                          fontWeight: FontWeight.w500),
                    ),
                    Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(0, 4, 0, 0),
                      child: Text(
                        pet,
                        style: const TextStyle(
                            color: Color(0xFF707070),
                            fontSize: 14,
                            fontWeight: FontWeight.w400),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                iconPath,
                color: Colors.black,
                size: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class InfoText extends StatelessWidget {
  String text;
  InfoText({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(20, 0, 0, 0),
      child: Text(
        text,
        textAlign: TextAlign.start,
        style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF707070)),
      ),
    );
  }
}
