import 'package:cortadoeg/src/connectivity/connectivity.dart';
import 'package:cortadoeg/src/features/admin_side/admin_main_screen/controllers/admin_main_screen_controller.dart';
import 'package:cortadoeg/src/features/admin_side/custody_shifts/screens/custody_shifts_screen.dart';
import 'package:cortadoeg/src/features/admin_side/inventory/screens/inventory_screen.dart';
import 'package:cortadoeg/src/features/admin_side/passcodes/screens/passcodes_screen.dart';
import 'package:cortadoeg/src/features/admin_side/sales/screens/sales_screen.dart';
import 'package:cortadoeg/src/general/general_functions.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../authentication/authentication_repository.dart';
import '../../../../authentication/models.dart';
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
                    return hasPermission(
                            AuthenticationRepository.instance.employeeInfo!,
                            UserPermission.viewSalesReports)
                        ? const SalesScreen()
                        : const SizedBox.shrink();
                  case 1:
                    return hasPermission(
                            AuthenticationRepository.instance.employeeInfo!,
                            UserPermission.viewCustodyReports)
                        ? const CustodyShiftsScreen()
                        : const SizedBox.shrink();
                  case 2:
                    return hasPermission(
                            AuthenticationRepository.instance.employeeInfo!,
                            UserPermission.manageTablesAvailability)
                        ? const ManageTablesScreen()
                        : const SizedBox.shrink();
                  case 3:
                    return hasPermission(
                            AuthenticationRepository.instance.employeeInfo!,
                            UserPermission.manageItems)
                        ? const MeniItemsScreen()
                        : const SizedBox.shrink();
                  case 4:
                    return hasPermission(
                            AuthenticationRepository.instance.employeeInfo!,
                            UserPermission.manageItems)
                        ? const CategoriesScreen()
                        : const SizedBox.shrink();
                  case 5:
                    return hasPermission(
                            AuthenticationRepository.instance.employeeInfo!,
                            UserPermission.manageInventory)
                        ? const InventoryScreen()
                        : const SizedBox.shrink();
                  case 6:
                    return hasPermission(
                            AuthenticationRepository.instance.employeeInfo!,
                            UserPermission.manageCustomers)
                        ? const AdminCustomersScreen()
                        : const SizedBox.shrink();
                  case 7:
                    return hasPermission(
                            AuthenticationRepository.instance.employeeInfo!,
                            UserPermission.manageEmployees)
                        ? const EmployeesScreen()
                        : const SizedBox.shrink();
                  case 8:
                    return hasPermission(
                            AuthenticationRepository.instance.employeeInfo!,
                            UserPermission.managePasscodes)
                        ? const PasscodesScreen()
                        : const SizedBox.shrink();
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
