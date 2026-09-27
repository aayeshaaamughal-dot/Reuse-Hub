import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';
import '../../models/material_model.dart';
import '../../models/request_model.dart';
import '../../models/user_model.dart';
import '../../services/firestore_service.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class MaterialDetailsScreen extends StatefulWidget {
  final MaterialModel material;

  const MaterialDetailsScreen({super.key, required this.material});

  @override
  State<MaterialDetailsScreen> createState() => _MaterialDetailsScreenState();
}

class _MaterialDetailsScreenState extends State<MaterialDetailsScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final String _currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';

  UserModel? _currentUserModel;

  @override
  void initState() {
    super.initState();
    _loadCurrentUserData();
  }

  void _loadCurrentUserData() async {
    if (_currentUserId.isNotEmpty) {
      final model = await _firestoreService.getUserData(_currentUserId);
      if (mounted) setState(() => _currentUserModel = model);
    }
  }

  void _openRequestDialog() {
    if (_currentUserId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in to send requests.')),
      );
      return;
    }

    final TextEditingController qtyController =
        TextEditingController(text: widget.material.quantity);
    final TextEditingController purposeController = TextEditingController();
    final TextEditingController messageController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    bool isSubmitting = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                top: 24,
                left: 24,
                right: 24,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Request ${widget.material.name}',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                      const Divider(),
                      const SizedBox(height: 12),

                      // Quantity Needed
                      CustomTextField(
                        controller: qtyController,
                        labelText: 'Required Quantity',
                        hintText: 'e.g. 4 pieces or 2 kg',
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) return 'Please enter quantity';
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Purpose
                      CustomTextField(
                        controller: purposeController,
                        labelText: 'Purpose / Project',
                        hintText: 'e.g. University design project, prototype, art work',
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) return 'Please state your project purpose';
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Message
                      CustomTextField(
                        controller: messageController,
                        labelText: 'Message to Supplier',
                        hintText: 'Add a friendly note for the material supplier...',
                        maxLines: 3,
                      ),
                      const SizedBox(height: 24),

                      CustomButton(
                        text: 'Send Request',
                        isLoading: isSubmitting,
                        onPressed: () async {
                          if (!formKey.currentState!.validate()) return;

                          setModalState(() => isSubmitting = true);

                          try {
                            final req = RequestModel(
                              id: '',
                              materialId: widget.material.id,
                              materialName: widget.material.name,
                              materialImageUrl: widget.material.imageUrl,
                              supplierId: widget.material.supplierId,
                              supplierName: widget.material.supplierName,
                              makerId: _currentUserId,
                              makerName: _currentUserModel?.name ?? 'Maker User',
                              makerPhone: _currentUserModel?.phone ?? '',
                              requestedQuantity: qtyController.text.trim(),
                              purpose: purposeController.text.trim(),
                              message: messageController.text.trim(),
                              status: AppConstants.requestPending,
                              createdAt: DateTime.now(),
                              updatedAt: DateTime.now(),
                            );

                            await _firestoreService.sendMaterialRequest(req);

                            if (!context.mounted) return;
                            Navigator.pop(context); // Close bottom sheet

                            _showSuccessDialog();
                          } catch (e) {
                            if (!context.mounted) return;
                            setModalState(() => isSubmitting = false);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(e.toString()), backgroundColor: AppTheme.errorColor),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Text('🎉 ', style: TextStyle(fontSize: 24)),
            Expanded(child: Text('Request Sent Successfully', style: TextStyle(fontSize: 18))),
          ],
        ),
        content: const Text(
          'The supplier can now review your request. You can check the status anytime under the Requests tab.',
          style: TextStyle(color: AppTheme.textSecondaryColor),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Great!'),
          ),
        ],
      ),
    );
  }

  void _showContactSupplierDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Contact Supplier'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              leading: const CircleAvatar(
                backgroundColor: AppTheme.primaryColor,
                child: Icon(Icons.store, color: Colors.white),
              ),
              title: Text(
                widget.material.supplierName,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(widget.material.location),
            ),
            const SizedBox(height: 12),
            const Text(
              '💡 Note: For security and privacy, supplier phone numbers are revealed once your request is accepted by the supplier.',
              style: TextStyle(fontSize: 12, color: AppTheme.textSecondaryColor),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _openRequestDialog();
            },
            child: const Text('Submit Request Now'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isFree = widget.material.availabilityType.toLowerCase() == 'free';
    String formattedDate = DateFormat('MMM dd, yyyy').format(widget.material.createdAt);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Material Details'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Large Image Header
              Stack(
                children: [
                  widget.material.imageUrl.isNotEmpty
                      ? Image.network(
                          widget.material.imageUrl,
                          height: 250,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            height: 250,
                            color: AppTheme.primaryColor.withOpacity(0.1),
                            child: Center(
                              child: Text(
                                AppConstants.getCategoryEmoji(widget.material.category),
                                style: const TextStyle(fontSize: 72),
                              ),
                            ),
                          ),
                        )
                      : Container(
                          height: 250,
                          color: AppTheme.primaryColor.withOpacity(0.1),
                          child: Center(
                            child: Text(
                              AppConstants.getCategoryEmoji(widget.material.category),
                              style: const TextStyle(fontSize: 72),
                            ),
                          ),
                        ),
                  Positioned(
                    top: 16,
                    left: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: isFree ? AppTheme.primaryColor : AppTheme.accentColor,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                      child: Text(
                        isFree ? 'FREE' : 'Rs. ${widget.material.price.toStringAsFixed(0)}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Category Chip
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            '${AppConstants.getCategoryEmoji(widget.material.category)} ${widget.material.category}',
                            style: const TextStyle(
                              color: AppTheme.primaryColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          'Posted: $formattedDate',
                          style: const TextStyle(color: AppTheme.textSecondaryColor, fontSize: 12),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Material Title
                    Text(
                      widget.material.name,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimaryColor,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Info Cards Grid
                    Row(
                      children: [
                        Expanded(
                          child: _buildInfoCard(
                            title: 'Quantity',
                            value: '${widget.material.quantity} ${widget.material.unit}',
                            icon: Icons.inventory_2_outlined,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildInfoCard(
                            title: 'Condition',
                            value: widget.material.condition,
                            icon: Icons.check_circle_outline,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Description
                    const Text(
                      'Description',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.material.description,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppTheme.textPrimaryColor,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Location & Supplier Box
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.backgroundColor,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppTheme.dividerColor),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.location_on, color: AppTheme.primaryColor),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  widget.material.location,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const Divider(height: 24),
                          Row(
                            children: [
                              const CircleAvatar(
                                backgroundColor: AppTheme.primaryColor,
                                radius: 20,
                                child: Icon(Icons.store, color: Colors.white, size: 20),
                              ),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Material Supplier',
                                    style: TextStyle(fontSize: 12, color: AppTheme.textSecondaryColor),
                                  ),
                                  Text(
                                    widget.material.supplierName,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.textPrimaryColor,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Action Buttons
                    CustomButton(
                      text: 'Request Material',
                      onPressed: _openRequestDialog,
                      icon: Icons.send,
                    ),
                    const SizedBox(height: 12),
                    CustomButton(
                      text: 'Contact Supplier',
                      isOutline: true,
                      onPressed: _showContactSupplierDialog,
                      icon: Icons.chat_bubble_outline,
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.dividerColor),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.primaryColor, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 11, color: AppTheme.textSecondaryColor)),
                Text(
                  value,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
