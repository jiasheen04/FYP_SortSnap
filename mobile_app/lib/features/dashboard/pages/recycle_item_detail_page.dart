import 'package:flutter/material.dart';

class TrashItemDetail {
  final String number;
  final String description;
  final List<String> components;
  final List<String> whatToDo;
  final List<String> steps;

  const TrashItemDetail({
    required this.number,
    required this.description,
    required this.components,
    required this.whatToDo,
    required this.steps,
  });
}

class RecycleItemDetailPage extends StatelessWidget {
  final String itemName;
  final String imagePath;
  final IconData icon;
  final bool isRecyclable;

  const RecycleItemDetailPage({
    super.key,
    required this.itemName,
    required this.imagePath,
    required this.icon,
    required this.isRecyclable,
  });

  static const Color backgroundColor = Color(0xFFD5EDE4);
  static const Color mainGreen = Color(0xFF51BA90);
  static const Color darkGreen = Color(0xFF2F6F57);

  TrashItemDetail get detail {
    return itemDetails[itemName] ??
        const TrashItemDetail(
          number: '-',
          description: 'Information for this item is not available yet.',
          components: ['Component information is not available yet.'],
          whatToDo: ['Disposal guidance is not available yet.'],
          steps: ['Place into the respective bin.'],
        );
  }

