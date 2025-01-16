import 'package:cortadoeg/src/connectivity/connectivity_controller.dart';
import 'package:cortadoeg/src/general/app_init.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'localization/language/localization_strings.dart';

void main() async {
  await AppInit.initialize().whenComplete(
    () => runApp(const MyApp()),
  );
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
      theme: ThemeData(
        textSelectionTheme: TextSelectionThemeData(
          selectionColor: Colors.grey.shade300,
          selectionHandleColor: Colors.black,
        ),
      ),
      locale: AppInit.setLocale,
      fallbackLocale: const Locale('en', 'US'),
      home: const OrientationLockScreen(),
    );
  }
}

class OrientationLockScreen extends StatefulWidget {
  const OrientationLockScreen({super.key});

  @override
  State<OrientationLockScreen> createState() => _OrientationLockScreenState();
}

class _OrientationLockScreenState extends State<OrientationLockScreen> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final isPhone = MediaQuery.of(context).size.shortestSide < 600;
    if (isPhone) {
      SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    } else {
      SystemChrome.setPreferredOrientations(
          [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
    }
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
