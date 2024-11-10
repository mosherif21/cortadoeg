import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

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

class ItemModel {
  final String id;
  final String name;
  final String categoryId; // Reference to the category the item belongs to
  final List<ItemSizeModel> sizes;
  final List<String>
      ingredientIds; // IDs of ingredients from the Inventory collection
  final Map<String, List<String>>
      options; // Example: {'milk': ['skimmed', 'almond', 'soy']}
  final List<String> sugarLevels; // Example: ['no sugar', '1 tsp', '2 tsp']

  ItemModel({
    required this.id,
    required this.name,
    required this.categoryId,
    this.sizes = const [],
    this.ingredientIds = const [],
    this.options = const {},
    this.sugarLevels = const [],
  });

  factory ItemModel.fromFirestore(Map<String, dynamic> data, String id) {
    return ItemModel(
      id: id,
      name: data['name'] ?? '',
      categoryId: data['categoryId'] ?? '',
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
      'categoryId': categoryId,
      'sizes': sizes.map((size) => size.toFirestore()).toList(),
      'ingredientIds': ingredientIds,
      'options': options,
      'sugarLevels': sugarLevels,
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

List<ItemModel> cafeItemsExample = [
  ItemModel(
    id: "item1",
    name: "Coffee Item 1",
    categoryId: "3",
    sizes: [
      ItemSizeModel(name: "Small", price: 3.0, costPrice: 1.5),
      ItemSizeModel(name: "Medium", price: 4.0, costPrice: 2.0),
      ItemSizeModel(name: "Large", price: 5.0, costPrice: 2.5),
    ],
    ingredientIds: ['vanilla', 'sugar', 'flour'],
    options: {
      'milk': ['full fat', 'almond', 'soy', 'skimmed'],
      'flavor': ['mango', 'strawberry', 'chocolate', 'mint', 'vanilla'],
      'syrup': ['hazelnut', 'chocolate'],
    },
    sugarLevels: ['2 tsp'],
  ),
  ItemModel(
    id: "item2",
    name: "Cakes Item 2",
    categoryId: "4",
    sizes: [
      ItemSizeModel(name: "Small", price: 3.0, costPrice: 1.5),
      ItemSizeModel(name: "Medium", price: 4.0, costPrice: 2.0),
      ItemSizeModel(name: "Large", price: 5.0, costPrice: 2.5),
    ],
    ingredientIds: ['cream', 'chocolate', 'milk'],
    options: {
      'milk': ['full fat', 'skimmed'],
      'flavor': ['strawberry', 'mint', 'vanilla', 'chocolate', 'mango'],
      'syrup': ['chocolate', 'hazelnut'],
    },
    sugarLevels: ['no sugar', '3 tsp'],
  ),
  ItemModel(
    id: "item3",
    name: "Cakes Item 3",
    categoryId: "4",
    sizes: [
      ItemSizeModel(name: "Medium", price: 4.0, costPrice: 2.0),
      ItemSizeModel(name: "Large", price: 5.0, costPrice: 2.5),
    ],
    ingredientIds: ['nuts', 'milk', 'vanilla'],
    options: {
      'milk': ['soy'],
      'flavor': ['mint', 'mango', 'vanilla', 'strawberry', 'chocolate'],
      'syrup': ['caramel', 'hazelnut'],
    },
    sugarLevels: ['2 tsp', '1 tsp'],
  ),
  ItemModel(
    id: "item4",
    name: "Cakes Item 4",
    categoryId: "4",
    sizes: [
      ItemSizeModel(name: "Small", price: 3.0, costPrice: 1.5),
      ItemSizeModel(name: "Large", price: 5.0, costPrice: 2.5),
    ],
    ingredientIds: ['sugar', 'coffeeBeans'],
    options: {
      'milk': ['almond', 'skimmed', 'soy'],
      'flavor': ['mango', 'strawberry', 'vanilla'],
      'syrup': ['hazelnut'],
    },
    sugarLevels: ['2 tsp'],
  ),
  ItemModel(
    id: "item5",
    name: "Cakes Item 5",
    categoryId: "4",
    sizes: [
      ItemSizeModel(name: "Small", price: 3.0, costPrice: 1.5),
      ItemSizeModel(name: "Large", price: 5.0, costPrice: 2.5),
    ],
    ingredientIds: ['sugar', 'milk'],
    options: {
      'milk': ['almond', 'full fat', 'skimmed'],
      'flavor': ['vanilla', 'strawberry'],
      'syrup': ['caramel', 'chocolate'],
    },
    sugarLevels: ['1 tsp', '2 tsp'],
  ),
  ItemModel(
    id: "item6",
    name: "Coffee Item 6",
    categoryId: "3",
    sizes: [
      ItemSizeModel(name: "Small", price: 3.0, costPrice: 1.5),
      ItemSizeModel(name: "Medium", price: 4.5, costPrice: 2.2),
      ItemSizeModel(name: "Large", price: 5.5, costPrice: 2.8),
    ],
    ingredientIds: ['sugar', 'coffeeBeans'],
    options: {
      'milk': ['almond', 'skimmed'],
      'flavor': ['chocolate', 'vanilla'],
      'syrup': ['caramel'],
    },
    sugarLevels: ['2 tsp', '1 tsp'],
  ),
  ItemModel(
    id: "item7",
    name: "Cakes Item 6",
    categoryId: "4",
    sizes: [
      ItemSizeModel(name: "Medium", price: 4.0, costPrice: 2.1),
      ItemSizeModel(name: "Large", price: 5.0, costPrice: 2.6),
    ],
    ingredientIds: ['cream', 'chocolate', 'sugar'],
    options: {
      'milk': ['full fat', 'skimmed'],
      'flavor': ['chocolate', 'mint'],
      'syrup': ['chocolate'],
    },
    sugarLevels: ['no sugar', '3 tsp'],
  ),
  ItemModel(
    id: "item8",
    name: "Ice Cream Item 6",
    categoryId: "2",
    sizes: [
      ItemSizeModel(name: "Small", price: 3.0, costPrice: 1.4),
      ItemSizeModel(name: "Large", price: 5.0, costPrice: 2.5),
    ],
    ingredientIds: ['milk', 'chocolate'],
    options: {
      'milk': ['full fat', 'almond'],
      'flavor': ['vanilla', 'chocolate'],
      'syrup': ['caramel', 'hazelnut'],
    },
    sugarLevels: ['2 tsp', '3 tsp'],
  ),
  ItemModel(
    id: "item9",
    name: "Cakes Item 7",
    categoryId: "4",
    sizes: [
      ItemSizeModel(name: "Small", price: 3.5, costPrice: 1.7),
      ItemSizeModel(name: "Large", price: 5.5, costPrice: 2.9),
    ],
    ingredientIds: ['cream', 'vanilla'],
    options: {
      'milk': ['soy', 'skimmed'],
      'flavor': ['vanilla', 'strawberry'],
      'syrup': ['hazelnut'],
    },
    sugarLevels: ['no sugar', '2 tsp'],
  ),
  ItemModel(
    id: "item10",
    name: "Ice Cream Item 7",
    categoryId: "2",
    sizes: [
      ItemSizeModel(name: "Medium", price: 4.0, costPrice: 2.0),
      ItemSizeModel(name: "Large", price: 5.5, costPrice: 2.8),
    ],
    ingredientIds: ['cream', 'milk'],
    options: {
      'milk': ['full fat', 'soy'],
      'flavor': ['chocolate', 'mint'],
      'syrup': ['chocolate'],
    },
    sugarLevels: ['1 tsp', '2 tsp'],
  ),
  ItemModel(
    id: "item11",
    name: "Coffee Item 7",
    categoryId: "3",
    sizes: [
      ItemSizeModel(name: "Small", price: 2.8, costPrice: 1.4),
      ItemSizeModel(name: "Medium", price: 4.2, costPrice: 2.0),
      ItemSizeModel(name: "Large", price: 5.3, costPrice: 2.5),
    ],
    ingredientIds: ['sugar', 'coffeeBeans', 'milk'],
    options: {
      'milk': ['almond', 'full fat', 'soy'],
      'flavor': ['vanilla', 'mint'],
      'syrup': ['hazelnut'],
    },
    sugarLevels: ['3 tsp', '2 tsp'],
  ),
  ItemModel(
    id: "item12",
    name: "Cakes Item 8",
    categoryId: "4",
    sizes: [
      ItemSizeModel(name: "Small", price: 3.5, costPrice: 1.8),
      ItemSizeModel(name: "Medium", price: 4.8, costPrice: 2.4),
      ItemSizeModel(name: "Large", price: 5.9, costPrice: 3.1),
    ],
    ingredientIds: ['cream', 'sugar', 'coffeeBeans'],
    options: {
      'milk': ['soy', 'skimmed'],
      'flavor': ['chocolate', 'mint'],
      'syrup': ['hazelnut'],
    },
    sugarLevels: ['1 tsp', '2 tsp'],
  ),
  ItemModel(
    id: "item13",
    name: "Ice Cream Item 8",
    categoryId: "2",
    sizes: [
      ItemSizeModel(name: "Small", price: 3.0, costPrice: 1.6),
      ItemSizeModel(name: "Large", price: 5.0, costPrice: 2.7),
    ],
    ingredientIds: ['milk', 'chocolate', 'cream'],
    options: {
      'milk': ['full fat', 'almond'],
      'flavor': ['chocolate', 'mint'],
      'syrup': ['chocolate', 'hazelnut'],
    },
    sugarLevels: ['2 tsp', '3 tsp'],
  ),
  ItemModel(
    id: "item14",
    name: "Coffee Item 8",
    categoryId: "3",
    sizes: [
      ItemSizeModel(name: "Medium", price: 4.0, costPrice: 2.0),
      ItemSizeModel(name: "Large", price: 5.0, costPrice: 2.3),
    ],
    ingredientIds: ['coffeeBeans', 'sugar'],
    options: {
      'milk': ['full fat', 'soy'],
      'flavor': ['chocolate', 'vanilla'],
      'syrup': ['hazelnut', 'caramel'],
    },
    sugarLevels: ['1 tsp', '2 tsp'],
  ),
  ItemModel(
    id: "item15",
    name: "Ice Cream Item 9",
    categoryId: "2",
    sizes: [
      ItemSizeModel(name: "Small", price: 3.0, costPrice: 1.4),
      ItemSizeModel(name: "Large", price: 5.0, costPrice: 2.5),
    ],
    ingredientIds: ['milk', 'cream'],
    options: {
      'milk': ['soy', 'full fat'],
      'flavor': ['vanilla', 'chocolate'],
      'syrup': ['caramel'],
    },
    sugarLevels: ['no sugar', '3 tsp'],
  ),
  ItemModel(
    id: "item16",
    name: "Cakes Item 9",
    categoryId: "4",
    sizes: [
      ItemSizeModel(name: "Medium", price: 4.0, costPrice: 2.2),
      ItemSizeModel(name: "Large", price: 5.5, costPrice: 2.8),
    ],
    ingredientIds: ['chocolate', 'milk'],
    options: {
      'milk': ['almond', 'soy'],
      'flavor': ['mint', 'chocolate'],
      'syrup': ['caramel'],
    },
    sugarLevels: ['2 tsp'],
  ),
  ItemModel(
    id: "item17",
    name: "Ice Cream Item 10",
    categoryId: "2",
    sizes: [
      ItemSizeModel(name: "Medium", price: 3.5, costPrice: 1.7),
      ItemSizeModel(name: "Large", price: 5.5, costPrice: 2.8),
    ],
    ingredientIds: ['milk', 'cream', 'chocolate'],
    options: {
      'milk': ['full fat', 'soy'],
      'flavor': ['mint', 'vanilla'],
      'syrup': ['caramel'],
    },
    sugarLevels: ['no sugar', '1 tsp'],
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
