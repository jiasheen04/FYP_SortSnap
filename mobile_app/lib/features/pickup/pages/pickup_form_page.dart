import 'package:flutter/material.dart';
import 'package:mobile_app/features/pickup/services/pickup_service.dart';

class PickupFormPage extends StatefulWidget {
  const PickupFormPage({super.key});

  @override
  State<PickupFormPage> createState() => _PickupFormPageState();
}

class _PickupFormPageState extends State<PickupFormPage> {
  final PickupService _pickupService = PickupService();

  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _unitNoController = TextEditingController();
  final TextEditingController _postalCodeController = TextEditingController();
  final TextEditingController _remarksController = TextEditingController();

  bool _isSubmitting = false;

  final List<String> _allItemTypes = [
    'Plastic',
    'Metal',
    'Paper',
    'Cardboard',
    'E-waste',
    'Glass',
    'Others',
  ];

  final Set<String> _selectedItems = {};

  void _toggleItem(String item) {
    setState(() {
      if (_selectedItems.contains(item)) {
        _selectedItems.remove(item);
      } else {
        _selectedItems.add(item);
      }
    });
  }

  Future<void> _submitRequest() async {
    if (_addressController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter pickup address')),
      );
      return;
    }

    if (_selectedItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one item type')),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      await _pickupService.submitPickupRequest(
        pickupAddress: _addressController.text,
        unitNo: _unitNoController.text.trim().isEmpty
            ? null
            : _unitNoController.text,
        postalCode: _postalCodeController.text.trim().isEmpty
            ? null
            : _postalCodeController.text,
        remarks: _remarksController.text.trim().isEmpty
            ? null
            : _remarksController.text,
        itemTypes: _selectedItems.toList(),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pickup request submitted successfully')),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to submit request: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _addressController.dispose();
    _unitNoController.dispose();
    _postalCodeController.dispose();
    _remarksController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD5EDE4),
      appBar: AppBar(
        backgroundColor: const Color(0xFF62C49D),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.white,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'New Pickup Request',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Request Recycling Pickup',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              'Fill in the details below and we will arrange a pickup for you.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.black54,
                height: 1.5,
              ),
            ),

            const SizedBox(height: 28),

            const Text(
              'Pickup Address *',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 8),

            TextField(
              controller: _addressController,
              maxLines: 3,
              decoration: _inputDecoration('Enter your full address'),
            ),

            const SizedBox(height: 22),

            Row(
              children: [
                Expanded(
                  child: _buildSmallInput(
                    label: 'Unit No.',
                    hint: 'e.g. A-12-3',
                    controller: _unitNoController,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: _buildSmallInput(
                    label: 'Postal Code',
                    hint: 'e.g. 63000',
                    controller: _postalCodeController,
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            const Text(
              'Item Types *',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 4),

            const Text(
              'Select items for pickup',
              style: TextStyle(
                fontSize: 13,
                color: Colors.black54,
              ),
            ),

            const SizedBox(height: 14),

            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: _allItemTypes.map((item) {
                final bool isSelected = _selectedItems.contains(item);

                return GestureDetector(
                  onTap: () => _toggleItem(item),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 11,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFF51BA90)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFF51BA90)
                            : Colors.grey.shade300,
                      ),
                    ),
                    child: Text(
                      item,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.black87,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 24),

            const Text(
              'Remarks',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 8),

            TextField(
              controller: _remarksController,
              maxLines: 4,
              decoration: _inputDecoration('Any additional notes (optional)'),
            ),

            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitRequest,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF51BA90),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'Submit Request',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSmallInput({
    required String label,
    required String hint,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: _inputDecoration(hint),
        ),
      ],
    );
  }

  InputDecoration _inputDecoration(String hintText) {
    return InputDecoration(
      hintText: hintText,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 18,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
    );
  }
}