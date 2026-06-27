import 'package:flutter/material.dart';
import 'package:mobile_app/features/pickup/models/pickup_request.dart';

class PickupRequestCard extends StatelessWidget {
  final PickupRequest request;

  const PickupRequestCard({super.key, required this.request});

  bool _hasText(String? value) {
    return value != null && value.trim().isNotEmpty;
  }

  bool _isForwarded() {
    return request.status.toLowerCase() == 'forwarded';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _showRequestDetails(context),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Pickup ${request.pickupId.replaceAll('PR', '')}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE6F6EF),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      request.status,
                      style: const TextStyle(
                        color: Color(0xFF2D9C75),
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 6),

              Text(
                request.pickupAddress,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.black54, fontSize: 12),
              ),

              const SizedBox(height: 6),

              Text(
                request.itemTypes.join(', '),
                style: const TextStyle(
                  color: Color(0xFF2D9C75),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),

              if (_isForwarded() && _hasText(request.forwardedToPointName)) ...[
                const SizedBox(height: 6),
                Text(
                  'Recycling Point: ${request.forwardedToPointName}',
                  style: const TextStyle(
                    color: Colors.black54,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _showRequestDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 45,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),

              const SizedBox(height: 18),

              Text(
                'Pickup ${request.pickupId.replaceAll('PR', '')} Details',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),

              const SizedBox(height: 12),

              _buildDetailRow('Status', request.status),
              _buildDetailRow('Address', request.pickupAddress),

              if (request.unitNo != null && request.unitNo!.isNotEmpty)
                _buildDetailRow('Unit No.', request.unitNo!),

              if (request.postalCode != null && request.postalCode!.isNotEmpty)
                _buildDetailRow('Postal Code', request.postalCode!),

              _buildDetailRow('Items', request.itemTypes.join(', ')),

              if (request.remarks != null && request.remarks!.isNotEmpty)
                _buildDetailRow('Remarks', request.remarks!),

              if (_isForwarded() && _hasText(request.forwardedToPointName)) ...[
                const SizedBox(height: 6),
                const Divider(),

                _buildDetailRow(
                  'Recycling Point',
                  request.forwardedToPointName!,
                ),

                const SizedBox(height: 8),

                const Text(
                  'Note: The recycling point PIC will contact you for pickup arrangement.',
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ],

              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 115,
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.black54,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
