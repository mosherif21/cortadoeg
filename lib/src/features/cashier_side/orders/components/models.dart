import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cortadoeg/src/features/admin_side/inventory/components/models.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';

import '../../../../constants/enums.dart';

class CategoryModel {
  final String id;
  final String name;
  final String iconName;

  CategoryModel({
    required this.id,
    required this.name,
    required this.iconName,
  });

  factory CategoryModel.fromFirestore(Map<String, dynamic> data, String id) {
    return CategoryModel(
      id: id,
      name: data['name'] ?? '',
      iconName: data['iconName'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'iconName': iconName,
    };
  }
}

class OrderModel {
  final String orderId;
  final String shiftId;
  final Timestamp shiftOpeningTime;
  final bool isTakeaway;
  final bool isTakeawayEmployee;
  final int orderNumber;
  List<int>? tableNumbers;
  List<OrderItemModel> items;
  OrderStatus status;
  final Timestamp timestamp;
  String? discountType;
  double? discountValue;
  String? customerId;
  final String employeeId;
  final String employeeName;
  String? customerName;
  double totalAmount;
  double discountAmount;
  double subtotalAmount;
  double taxTotalAmount;

  OrderModel({
    required this.orderId,
    required this.employeeId,
    required this.employeeName,
    required this.isTakeaway,
    required this.isTakeawayEmployee,
    required this.orderNumber,
    required this.shiftId,
    required this.shiftOpeningTime,
    this.tableNumbers,
    required this.items,
    required this.status,
    required this.timestamp,
    this.discountType,
    this.discountValue,
    this.customerId,
    this.customerName,
    required this.totalAmount,
    required this.discountAmount,
    required this.subtotalAmount,
    required this.taxTotalAmount,
  });

  Map<String, dynamic> toFirestore() {
    return {
      'isTakeaway': isTakeaway,
      'tableNumbers': tableNumbers,
      'orderNumber': orderNumber,
      'shiftId': shiftId,
      'shiftOpeningTime': shiftOpeningTime,
      'employeeId': employeeId,
      'employeeName': employeeName,
      'isTakeawayEmployee': isTakeawayEmployee,
      'items': items.map((item) => item.toFirestore()).toList(),
      'status': status.name,
      'timestamp': timestamp,
      'discountType': discountType,
      'customerId': customerId,
      'customerName': customerName,
      'discountValue': discountValue,
      'subtotalAmount': subtotalAmount,
      'discountAmount': discountAmount,
      'taxTotalAmount': taxTotalAmount,
      'totalAmount': totalAmount,
    };
  }

  factory OrderModel.fromFirestore(Map<String, dynamic> map, String id) {
    return OrderModel(
      orderId: id,
      isTakeaway: map['isTakeaway'],
      isTakeawayEmployee: map['isTakeawayEmployee'],
      tableNumbers: List<int>.from(map['tableNumbers']),
      items: (map['items'] as List)
          .map((itemMap) => OrderItemModel.fromFirestore(itemMap))
          .toList(),
      status: OrderStatus.values.firstWhere((e) => e.name == map['status']),
      timestamp: map['timestamp'],
      discountType: map['discountType'],
      orderNumber: map['orderNumber'],
      shiftId: map['shiftId'],
      shiftOpeningTime: map['shiftOpeningTime'],
      customerId: map['customerId'],
      employeeId: map['employeeId'],
      employeeName: map['employeeName'],
      customerName: map['customerName'],
      discountValue: map['discountValue']?.toDouble(),
      subtotalAmount: map['subtotalAmount'].toDouble(),
      discountAmount: map['discountAmount'].toDouble(),
      taxTotalAmount: map['taxTotalAmount'].toDouble(),
      totalAmount: map['totalAmount'].toDouble(),
    );
  }
}

class OrderItemModel {
  final String orderItemId;
  final String itemId;
  final String? itemImageUrl;
  final String name;
  final String size;
  int quantity;
  final Map<String, String> options;
  final String sugarLevel;
  final String note;
  final double price;
  double costPrice;

  final ItemSizeModel selectedSize;
  final List<OptionValue> selectedOptions;

  OrderItemModel({
    required this.orderItemId,
    required this.itemId,
    required this.name,
    required this.size,
    required this.quantity,
    required this.options,
    required this.sugarLevel,
    required this.note,
    this.itemImageUrl,
    required this.price,
    required this.costPrice,
    required this.selectedSize,
    this.selectedOptions = const [],
  });

