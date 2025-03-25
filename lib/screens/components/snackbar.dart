import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class CustomSnackBar extends StatefulWidget {
  CustomSnackBar({super.key, this.errorText, this.successfulText});

  String? errorText;
  String? successfulText;

  void showCustomSnackBar(String message, BuildContext context) {
    final snackBar = SnackBar(
      content: CustomSnackBar(errorText: message),
      backgroundColor: Colors.transparent,
      behavior: SnackBarBehavior.floating,
      elevation: 0,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  @override
  State<CustomSnackBar> createState() => _CustomSnackBarState();
}

class _CustomSnackBarState extends State<CustomSnackBar> {
  @override
  Widget build(BuildContext context) {
    if (widget.errorText == null) {
      return SuccessfulSnackBar(widget: widget);
    } else {
      return SnackBarError(widget: widget);
    }
  }
}

class SnackBarError extends StatelessWidget {
  const SnackBarError({
    super.key,
    required this.widget,
  });

  final CustomSnackBar widget;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          height: 90,
          decoration: const BoxDecoration(
            color: Color(0xFFC72C41),
            borderRadius: BorderRadius.all(Radius.circular(20)),
          ),
          child: Row(
            children: [
              const SizedBox(width: 48),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Hmm, algo deu errado!",
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                    const Spacer(),
                    Text(
                      widget.errorText!,
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Positioned(
          bottom: 0,
          child: ClipRRect(
            borderRadius:
                const BorderRadius.only(bottomLeft: Radius.circular(20)),
            child: SvgPicture.asset(
              "lib/screens/assets/bubbles_snack_bar.svg",
              height: 48,
              width: 40,
              color: const Color(0xFF801336),
            ),
          ),
        ),
        Positioned(
          top: -20,
          left: 0,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Stack(alignment: Alignment.center, children: [
              SvgPicture.asset(
                "lib/screens/assets/fail_snack_bar.svg",
                height: 40,
              ),
              Positioned(
                top: 10,
                child: SvgPicture.asset(
                  "lib/screens/assets/close_snack_bar.svg",
                  height: 16,
                ),
              ),
            ]),
          ),
        )
      ],
    );
  }
}

class SuccessfulSnackBar extends StatelessWidget {
  const SuccessfulSnackBar({
    super.key,
    required this.widget,
  });

  final CustomSnackBar widget;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          height: 90,
          decoration: const BoxDecoration(
            color: Color(0xFF38b000),
            borderRadius: BorderRadius.all(Radius.circular(20)),
          ),
          child: Row(
            children: [
              const SizedBox(width: 48),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Perfeito!",
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                    const Spacer(),
                    Text(
                      widget.successfulText!,
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Positioned(
          bottom: 0,
          child: ClipRRect(
            borderRadius:
                const BorderRadius.only(bottomLeft: Radius.circular(20)),
            child: SvgPicture.asset(
              "lib/screens/assets/bubbles_snack_bar.svg",
              height: 48,
              width: 40,
              color: const Color(0xFF008000),
            ),
          ),
        ),
        Positioned(
          top: -20,
          left: 0,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Stack(alignment: Alignment.center, children: [
              SvgPicture.asset(
                "lib/screens/assets/fail_snack_bar.svg",
                color: const Color(0xFF008000),
                height: 40,
              ),
              Positioned(
                top: 10,
                child: SvgPicture.asset(
                  "lib/screens/assets/close_snack_bar.svg",
                  color: const Color(0xFF008000),
                  height: 16,
                ),
              ),
            ]),
          ),
        )
      ],
    );
  }
}
