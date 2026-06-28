import 'package:flutter/material.dart';

class RecycleCategory {
  final String name;
  final IconData icon;
  final bool isRecyclable;
  final List<String> items;
  final String imagePath;
  final Map<String, String> itemImages;

  const RecycleCategory({
    required this.name,
    required this.icon,
    required this.isRecyclable,
    required this.items,
    this.imagePath = '',
    this.itemImages = const {},
  });

  String getItemImagePath(String item) {
    return itemImages[item] ?? imagePath;
  }
}

class RecycleCategoryData {
  static const String recyclablePath = 'assets/images/categories/recyclable';
  static const String nonRecyclablePath =
      'assets/images/categories/specialhandling';

  static const List<RecycleCategory> recyclableCategories = [
    RecycleCategory(
      name: 'Plastic',
      icon: Icons.local_drink_outlined,
      isRecyclable: true,
      imagePath: '$recyclablePath/plasticbottle.png',
      items: [
        'Plastic bag',
        'Plastic takeaway container',
        'Plastic bottled water',
        'Shampoo/ Soap Bottle',
        'Mouthwash bottle',
      ],
      itemImages: {
        'Plastic bag': '$recyclablePath/plasticbag.png',
        'Plastic takeaway container': '$recyclablePath/takeawaycontainer.png',
        'Plastic bottled water': '$recyclablePath/plasticbottle.png',
        'Shampoo/ Soap Bottle': '$recyclablePath/shampoobottle.png',
        'Mouthwash bottle': '$recyclablePath/detergentbottle.png',
      },
    ),
    RecycleCategory(
      name: 'Paper',
      icon: Icons.description_outlined,
      isRecyclable: true,
      imagePath: '$recyclablePath/newspaper.png',
      items: ['Newspaper', 'Magazine', 'Used Beverage Carton'],
      itemImages: {
        'Newspaper': '$recyclablePath/newspaper.png',
        'Magazine': '$recyclablePath/magazine.png',
        'Used Beverage Carton': '$nonRecyclablePath/beveragecarton.png',
      },
    ),
    RecycleCategory(
      name: 'Cardboard',
      icon: Icons.inventory_2_outlined,
      isRecyclable: true,
      imagePath: '$recyclablePath/cartonbox.png',
      items: [
        'Pizza box',
        'Cylinder tube packaging',
        'Cardboard boxes',
        'Mooncake boxes',
      ],
      itemImages: {
        'Pizza box': '$recyclablePath/pizzabox.png',
        'Cylinder tube packaging': '$recyclablePath/cylindertubepackaging.png',
        'Cardboard boxes': '$recyclablePath/cartonbox.png',
        'Mooncake boxes': '$recyclablePath/mooncakebox.png',
      },
    ),
    RecycleCategory(
      name: 'Glass',
      icon: Icons.wine_bar_outlined,
      isRecyclable: true,
      imagePath: '$recyclablePath/glassjar.png',
      items: ['Glass container'],
      itemImages: {'Glass container': '$recyclablePath/glassjar.png'},
    ),
    RecycleCategory(
      name: 'Metal',
      icon: Icons.settings_outlined,
      isRecyclable: true,
      imagePath: '$recyclablePath/aluminiumcan.png',
      items: ['Aluminium Can'],
      itemImages: {'Aluminium Can': '$recyclablePath/aluminiumcan.png'},
    ),
    RecycleCategory(
      name: 'Battery',
      icon: Icons.battery_full_outlined,
      isRecyclable: true,
      imagePath: '$recyclablePath/AAbattery.png',
      items: ['Dry Cell Battery', 'Old car battery'],
      itemImages: {
        'Dry Cell Battery': '$recyclablePath/AAbattery.png',
        'Old car battery': '$recyclablePath/carbattery.png',
      },
    ),
    RecycleCategory(
      name: 'E-Waste',
      icon: Icons.devices_outlined,
      isRecyclable: true,
      imagePath: '$recyclablePath/laptop.png',
      items: ['Computer/ Laptop', 'Printer ink cartridge', 'Earphones', 'CD'],
      itemImages: {
        'Computer/ Laptop': '$recyclablePath/laptop.png',
        'Printer ink cartridge': '$recyclablePath/inkcatridge.png',
        'Earphones': '$recyclablePath/earphones.png',
        'CD': '$nonRecyclablePath/cd.png',
      },
    ),
  ];

  static const List<RecycleCategory> nonRecyclableCategories = [
    RecycleCategory(
      name: 'General Waste',
      icon: Icons.delete_outline,
      isRecyclable: false,
      imagePath: '$nonRecyclablePath/coffeecup.png',
      items: [
        'Coffee paper cup',
        'Plastic straw',
        'Plush toy',
        'Snack packaging',
        'Receipt',
        'Polystyrene Box',
      ],
      itemImages: {
        'Coffee paper cup': '$nonRecyclablePath/coffeecup.png',
        'Plastic straw': '$nonRecyclablePath/straw.png',
        'Plush toy': '$nonRecyclablePath/plushtoy.png',
        'Snack packaging': '$nonRecyclablePath/snackpacket.png',
        'Receipt': '$recyclablePath/receipt.png',
        'Polystyrene Box': '$nonRecyclablePath/polysterene.png',
      },
    ),
    RecycleCategory(
      name: 'Personal Waste',
      icon: Icons.baby_changing_station_outlined,
      isRecyclable: false,
      imagePath: '$nonRecyclablePath/diapers.png',
      items: ['Diapers'],
      itemImages: {'Diapers': '$nonRecyclablePath/diapers.png'},
    ),
    RecycleCategory(
      name: 'Fragile Waste',
      icon: Icons.broken_image_outlined,
      isRecyclable: false,
      imagePath: '$nonRecyclablePath/brokenglass.png',
      items: ['Mirror', 'Broken Glass (Household Jar)'],
      itemImages: {
        'Mirror': '$nonRecyclablePath/mirror.png',
        'Broken Glass (Household Jar)': '$nonRecyclablePath/brokenglass.png',
      },
    ),
    RecycleCategory(
      name: 'Hazardous Waste',
      icon: Icons.warning_amber_outlined,
      isRecyclable: false,
      imagePath: '$nonRecyclablePath/lightbulb.png',
      items: ['Light bulb'],
      itemImages: {'Light bulb': '$nonRecyclablePath/lightbulb.png'},
    ),
    RecycleCategory(
      name: 'Food Waste',
      icon: Icons.restaurant_outlined,
      isRecyclable: false,
      imagePath: '$nonRecyclablePath/foodwaste.png',
      items: ['Food Waste'],
      itemImages: {'Food Waste': '$nonRecyclablePath/foodwaste.png'},
    ),
  ];

  static List<RecycleCategory> get allCategories {
    return [...recyclableCategories, ...nonRecyclableCategories];
  }

  static RecycleCategory getCategoryByName(String name) {
    return allCategories.firstWhere(
      (category) => category.name == name,
      orElse: () => recyclableCategories.first,
    );
  }
}
