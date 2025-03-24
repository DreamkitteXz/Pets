import 'package:flutter/material.dart';

class Titles extends StatelessWidget {
  String title;
  double fontSize;
  double paddingL;
  Color? cor;
  FontWeight? fontWeight;
  Titles(
      {super.key,
      required this.title,
      required this.fontSize,
      required this.paddingL,
      this.cor,
      this.fontWeight});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: paddingL),
      child: Text(
        title,
        style: TextStyle(
            fontSize: fontSize,
            fontWeight: fontWeight ?? FontWeight.w700,
            // fontFamily: 'Inter',
            color: cor ?? const Color(0xFF041A23)),
      ),
    );
  }
}
