import 'package:flutter/material.dart';
import 'package:pet_app/mvc_implementation/screens/signup.dart';

class ActionText extends StatelessWidget {
  String text, textAction;
  ActionText({super.key, required this.text, required this.textAction});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          text,
          textAlign: TextAlign.start,
          style: const TextStyle(
              color: Color(0xFF707070),
              fontSize: 14,
              fontWeight: FontWeight.w500),
        ),
        InkWell(
          onTap: (() => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SignUpPage(),
              ))),
          child: Text(
            textAction,
            textAlign: TextAlign.start,
            style: const TextStyle(
                color: Color(0xFF000000),
                fontSize: 14,
                fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
