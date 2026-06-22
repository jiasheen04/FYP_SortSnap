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
  static const String specialPath = 'assets/images/categories/specialhandling';

  // Trashpedia - Zero Waste Malaysia 101 Trash.
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
        'Clear Clamshell Food Container',
      ],
      itemImages: {
        'Plastic bag': '$recyclablePath/plasticbag.png',
        'Plastic takeaway container': '$recyclablePath/takeawaycontainer.png',
        'Plastic bottled water': '$recyclablePath/plasticbottle.png',
        'Shampoo/ Soap Bottle': '$recyclablePath/shampoobottle.png',
        'Mouthwash bottle': '$recyclablePath/detergentbottle.png',
        'Clear Clamshell Food Container': '$recyclablePath/foodcontainer.png',
      },
    ),
    RecycleCategory(
      name: 'Paper',
      icon: Icons.description_outlined,
      isRecyclable: true,
      imagePath: '$recyclablePath/newspaper.png',
      items: [
        'Newspaper',
        'Magazine',
        'Advertisement flyers',
        'Envelope with window',
        'Receipt',
        'Shredded paper',
      ],
      itemImages: {
        'Newspaper': '$recyclablePath/newspaper.png',
        'Magazine': '$recyclablePath/magazine.png',
        'Advertisement flyers': '$recyclablePath/officepaper.png',
        'Envelope with window': '$recyclablePath/envelope.png',
        'Receipt': '$recyclablePath/receipt.png',
        'Shredded paper': '$recyclablePath/shreddedpaper.png',
      },
    ),
    RecycleCategory(
      name: 'Cardboard',
      icon: Icons.inventory_2_outlined,
      isRecyclable: true,
      imagePath: '$recyclablePath/cartonbox.png',
      items: [
        'Cardboard boxes',
        'Pizza box',
        'Mooncake boxes',
        'Product packaging box',
        'Cylinder tube packaging',
        'Delivery parcel packaging',
      ],
      itemImages: {
        'Cardboard boxes': '$recyclablePath/cartonbox.png',
        'Pizza box': '$recyclablePath/pizzabox.png',
        'Mooncake boxes': '$recyclablePath/mooncakebox.png',
        'Product packaging box': '$recyclablePath/cerealbox.png',
        'Cylinder tube packaging': '$recyclablePath/cylindertubepackaging.png',
        'Delivery parcel packaging': '$recyclablePath/deliverybox.png',
      },
    ),
    RecycleCategory(
      name: 'Metal',
      icon: Icons.settings_outlined,
      isRecyclable: true,
      imagePath: '$recyclablePath/aluminiumcan.png',
      items: [
        'Aluminium Can',
        'Tin Can',
        'Aluminium foil',
        'Aluminium cream tube',
        'Medals',
        'Staples',
      ],
      itemImages: {
        'Aluminium Can': '$recyclablePath/aluminiumcan.png',
        'Tin Can': '$recyclablePath/tincan.png',
        'Aluminium foil': '$recyclablePath/cleanfoil.png',
        'Aluminium cream tube': '$recyclablePath/aluminiumcreamtube.png',
        'Medals': '$recyclablePath/medal.png',
        'Staples': '$recyclablePath/staples.png',
      },
    ),
    RecycleCategory(
      name: 'Glass',
      icon: Icons.wine_bar_outlined,
      isRecyclable: true,
      imagePath: '$recyclablePath/glassbottle.png',
      items: [
        'Glass container',
        'Broken Glass (Household Jar)',
        'Mirror',
        'Juice bottle',
      ],
      itemImages: {
        'Glass container': '$recyclablePath/glassjar.png',
        'Broken Glass (Household Jar)': '$recyclablePath/brokenglass.png',
        'Mirror': '$recyclablePath/mirror.png',
        'Juice bottle': '$recyclablePath/glassbottle.png',
      },
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
      imagePath: '$recyclablePath/mobilephone.png',
      items: [
        'Computer/ Laptop',
        'Charging Cable',
        'Earphones',
        'Printer ink cartridge',
        'Fridge',
      ],
      itemImages: {
        'Computer/ Laptop': '$recyclablePath/laptop.png',
        'Charging Cable': '$recyclablePath/charger.png',
        'Earphones': '$recyclablePath/earphones.png',
        'Printer ink cartridge': '$recyclablePath/inkcatridge.png',
        'Fridge': '$recyclablePath/fridge.png',
      },
    ),
  ];

  // These items need special disposal guidance or are not suitable for normal recycling bins.
  static const List<RecycleCategory> nonRecyclableCategories = [
    RecycleCategory(
      name: 'Personal Waste',
      icon: Icons.delete_outline,
      isRecyclable: false,
      imagePath: '$specialPath/diapers.png',
      items: [
        'Diapers',
        'Face Mask',
        'Cotton bud',
        'Contact Lens',
        'Floss pick',
        'Disposable razor',
      ],
      itemImages: {
        'Diapers': '$specialPath/diapers.png',
        'Face Mask': '$specialPath/facemask.png',
        'Cotton bud': '$specialPath/cottonbud.png',
        'Contact Lens': '$specialPath/contactlens.png',
        'Floss pick': '$specialPath/flosspick.png',
        'Disposable razor': '$specialPath/disposablerazor.png',
      },
    ),
    RecycleCategory(
      name: 'Food Waste',
      icon: Icons.restaurant_outlined,
      isRecyclable: false,
      imagePath: '$specialPath/foodwaste.png',
      items: ['Food Waste'],
      itemImages: {'Food Waste': '$specialPath/foodwaste.png'},
    ),
    RecycleCategory(
      name: 'Medical Waste',
      icon: Icons.medical_services_outlined,
      isRecyclable: false,
      imagePath: '$specialPath/expiredmedicine.png',
      items: ['Medical strips', 'Expired medicine', 'Home test kits'],
      itemImages: {
        'Medical strips': '$specialPath/medicalstrips.png',
        'Expired medicine': '$specialPath/expiredmedicine.png',
        'Home test kits': '$specialPath/testkits.png',
      },
    ),
    RecycleCategory(
      name: 'Ceramic / Glass',
      icon: Icons.local_cafe_outlined,
      isRecyclable: false,
      imagePath: '$specialPath/brokebowl.png',
      items: ['Broken ceramic bowl', 'Broken Glass (Household Jar)', 'Mirror'],
      itemImages: {
        'Broken ceramic bowl': '$specialPath/brokebowl.png',
        'Broken Glass (Household Jar)': '$specialPath/brokenglass.png',
        'Mirror': '$specialPath/mirror.png',
      },
    ),
    RecycleCategory(
      name: 'Hazardous Items',
      icon: Icons.warning_amber_outlined,
      isRecyclable: false,
      imagePath: '$specialPath/lightbulb.png',
      items: ['Light bulb', 'Disposable Gas Lighter', 'Cigarettes and box'],
      itemImages: {
        'Light bulb': '$specialPath/lightbulb.png',
        'Disposable Gas Lighter': '$specialPath/lighter.png',
        'Cigarettes and box': '$specialPath/cigaretts.png',
      },
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
