import 'package:auto_size_text/auto_size_text.dart';
import 'package:cortadoeg/src/general/general_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:input_quantity/input_quantity.dart';

import '../../../../constants/assets_strings.dart';
import 'models.dart';

class CheckOutItemPhone extends StatelessWidget {
  CheckOutItemPhone({
    super.key,
    required this.orderItemModel,
    required this.onEditTap,
    required this.onDeleteTap,
    required this.onDismissed,
    required this.onQuantityChanged,
    required this.index,
  });

  final int index;
  final OrderItemModel orderItemModel;
  final Function onEditTap;
  final Function onDeleteTap;
  final Function onDismissed;
  final Function onQuantityChanged;
  final GlobalKey key0 = GlobalKey();
  @override
  Widget build(BuildContext context) {
    return Slidable(
      useTextDirection: false,
      key: key0,
      endActionPane: ActionPane(
        motion: const DrawerMotion(),
        dismissible: DismissiblePane(
          onDismissed: () {},
          confirmDismiss: () async {
            return await onDismissed();
          },
        ),
        children: [
          SlidableAction(
            onPressed: (context) => onEditTap(),
            backgroundColor: Colors.lightBlueAccent,
            foregroundColor: Colors.white,
            icon: Icons.edit,
          ),
          SlidableAction(
            onPressed: (context) => onDeleteTap(),
            backgroundColor: Colors.redAccent,
            foregroundColor: Colors.white,
            icon: Icons.delete_outline_outlined,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const SizedBox(width: 10),
                Material(
                  elevation: orderItemModel.itemImageUrl != null ? 5 : 0,
                  color: Colors.transparent,
                  borderRadius: const BorderRadius.all(Radius.circular(50)),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.all(Radius.circular(50)),
                    child: Image.asset(
                      orderItemModel.itemImageUrl ?? kLogoImage,
                      height: 70,
                      width: 70,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: SizedBox(
                    height: 70,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            AutoSizeText(
                              orderItemModel.name,
                              maxLines: 2,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                            Text(
                              orderItemModel.size,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          'EGP ${(orderItemModel.price * orderItemModel.quantity).toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 10),
              ],
            ),
            Align(
              alignment: isLangEnglish()
                  ? Alignment.centerRight
                  : Alignment.centerLeft,
              child: InputQty.int(
                initVal: orderItemModel.quantity,
                minVal: 1,
                decoration: const QtyDecorationProps(
                  isBordered: false,
                  borderShape: BorderShapeBtn.circle,
                  btnColor: Colors.black,
                  width: 10,
                ),
                onQtyChanged: (quantity) => onQuantityChanged(quantity),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
