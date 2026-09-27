import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';
import '../../models/material_model.dart';
import '../../models/user_model.dart';
import '../../services/firestore_service.dart';
import '../../widgets/category_card.dart';
import '../../widgets/material_card.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/refab_logo.dart';
import '../../widgets/reusehub_loading_sign.dart';
import 'material_details_screen.dart';
import 'favorites_screen.dart';
import '../notifications/notifications_screen.dart';

class MakerHomeScreen extends StatefulWidget {
  const MakerHomeScreen({super.key});

  @override
  State<MakerHomeScreen> createState() => _MakerHomeScreenState();
}

class _MakerHomeScreenState extends State<MakerHomeScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final String _currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';
  String _selectedCategory = 'All';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const ReFabLogo(
          size: 28,
          isHorizontal: true,
          showTagline: false,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite_border),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const FavoritesScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const NotificationsScreen()),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            setState(() {});
          },
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Welcome Banner
                StreamBuilder<UserModel?>(
                  stream: _firestoreService.streamUserData(_currentUserId),
                  builder: (context, snapshot) {
                    String name = snapshot.data?.name ?? 'Maker';
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hello, $name 👋',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimaryColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Find materials. Create something new.',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppTheme.textSecondaryColor,
                          ),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 16),

                // App Message Banner
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.primaryColor.withOpacity(0.2)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.lightbulb_outline, color: AppTheme.primaryColor),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          AppConstants.appHomeMessage,
                          style: const TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w500,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Search Bar
                TextField(
                  controller: _searchController,
                  onChanged: (val) {
                    setState(() {
                      _searchQuery = val.trim();
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Search metal, wood, packaging...',
                    prefixIcon: const Icon(Icons.search, color: AppTheme.textSecondaryColor),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, color: AppTheme.textSecondaryColor),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _searchQuery = '');
                            },
                          )
                        : null,
                  ),
                ),
                const SizedBox(height: 20),

                // Categories Header
                const Text(
                  'Categories',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimaryColor,
                  ),
                ),
                const SizedBox(height: 12),

                // Horizontal Category Selector
                SizedBox(
                  height: 44,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: AppConstants.categories.length,
                    itemBuilder: (context, index) {
                      String category = AppConstants.categories[index];
                      return CategoryCard(
                        categoryName: category,
                        isSelected: _selectedCategory == category,
                        onTap: () {
                          setState(() {
                            _selectedCategory = category;
                          });
                        },
                      );
                    },
                  ),
                ),
                const SizedBox(height: 24),

                // Materials List Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _selectedCategory == 'All'
                          ? 'Latest Materials'
                          : '$_selectedCategory Materials',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimaryColor,
                      ),
                    ),
                    Text(
                      'Gujranwala',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primaryColor.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Material Stream
                StreamBuilder<List<MaterialModel>>(
                  stream: _firestoreService.getAvailableMaterials(
                    category: _selectedCategory,
                    searchQuery: _searchQuery,
                  ),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(32.0),
                          child: ReUseLoadingSign(
                            size: 50,
                            isDark: false,
                            message: 'Finding materials in Gujranwala...',
                          ),
                        ),
                      );
                    }

                    final materials = snapshot.data ?? [];

                    if (materials.isEmpty) {
                      return EmptyState(
                        title: 'No materials found',
                        description: _searchQuery.isNotEmpty
                            ? 'Try another search term or select a different category.'
                            : 'New materials will appear here when suppliers list them.',
                      );
                    }

                    return StreamBuilder<List<String>>(
                      stream: _firestoreService.getUserFavoriteMaterialIds(_currentUserId),
                      builder: (context, favSnapshot) {
                        final favIds = favSnapshot.data ?? [];

                        return ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: materials.length,
                          itemBuilder: (context, index) {
                            final mat = materials[index];
                            final isFav = favIds.contains(mat.id);

                            return MaterialCard(
                              material: mat,
                              isFavorite: isFav,
                              onFavoriteToggle: () {
                                _firestoreService.toggleFavorite(_currentUserId, mat.id);
                              },
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => MaterialDetailsScreen(material: mat),
                                  ),
                                );
                              },
                            );
                          },
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
