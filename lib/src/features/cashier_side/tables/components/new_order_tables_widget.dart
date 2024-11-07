import 'package:cortadoeg/src/features/cashier_side/tables/components/table_selection_widget.dart';
import 'package:cortadoeg/src/general/general_functions.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NewOrderTablesWidget extends StatefulWidget {
  const NewOrderTablesWidget({
    super.key,
    required this.tablesNo,
    required this.onNewOrderTap,
  });
  final RxList<int> tablesNo;
  final Function onNewOrderTap;

  @override
  NewOrderTablesWidgetState createState() => NewOrderTablesWidgetState();
}

class NewOrderTablesWidgetState extends State<NewOrderTablesWidget>
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
    final isEnglish = isLangEnglish();

    // Render the widget conditionally based on `_isVisible`
    return _isVisible
        ? Positioned(
            bottom: 20,
            left: isEnglish ? 50 : 120,
            right: isEnglish ? 120 : 50,
            child: SlideTransition(
              position: _offsetAnimation,
              child: Container(
                width: screenWidth * 0.7,
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
                    SingleChildScrollView(
                      child: Row(
                        children: [
                          for (int table in widget.tablesNo)
                            GestureDetector(
                              onTap: () => widget.tablesNo.remove(table),
                              child: TableSelectionWidget(tableNo: table),
                            ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          )
        : const SizedBox.shrink(); // Empty widget when hidden
  }
}
