import 'package:flutter/material.dart';

class LocationFilterSheet extends StatefulWidget {
  final bool initialShowOpenOnly;
  final bool initialShowAcceptingOnly;
  final double? initialDistanceKm;
  final ValueChanged<bool> onOpenOnlyChanged;
  final ValueChanged<bool> onAcceptingOnlyChanged;
  final ValueChanged<double?> onDistanceChanged;
  final VoidCallback onApply;

  const LocationFilterSheet({
    super.key,
    required this.initialShowOpenOnly,
    required this.initialShowAcceptingOnly,
    required this.initialDistanceKm,
    required this.onOpenOnlyChanged,
    required this.onAcceptingOnlyChanged,
    required this.onDistanceChanged,
    required this.onApply,
  });

  @override
  State<LocationFilterSheet> createState() => _LocationFilterSheetState();
}

class _LocationFilterSheetState extends State<LocationFilterSheet> {
  late bool tempShowOpenOnly;
  late bool tempShowAcceptingOnly;
  double? tempDistanceKm;

  @override
  void initState() {
    super.initState();
    tempShowOpenOnly = widget.initialShowOpenOnly;
    tempShowAcceptingOnly = widget.initialShowAcceptingOnly;
    tempDistanceKm = widget.initialDistanceKm;
  }

  Widget _distanceOption({
    required String label,
    required double? value,
    required double? groupValue,
    required VoidCallback onTap,
  }) {
    final selected = value == groupValue;

    return InkWell(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            selected ? Icons.radio_button_checked : Icons.radio_button_off,
            size: 20,
            color: Colors.black54,
          ),
          const SizedBox(width: 6),
          Text(label),
        ],
      ),
    );
  }

  Widget _filterCheckRow({
    required String label,
    required bool value,
    required ValueChanged<bool?> onChanged,
  }) {
    return Row(
      children: [
        Expanded(child: Text(label, style: const TextStyle(fontSize: 16))),
        Checkbox(value: value, onChanged: onChanged),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F0F0),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _filterCheckRow(
            label: 'Show open locations only',
            value: tempShowOpenOnly,
            onChanged: (value) {
              setState(() {
                tempShowOpenOnly = value ?? false;
              });
            },
          ),
          _filterCheckRow(
            label: 'Show accepting items only',
            value: tempShowAcceptingOnly,
            onChanged: (value) {
              setState(() {
                tempShowAcceptingOnly = value ?? true;
              });
            },
          ),
          const Divider(),
          const SizedBox(height: 8),
          const Text('Distance:', style: TextStyle(fontSize: 16)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: [
              _distanceOption(
                label: 'within 500m',
                value: 0.5,
                groupValue: tempDistanceKm,
                onTap: () {
                  setState(() {
                    tempDistanceKm = 0.5;
                  });
                },
              ),
              _distanceOption(
                label: '<2km',
                value: 2,
                groupValue: tempDistanceKm,
                onTap: () {
                  setState(() {
                    tempDistanceKm = 2;
                  });
                },
              ),
              _distanceOption(
                label: '<5km',
                value: 5,
                groupValue: tempDistanceKm,
                onTap: () {
                  setState(() {
                    tempDistanceKm = 5;
                  });
                },
              ),
              _distanceOption(
                label: 'All',
                value: null,
                groupValue: tempDistanceKm,
                onTap: () {
                  setState(() {
                    tempDistanceKm = null;
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 18),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFA7E1C8),
                foregroundColor: Colors.black87,
              ),
              onPressed: () {
                widget.onOpenOnlyChanged(tempShowOpenOnly);
                widget.onAcceptingOnlyChanged(tempShowAcceptingOnly);
                widget.onDistanceChanged(tempDistanceKm);
                widget.onApply();
              },
              child: const Text('Apply'),
            ),
          ),
        ],
      ),
    );
  }
}
