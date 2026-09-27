import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';
import '../../models/request_model.dart';
import '../../services/firestore_service.dart';
import '../../widgets/request_card.dart';
import '../../widgets/empty_state.dart';

class MakerRequestsScreen extends StatefulWidget {
  const MakerRequestsScreen({super.key});

  @override
  State<MakerRequestsScreen> createState() => _MakerRequestsScreenState();
}

class _MakerRequestsScreenState extends State<MakerRequestsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final FirestoreService _firestoreService = FirestoreService();
  final String _currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showContactDialog(RequestModel req) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Contact Supplier'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Supplier: ${req.supplierName}', style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Material: ${req.materialName}'),
            const SizedBox(height: 8),
            Text('Phone: ${req.makerPhone.isNotEmpty ? req.makerPhone : "0300 1234567"}'),
            const SizedBox(height: 12),
            const Text(
              'Your request is ACCEPTED! You can call or WhatsApp the supplier to coordinate collection.',
              style: TextStyle(fontSize: 12, color: AppTheme.primaryColor),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Material Requests'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppTheme.primaryColor,
          unselectedLabelColor: AppTheme.textSecondaryColor,
          indicatorColor: AppTheme.primaryColor,
          isScrollable: false,
          tabs: const [
            Tab(text: 'Pending'),
            Tab(text: 'Accepted'),
            Tab(text: 'Completed'),
            Tab(text: 'Rejected'),
          ],
        ),
      ),
      body: SafeArea(
        child: StreamBuilder<List<RequestModel>>(
          stream: _firestoreService.getMakerRequests(_currentUserId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor));
            }

            final allRequests = snapshot.data ?? [];

            return TabBarView(
              controller: _tabController,
              children: [
                _buildRequestList(allRequests, AppConstants.requestPending),
                _buildRequestList(allRequests, AppConstants.requestAccepted),
                _buildRequestList(allRequests, AppConstants.requestCompleted),
                _buildRequestList(allRequests, AppConstants.requestRejected),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildRequestList(List<RequestModel> requests, String targetStatus) {
    final filtered = requests
        .where((r) => r.status.toLowerCase() == targetStatus.toLowerCase())
        .toList();

    if (filtered.isEmpty) {
      return EmptyState(
        title: 'No $targetStatus requests',
        description: 'Requests in this category will appear here.',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final req = filtered[index];
        return RequestCard(
          request: req,
          isSupplier: false,
          onContact: () => _showContactDialog(req),
        );
      },
    );
  }
}
