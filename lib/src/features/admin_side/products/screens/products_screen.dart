import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../general/general_functions.dart';
import '../../admin_main_screen/components/main_appbar.dart';

class ProductsScreen extends StatelessWidget {
  const ProductsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = getScreenHeight(context);
    final screenWidth = getScreenWidth(context);
    final screenType = GetScreenType(context);
    return Scaffold(
      appBar: screenType.isPhone
          ? null
          : AppBar(
              elevation: 0,
              title: MainScreenAppbar(
                isPhone: screenType.isPhone,
                appBarTitle: 'products'.tr,
              ),
              backgroundColor: Colors.white,
              foregroundColor: Colors.white,
              surfaceTintColor: Colors.white,
            ),
      backgroundColor: Colors.white,
      body: const SafeArea(
        child: StretchingOverscrollIndicator(
          axisDirection: AxisDirection.down,
          child: SingleChildScrollView(
            child: Column(
              children: [Text('')],
            ),
          ),
        ),
      ),
    );
  }
}