  Map<String, dynamic> toFirestore() {
    return {
      'orderItemId': orderItemId,
      'itemId': itemId,
      'itemImageUrl': itemImageUrl,
      'name': name,
      'size': size,
      'quantity': quantity,
      'options': options,
      'sugarLevel': sugarLevel,
      'note': note,
      'price': price,
      'costPrice': costPrice,
      'selectedSize': selectedSize.toFirestore(),
      'selectedOptions':
          selectedOptions.map((option) => option.toFirestore()).toList(),
    };
  }

  factory OrderItemModel.fromFirestore(Map<String, dynamic> map) {
    ItemSizeModel selectedSize =
        ItemSizeModel.fromFirestore(map['selectedSize']);
    List<OptionValue> selectedOptions = map['selectedOptions'] != null
        ? (map['selectedOptions'] as List<dynamic>)
            .map((option) =>
                OptionValue.fromFirestore(option as Map<String, dynamic>))
            .toList()
        : [];

    return OrderItemModel(
      orderItemId: map['orderItemId'],
      itemId: map['itemId'],
      itemImageUrl: map['itemImageUrl'],
      name: map['name'],
      size: map['size'],
      quantity: map['quantity'],
      options: Map<String, String>.from(map['options'] ?? {}),
      sugarLevel: map['sugarLevel'],
      note: map['note'],
      price: map['price'].toDouble(),
      costPrice: map['costPrice'].toDouble(),
      selectedSize: selectedSize,
      selectedOptions: selectedOptions,
    );
  }
}

class CustomerModel {
  String customerId;
  final String name;
  final String number;
  final String discountType;
  final double discountValue;

  CustomerModel({
    required this.customerId,
    required this.name,
    required this.number,
    required this.discountType,
    required this.discountValue,
  });

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'number': number,
      'discountType': discountType,
      'discountValue': discountValue,
    };
  }

  factory CustomerModel.fromFirestore(Map<String, dynamic> map, String id) {
    return CustomerModel(
      customerId: id,
      name: map['name'],
      number: map['number'],
      discountType: map['discountType'],
      discountValue: map['discountValue'],
    );
  }
}

class ItemModel {
  String itemId;
  final String name;
  final String description;
  final String? imageUrl;
  final String categoryId;
  final List<ItemSizeModel> sizes;
  final Map<String, List<OptionValue>> options;
  final List<String> sugarLevels;

  ItemModel({
    required this.itemId,
    required this.name,
    required this.categoryId,
    required this.description,
    this.imageUrl,
    this.sizes = const [],
    this.options = const {},
    this.sugarLevels = const [],
  });

  factory ItemModel.fromFirestore(Map<String, dynamic> data, String id) {
    return ItemModel(
      itemId: id,
      name: data['name'] ?? '',
      categoryId: data['categoryId'] ?? '',
      imageUrl: data['imageUrl'],
      description: data['description'] ?? '',
      sizes: (data['sizes'] as List<dynamic>? ?? [])
          .map((size) =>
              ItemSizeModel.fromFirestore(size as Map<String, dynamic>))
          .toList(),
      options: data['options'] != null
          ? (data['options'] as Map<String, dynamic>).map(
              (key, value) => MapEntry(
                key,
                (value as List<dynamic>)
                    .map((option) => OptionValue.fromFirestore(
                        option as Map<String, dynamic>))
                    .toList(),
              ),
            )
          : {},
      sugarLevels: List<String>.from(data['sugarLevels'] ?? []),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'name_lowercase': name.toLowerCase(),
      'imageUrl': imageUrl,
      'categoryId': categoryId,
      'sizes': sizes.map((size) => size.toFirestore()).toList(),
      'options': options.map((key, value) =>
          MapEntry(key, value.map((option) => option.toFirestore()).toList())),
      'sugarLevels': sugarLevels,
      'description': description,
    };
  }
}

class OptionValue {
  String name;
  RxList<RecipeItem> recipe;

  OptionValue({
    required this.name,
    required this.recipe,
  });

  factory OptionValue.fromFirestore(Map<String, dynamic> data) {
    return OptionValue(
      name: data['value'] ?? '',
      recipe: (data['recipe'] as List<dynamic>? ?? [])
          .map((item) => RecipeItem.fromFirestore(item as Map<String, dynamic>))
          .toList()
          .obs,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'value': name,
      'recipe': recipe.map((item) => item.toFirestore()).toList(),
    };
  }
}

