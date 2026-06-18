import 'package:flutter/material.dart';
import 'package:mobile_app/features/pickup/models/pickup_request.dart';
import 'package:mobile_app/features/pickup/pages/pickup_form_page.dart';
import 'package:mobile_app/features/pickup/services/pickup_service.dart';
import 'package:mobile_app/features/pickup/widgets/pickup_request_card.dart';

class PickupPage extends StatefulWidget {
  const PickupPage({super.key});

  @override
  State<PickupPage> createState() => _PickupPageState();
}

class _PickupPageState extends State<PickupPage> {
  final PickupService _pickupService = PickupService();

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
          'Pickup Request',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
      ),
      body: StreamBuilder<List<PickupRequest>>(
        stream: _pickupService.getUserPickupRequestsStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF51BA90),
              ),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Failed to load pickup requests.\n${snapshot.error}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.black54),
                ),
              ),
            );
          }

          final List<PickupRequest> requests = snapshot.data ?? [];

          final List<PickupRequest> pendingRequests = requests.where((request) {
            return request.status.toLowerCase() == 'pending';
          }).toList();

          final List<PickupRequest> forwardedRequests =
              requests.where((request) {
            return request.status.toLowerCase() == 'forwarded';
          }).toList();

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildNewRequestButton(context),

                const SizedBox(height: 22),

                _buildSectionTitle('Pending Request'),
                const SizedBox(height: 10),

                if (pendingRequests.isEmpty)
                  _buildEmptyBox('No pending request yet.')
                else
                  ...pendingRequests.map(
                    (request) => PickupRequestCard(request: request),
                  ),

                const SizedBox(height: 48),

                _buildSectionTitle('Forwarded Request'),
                const SizedBox(height: 10),

                if (forwardedRequests.isEmpty)
                  _buildEmptyBox('No forwarded request yet.')
                else
                  ...forwardedRequests.map(
                    (request) => PickupRequestCard(request: request),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildNewRequestButton(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: OutlinedButton.icon(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const PickupFormPage(),
            ),
          );
        },
        icon: const Icon(Icons.add, size: 18),
        label: const Text('New Request'),
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFF2D9C75),
          side: const BorderSide(color: Color(0xFF2D9C75)),
          padding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 10,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        color: Colors.grey[600],
        fontSize: 14,
        fontWeight: FontWeight.w800,
      ),
    );
  }

  Widget _buildEmptyBox(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.65),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        message,
        style: const TextStyle(
          color: Colors.black54,
          fontSize: 13,
        ),
      ),
    );
  }
}