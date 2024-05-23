import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pet_app/mvc_implementation/models/onboarding_info.dart';
import 'package:pet_app/mvc_implementation/screens/components/logo.dart';
import 'package:carousel_slider/carousel_slider.dart';
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
          //mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Logo(),
            OnboardingCarrousel(slides: slides),
          ],
        ),
      ),
    );
  }
}

class OnboardingCarrousel extends StatefulWidget {
  final List<SlideInfo> slides;

  OnboardingCarrousel({
    required this.slides,
    super.key,
  });

  @override
  State<OnboardingCarrousel> createState() => _OnboardingCarrouselState();
}

class _OnboardingCarrouselState extends State<OnboardingCarrousel> {
  int activeIndex = 0;
  List<Color> dotsColors = [
    Color(0xFFF29301),
    Color(0xFF4A406E),
    Color(0xFF041A23)
  ];
  final controller = CarouselController();

  @override
  Widget build(BuildContext context) {
    return CarouselSlider(
      carouselController: controller,
      options: CarouselOptions(
        height: 500.0,
        onPageChanged: (index, reason) => setState(() => activeIndex = index),
      ),
      items: widget.slides.map((slide) {
        return Column(
          children: [
            Builder(
              builder: (BuildContext context) {
                return Container(
                  width: MediaQuery.of(context).size.width,
                  margin: EdgeInsets.symmetric(horizontal: 5.0),
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
                            // fontFamily: 'Inter',
                            color: Color(0xFF062D3E)),
                      ),
                      const SizedBox(height: 30.0),
                      Text(
                        slide.description,
                        style: const TextStyle(
                            fontSize: 20.0,
                            fontWeight: FontWeight.w400,
                            //fontFamily: 'Inter',
                            color: Color(0xFF1F4251)),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 32),
            dotIndicator(3),
            //const SizedBox(height: 32),
          ],
        );
      }).toList(),
    );
  }

  Widget dotIndicator(int dots) => AnimatedSmoothIndicator(
        activeIndex: activeIndex,
        count: dots,
        effect: SwapEffect(
            activeDotColor: dotsColors[activeIndex], dotColor: Colors.black38),
      );
}
