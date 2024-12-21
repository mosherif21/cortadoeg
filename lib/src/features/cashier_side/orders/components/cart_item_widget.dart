import 'package:auto_size_text/auto_size_text.dart';
import 'package:expansion_tile_group/expansion_tile_group.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';

import '../../../../constants/assets_strings.dart';
import 'models.dart';

class CartItemWidget extends StatelessWidget {
  CartItemWidget({
    super.key,
    required this.orderItemModel,
    required this.onEditTap,
    required this.onDeleteTap,
    required this.onDismissed,
  });

  final GlobalKey key1 = GlobalKey();

  final OrderItemModel orderItemModel;
  final Function onEditTap;
  final Function onDeleteTap;
  final Function onDismissed;
  final RxBool extended = false.obs;
  final GlobalKey<ExpansionTileCoreState> key0 = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: ExpansionTileCard(
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
          useTextDirection: false,
          key: key1,
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
          child: buildItem(context),
        ),
        children: [_buildChildren(context)],
      ),
    );
  }

  Widget buildItem(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        const SizedBox(width: 5),
        ClipRRect(
          borderRadius: const BorderRadius.all(Radius.circular(10)),
          child: Image.asset(
            orderItemModel.itemImageUrl ?? kLogoImage,
            height: 70,
            width: 70,
            fit: BoxFit.contain,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: SizedBox(
            height: 75,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AutoSizeText(
                  orderItemModel.name,
                  maxLines: 2,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  '${orderItemModel.quantity}x',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black54,
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'itemDetails'.tr,
                      style: const TextStyle(
                        fontSize: 14,
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
                    Text(
                      '\$${(orderItemModel.price * orderItemModel.quantity).toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: Colors.green,
                      ),
                    ),
                  ],
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