class RecipeItem {
  final String productId;
  final String productName;
  int quantity;
  final double cost;
  final int costQuantity;
  final MeasuringUnit measuringUnit;

  RecipeItem({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.measuringUnit,
    required this.cost,
    required this.costQuantity,
  });

  factory RecipeItem.fromFirestore(Map<String, dynamic> data) {
    return RecipeItem(
      productId: data['productId'] ?? '',
      productName: data['productName'] ?? '',
      quantity: (data['quantity'] ?? 0.0).toInt(),
      cost: (data['cost'] ?? 0.0).toDouble(),
      costQuantity: (data['costQuantity'] ?? 0.0).toInt(),
      measuringUnit: MeasuringUnit.values.firstWhere(
        (unit) => unit.name == (data['measuringUnit'] ?? 'gm'),
        orElse: () => MeasuringUnit.gm,
      ),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'productId': productId,
      'productName': productName,
      'quantity': quantity,
      'cost': cost,
      'costQuantity': costQuantity,
      'measuringUnit': measuringUnit.name,
    };
  }
}

class ItemSizeModel {
  String name;
  double price;
  double costPrice;
  final RxList<RecipeItem> recipe;

  ItemSizeModel({
    required this.name,
    required this.price,
    required this.costPrice,
    required this.recipe,
  });

  factory ItemSizeModel.fromFirestore(Map<String, dynamic> data) {
    return ItemSizeModel(
      name: data['name'] ?? '',
      price: (data['price'] ?? 0.0).toDouble(),
      costPrice: (data['costPrice'] ?? 0.0).toDouble(),
      recipe: (data['recipe'] as List<dynamic>? ?? [])
          .map((item) => RecipeItem.fromFirestore(item as Map<String, dynamic>))
          .toList()
          .obs,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'price': price,
      'costPrice': costPrice,
      'recipe': recipe.map((item) => item.toFirestore()).toList(),
    };
  }
}

final categoriesIconMap = {
  'allMenu': Icons.select_all,
  'coffee': Icons.coffee,
  'fastfood': Icons.fastfood,
  'local_dining': Icons.local_dining,
  'restaurant': Icons.restaurant,
  'local_cafe': Icons.local_cafe,
  'icecream': Icons.icecream,
  'cake': Icons.cake,
  'bakery_dining': Icons.bakery_dining,
  'liquor': Icons.liquor,
  'local_bar': Icons.local_bar,
  'wine_bar': Icons.wine_bar,
  'set_meal': Icons.set_meal,
  'lunch_dining': Icons.lunch_dining,
  'breakfast_dining': Icons.breakfast_dining,
  'dinner_dining': Icons.dinner_dining,
  'takeout_dining': Icons.takeout_dining,
  'emoji_food_beverage': Icons.emoji_food_beverage,
  'local_pizza': Icons.local_pizza,
  'ramen_dining': Icons.ramen_dining,
  'rice_bowl': Icons.rice_bowl,
  'fa_coffee': FontAwesomeIcons.coffee,
  'fa_pizza_slice': FontAwesomeIcons.pizzaSlice,
  'fa_hamburger': FontAwesomeIcons.hamburger,
  'fa_hotdog': FontAwesomeIcons.hotdog,
  'fa_ice_cream': FontAwesomeIcons.iceCream,
  'fa_birthday_cake': FontAwesomeIcons.birthdayCake,
  'fa_wine_glass_alt': FontAwesomeIcons.wineGlassAlt,
  'fa_beer': FontAwesomeIcons.beer,
  'fa_cocktail': FontAwesomeIcons.cocktail,
  'fa_apple_alt':
      FontAwesomeIcons.appleAlt, // Can represent fruits or healthy options
  'fa_cheese': FontAwesomeIcons.cheese, // For cheese items
  'fa_fish': FontAwesomeIcons.fish, // For seafood
  'fa_bacon': FontAwesomeIcons.bacon, // For breakfast/meat items
  'fa_bread_slice': FontAwesomeIcons.breadSlice,
  'fa_cookie': FontAwesomeIcons.cookie, // For cookies or baked goods
  'fa_drumstick_bite': FontAwesomeIcons.drumstickBite, // For poultry items
  'fa_carrot': FontAwesomeIcons.carrot, // For vegetarian/vegan options
};
