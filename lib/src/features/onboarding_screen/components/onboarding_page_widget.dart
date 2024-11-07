import 'package:flutter/material.dart';

class OnboardingPageWidget extends StatelessWidget {
  const OnboardingPageWidget(
      {super.key,
      required this.onBoardingTitle,
      required this.onBoardingDescription});
  final String onBoardingTitle;
  final String onBoardingDescription;
  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          const SizedBox(
            height: 480,
          ),
          Text(
            onBoardingTitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 24.0,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          Text(
            onBoardingDescription,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.black26,
              fontSize: 18.0,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
