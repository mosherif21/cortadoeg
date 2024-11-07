import 'package:cortadoeg/src/connectivity/connectivity.dart';
import 'package:cortadoeg/src/features/cashier_side/main_screen/controllers/main_screen_controller.dart';
import 'package:cortadoeg/src/general/general_functions.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hawk_fab_menu/hawk_fab_menu.dart';

import '../../../../constants/colors.dart';
import '../../../../general/common_widgets/coffee_cup_add_icon.dart';
import '../../account/screens/account_screen.dart';
import '../../home_screen/screens/home_screen.dart';
import '../../orders/screens/orders_screen.dart';
import '../../reports/screens/reports_screen.dart';
import '../../settings/screens/settings_screen.dart';
import '../../tables/screens/tables_screen.dart';
import '../components/navigation_bar.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final mainController = Get.put(MainScreenController());
    final screenType = GetScreenType(context);
    ConnectivityChecker.checkConnection(displayAlert: true);
    return Scaffold(
      backgroundColor: Colors.white,
      key: mainController.homeScaffoldKey,
      appBar: screenType.isPhone
          ? AppBar(
              backgroundColor: canvasColor,
              leading: IconButton(
                onPressed: mainController.onDrawerOpen,
                icon: const Icon(
                  Icons.menu,
                  color: Colors.white,
                ),
              ),
            )
          : null,
      drawer: SideNavigationBar(
        controller: mainController.barController,
        isLangEnglish: isLangEnglish(),
      ),
      body: HawkFabMenu(
        isEnglish: isLangEnglish(),
        openIcon: const Padding(
          padding: EdgeInsets.all(8),
          child: CoffeeCupAddIcon(size: 50),
        ),
        closeIcon: const Padding(
          padding: EdgeInsets.all(10),
          child: Icon(
            Icons.close,
            color: Colors.white,
            size: 35,
          ),
        ),
        fabColor: Colors.black,
        iconColor: Colors.white,
        items: [
          HawkFabMenuItem(
            label: 'dineInOrder'.tr,
            ontap: () {
              displayChangeLang();
            },
            icon: const Icon(
              Icons.local_cafe,
              color: Colors.white,
              size: 35,
            ),
            color: Colors.black,
            labelColor: Colors.white,
            labelBackgroundColor: Colors.black,
            labelFontSize: 20,
          ),
          HawkFabMenuItem(
            label: 'takeawayOrder'.tr,
            ontap: () {},
            icon: const Icon(
              Icons.delivery_dining_rounded,
              color: Colors.white,
              size: 35,
            ),
            color: Colors.black,
            labelColor: Colors.white,
            labelBackgroundColor: Colors.black,
            labelFontSize: 20,
          ),
        ],
        body: Row(
          children: [
            if (!screenType.isPhone)
              SideNavigationBar(
                controller: mainController.barController,
                isLangEnglish: isLangEnglish(),
              ),
            Expanded(
              child: PageView.builder(
                pageSnapping: false,
                scrollDirection:
                    screenType.isPhone ? Axis.horizontal : Axis.vertical,
                physics: const NeverScrollableScrollPhysics(),
                controller: mainController.pageController,
                itemCount: 6,
                itemBuilder: (BuildContext context, int index) {
                  switch (index) {
                    case 0:
                      return const HomeScreen();
                    case 1:
                      return const TablesScreen();
                    case 2:
                      return const OrdersScreen();
                    case 3:
                      return const ReportsScreen();
                    case 4:
                      return const AccountScreen();
                    case 5:
                      return const SettingsScreen();
                    default:
                      return const HomeScreen();
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
