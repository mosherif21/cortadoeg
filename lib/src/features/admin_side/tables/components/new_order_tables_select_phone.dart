import 'package:cortadoeg/src/constants/enums.dart';
import 'package:cortadoeg/src/features/cashier_side/tables/components/models.dart';
import 'package:cortadoeg/src/general/general_functions.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../general/common_widgets/icon_text_elevated_button.dart';

class ManageTablesSelectPhone extends StatefulWidget {
  const ManageTablesSelectPhone({
    super.key,
    required this.tableNo,
    required this.tableModel,
    required this.onSetUnavailableTap,
    required this.onSetAvailableTap,
  });
  final Rxn<int> tableNo;
  final Rxn<TableModel> tableModel;
  final VoidCallback onSetUnavailableTap;
  final VoidCallback onSetAvailableTap;

  @override
  NewOrderTablesSelectPhoneState createState() =>
      NewOrderTablesSelectPhoneState();
}

class NewOrderTablesSelectPhoneState extends State<ManageTablesSelectPhone>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;
  bool _isVisible = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void dismissWidget() async {
    await _controller.reverse();
    setState(() {
      _isVisible = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = getScreenWidth(context);
    return _isVisible
        ? Positioned(
            bottom: 20,
            left: 10,
            right: 10,
            child: SlideTransition(
              position: _offsetAnimation,
              child: Container(
                width: screenWidth,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.shade300,
                      blurRadius: 5.0,
                    )
                  ],
                  color: Colors.white,
                  borderRadius: const BorderRadius.all(
                    Radius.circular(30),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: const BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.all(
                          Radius.circular(25),
                        ),
                      ),
                      child: const Icon(
                        Icons.table_bar,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'table'.tr,
                          style: const TextStyle(
                            color: Colors.black87,
                            fontWeight: FontWeight.w800,
                            fontSize: 15,
                          ),
                        ),
                        Text(
                          widget.tableModel.value!.status ==
                                  TableStatus.available
                              ? 'available'.tr
                              : 'unavailable'.tr,
                          style: const TextStyle(
                            color: Colors.black54,
                            fontWeight: FontWeight.w800,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.grey, // Grey border color
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          'tableNumber'.trParams({
                            'number': (widget.tableNo.value ?? 0).toString(),
                          }),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Obx(
                        () => widget.tableModel.value!.status ==
                                TableStatus.available
                            ? SizedBox(
                                height: 50,
                                child: IconTextElevatedButton(
                                  buttonColor: Colors.black,
                                  textColor: Colors.white,
                                  borderRadius: 25,
                                  fontSize: 18,
                                  iconSize: 24,
                                  elevation: 0,
                                  icon: Icons.event_busy_rounded,
                                  iconColor: Colors.white,
                                  enabled: true,
                                  text: 'unavailable'.tr,
                                  onClick: widget.onSetUnavailableTap,
                                ),
                              )
                            : SizedBox(
                                height: 50,
                                child: IconTextElevatedButton(
                                  buttonColor: Colors.green,
                                  textColor: Colors.white,
                                  borderRadius: 25,
                                  fontSize: 18,
                                  iconSize: 24,
                                  elevation: 0,
                                  icon: Icons.event_available_rounded,
                                  iconColor: Colors.white,
                                  enabled: true,
                                  text: 'available'.tr,
                                  onClick: widget.onSetAvailableTap,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
        : const SizedBox.shrink();
  }
}
