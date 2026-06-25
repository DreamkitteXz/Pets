// Flutter 3.24+ passou a exportar CarouselController em material, colidindo com
// o do carousel_slider (usado aqui). Ocultamos o do material.
import 'package:flutter/material.dart' hide CarouselController;
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pet_app/models/onboarding_info.dart';
import 'package:pet_app/screens/components/logo.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:pet_app/screens/auth/login_screen.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class OnBoarding extends StatefulWidget {
  const OnBoarding({super.key});

  @override
  State<OnBoarding> createState() => _OnBoardingState();
}

class _OnBoardingState extends State<OnBoarding> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Column(
          children: [
            // LOGO NO TOPO
            const Padding(
              padding: EdgeInsets.only(bottom: 16.0, left: 8.0, top: 8.0),
              child: Row(children: [Logo()]),
            ),

            // CARROSSEL EXPANDIDO PARA OCUPAR O ESPAÇO DISPONÍVEL
            Expanded(
              child: OnboardingCarousel(slides: slides),
            ),

            // BOTÃO FIXADO NA PARTE INFERIOR
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginPage(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(27.0),
                    ),
                    backgroundColor: const Color(0xFF041A23),
                  ),
                  child: const Text(
                    'Começar',
                    style: TextStyle(fontSize: 18.0),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class OnboardingCarousel extends StatefulWidget {
  final List<SlideInfo> slides;

  const OnboardingCarousel({required this.slides, super.key});

  @override
  State<OnboardingCarousel> createState() => _OnboardingCarouselState();
}

class _OnboardingCarouselState extends State<OnboardingCarousel> {
  int activeIndex = 0;
  final CarouselController controller = CarouselController();
  final List<Color> dotsColors = [
    const Color(0xFFF29301),
    const Color(0xFF4A406E),
    const Color(0xFF041A23)
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // CARROSSEL COM TAMANHO AJUSTADO PARA EVITAR OVERFLOW
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.5,
          child: CarouselSlider(
            carouselController: controller,
            options: CarouselOptions(
              height: double.infinity,
              viewportFraction: 1.0,
              enableInfiniteScroll: false,
              onPageChanged: (index, reason) {
                setState(() => activeIndex = index);
              },
            ),
            items: widget.slides.map((slide) {
              return Container(
                width: MediaQuery.of(context).size.width,
                margin: const EdgeInsets.symmetric(horizontal: 5.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SvgPicture.asset(
                      slide.imageUrl,
                      height: 220,
                    ),
                    const SizedBox(height: 40.0),
                    Text(
                      slide.title,
                      style: const TextStyle(
                        fontSize: 24.0,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF062D3E),
                      ),
                    ),
                    const SizedBox(height: 20.0),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text(
                        slide.description,
                        style: const TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF1F4251),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 24),

        // INDICADOR DE PAGINAÇÃO
        AnimatedSmoothIndicator(
          activeIndex: activeIndex,
          count: widget.slides.length,
          effect: SwapEffect(
            activeDotColor: dotsColors[activeIndex],
            dotColor: Colors.black38,
          ),
        ),
      ],
    );
  }
}