  static const Map<String, TrashItemDetail> itemDetails = {
    'Glass container': TrashItemDetail(
      number: '016',
      description:
          'Glass containers are commonly used for storing food condiments, liquids, pickles and other items. Glass can take a very long time to decompose in the environment.',
      components: ['Body: Glass', 'Label: Paper or plastic label'],
      whatToDo: [
        'Glass body: Recycle if clean and accepted',
        'Label: Remove before recycling if possible',
      ],
      steps: ['Remove label.', 'Clean and dry.', 'Place into respective bins.'],
    ),

    'Pizza box': TrashItemDetail(
      number: '018',
      description:
          'Most pizza boxes are made of cardboard. They can be recycled if the box is not smeared with grease or food stain.',
      components: [
        'Body: Cardboard',
        'Contaminated part: Grease or food-stained cardboard',
      ],
      whatToDo: [
        'Clean cardboard part: Paper or cardboard bin',
        'Greasy part: Compost bin if available, otherwise general waste',
      ],
      steps: [
        'Tear off the contaminated parts.',
        'Place the contaminated part in compost bin if available.',
        'Place the remaining clean part into the respective bin.',
      ],
    ),

    'Light bulb': TrashItemDetail(
      number: '021',
      description:
          'Light bulbs may contain small amounts of mercury, which can be harmful if not disposed properly.',
      components: [
        'Body: Glass and metal parts',
        'Inside: Electrical and lighting material',
      ],
      whatToDo: [
        'Do not throw loosely into the bin.',
        'Wrap and label it before disposal.',
      ],
      steps: [
        'Wrap and tie them in a newspaper.',
        'Label “light bulb”.',
        'Place into the respective bin.',
      ],
    ),

    'Mirror': TrashItemDetail(
      number: '023',
      description:
          'Mirrors are made with reflective coating. Because of this coating, they are not recyclable like normal glass bottles or jars.',
      components: ['Body: Glass with reflective coating'],
      whatToDo: ['Mirror: General waste'],
      steps: ['Place into the respective bin.'],
    ),

    'Dry Cell Battery': TrashItemDetail(
      number: '024',
      description:
          'Dry cell batteries are used in many household electronics. They contain metal and chemicals, so they should be disposed responsibly.',
      components: [
        'Body: Metal exterior',
        'Inside: Battery chemicals and heavy metals',
      ],
      whatToDo: ['Dry cell battery: Battery recycling or collection point'],
      steps: [
        'Tie them together or put them in a box.',
        'Place into the respective bin.',
      ],
    ),

    'Mouthwash bottle': TrashItemDetail(
      number: '026',
      description:
          'Mouthwash bottles are usually plastic bottles. A 1-PET bottle can take up to 450 years to decompose.',
      components: [
        'Cap: Plastic',
        'Body: Plastic bottle',
        'Label: Plastic or paper label',
      ],
      whatToDo: [
        'Cap: Plastic bin',
        'Bottle body: Plastic bin',
        'Label: General bin',
      ],
      steps: [
        'Remove the label if possible.',
        'Clean and dry.',
        'Place into respective bins with caps on.',
      ],
    ),

    'Broken Glass (Household Jar)': TrashItemDetail(
      number: '027',
      description:
          'Broken glass can hurt cleaners and waste collectors if it is thrown away without protection.',
      components: ['Body: Broken glass pieces'],
      whatToDo: ['Broken glass: Place safely into the respective bin'],
      steps: [
        'Place all the broken glass in a transparent container.',
        'Label as broken glass.',
        'Place into the respective bin.',
      ],
    ),

    'Food Waste': TrashItemDetail(
      number: '028',
      description:
          'Food waste is one of the common wastes produced daily. It should be separated properly when possible.',
      components: ['Food scraps', 'Leftover food'],
      whatToDo: ['Food waste: Food waste bin or compost bin if available'],
      steps: ['Place into the respective bin.'],
    ),

    'Polystyrene Box': TrashItemDetail(
      number: '030',
      description:
          'Polystyrene is commonly used as packaging material because it can absorb shock. However, it can take around 500 years to decompose.',
      components: [
        'Body: Polystyrene / styrofoam',
        'Label: Sticker or paper label',
      ],
      whatToDo: [
        'Clean polystyrene: Recycle only if accepted',
        'Dirty polystyrene: General waste',
      ],
      steps: [
        'Remove any label on the styrofoam.',
        'Keep it dry.',
        'Place into respective bins.',
      ],
    ),

    'Computer/ Laptop': TrashItemDetail(
      number: '036',
      description:
          'Computers and laptops contain valuable metals that can be reused through recycling. They should not be thrown away as normal waste.',
      components: [
        'Body: Plastic and metal casing',
        'Inside: Circuit board and electronic components',
        'Battery: Electronic waste component',
      ],
      whatToDo: ['Computer or laptop: E-waste collection point'],
      steps: [
        'Format the device to protect personal data.',
        'Place into the respective bin.',
      ],
    ),

    'Old car battery': TrashItemDetail(
      number: '039',
      description:
          'Old car batteries contain toxic lead and sulfuric acid. These materials should be kept out of the environment.',
      components: [
        'Body: Plastic battery casing',
        'Inside: Lead and sulfuric acid',
      ],
      whatToDo: ['Old car battery: Drop-off centre or pickup service'],
      steps: [
        'Check for the nearest drop-off centre or arrange a pickup service.',
      ],
    ),

    'Printer ink cartridge': TrashItemDetail(
      number: '040',
      description:
          'Printer ink cartridges are part of e-waste. They can be kept out of landfills by using proper take-back or recycling services.',
      components: [
        'Body: Plastic cartridge',
        'Inside: Ink residue and cartridge parts',
      ],
      whatToDo: ['Authentic cartridge: Brand take-back or drop-off point'],
      steps: [
        'For authentic cartridges, check for drop-off location or arrange a pickup service.',
      ],
    ),

    'Aluminium Can': TrashItemDetail(
      number: '041',
      description:
          'Aluminium cans are commonly used for drinks and food products. Aluminium is one of the materials that is commonly recycled.',
      components: ['Body: Aluminium'],
      whatToDo: ['Aluminium can: Metal bin'],
      steps: ['Clean and dry.', 'Compress.', 'Place into the respective bin.'],
    ),

    'Cylinder tube packaging': TrashItemDetail(
      number: '047',
      description:
          'Cylinder tube packaging is used for dry food such as chips, coffee grounds and powdered beverages. It is difficult to recycle because it is made from mixed materials.',
      components: [
        'Lid: Plastic',
        'Body: Mixed paper, plastic and metal layer',
        'Base: Metal or mixed material',
      ],
      whatToDo: [
        'Separate each component first.',
        'Place each part into the correct bin based on material.',
      ],
      steps: [
        'Clean and dry.',
        'Separate the component.',
        'Place into respective bins.',
      ],
    ),

    'Earphones': TrashItemDetail(
      number: '056',
      description:
          'Earphones are electronic accessories. Since they are e-waste, they should be disposed at the correct collection point.',
      components: [
        'Body: Plastic and rubber parts',
        'Wire: Metal and plastic',
        'Inside: Small electronic components',
      ],
      whatToDo: ['Earphones: E-waste collection point'],
      steps: ['Place into the respective bin.'],
    ),

    'Cardboard boxes': TrashItemDetail(
      number: '066',
      description:
          'Cardboard boxes are used for packaging, moving, storage and transporting goods.',
      components: ['Body: Cardboard', 'Tape: Adhesive tape'],
      whatToDo: ['Cardboard: Paper or cardboard bin', 'Tape: General bin'],
      steps: [
        'Remove any adhesive tape.',
        'Dismantle the box.',
        'Place into respective bins.',
      ],
    ),

    'Mooncake boxes': TrashItemDetail(
      number: '070',
      description:
          'Mooncake boxes come in different shapes and sizes. They are often designed to look premium, especially when used as gifts.',
      components: [
        'Body: Cardboard or paper packaging',
        'Extra parts: Plastic or metal parts depending on design',
      ],
      whatToDo: [
        'Separate the parts first.',
        'Place each part into the correct bin based on material.',
      ],
      steps: ['Separate the component.', 'Place into respective bins.'],
    ),
  };

