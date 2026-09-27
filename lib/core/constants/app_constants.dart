class AppConstants {
  static const String appName = 'ReUse';
  static const String tagline = 'From Scrap to Reuse';
  static const String subtitle = 'From Scrap to Reuse';
  static const String appHomeMessage =
      'Gujranwala makes things. ReUse helps leftover materials find their next maker.';

  // Roles
  static const String roleSupplier = 'supplier';
  static const String roleMaker = 'maker';

  // Categories
  static const List<String> categories = [
    'All',
    'Metal',
    'Wood',
    'Packaging',
    'Fabric',
    'Machine Parts',
    'Other',
  ];

  static const List<String> formCategories = [
    'Metal',
    'Wood',
    'Packaging',
    'Fabric',
    'Machine Parts',
    'Other',
  ];

  // Category Icons mapping
  static String getCategoryEmoji(String category) {
    switch (category.toLowerCase()) {
      case 'metal':
        return '🔩';
      case 'wood':
        return '🪵';
      case 'packaging':
        return '📦';
      case 'fabric':
        return '🧵';
      case 'machine parts':
        return '⚙️';
      case 'other':
      default:
        return '📦';
    }
  }

  // Units
  static const List<String> units = [
    'Pieces',
    'Kg',
    'Meter',
    'Box',
    'Other',
  ];

  // Conditions
  static const List<String> conditions = [
    'Good',
    'Usable',
    'Mixed',
  ];

  // Material Availability
  static const String availabilityFree = 'Free';
  static const String availabilityPaid = 'Paid';

  // Material Status
  static const String materialStatusAvailable = 'available';
  static const String materialStatusRequested = 'requested';
  static const String materialStatusCollected = 'collected';
  static const String materialStatusInactive = 'inactive';

  // Request Status
  static const String requestPending = 'pending';
  static const String requestAccepted = 'accepted';
  static const String requestRejected = 'rejected';
  static const String requestCompleted = 'completed';

  // Default City
  static const String defaultCity = 'Gujranwala';
}
