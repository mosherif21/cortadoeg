import 'package:cortadoeg/src/connectivity/connectivity.dart';
import 'package:cortadoeg/src/features/admin_side/admin_main_screen/controllers/admin_main_screen_controller.dart';
import 'package:cortadoeg/src/features/admin_side/custody_shifts/screens/custody_shifts_screen.dart';
import 'package:cortadoeg/src/features/admin_side/inventory/screens/inventory_screen.dart';
import 'package:cortadoeg/src/features/admin_side/passcodes/screens/passcodes_screen.dart';
import 'package:cortadoeg/src/features/admin_side/reports/screens/reports_screen.dart';
import 'package:cortadoeg/src/general/general_functions.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../account/screens/account_screen.dart';
import '../../categories/screens/categories_screen.dart';
import '../../customers/screens/customers_screen.dart';
import '../../employees/screens/employees_screen.dart';
import '../../menu_items/screens/meni_items_screen.dart';
import '../../tables/screens/manage_tables_screen.dart';
import '../components/main_appbar.dart';
import '../components/navigation_bar.dart';

class AdminMainScreen extends StatelessWidget {
  const AdminMainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final mainController = Get.put(AdminMainScreenController());
    final screenType = GetScreenType(context);
    ConnectivityChecker.checkConnection(displayAlert: true);
    return Scaffold(
      backgroundColor: Colors.white,
      key: mainController.homeScaffoldKey,
      appBar: screenType.isPhone
          ? AppBar(
              surfaceTintColor: Colors.white,
              shadowColor: Colors.white,
              foregroundColor: Colors.white,
              backgroundColor: Colors.white,
              leading: IconButton(
                onPressed: mainController.onDrawerOpen,
                icon: const Icon(
                  Icons.menu_outlined,
                  color: Colors.black,
                  size: 30,
                ),
              ),
              title: Obx(
                () => MainScreenAppbar(
                  appBarTitle: mainController
                      .getPageTitle(mainController.navBarIndex.value),
                  isPhone: screenType.isPhone,
                ),
              ),
              centerTitle: true,
            )
          : null,
      drawer: Container(
        color: Colors.black,
        child: SafeArea(
          child: AdminSideNavigationBar(
            controller: mainController.barController,
            isLangEnglish: isLangEnglish(),
            isPhone: screenType.isPhone,
          ),
        ),
      ),
      body: Row(
        children: [
          if (!screenType.isPhone)
            AdminSideNavigationBar(
              controller: mainController.barController,
              isLangEnglish: isLangEnglish(),
              isPhone: screenType.isPhone,
            ),
          Expanded(
            child: PageView.builder(
              pageSnapping: false,
              scrollDirection:
                  screenType.isPhone ? Axis.horizontal : Axis.vertical,
              physics: const NeverScrollableScrollPhysics(),
              controller: mainController.pageController,
              itemCount: 11,
              itemBuilder: (BuildContext context, int index) {
                switch (index) {
                  case 0:
                    return const ReportsScreen();
                  case 1:
                    return const CustodyShiftsScreen();
                  case 2:
                    return const ManageTablesScreen();
                  case 3:
                    return const MeniItemsScreen();
                  case 4:
                    return const CategoriesScreen();
                  case 5:
                    return const InventoryScreen();
                  case 6:
                    return const AdminCustomersScreen();
                  case 7:
                    return const EmployeesScreen();
                  case 8:
                    return const PasscodesScreen();
                  case 9:
                    return const AdminAccountScreen();
                  default:
                    return const SizedBox.shrink();
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
