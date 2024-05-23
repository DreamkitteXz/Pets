import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class Logo extends StatelessWidget {
  const Logo({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(left: 30.0, top: 40.0),
      child: SvgPicture.asset(
        'assets/app/pets_logo.svg',
        color: Colors.black,
        width: 58.0, // Defina a largura desejada
        height: 58.0, // Defina a altura desejada
      ),
    );
  }
}
