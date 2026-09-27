import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';
import '../../services/firestore_service.dart';
import '../../widgets/custom_button.dart';
import '../maker/maker_main_screen.dart';
import '../supplier/supplier_main_screen.dart';

class RoleSelectionScreen extends StatefulWidget {
  final String userId;

  const RoleSelectionScreen({super.key, required this.userId});

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen> {
  String _selectedRole = AppConstants.roleMaker;
  bool _isLoading = false;
  final FirestoreService _firestoreService = FirestoreService();

  void _saveRoleAndProceed() async {
    setState(() => _isLoading = true);
    try {
      await _firestoreService.updateUserRole(widget.userId, _selectedRole);

      if (!mounted) return;

      if (_selectedRole == AppConstants.roleSupplier) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const SupplierMainScreen()),
          (route) => false,
        );
      } else {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const MakerMainScreen()),
          (route) => false,
        );
      }
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
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              const Text(
                'Choose Your Role',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimaryColor,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Select how you would like to use ReUse.',
                style: TextStyle(fontSize: 15, color: AppTheme.textSecondaryColor),
              ),
              const SizedBox(height: 36),

              // Supplier Card
              _buildRoleCard(
                role: AppConstants.roleSupplier,
                emoji: '🏭',
                title: 'Supplier',
                subtitle: 'I have materials to share.',
                description: 'For workshops, small industries, manufacturers, or businesses with leftover offcuts, packaging, or scrap.',
              ),

              const SizedBox(height: 20),

              // Maker Card
              _buildRoleCard(
                role: AppConstants.roleMaker,
                emoji: '👩‍💻',
                title: 'Maker',
                subtitle: 'I need materials for projects.',
                description: 'For students, designers, artists, DIY enthusiasts, and startups looking for affordable reusable materials.',
              ),

              const Spacer(),

              CustomButton(
                text: 'Continue',
                isLoading: _isLoading,
                onPressed: _saveRoleAndProceed,
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleCard({
    required String role,
    required String emoji,
    required String title,
    required String subtitle,
    required String description,
  }) {
    bool isSelected = _selectedRole == role;

    return GestureDetector(
      onTap: () => setState(() => _selectedRole = role),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppTheme.primaryColor : AppTheme.dividerColor,
            width: isSelected ? 2.5 : 1.0,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppTheme.primaryColor.withOpacity(0.15),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected ? AppTheme.primaryColor.withOpacity(0.1) : AppTheme.backgroundColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(emoji, style: const TextStyle(fontSize: 32)),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimaryColor,
                        ),
                      ),
                      const Spacer(),
                      Radio<String>(
                        value: role,
                        groupValue: _selectedRole,
                        activeColor: AppTheme.primaryColor,
                        onChanged: (val) {
                          if (val != null) setState(() => _selectedRole = val);
                        },
                      ),
                    ],
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.textSecondaryColor,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
