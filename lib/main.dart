import 'package:cortadoeg/src/connectivity/connectivity_controller.dart';
import 'package:cortadoeg/src/general/app_init.dart';
import 'package:cortadoeg/src/general/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'localization/language/localization_strings.dart';

void main() async {
  await AppInit.initialize().whenComplete(() {
    runApp(const MyApp());
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(ConnectivityController());
    return GetMaterialApp(
      title: 'Cortado Business',
      debugShowCheckedModeBanner: false,
      builder: (context, child) {
        return ScrollConfiguration(
          behavior: NonScrollPhysics(),
          child: child!,
        );
      },
      translations: Languages(),
      theme: AppTheme.lightTheme,
      locale: AppInit.setLocale,
      fallbackLocale: const Locale('en', 'US'),
      home: const OrientationHandler(),
    );
  }
}

class OrientationHandler extends StatelessWidget {
  const OrientationHandler({super.key});

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.shortestSide;

    if (screenWidth >= 600) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    } else {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
    }

    return AppInit.getInitialPage();
  }
}

class NonScrollPhysics extends ScrollBehavior {
  @override
  Widget buildOverscrollIndicator(
      BuildContext context, Widget child, ScrollableDetails details) {
    return child;
  }
}