  Widget buildItemImage() {
    return Container(
      width: 130,
      height: 130,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: imagePath.isNotEmpty
            ? Image.asset(
                imagePath,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(icon, color: mainGreen, size: 55);
                },
              )
            : Icon(icon, color: mainGreen, size: 55),
      ),
    );
  }

  Widget buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        title,
        style: const TextStyle(
          color: darkGreen,
          fontSize: 16,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget buildWhiteCard({required Widget child}) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget buildTextList(List<String> texts) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: texts.map((text) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 6),
                child: Icon(Icons.circle, size: 7, color: mainGreen),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  text,
                  style: const TextStyle(
                    color: Colors.black54,
                    fontSize: 14,
                    height: 1.35,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget buildStepsList(List<String> steps) {
    return Column(
      children: List.generate(steps.length, (index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 26,
                height: 26,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: mainGreen,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '${index + 1}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  steps[index],
                  style: const TextStyle(
                    color: Colors.black54,
                    fontSize: 14,
                    height: 1.35,
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final TrashItemDetail itemDetail = detail;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: mainGreen,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back, color: Colors.white, size: 29),
        ),
        title: Text(
          itemName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(22, 24, 22, 24),
        child: Column(
          children: [
            buildItemImage(),
            const SizedBox(height: 16),
            Text(
              itemDetail.number,
              style: const TextStyle(
                color: mainGreen,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                color: isRecyclable
                    ? const Color(0xFFE8F8F0)
                    : const Color(0xFFFFF0E8),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Text(
                isRecyclable ? 'Recyclable' : 'Non-Recyclable',
                style: TextStyle(
                  color: isRecyclable ? mainGreen : Colors.orange.shade700,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: 22),
            buildWhiteCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildSectionTitle('About This Item'),
                  Text(
                    itemDetail.description,
                    style: const TextStyle(
                      color: Colors.black54,
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            buildWhiteCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildSectionTitle('Components'),
                  buildTextList(itemDetail.components),
                ],
              ),
            ),
            buildWhiteCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildSectionTitle('What To Do'),
                  buildTextList(itemDetail.whatToDo),
                ],
              ),
            ),
            buildWhiteCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildSectionTitle('Step(s) to Dispose'),
                  buildStepsList(itemDetail.steps),
                ],
              ),
            ),
            const Text(
              'Source: Trashpedia - Zero Waste Malaysia',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black38, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
