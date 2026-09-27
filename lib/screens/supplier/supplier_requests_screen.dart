import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';
import '../../models/request_model.dart';
import '../../services/firestore_service.dart';
import '../../widgets/request_card.dart';
import '../../widgets/empty_state.dart';

class SupplierRequestsScreen extends StatefulWidget {
  const SupplierRequestsScreen({super.key});

  @override
  State<SupplierRequestsScreen> createState() => _SupplierRequestsScreenState();
}

class _SupplierRequestsScreenState extends State<SupplierRequestsScreen> with SingleTickerProviderStateMixin {
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

  void _handleRequestStatusUpdate(RequestModel request, String newStatus) async {
    try {
      await _firestoreService.updateRequestStatus(request.id, newStatus, request);
      if (mounted) {
        String msg = newStatus == AppConstants.requestAccepted
            ? 'Request accepted! Maker notified.'
            : newStatus == AppConstants.requestRejected
                ? 'Request declined.'
                : 'Marked as collected!';
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: AppTheme.errorColor),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Incoming Material Requests'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppTheme.primaryColor,
          unselectedLabelColor: AppTheme.textSecondaryColor,
          indicatorColor: AppTheme.primaryColor,
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
          stream: _firestoreService.getSupplierRequests(_currentUserId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor));
            }

            final requests = snapshot.data ?? [];

            return TabBarView(
              controller: _tabController,
              children: [
                _buildRequestsList(requests, AppConstants.requestPending),
                _buildRequestsList(requests, AppConstants.requestAccepted),
                _buildRequestsList(requests, AppConstants.requestCompleted),
                _buildRequestsList(requests, AppConstants.requestRejected),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildRequestsList(List<RequestModel> allRequests, String status) {
    final filtered = allRequests.where((r) => r.status.toLowerCase() == status.toLowerCase()).toList();

    if (filtered.isEmpty) {
      return EmptyState(
        title: 'No $status requests',
        description: 'Requests in this state will appear here.',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final req = filtered[index];
        return RequestCard(
          request: req,
          isSupplier: true,
          onAccept: () => _handleRequestStatusUpdate(req, AppConstants.requestAccepted),
          onReject: () => _handleRequestStatusUpdate(req, AppConstants.requestRejected),
          onComplete: () => _handleRequestStatusUpdate(req, AppConstants.requestCompleted),
        );
      },
    );
  }
}
