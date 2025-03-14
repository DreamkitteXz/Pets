import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_svg/svg.dart';
import 'package:pet_app/mvc_implementation/controllers/validacao_controller.dart';
import 'package:pet_app/mvc_implementation/models/vacinas.dart';
import 'package:pet_app/mvc_implementation/screens/components/subtitle.dart';
import 'package:pet_app/mvc_implementation/screens/components/titles.dart';

class VacinaPage extends StatefulWidget {
  final Vacinas vacina;
  final String petId;
  const VacinaPage({super.key, required this.vacina, required this.petId});

  @override
  State<VacinaPage> createState() => _VacinaPageState();
}

class _VacinaPageState extends State<VacinaPage> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        child: Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              title: Text(
                widget.vacina.vacina,
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
              actions: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: SvgPicture.asset(
                    (widget.vacina.isValidadoVet == 'true' &&
                            widget.vacina.isValidadoTutor == 'true')
                        ? 'lib/mvc_implementation/screens/assets/validado.svg'
                        : 'lib/mvc_implementation/screens/assets/aguardando.svg',
                    width: 30,
                    height: 30,
                  ),
                )
              ],
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
                          title: 'Informações da Vacina',
                          fontSize: 18,
                          paddingL: 24,
                          cor: const Color(0xFF707070),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 12, 0, 24),
                        child: Titles(
                          title: 'Foto do Rótulo:',
                          fontSize: 16,
                          paddingL: 24,
                          cor: const Color(0xFF707070),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Padding(
                        padding:
                            const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 12),
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (widget.vacina.imageRotulo.isNotEmpty)
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  widget.vacina.imageRotulo,
                                  width: 300,
                                  height: 220,
                                  fit: BoxFit.cover,
                                ),
                              )
                            else
                              const SizedBox(),
                          ],
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
                            VacinaInfo(
                                widget: widget.vacina.vacina,
                                title: 'Vacina',
                                icon: Icons.vaccines),
                            VacinaInfo(
                                widget: widget.vacina.dataAplicada,
                                title: 'Data Aplicada',
                                icon: Icons.date_range),
                            VacinaInfo(
                                widget: widget.vacina.proximaAplicacao,
                                title: 'Próxima Aplicação',
                                icon: Icons.date_range),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(0, 12, 0, 24),
                              child: Titles(
                                title: 'Dados da Vacina',
                                fontSize: 24,
                                paddingL: 24,
                                cor: const Color(0xFF062D3E),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            VacinaInfo(
                                widget: widget.vacina.lote,
                                title: 'Lote',
                                icon: Icons.folder),
                            VacinaInfo(
                                widget: widget.vacina.farmaceutica,
                                title: 'Farmacêutica',
                                icon: Icons.medical_information),
                            VacinaInfo(
                                widget: widget.vacina.dataValidade,
                                title: 'Data de Validade',
                                icon: Icons.date_range),
                            VacinaInfo(
                                widget: widget.vacina.pesoDataAplicacao,
                                title: 'Peso do Pet',
                                icon: Icons.percent),
                            VacinaInfo(
                                widget: widget.vacina.observacoes,
                                title: 'Observações',
                                icon: Icons.insert_drive_file_outlined),
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
                            ListView(
                              padding: EdgeInsets.zero,
                              primary: false,
                              shrinkWrap: true,
                              scrollDirection: Axis.vertical,
                              children: [
                                VacinaInfo(
                                    widget: widget.vacina.nomeVet,
                                    title: 'Nome',
                                    icon: Icons.person),
                                VacinaInfo(
                                    widget: widget.vacina.crmv,
                                    title: 'CRMV',
                                    icon: Icons.edit_document),
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
                                VacinaInfo(
                                    widget: widget.vacina.cnpj,
                                    title: 'CNPJ',
                                    icon: Icons.document_scanner),
                                VacinaInfo(
                                    widget: widget.vacina.clinica,
                                    title: 'Clínica',
                                    icon: Icons.store),
                                VacinaInfo(
                                    widget: widget.vacina.rua,
                                    title: 'Rua',
                                    icon: Icons.location_on_outlined),
                                VacinaInfo(
                                    widget: widget.vacina.bairro,
                                    title: 'Bairro',
                                    icon: Icons.location_on_outlined),
                                VacinaInfo(
                                    widget: widget.vacina.numero,
                                    title: 'Número',
                                    icon: Icons.location_on_outlined),
                                VacinaInfo(
                                    widget: widget.vacina.cidade,
                                    title: 'Cidade',
                                    icon: Icons.location_city),
                              ],
                            ),
                          ],
                        ),
                      ),
                      if (widget.vacina.isValidadoVet == 'true' &&
                          widget.vacina.isValidadoTutor == 'false')
                        Padding(
                          padding: const EdgeInsets.fromLTRB(0, 12, 0, 24),
                          child: Titles(
                            title: 'Valide essa Vacina',
                            fontSize: 24,
                            paddingL: 24,
                            cor: const Color(0xFF041A23),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      if (widget.vacina.isValidadoVet == 'true' &&
                          widget.vacina.isValidadoTutor == 'false')
                        Padding(
                          padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
                          child: SubTitle(
                            subtitle: '',
                            fontSize: 1,
                            isObservacoes: true,
                            titleObservacoes: 'Orientações:',
                            textObservacoes:
                                'Seu veterinário ja validou a aplicação dessa vacina, para finalizar o processo clique em validar para poder emiti-la no Certificado de vacinação do seu Pet.',
                            padding: 0,
                          ),
                        ),
                      if (widget.vacina.isValidadoVet == 'true' &&
                          widget.vacina.isValidadoTutor == 'false')
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 24.0, right: 24.0, bottom: 42, top: 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              SizedBox(
                                height: 40,
                                width: 120,
                                child: ElevatedButton(
                                  onPressed: (() {}),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFFED7D7),
                                    elevation: 4,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(17),
                                    ),
                                  ),
                                  child: const Text(
                                    'Recusar',
                                    style: TextStyle(
                                        color: Color(0xFFBE5050), fontSize: 18),
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 40,
                                width: 120,
                                child: ElevatedButton(
                                  onPressed: (() {
                                    ValidacaoController().validadeVacTutor(
                                        widget.petId, widget.vacina.id);
                                  }),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFD5F3C2),
                                    elevation: 4,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(17),
                                    ),
                                  ),
                                  child: const Text(
                                    'Validar',
                                    style: TextStyle(
                                        color: Color(0xFF5A9F31), fontSize: 18),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      if (widget.vacina.isValidadoVet == 'false' ||
                          widget.vacina.isValidadoTutor == 'true')
                        const SizedBox(
                          height: 1,
                        )
                    ],
                  ),
                ))));
  }
}

class VacinaInfo extends StatelessWidget {
  String title;
  IconData? icon;
  VacinaInfo({super.key, required this.widget, required this.title, this.icon});

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
