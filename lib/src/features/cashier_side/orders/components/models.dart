import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

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
  final bool isTakeaway;
  List<int>? tableNumbers;
  List<OrderItemModel> items;
  OrderStatus status;
  final Timestamp timestamp;
  String? discountType;
  double? discountValue;
  String? customerId;
  String? customerName;
  final double totalAmount;
  final double discountAmount;
  final double subtotalAmount;
  final double taxTotalAmount;

  OrderModel({
    required this.orderId,
    required this.isTakeaway,
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
      'items': items.map((item) => item.toFirestore()).toList(),
      'status': status.name,
      'orderDate': timestamp,
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
      tableNumbers: List<int>.from(map['tableNumbers']),
      items: (map['items'] as List)
          .map((itemMap) => OrderItemModel.fromFirestore(itemMap))
          .toList(),
      status: OrderStatus.values.firstWhere((e) => e.name == map['status']),
      timestamp: map['orderDate'],
      discountType: map['discountType'],
      customerId: map['customerId'],
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
    };
  }

  factory OrderItemModel.fromFirestore(Map<String, dynamic> map) {
    return OrderItemModel(
      orderItemId: map['orderItemId'],
      itemId: map['itemId'],
      itemImageUrl: map['itemImageUrl'],
      name: map['name'],
      size: map['size'],
      quantity: map['quantity'],
      options: Map<String, String>.from(map['options']),
      sugarLevel: map['sugarLevel'],
      note: map['note'],
      price: map['price'].toDouble(),
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
  final String itemId;
  final String name;
  final String description;
  final String? imageUrl;
  final String categoryId;
  final List<ItemSizeModel> sizes;
  final List<String> ingredientIds;
  final Map<String, List<String>> options;
  final List<String> sugarLevels;

  ItemModel({
    required this.itemId,
    required this.name,
    required this.categoryId,
    required this.description,
    this.imageUrl,
    this.sizes = const [],
    this.ingredientIds = const [],
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
      sizes: (data['sizes'] as List<dynamic>?)
              ?.map((size) => ItemSizeModel.fromFirestore(size))
              .toList() ??
          [],
      ingredientIds: List<String>.from(data['ingredientIds'] ?? []),
      options: Map<String, List<String>>.from(data['options'] ?? {}),
      sugarLevels: List<String>.from(data['sugarLevels'] ?? []),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'imageUrl': imageUrl,
      'categoryId': categoryId,
      'sizes': sizes.map((size) => size.toFirestore()).toList(),
      'ingredientIds': ingredientIds,
      'options': options,
      'sugarLevels': sugarLevels,
      'description': description,
    };
  }
}

class ItemSizeModel {
  final String name;
  final double price;
  final double costPrice;

  ItemSizeModel({
    required this.name,
    required this.price,
    required this.costPrice,
  });

  factory ItemSizeModel.fromFirestore(Map<String, dynamic> data) {
    return ItemSizeModel(
      name: data['name'] ?? '',
      price: data['price'] ?? 0.0,
      costPrice: data['costPrice'] ?? 0.0,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'price': price,
      'costPrice': costPrice,
    };
  }
}

List<CategoryModel> categoriesExample = [
  CategoryModel(id: '', name: 'All Menu', iconName: 'allMenu'),
  CategoryModel(id: '1', name: 'Ice Cream', iconName: 'fa_ice_cream'),
  CategoryModel(id: '2', name: 'Coffee', iconName: 'coffee'),
  CategoryModel(id: '3', name: 'Cakes', iconName: 'fa_birthday_cake'),
  CategoryModel(id: '3', name: 'Special Cakes', iconName: 'fa_birthday_cake'),
];

List<ItemModel> cafeItemsExample = [
  ItemModel(
    itemId: "item1",
    name: "Espresso",
    categoryId: "2",
    sizes: [
      ItemSizeModel(name: "Single", price: 2.5, costPrice: 1.0),
      ItemSizeModel(name: "Double", price: 3.5, costPrice: 1.8),
    ],
    ingredientIds: ['coffeeBeans', 'water'],
    sugarLevels: ['no sugar', '1 tsp'],
    description:
        'A rich, intense shot of espresso made from freshly ground coffee beans.',
  ),
  ItemModel(
    itemId: "item2",
    name: "Cappuccino",
    categoryId: "2",
    sizes: [
      ItemSizeModel(name: "Small", price: 3.5, costPrice: 1.5),
      ItemSizeModel(name: "Medium", price: 4.5, costPrice: 2.2),
      ItemSizeModel(name: "Large", price: 5.5, costPrice: 3.0),
    ],
    ingredientIds: ['coffeeBeans', 'milk', 'water'],
    options: {
      'milk': ['full fat', 'almond', 'oat'],
      'flavor': ['vanilla', 'caramel'],
      'syrup': ['chocolate', 'caramel'],
    },
    sugarLevels: ['1 tsp', '2 tsp'],
    description:
        'A classic Italian coffee with a rich, velvety foam and a sprinkle of chocolate.',
  ),
  ItemModel(
    itemId: "item3",
    name: "Muffin",
    categoryId: "3",
    sizes: [
      ItemSizeModel(name: "Regular", price: 2.5, costPrice: 1.2),
    ],
    ingredientIds: ['flour', 'sugar', 'milk', 'blueberries'],
    options: {
      'flavor': ['blueberry', 'chocolate chip', 'banana nut'],
    },
    sugarLevels: ['default'],
    description:
        'A soft, fluffy muffin filled with real blueberries or other seasonal flavors.',
  ),
  ItemModel(
    itemId: "item4",
    name: "Lemon Ice Cream",
    categoryId: "1",
    sizes: [
      ItemSizeModel(name: "Small", price: 2.0, costPrice: 0.8),
      ItemSizeModel(name: "Large", price: 3.0, costPrice: 1.2),
    ],
    ingredientIds: ['lemon', 'sugar', 'water'],
    options: {
      'flavor': ['mint', 'ginger'],
    },
    sugarLevels: ['no sugar', '1 tsp', '2 tsp'],
    description:
        'A refreshing lemonade made from freshly squeezed lemons and a touch of sweetness.',
  ),
  ItemModel(
    itemId: "item5",
    name: "Avocado Toast",
    categoryId: "3",
    sizes: [
      ItemSizeModel(name: "Regular", price: 6.0, costPrice: 3.0),
    ],
    ingredientIds: ['bread', 'avocado', 'olive oil', 'seasoning'],
    options: {
      'toppings': ['egg', 'smoked salmon', 'feta cheese'],
    },
    sugarLevels: ['none'],
    description:
        'Toasted whole grain bread topped with creamy avocado and a variety of toppings.',
  ),
  ItemModel(
    itemId: "item6",
    name: "Iced Latte",
    categoryId: "2",
    sizes: [
      ItemSizeModel(name: "Medium", price: 4.0, costPrice: 2.0),
      ItemSizeModel(name: "Large", price: 5.0, costPrice: 2.5),
    ],
    ingredientIds: ['coffeeBeans', 'milk', 'ice'],
    options: {
      'milk': ['full fat', 'skimmed', 'almond', 'oat'],
      'syrup': ['vanilla', 'caramel', 'hazelnut'],
    },
    sugarLevels: ['1 tsp', '2 tsp', '3 tsp'],
    description:
        'A chilled espresso drink blended with milk over ice and customizable with flavors.',
  ),
  ItemModel(
    itemId: "item7",
    name: "Bagel",
    categoryId: "3",
    sizes: [
      ItemSizeModel(name: "Single", price: 3.0, costPrice: 1.5),
    ],
    ingredientIds: ['flour', 'yeast', 'sugar', 'salt'],
    options: {
      'toppings': ['cream cheese', 'smoked salmon', 'tomato', 'cucumber'],
    },
    sugarLevels: ['default'],
    description:
        'A fresh, chewy bagel with the option of various delicious toppings.',
  ),
  ItemModel(
    itemId: "item8",
    name: "Cake Bowl",
    categoryId: "3",
    sizes: [
      ItemSizeModel(name: "Regular", price: 6.5, costPrice: 3.5),
    ],
    ingredientIds: ['banana', 'berries', 'yogurt', 'granola'],
    options: {
      'toppings': ['chia seeds', 'coconut flakes', 'honey'],
    },
    sugarLevels: ['no sugar', '1 tsp'],
    description:
        'A nutritious smoothie bowl topped with fresh fruits, granola, and superfoods.',
  ),
  ItemModel(
    itemId: "item9",
    name: "Hot Chocolate",
    categoryId: "2",
    sizes: [
      ItemSizeModel(name: "Small", price: 3.0, costPrice: 1.5),
      ItemSizeModel(name: "Medium", price: 4.0, costPrice: 2.0),
      ItemSizeModel(name: "Large", price: 5.0, costPrice: 2.5),
    ],
    ingredientIds: ['milk', 'chocolate', 'sugar'],
    options: {
      'milk': ['full fat', 'almond', 'soy'],
      'toppings': ['whipped cream', 'marshmallows', 'chocolate shavings'],
    },
    sugarLevels: ['1 tsp', '2 tsp', 'no sugar'],
    description:
        'A rich, creamy hot chocolate with optional toppings for added sweetness.',
  ),
  ItemModel(
    itemId: "item10",
    name: "Croissant",
    categoryId: "3",
    sizes: [
      ItemSizeModel(name: "Single", price: 3.0, costPrice: 1.8),
    ],
    ingredientIds: ['flour', 'butter', 'sugar', 'salt'],
    options: {
      'fillings': ['chocolate', 'almond', 'cheese'],
    },
    sugarLevels: ['default'],
    description:
        'A flaky, buttery croissant with options for sweet or savory fillings.',
  ),
];

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
