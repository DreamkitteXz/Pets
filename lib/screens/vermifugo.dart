import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:pet_app/models/vermifugos.dart';
import 'package:pet_app/screens/components/subtitle.dart';
import 'package:pet_app/screens/components/titles.dart';

class VermifugoPage extends StatefulWidget {
  final Vermifugo vermifugo;
  final String petId;
  const VermifugoPage(
      {super.key, required this.vermifugo, required this.petId});

  @override
  State<VermifugoPage> createState() => _VermifugoPageState();
}

class _VermifugoPageState extends State<VermifugoPage> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        child: Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              title: Text(
                widget.vermifugo.name ?? 'Unknown Dewormer',
                style: const TextStyle(
                    color: Color(0xFF080809),
                    fontSize: 24,
                    fontWeight: FontWeight.w600),
              ),
              backgroundColor: Colors.white,
              automaticallyImplyLeading: false,
              leading: GestureDetector(
                child: const Icon(
                  Icons.arrow_back_rounded,
                  color: Colors.black,
                  size: 30,
                ),
                onTap: () => Navigator.pop(context),
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
                        padding: const EdgeInsets.fromLTRB(0, 12, 0, 12),
                        child: Titles(
                          title: 'Informações do Vermífugo',
                          fontSize: 18,
                          paddingL: 24,
                          cor: const Color(0xFF707070),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Padding(
                        padding:
                            const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 12),
                        child: ListView(
                          padding: EdgeInsets.zero,
                          primary: false,
                          shrinkWrap: true,
                          scrollDirection: Axis.vertical,
                          children: [
                            VermifugoInfo(
                                widget: widget.vermifugo.name ?? 'N/A',
                                title: 'Vermífugo',
                                icon: Icons.medical_information),
                            VermifugoInfo(
                                widget: formatDate(
                                    widget.vermifugo.administrationDate),
                                title: 'Data de Aplicação',
                                icon: Icons.calendar_today),
                            if (widget.vermifugo.isReinforcementNeeded == true)
                              VermifugoInfo(
                                  widget: formatDate(
                                      widget.vermifugo.reinforcementDate),
                                  title: 'Data do Reforço',
                                  icon: Icons.event_repeat),
                            VermifugoInfo(
                                widget: widget.vermifugo.manufacturer ?? 'N/A',
                                title: 'Fabricante',
                                icon: Icons.factory),
                            VermifugoInfo(
                                widget: widget.vermifugo.dosage ?? 'N/A',
                                title: 'Dosagem',
                                icon: Icons.science),
                            VermifugoInfo(
                                widget:
                                    '${widget.vermifugo.weight ?? 'N/A'} kg',
                                title: 'Peso do Pet',
                                icon: Icons.monitor_weight),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(0, 12, 0, 24),
                              child: Titles(
                                title: 'Dados do veterinário(a)',
                                fontSize: 24,
                                paddingL: 24,
                                cor: const Color(0xFF062D3E),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            VermifugoInfo(
                                widget:
                                    widget.vermifugo.veterinarianName ?? 'N/A',
                                title: 'Nome',
                                icon: Icons.person),
                            VermifugoInfo(
                                widget: widget.vermifugo.crmvNumber ?? 'N/A',
                                title: 'CRMV',
                                icon: Icons.badge),
                            if (widget.vermifugo.clinicName != null) ...[
                              Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(0, 12, 0, 24),
                                child: Titles(
                                  title: 'Dados da Clínica',
                                  fontSize: 24,
                                  paddingL: 24,
                                  cor: const Color(0xFF062D3E),
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              VermifugoInfo(
                                  widget: widget.vermifugo.clinicName,
                                  title: 'Clínica',
                                  icon: Icons.local_hospital),
                              // ...Add more clinic details if needed
                            ],
                            Padding(
                              padding: const EdgeInsets.fromLTRB(0, 12, 0, 24),
                              child: Titles(
                                title: 'Observações',
                                fontSize: 24,
                                paddingL: 24,
                                cor: const Color(0xFF062D3E),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            VermifugoInfo(
                                widget: widget.vermifugo.effectivenessNotes ??
                                    'N/A',
                                title: 'Notas de Efetividade',
                                icon: Icons.note),
                            VermifugoInfo(
                                widget: widget.vermifugo.observations ?? 'N/A',
                                title: 'Observações Gerais',
                                icon: Icons.description),
                          ],
                        ),
                      ),
                    ],
                  ),
                ))));
  }

  String formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    return '${date.day}/${date.month}/${date.year}';
  }
}

class VermifugoInfo extends StatelessWidget {
  final String title;
  final IconData? icon;
  const VermifugoInfo(
      {super.key, required this.widget, required this.title, this.icon});

  final String? widget;

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
          padding: const EdgeInsetsDirectional.fromSTEB(16, 14, 16, 14),
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
                      title,
                      style: const TextStyle(
                          color: Color(0xFF707070),
                          fontSize: 17,
                          fontWeight: FontWeight.w500),
                    ),
                    Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(0, 4, 0, 0),
                      child: Text(
                        widget!,
                        style: const TextStyle(
                            color: Color(0xFF707070),
                            fontSize: 14,
                            fontWeight: FontWeight.w400),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(icon, color: Colors.black, size: 24),
            ],
          ),
        ),
      ),
    );
  }
}
