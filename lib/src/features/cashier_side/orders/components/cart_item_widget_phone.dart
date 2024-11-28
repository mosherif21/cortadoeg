import 'package:auto_size_text/auto_size_text.dart';
import 'package:expansion_tile_group/expansion_tile_group.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';

import '../../../../constants/assets_strings.dart';
import 'models.dart';

class CartItemWidgetPhone extends StatelessWidget {
  CartItemWidgetPhone({
    super.key,
    required this.orderItemModel,
    required this.onEditTap,
    required this.onDeleteTap,
    required this.onDismissed,
    required this.index,
  });

  final int index;
  final OrderItemModel orderItemModel;
  final Function onEditTap;
  final Function onDeleteTap;
  final Function onDismissed;
  final RxBool extended = false.obs;
  final GlobalKey<ExpansionTileCoreState> key0 = GlobalKey();
  final GlobalKey key1 = GlobalKey();
  @override
  Widget build(BuildContext context) {
    return ExpansionTileCard(
      onExpansionChanged: (extendStatus) {
        extended.value = extendStatus;
      },
      backgroundColor: Colors.white,
      collapsedBackgroundColor: Colors.white,
      expansionKey: key0,
      elevation: 0,
      tilePadding: const EdgeInsets.all(0),
      isHasTrailing: false,
      childrenPadding: EdgeInsets.zero,
      initiallyExpanded: false,
      isHideSubtitleOnExpanded: true,
      title: Slidable(
        key: key1,
        endActionPane: ActionPane(
          motion: const DrawerMotion(),
          dismissible: DismissiblePane(onDismissed: () => onDismissed()),
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
        child: buildItem(context),
      ),
      children: [_buildChildren(context)],
    );
  }

  Widget buildItem(BuildContext context) {
    return Row(
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
        Text(
          'x${orderItemModel.quantity}',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black38,
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
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          'itemDetails'.tr,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: Colors.grey,
                          ),
                        ),
                        Obx(
                          () => Icon(
                            extended.value
                                ? Icons.keyboard_arrow_up_rounded
                                : Icons.keyboard_arrow_down_rounded,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Text(
                  '\$${(orderItemModel.price * orderItemModel.quantity).toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 22,
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
    );
  }

  Widget _buildChildren(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${orderItemModel.size} - \$${orderItemModel.price.toStringAsFixed(2)}',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: Colors.grey,
          ),
        ),
        orderItemModel.options.isEmpty
            ? const SizedBox.shrink()
            : Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: orderItemModel.options.entries.map((option) {
                  return Text(
                    '${option.key[0].toUpperCase() + option.key.substring(1)} - ${option.value[0].toUpperCase() + option.value.substring(1)} ',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Colors.grey,
                    ),
                  );
                }).toList(),
              ),
        Text(
          'sugarItemReveal'.trParams({'sugarLevel': orderItemModel.sugarLevel}),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: Colors.grey,
          ),
        ),
        if (orderItemModel.note.isNotEmpty)
          AutoSizeText(
            '${'note'.tr}: ${orderItemModel.note}',
            maxLines: 4,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: Colors.grey,
            ),
          ),
      ],
    );
  }
}
