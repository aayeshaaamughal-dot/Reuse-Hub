import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/theme/app_theme.dart';
import '../../models/material_model.dart';
import '../../services/firestore_service.dart';
import '../../widgets/material_card.dart';
import '../../widgets/empty_state.dart';
import 'material_details_screen.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final String _currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Materials'),
      ),
      body: SafeArea(
        child: StreamBuilder<List<String>>(
          stream: _firestoreService.getUserFavoriteMaterialIds(_currentUserId),
          builder: (context, favSnapshot) {
            if (favSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor));
            }

            final favIds = favSnapshot.data ?? [];

            if (favIds.isEmpty) {
              return const EmptyState(
                emoji: '❤️',
                title: 'No saved materials yet',
                description: 'Tap the heart icon on any material to save it for quick access.',
              );
            }

            return StreamBuilder<List<MaterialModel>>(
              stream: _firestoreService.getAvailableMaterials(),
              builder: (context, matSnapshot) {
                if (matSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor));
                }

                final allMaterials = matSnapshot.data ?? [];
                final favMaterials = allMaterials.where((m) => favIds.contains(m.id)).toList();

                if (favMaterials.isEmpty) {
                  return const EmptyState(
                    title: 'No saved materials available',
                    description: 'Saved items may have been removed or marked completed.',
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: favMaterials.length,
                  itemBuilder: (context, index) {
                    final mat = favMaterials[index];
                    return MaterialCard(
                      material: mat,
                      isFavorite: true,
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
      ),
    );
  }
}
