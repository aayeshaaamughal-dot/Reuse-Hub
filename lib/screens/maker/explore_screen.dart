import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';
import '../../models/material_model.dart';
import '../../models/place_model.dart';
import '../../services/firestore_service.dart';
import '../../services/places_service.dart';
import '../../widgets/material_card.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/reusehub_loading_sign.dart';
import 'material_details_screen.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Firebase Materials State
  final FirestoreService _firestoreService = FirestoreService();
  final TextEditingController _materialSearchController =
  TextEditingController();

  String _materialSearchQuery = '';
  String _selectedCategory = 'All';
  String _selectedAvailability = 'All';

  // Google Places API State
  final PlacesService _placesService = PlacesService();
  final TextEditingController _placesSearchController =
  TextEditingController();

  String _currentPlacesQuery = 'industries in Gujranwala Pakistan';
  List<PlaceModel> _places = [];
  bool _isLoadingPlaces = false;
  String? _placesErrorMessage;

  // Preset queries for Google Places search
  final List<Map<String, String>> _placesPresets = [
    {
      'label': '🏭 Industries',
      'query': 'industries in Gujranwala Pakistan',
    },
    {
      'label': '⚙️ Factories',
      'query': 'factories in Gujranwala Pakistan',
    },
    {
      'label': '♻️ Recycling',
      'query': 'recycling companies in Gujranwala Pakistan',
    },
    {
      'label': '🔩 Metal Industries',
      'query': 'metal industries in Gujranwala Pakistan',
    },
    {
      'label': '📦 Scrap Dealers',
      'query': 'scrap dealers in Gujranwala Pakistan',
    },
  ];

  @override
  void initState() {
    super.initState();

    _tabController = TabController(
      length: 2,
      vsync: this,
    );

    _placesSearchController.text = _currentPlacesQuery;

    _fetchPlaces(_currentPlacesQuery);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _materialSearchController.dispose();
    _placesSearchController.dispose();

    super.dispose();
  }

  Future<void> _fetchPlaces(String query) async {
    setState(() {
      _isLoadingPlaces = true;
      _placesErrorMessage = null;
      _currentPlacesQuery = query;
    });

    try {
      final results = await _placesService.searchPlaces(
        query: query,
      );

      if (!mounted) return;

      setState(() {
        _places = results;
        _isLoadingPlaces = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _placesErrorMessage = e.toString();
        _isLoadingPlaces = false;
      });
    }
  }

  void _showFilterModal() {
    String tempCategory = _selectedCategory;
    String tempAvailability = _selectedAvailability;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                top: 24,
                left: 24,
                right: 24,
                bottom:
                MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Filter Materials',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  ),
                  const Divider(),
                  const SizedBox(height: 12),

                  // Category Filter
                  const Text(
                    'Category',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 10),

                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children:
                    AppConstants.categories.map((cat) {
                      final bool isSelected =
                          tempCategory == cat;

                      return ChoiceChip(
                        label: Text(cat),
                        selected: isSelected,
                        selectedColor:
                        AppTheme.primaryColor,
                        labelStyle: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : AppTheme.textPrimaryColor,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                        onSelected: (selected) {
                          if (selected) {
                            setModalState(() {
                              tempCategory = cat;
                            });
                          }
                        },
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 20),

                  // Availability Filter
                  const Text(
                    'Availability',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 10),

                  Row(
                    children:
                    ['All', 'Free', 'Paid'].map((type) {
                      final bool isSelected =
                          tempAvailability == type;

                      return Padding(
                        padding:
                        const EdgeInsets.only(right: 8.0),
                        child: ChoiceChip(
                          label: Text(type),
                          selected: isSelected,
                          selectedColor:
                          AppTheme.primaryColor,
                          labelStyle: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : AppTheme.textPrimaryColor,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                          onSelected: (selected) {
                            if (selected) {
                              setModalState(() {
                                tempAvailability = type;
                              });
                            }
                          },
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 28),

                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            setModalState(() {
                              tempCategory = 'All';
                              tempAvailability = 'All';
                            });
                          },
                          child: const Text('Reset'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _selectedCategory =
                                  tempCategory;
                              _selectedAvailability =
                                  tempAvailability;
                            });

                            Navigator.pop(context);
                          },
                          child: const Text(
                            'Apply Filters',
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Explore Marketplace'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterModal,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppTheme.primaryColor,
          unselectedLabelColor:
          AppTheme.textSecondaryColor,
          indicatorColor: AppTheme.primaryColor,
          tabs: const [
            Tab(
              icon: Icon(
                Icons.inventory_2_outlined,
                size: 20,
              ),
              text: 'Scrap Materials',
            ),
            Tab(
              icon: Icon(
                Icons.location_city_outlined,
                size: 20,
              ),
              text: 'Gujranwala Industries',
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildMaterialsView(),
            _buildIndustriesPlacesView(),
          ],
        ),
      ),
    );
  }

  // ----------------------------------------------------------
  // TAB 1: FIREBASE MATERIALS
  // ----------------------------------------------------------

  Widget _buildMaterialsView() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(
                controller: _materialSearchController,
                onChanged: (val) {
                  setState(() {
                    _materialSearchQuery = val.trim();
                  });
                },
                decoration: InputDecoration(
                  hintText:
                  'Search material by name, description or location...',
                  prefixIcon: const Icon(
                    Icons.search,
                    color: AppTheme.textSecondaryColor,
                  ),
                  suffixIcon:
                  _materialSearchQuery.isNotEmpty
                      ? IconButton(
                    icon: const Icon(
                      Icons.clear,
                    ),
                    onPressed: () {
                      _materialSearchController
                          .clear();

                      setState(() {
                        _materialSearchQuery =
                        '';
                      });
                    },
                  )
                      : null,
                ),
              ),

              if (_selectedCategory != 'All' ||
                  _selectedAvailability != 'All') ...[
                const SizedBox(height: 12),

                Row(
                  children: [
                    if (_selectedCategory != 'All')
                      Chip(
                        label: Text(
                          'Category: $_selectedCategory',
                        ),
                        onDeleted: () {
                          setState(() {
                            _selectedCategory = 'All';
                          });
                        },
                        backgroundColor:
                        AppTheme.primaryColor
                            .withOpacity(0.1),
                      ),

                    const SizedBox(width: 8),

                    if (_selectedAvailability != 'All')
                      Chip(
                        label: Text(
                          'Type: $_selectedAvailability',
                        ),
                        onDeleted: () {
                          setState(() {
                            _selectedAvailability = 'All';
                          });
                        },
                        backgroundColor:
                        AppTheme.primaryColor
                            .withOpacity(0.1),
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),

        Expanded(
          child: StreamBuilder<List<MaterialModel>>(
            stream:
            _firestoreService.getAvailableMaterials(
              category: _selectedCategory,
              availability:
              _selectedAvailability,
              searchQuery:
              _materialSearchQuery,
            ),
            builder: (context, snapshot) {
              if (snapshot.connectionState ==
                  ConnectionState.waiting) {
                return const Center(
                  child: ReUseLoadingSign(
                    size: 50,
                    isDark: false,
                    message:
                    'Exploring marketplace...',
                  ),
                );
              }

              final materials =
                  snapshot.data ?? [];

              if (materials.isEmpty) {
                return EmptyState(
                  title: 'No materials found',
                  description:
                  'Try another search query or clear your active filters.',
                );
              }

              return ListView.builder(
                padding:
                const EdgeInsets.symmetric(
                  horizontal: 16,
                ),
                itemCount: materials.length,
                itemBuilder: (context, index) {
                  final mat = materials[index];

                  return MaterialCard(
                    material: mat,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              MaterialDetailsScreen(
                                material: mat,
                              ),
                        ),
                      );
                    },
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  // ----------------------------------------------------------
  // TAB 2: GOOGLE PLACES / GUJRANWALA INDUSTRIES
  // ----------------------------------------------------------

  Widget _buildIndustriesPlacesView() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              TextField(
                controller:
                _placesSearchController,
                onSubmitted: (val) {
                  if (val.trim().isNotEmpty) {
                    _fetchPlaces(val.trim());
                  }
                },
                decoration: InputDecoration(
                  hintText:
                  'Search e.g. factories in Gujranwala...',
                  prefixIcon: const Icon(
                    Icons.business_outlined,
                    color: AppTheme.primaryColor,
                  ),
                  suffixIcon: IconButton(
                    icon: const Icon(
                      Icons.search,
                      color: AppTheme.primaryColor,
                    ),
                    onPressed: () {
                      final query =
                      _placesSearchController
                          .text
                          .trim();

                      if (query.isNotEmpty) {
                        _fetchPlaces(query);
                      }
                    },
                  ),
                ),
              ),

              const SizedBox(height: 12),

              SizedBox(
                height: 38,
                child: ListView.builder(
                  scrollDirection:
                  Axis.horizontal,
                  itemCount:
                  _placesPresets.length,
                  itemBuilder: (context, index) {
                    final item =
                    _placesPresets[index];

                    final isSelected =
                        _currentPlacesQuery
                            .toLowerCase() ==
                            item['query']!
                                .toLowerCase();

                    return Padding(
                      padding:
                      const EdgeInsets.only(
                        right: 8.0,
                      ),
                      child: ChoiceChip(
                        label:
                        Text(item['label']!),
                        selected: isSelected,
                        selectedColor:
                        AppTheme.primaryColor,
                        labelStyle: TextStyle(
                          fontSize: 12.5,
                          color: isSelected
                              ? Colors.white
                              : AppTheme
                              .textPrimaryColor,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                        onSelected: (selected) {
                          if (selected) {
                            final query =
                            item['query']!;

                            _placesSearchController
                                .text = query;

                            _fetchPlaces(query);
                          }
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),

        Expanded(
          child:
          _buildPlacesResultsContent(),
        ),
      ],
    );
  }

  // ----------------------------------------------------------
  // GOOGLE PLACES RESULTS
  // ----------------------------------------------------------

  Widget _buildPlacesResultsContent() {
    if (_isLoadingPlaces) {
      return const Center(
        child: ReUseLoadingSign(
          size: 50,
          isDark: false,
          message:
          'Fetching real places from Google Places API...',
        ),
      );
    }

    if (_placesErrorMessage != null) {
      return Padding(
        padding:
        const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment:
          MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.cloud_off_outlined,
              size: 56,
              color: AppTheme.errorColor,
            ),

            const SizedBox(height: 16),

            const Text(
              'Google Places Error',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color:
                AppTheme.textPrimaryColor,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              _placesErrorMessage!,
              style: const TextStyle(
                fontSize: 13,
                color:
                AppTheme.textSecondaryColor,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 24),

            ElevatedButton.icon(
              onPressed: () {
                _fetchPlaces(
                  _currentPlacesQuery,
                );
              },
              icon:
              const Icon(Icons.refresh),
              label:
              const Text('Retry Search'),
              style:
              ElevatedButton.styleFrom(
                backgroundColor:
                AppTheme.primaryColor,
                padding:
                const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (_places.isEmpty) {
      return EmptyState(
        title:
        'No Gujranwala industries found',
        description:
        'Try searching for "factories in Gujranwala" or "recycling companies in Gujranwala".',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 8,
      ),
      itemCount: _places.length,
      itemBuilder: (context, index) {
        final place = _places[index];

        return _buildPlaceCard(place);
      },
    );
  }

  // ----------------------------------------------------------
  // PLACE CARD
  // ----------------------------------------------------------

  Widget _buildPlaceCard(
      PlaceModel place,
      ) {
    return Card(
      margin:
      const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius:
        BorderRadius.circular(16),
        side: BorderSide(
          color: AppTheme.dividerColor
              .withOpacity(0.8),
        ),
      ),
      elevation: 1,
      child: Padding(
        padding:
        const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Container(
                  padding:
                  const EdgeInsets.all(10),
                  decoration:
                  BoxDecoration(
                    color: AppTheme
                        .primaryColor
                        .withOpacity(0.1),
                    borderRadius:
                    BorderRadius.circular(
                      12,
                    ),
                  ),
                  child: const Icon(
                    Icons.factory_outlined,
                    color:
                    AppTheme.primaryColor,
                    size: 24,
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment
                        .start,
                    children: [
                      Text(
                        place.name,
                        style:
                        const TextStyle(
                          fontSize: 16,
                          fontWeight:
                          FontWeight.bold,
                          color: AppTheme
                              .textPrimaryColor,
                        ),
                      ),

                      const SizedBox(height: 4),

                      Row(
                        crossAxisAlignment:
                        CrossAxisAlignment
                            .start,
                        children: [
                          const Icon(
                            Icons
                                .location_on_outlined,
                            size: 15,
                            color: AppTheme
                                .textSecondaryColor,
                          ),

                          const SizedBox(
                            width: 4,
                          ),

                          Expanded(
                            child: Text(
                              place
                                  .formattedAddress,
                              style:
                              const TextStyle(
                                fontSize: 12.5,
                                color: AppTheme
                                    .textSecondaryColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            if (place.latitude != null ||
                place.websiteUri != null) ...[
              const SizedBox(height: 12),

              const Divider(),

              const SizedBox(height: 6),

              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: [
                  if (place.latitude != null &&
                      place.longitude != null)
                    Container(
                      padding:
                      const EdgeInsets
                          .symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration:
                      BoxDecoration(
                        color: Colors.blue
                            .withOpacity(0.08),
                        borderRadius:
                        BorderRadius
                            .circular(8),
                      ),
                      child: Row(
                        mainAxisSize:
                        MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.my_location,
                            size: 13,
                            color: Colors.blue,
                          ),

                          const SizedBox(
                            width: 4,
                          ),

                          Text(
                            '${place.latitude!.toStringAsFixed(4)}, ${place.longitude!.toStringAsFixed(4)}',
                            style:
                            const TextStyle(
                              fontSize: 11.5,
                              color:
                              Colors.blue,
                              fontWeight:
                              FontWeight
                                  .w600,
                            ),
                          ),
                        ],
                      ),
                    ),

                  if (place.websiteUri != null &&
                      place.websiteUri!.isNotEmpty)
                    Container(
                      padding:
                      const EdgeInsets
                          .symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration:
                      BoxDecoration(
                        color: AppTheme
                            .primaryColor
                            .withOpacity(0.08),
                        borderRadius:
                        BorderRadius
                            .circular(8),
                      ),
                      child: Row(
                        mainAxisSize:
                        MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.language,
                            size: 13,
                            color: AppTheme
                                .primaryColor,
                          ),

                          const SizedBox(
                            width: 4,
                          ),

                          Flexible(
                            child: Text(
                              place.websiteUri!,
                              style:
                              const TextStyle(
                                fontSize: 11.5,
                                color: AppTheme
                                    .primaryColor,
                                fontWeight:
                                FontWeight
                                    .w600,
                              ),
                              maxLines: 1,
                              overflow:
                              TextOverflow
                                  .ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
