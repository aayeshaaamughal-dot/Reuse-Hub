import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';
import '../../models/material_model.dart';
import '../../services/firestore_service.dart';
import '../../widgets/empty_state.dart';
import 'add_material_screen.dart';
import 'edit_material_screen.dart';

class MyListingsScreen extends StatefulWidget {
  const MyListingsScreen({super.key});

  @override
  State<MyListingsScreen> createState() => _MyListingsScreenState();
}

class _MyListingsScreenState extends State<MyListingsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final FirestoreService _firestoreService = FirestoreService();
  final String _currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _confirmDelete(MaterialModel material) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete this listing?'),
        content: const Text(
          'This material will no longer appear in available marketplace listings.',
          style: TextStyle(color: AppTheme.textSecondaryColor),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.errorColor),
            onPressed: () async {
              Navigator.pop(context);
              try {
                await _firestoreService.deleteMaterial(material.id);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Listing deleted.')),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(e.toString()), backgroundColor: AppTheme.errorColor),
                  );
                }
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Material Listings'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppTheme.primaryColor,
          unselectedLabelColor: AppTheme.textSecondaryColor,
          indicatorColor: AppTheme.primaryColor,
          tabs: const [
            Tab(text: 'Active'),
            Tab(text: 'Requested'),
            Tab(text: 'Collected'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddMaterialScreen()),
          );
        },
        backgroundColor: AppTheme.primaryColor,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Add Material', style: TextStyle(color: Colors.white)),
      ),
      body: SafeArea(
        child: StreamBuilder<List<MaterialModel>>(
          stream: _firestoreService.getSupplierListings(_currentUserId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor));
            }

            final listings = snapshot.data ?? [];

            return TabBarView(
              controller: _tabController,
              children: [
                _buildListingsView(listings, AppConstants.materialStatusAvailable),
                _buildListingsView(listings, AppConstants.materialStatusRequested),
                _buildListingsView(listings, AppConstants.materialStatusCollected),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildListingsView(List<MaterialModel> allListings, String status) {
    final filtered = allListings.where((m) => m.status.toLowerCase() == status.toLowerCase()).toList();

    if (filtered.isEmpty) {
      return EmptyState(
        title: 'No $status listings',
        description: 'You haven\'t listed any materials in this state.',
        buttonText: status == AppConstants.materialStatusAvailable ? '+ Add Material' : null,
        onButtonPressed: status == AppConstants.materialStatusAvailable
            ? () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AddMaterialScreen()),
                );
              }
            : null,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final mat = filtered[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Image
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: mat.imageUrl.isNotEmpty
                      ? Image.network(
                          mat.imageUrl,
                          width: 70,
                          height: 70,
                          fit: BoxFit.cover,
                          errorBuilder: (c, e, s) => Container(
                            width: 70,
                            height: 70,
                            color: AppTheme.primaryColor.withOpacity(0.1),
                            child: Center(child: Text(AppConstants.getCategoryEmoji(mat.category))),
                          ),
                        )
                      : Container(
                          width: 70,
                          height: 70,
                          color: AppTheme.primaryColor.withOpacity(0.1),
                          child: Center(child: Text(AppConstants.getCategoryEmoji(mat.category))),
                        ),
                ),
                const SizedBox(width: 12),

                // Title & Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        mat.name,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${mat.category} • ${mat.quantity} ${mat.unit}',
                        style: const TextStyle(fontSize: 12, color: AppTheme.textSecondaryColor),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        mat.availabilityType == 'Free' ? 'FREE' : 'Rs. ${mat.price.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),

                // Actions Popup
                PopupMenuButton<String>(
                  onSelected: (val) {
                    if (val == 'edit') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditMaterialScreen(material: mat),
                        ),
                      );
                    } else if (val == 'delete') {
                      _confirmDelete(mat);
                    }
                  },
                  itemBuilder: (context) => const [
                    PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit_outlined, size: 18),
                          SizedBox(width: 8),
                          Text('Edit'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete_outline, size: 18, color: AppTheme.errorColor),
                          SizedBox(width: 8),
                          Text('Delete', style: TextStyle(color: AppTheme.errorColor)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
