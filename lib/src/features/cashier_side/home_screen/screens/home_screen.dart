import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../general/general_functions.dart';
import '../../main_screen/components/main_screen_pages_appbar.dart';
import '../components/no_orders_widget.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = getScreenHeight(context);
    final screenWidth = getScreenWidth(context);
    final screenType = GetScreenType(context);
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        title: MainScreenPagesAppbar(
          appBarTitle: 'activeOrders'.tr,
          unreadNotification: true,
        ),
      ),
      backgroundColor: Colors.white,
      body: const SafeArea(
        child: StretchingOverscrollIndicator(
          axisDirection: AxisDirection.down,
          child: SingleChildScrollView(
            child: NoOrdersWidget(),
          ),
        ),
      ),
    );
  }
}
