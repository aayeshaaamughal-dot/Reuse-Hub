import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';
import '../../models/material_model.dart';
import '../../models/user_model.dart';
import '../../services/firestore_service.dart';
import '../../services/storage_service.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class AddMaterialScreen extends StatefulWidget {
  const AddMaterialScreen({super.key});

  @override
  State<AddMaterialScreen> createState() => _AddMaterialScreenState();
}

class _AddMaterialScreenState extends State<AddMaterialScreen> {
  final _formKey = GlobalKey<FormState>();
  final FirestoreService _firestoreService = FirestoreService();
  final StorageService _storageService = StorageService();
  final String _currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _locationController =
      TextEditingController(text: 'Small Industrial Estate, Gujranwala');

  String _selectedCategory = AppConstants.formCategories.first;
  String _selectedUnit = AppConstants.units.first;
  String _selectedCondition = AppConstants.conditions.first;
  String _availabilityType = AppConstants.availabilityFree;

  File? _imageFile;
  bool _isLoading = false;
  UserModel? _supplierUserModel;

  @override
  void initState() {
    super.initState();
    _loadSupplierInfo();
  }

  void _loadSupplierInfo() async {
    if (_currentUserId.isNotEmpty) {
      final model = await _firestoreService.getUserData(_currentUserId);
      if (mounted) setState(() => _supplierUserModel = model);
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      File? image = await _storageService.pickImage(source);
      if (image != null) {
        setState(() => _imageFile = image);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: AppTheme.errorColor),
      );
    }
  }

  void _showImageSourceModal() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt, color: AppTheme.primaryColor),
                title: const Text('Take Photo with Camera'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library, color: AppTheme.primaryColor),
                title: const Text('Choose from Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _submitMaterial() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      String imageUrl = '';
      if (_imageFile != null) {
        imageUrl = await _storageService.uploadMaterialImage(_imageFile!, _currentUserId);
      } else {
        // High quality default placeholder image based on selected category
        imageUrl = 'https://images.unsplash.com/photo-1504917595217-d4dc5ebe6122?w=500';
      }

      double price = 0.0;
      if (_availabilityType == AppConstants.availabilityPaid) {
        price = double.tryParse(_priceController.text) ?? 0.0;
      }

      final material = MaterialModel(
        id: '',
        name: _nameController.text.trim(),
        category: _selectedCategory,
        description: _descriptionController.text.trim(),
        quantity: _quantityController.text.trim(),
        unit: _selectedUnit,
        condition: _selectedCondition,
        availabilityType: _availabilityType,
        price: price,
        imageUrl: imageUrl,
        location: _locationController.text.trim(),
        supplierId: _currentUserId,
        supplierName: _supplierUserModel?.name ?? 'Ali Workshop',
        supplierPhone: _supplierUserModel?.phone ?? '03001234567',
        status: AppConstants.materialStatusAvailable,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _firestoreService.addMaterial(material);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Material listed successfully! 🎉')),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: AppTheme.errorColor),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Leftover Material'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image Upload Container
                GestureDetector(
                  onTap: _showImageSourceModal,
                  child: Container(
                    height: 180,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppTheme.backgroundColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppTheme.primaryColor.withOpacity(0.3), width: 1.5),
                    ),
                    child: _imageFile != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.file(_imageFile!, fit: BoxFit.cover, width: double.infinity),
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircleAvatar(
                                backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                                radius: 28,
                                child: const Icon(Icons.add_a_photo, color: AppTheme.primaryColor, size: 28),
                              ),
                              const SizedBox(height: 10),
                              const Text(
                                'Upload Material Photo',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.textPrimaryColor,
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'Tap to choose from camera or gallery',
                                style: TextStyle(fontSize: 12, color: AppTheme.textSecondaryColor),
                              ),
                            ],
                          ),
                  ),
                ),
                const SizedBox(height: 24),

                // Name Field
                CustomTextField(
                  controller: _nameController,
                  labelText: 'Material Name',
                  hintText: 'e.g. Metal Sheet Offcuts, Wooden Scraps',
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) return 'Please enter material name';
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Category Dropdown
                const Text('Category', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  decoration: const InputDecoration(),
                  items: AppConstants.formCategories.map((cat) {
                    return DropdownMenuItem(
                      value: cat,
                      child: Text('${AppConstants.getCategoryEmoji(cat)} $cat'),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedCategory = val);
                  },
                ),
                const SizedBox(height: 16),

                // Quantity & Unit
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: CustomTextField(
                        controller: _quantityController,
                        labelText: 'Quantity',
                        hintText: 'e.g. 12',
                        keyboardType: TextInputType.number,
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) return 'Enter quantity';
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Unit', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 6),
                          DropdownButtonFormField<String>(
                            value: _selectedUnit,
                            items: AppConstants.units.map((unit) {
                              return DropdownMenuItem(value: unit, child: Text(unit));
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) setState(() => _selectedUnit = val);
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Condition Dropdown
                const Text('Condition', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  value: _selectedCondition,
                  items: AppConstants.conditions.map((cond) {
                    return DropdownMenuItem(value: cond, child: Text(cond));
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedCondition = val);
                  },
                ),
                const SizedBox(height: 16),

                // Availability Selection (Free / Paid)
                const Text('Availability', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: ChoiceChip(
                        label: const Center(child: Text('FREE (Recommended)')),
                        selected: _availabilityType == AppConstants.availabilityFree,
                        selectedColor: AppTheme.primaryColor,
                        labelStyle: TextStyle(
                          color: _availabilityType == AppConstants.availabilityFree
                              ? Colors.white
                              : AppTheme.textPrimaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                        onSelected: (selected) {
                          if (selected) setState(() => _availabilityType = AppConstants.availabilityFree);
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ChoiceChip(
                        label: const Center(child: Text('Paid Price')),
                        selected: _availabilityType == AppConstants.availabilityPaid,
                        selectedColor: AppTheme.accentColor,
                        labelStyle: TextStyle(
                          color: _availabilityType == AppConstants.availabilityPaid
                              ? Colors.white
                              : AppTheme.textPrimaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                        onSelected: (selected) {
                          if (selected) setState(() => _availabilityType = AppConstants.availabilityPaid);
                        },
                      ),
                    ),
                  ],
                ),

                if (_availabilityType == AppConstants.availabilityPaid) ...[
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: _priceController,
                    labelText: 'Price (PKR)',
                    hintText: 'e.g. 350',
                    keyboardType: TextInputType.number,
                    prefixIcon: Icons.payments_outlined,
                    validator: (val) {
                      if (_availabilityType == AppConstants.availabilityPaid) {
                        if (val == null || val.trim().isEmpty) return 'Please enter price';
                      }
                      return null;
                    },
                  ),
                ],

                const SizedBox(height: 16),

                // Description
                CustomTextField(
                  controller: _descriptionController,
                  labelText: 'Description',
                  hintText: 'Describe size, material quality, dimensions or usage tips...',
                  maxLines: 3,
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) return 'Please enter description';
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Location
                CustomTextField(
                  controller: _locationController,
                  labelText: 'Location / Workshop Address',
                  hintText: 'Area in Gujranwala',
                  prefixIcon: Icons.location_on_outlined,
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) return 'Please enter location';
                    return null;
                  },
                ),
                const SizedBox(height: 32),

                // Submit Button
                CustomButton(
                  text: 'List Material',
                  isLoading: _isLoading,
                  onPressed: _submitMaterial,
                  icon: Icons.check,
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
