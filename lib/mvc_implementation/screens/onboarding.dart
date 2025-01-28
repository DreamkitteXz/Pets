import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pet_app/mvc_implementation/models/onboarding_info.dart';
import 'package:pet_app/mvc_implementation/screens/components/logo.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:pet_app/mvc_implementation/screens/login.dart';
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
            const Row(
              children: [
                Padding(
                  padding: EdgeInsets.only(bottom: 16.0, left: 8.0, top: 8.0),
                  child: Logo(),
                ),
              ],
            ),
            Expanded(
              child: Center(
                child: OnboardingCarrousel(slides: slides),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
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
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(27.0),
                    ),
                    backgroundColor: const Color(0xFF041A23)),
                child: const Text('Começar', style: TextStyle(fontSize: 18.0)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class OnboardingCarrousel extends StatefulWidget {
  final List<SlideInfo> slides;

  const OnboardingCarrousel({
    required this.slides,
    super.key,
  });

  @override
  State<OnboardingCarrousel> createState() => _OnboardingCarrouselState();
}

class _OnboardingCarrouselState extends State<OnboardingCarrousel> {
  int activeIndex = 0;
  List<Color> dotsColors = [
    const Color(0xFFF29301),
    const Color(0xFF4A406E),
    const Color(0xFF041A23)
  ];
  final controller = CarouselController();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CarouselSlider(
          carouselController: controller,
          options: CarouselOptions(
            height: MediaQuery.of(context).size.height * 0.6,
            viewportFraction: 1.0,
            enableInfiniteScroll: false,
            onPageChanged: (index, reason) =>
                setState(() => activeIndex = index),
          ),
          items: widget.slides.map((slide) {
            return Builder(
              builder: (BuildContext context) {
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
                        height: 250,
                      ),
                      const SizedBox(height: 60.0),
                      Text(
                        slide.title,
                        style: const TextStyle(
                          fontSize: 26.0,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF062D3E),
                        ),
                      ),
                      const SizedBox(height: 30.0),
                      Padding(
                        padding: const EdgeInsets.only(right: 16.0, left: 16.0),
                        child: Text(
                          slide.description,
                          style: const TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.w400,
                            color: Color(0xFF1F4251),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          }).toList(),
        ),
        const SizedBox(height: 32),
        dotIndicator(widget.slides.length),
      ],
    );
  }

  Widget dotIndicator(int dots) => AnimatedSmoothIndicator(
        activeIndex: activeIndex,
        count: dots,
        effect: SwapEffect(
          activeDotColor: dotsColors[activeIndex],
          dotColor: Colors.black38,
        ),
      );
}
