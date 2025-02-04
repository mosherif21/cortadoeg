import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

enum MeasuringUnit {
  gm,
  ml,
  piece,
}

class ProductModel {
  String id;
  final String iconName;
  final String name;
  final MeasuringUnit measuringUnit;
  final double cost;
  final int costQuantity;
  final int availableQuantity;
  final int minimumQuantity;

  ProductModel({
    required this.id,
    required this.iconName,
    required this.name,
    required this.measuringUnit,
    required this.cost,
    required this.costQuantity,
    required this.availableQuantity,
    required this.minimumQuantity,
  });

  factory ProductModel.fromFirestore(Map<String, dynamic> data, String id) {
    return ProductModel(
      id: id,
      iconName: data['iconName'] ?? '',
      name: data['name'] ?? '',
      measuringUnit: MeasuringUnit.values.firstWhere(
        (unit) => unit.name == (data['measuringUnit'] ?? 'gm'),
        orElse: () => MeasuringUnit.gm,
      ),
      cost: (data['cost'] ?? 0.0).toDouble(),
      costQuantity: (data['costQuantity'] ?? 1.0).toInt(),
      availableQuantity: (data['availableQuantity'] ?? 0.0).toInt(),
      minimumQuantity: (data['minQuantity'] ?? 0.0).toInt(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'iconName': iconName,
      'name': name,
      'name_lowercase': name.toLowerCase(),
      'measuringUnit': measuringUnit.name,
      'cost': cost,
      'costQuantity': costQuantity,
      'availableQuantity': availableQuantity,
      'minQuantity': minimumQuantity,
    };
  }
}

final productsIconMap = {
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
  'fa_apple_alt': FontAwesomeIcons.appleAlt,
  'fa_cheese': FontAwesomeIcons.cheese,
  'fa_fish': FontAwesomeIcons.fish,
  'fa_bacon': FontAwesomeIcons.bacon,
  'fa_bread_slice': FontAwesomeIcons.breadSlice,
  'fa_cookie': FontAwesomeIcons.cookie,
  'fa_drumstick_bite': FontAwesomeIcons.drumstickBite,
  'fa_carrot': FontAwesomeIcons.carrot,
  'fa_egg': FontAwesomeIcons.egg,
  'fa_pepper_hot': FontAwesomeIcons.pepperHot,
  'fa_lemon': FontAwesomeIcons.lemon,
  'fa_wine_bottle': FontAwesomeIcons.wineBottle,
};
