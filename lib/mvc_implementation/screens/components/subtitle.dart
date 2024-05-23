import 'package:flutter/material.dart';

class SubTitle extends StatelessWidget {
  final String subtitle;
  final double fontSize;
  bool isObservacoes = false;
  String? titleObservacoes;
  String? textObservacoes;
  double? padding;

  SubTitle(
      {Key? key,
      required this.subtitle,
      required this.fontSize,
      this.isObservacoes = false,
      this.titleObservacoes,
      this.textObservacoes,
      this.padding})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: padding ?? 30.0),
      child: isObservacoes
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titleObservacoes!,
                  style: const TextStyle(
                      fontSize: 16,
                      fontFamily: 'Outfit',
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF041A23)),
                ),
                Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(0, 8, 0, 16),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          textObservacoes!,
                          textAlign: TextAlign.start,
                          style: TextStyle(
                              fontSize: 14,
                              fontFamily: 'Readex Pro',
                              fontWeight: FontWeight.w500,
                              color: Color(0XFF2A3C44)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            )
          : Text(
              subtitle,
              textAlign: TextAlign.start,
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF2A3C44),
              ),
            ),
    );
  }
}
