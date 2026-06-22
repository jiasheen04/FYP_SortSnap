import 'package:flutter/material.dart';

class RecycleCategory {
  final String name;
  final IconData icon;
  final bool isRecyclable;
  final List<String> items;

  const RecycleCategory({
    required this.name,
    required this.icon,
    required this.isRecyclable,
    required this.items,
  });
}

class RecycleCategoryData {
  static const List<RecycleCategory> recyclableCategories = [
    RecycleCategory(
      name: 'Plastic',
      icon: Icons.local_drink_outlined,
      isRecyclable: true,
      items: [
        'Plastic Bottle',
        'Plastic Bag',
        'Plastic Cup',
        'Food Container',
        'Shampoo Bottle',
        'Detergent Bottle',
      ],
    ),
    RecycleCategory(
      name: 'Paper',
      icon: Icons.description_outlined,
      isRecyclable: true,
      items: [
        'Newspaper',
        'Office Paper',
        'Magazine',
        'Paper Bag',
        'Envelope',
        'Notebook Paper',
      ],
    ),
    RecycleCategory(
      name: 'Cardboard',
      icon: Icons.inventory_2_outlined,
      isRecyclable: true,
      items: [
        'Carton Box',
        'Delivery Box',
        'Cereal Box',
        'Shoe Box',
        'Paper Tube',
        'Egg Tray',
      ],
    ),
    RecycleCategory(
      name: 'Metal',
      icon: Icons.settings_outlined,
      isRecyclable: true,
      items: [
        'Aluminium Can',
        'Drink Can',
        'Food Can',
        'Tin Can',
        'Metal Lid',
        'Clean Foil',
      ],
    ),
    RecycleCategory(
      name: 'Glass',
      icon: Icons.wine_bar_outlined,
      isRecyclable: true,
      items: [
        'Glass Bottle',
        'Glass Jar',
        'Sauce Bottle',
        'Jam Jar',
        'Drink Bottle',
        'Perfume Bottle',
      ],
    ),
    RecycleCategory(
      name: 'Battery',
      icon: Icons.battery_full_outlined,
      isRecyclable: true,
      items: [
        'AA Battery',
        'AAA Battery',
        'Button Battery',
        'Rechargeable Battery',
        'Phone Battery',
        'Power Bank Battery',
      ],
    ),
    RecycleCategory(
      name: 'E-Waste',
      icon: Icons.devices_outlined,
      isRecyclable: true,
      items: [
        'Mobile Phone',
        'Laptop',
        'Keyboard',
        'Mouse',
        'Charger',
        'Small Appliance',
      ],
    ),
  ];

  static const List<RecycleCategory> nonRecyclableCategories = [
    RecycleCategory(
      name: 'Trash',
      icon: Icons.delete_outline,
      isRecyclable: false,
      items: [
        'Used Tissue',
        'Dirty Wrapper',
        'Disposable Diaper',
        'Used Mask',
        'Broken Sponge',
        'Contaminated Cup',
      ],
    ),
    RecycleCategory(
      name: 'Food Waste',
      icon: Icons.restaurant_outlined,
      isRecyclable: false,
      items: [
        'Fruit Peel',
        'Rice Leftover',
        'Egg Shell',
        'Vegetable Scraps',
        'Bones',
        'Expired Food',
      ],
    ),
    RecycleCategory(
      name: 'Fabric',
      icon: Icons.checkroom_outlined,
      isRecyclable: false,
      items: [
        'Old Towel',
        'Used Socks',
        'Torn Shirt',
        'Old Curtain',
        'Dirty Cloth',
        'Fabric Scraps',
      ],
    ),
    RecycleCategory(
      name: 'Light Bulb',
      icon: Icons.lightbulb_outline,
      isRecyclable: false,
      items: [
        'Tube Light',
        'LED Bulb',
        'Broken Bulb',
        'Lamp Bulb',
        'Decorative Light',
        'Fluorescent Bulb',
      ],
    ),
    RecycleCategory(
      name: 'Ceramic',
      icon: Icons.local_cafe_outlined,
      isRecyclable: false,
      items: [
        'Broken Plate',
        'Ceramic Bowl',
        'Mug',
        'Porcelain Cup',
        'Broken Tile',
        'Flower Pot',
      ],
    ),
    RecycleCategory(
      name: 'Rubber',
      icon: Icons.radio_button_unchecked,
      isRecyclable: false,
      items: [
        'Rubber Glove',
        'Rubber Band',
        'Slipper',
        'Rubber Hose',
        'Rubber Mat',
        'Damaged Seal',
      ],
    ),
  ];

  static List<RecycleCategory> get allCategories {
    return [...recyclableCategories, ...nonRecyclableCategories];
  }

  static RecycleCategory getCategoryByName(String name) {
    return allCategories.firstWhere((category) => category.name == name);
  }
}
