import 'package:auto_size_text/auto_size_text.dart';
import 'package:cortadoeg/src/features/cashier_side/tables/components/table_selection_widget.dart';
import 'package:cortadoeg/src/general/common_widgets/widget_elevated_button.dart';
import 'package:cortadoeg/src/general/general_functions.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../general/common_widgets/coffee_cup_add_icon.dart';

class NewOrderTablesSelect extends StatefulWidget {
  const NewOrderTablesSelect({
    super.key,
    required this.tablesNo,
    required this.onNewOrderTap,
  });
  final RxList<int> tablesNo;
  final Function onNewOrderTap;

  @override
  NewOrderTablesSelectState createState() => NewOrderTablesSelectState();
}

class NewOrderTablesSelectState extends State<NewOrderTablesSelect>
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

    // Start the entrance animation
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void dismissWidget() async {
    // Trigger the exit animation
    await _controller.reverse();
    // Hide the widget after the animation completes
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
            left: 50,
            right: 50,
            child: SlideTransition(
              position: _offsetAnimation,
              child: Container(
                width: screenWidth * 0.9,
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
                          'ordersNoNew'.tr,
                          style: const TextStyle(
                            color: Colors.black54,
                            fontWeight: FontWeight.w800,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: StretchingOverscrollIndicator(
                        axisDirection: isLangEnglish()
                            ? AxisDirection.right
                            : AxisDirection.left,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              for (int tableNo in widget.tablesNo)
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                      vertical:
                                          widget.tablesNo.length > 5 ? 8 : 0),
                                  child: GestureDetector(
                                    onTap: () =>
                                        widget.tablesNo.remove(tableNo),
                                    child:
                                        TableSelectionWidget(tableNo: tableNo),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    WidgetElevatedButton(
                      onClick: () => widget.onNewOrderTap(),
                      widget: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Row(
                          children: [
                            const CoffeeCupAddIcon(
                              size: 40,
                              addSize: 8,
                            ),
                            const SizedBox(width: 5),
                            AutoSizeText(
                              'placeOrder'.tr,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
        : const SizedBox.shrink(); // Empty widget when hidden
  }
}
