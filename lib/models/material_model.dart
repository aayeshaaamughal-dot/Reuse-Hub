class MaterialModel {
  final String id;
  final String name;
  final String category;
  final String description;
  final String quantity;
  final String unit;
  final String condition;
  final String availabilityType; // 'Free' or 'Paid'
  final double price;
  final String imageUrl;
  final String location;
  final String supplierId;
  final String supplierName;
  final String supplierPhone;
  final String status; // 'available', 'requested', 'collected', 'inactive'
  final DateTime createdAt;
  final DateTime updatedAt;

  MaterialModel({
    required this.id,
    required this.name,
    required this.category,
    required this.description,
    required this.quantity,
    required this.unit,
    required this.condition,
    required this.availabilityType,
    this.price = 0.0,
    required this.imageUrl,
    required this.location,
    required this.supplierId,
    required this.supplierName,
    this.supplierPhone = '',
    this.status = 'available',
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'description': description,
      'quantity': quantity,
      'unit': unit,
      'condition': condition,
      'availabilityType': availabilityType,
      'price': price,
      'imageUrl': imageUrl,
      'location': location,
      'supplierId': supplierId,
      'supplierName': supplierName,
      'supplierPhone': supplierPhone,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory MaterialModel.fromMap(Map<String, dynamic> map, String docId) {
    return MaterialModel(
      id: docId,
      name: map['name'] ?? '',
      category: map['category'] ?? 'Other',
      description: map['description'] ?? '',
      quantity: map['quantity'] ?? '1',
      unit: map['unit'] ?? 'Pieces',
      condition: map['condition'] ?? 'Good',
      availabilityType: map['availabilityType'] ?? 'Free',
      price: (map['price'] ?? 0.0).toDouble(),
      imageUrl: map['imageUrl'] ?? '',
      location: map['location'] ?? 'Gujranwala',
      supplierId: map['supplierId'] ?? '',
      supplierName: map['supplierName'] ?? 'Supplier',
      supplierPhone: map['supplierPhone'] ?? '',
      status: map['status'] ?? 'available',
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: map['updatedAt'] != null
          ? DateTime.tryParse(map['updatedAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  MaterialModel copyWith({
    String? name,
    String? category,
    String? description,
    String? quantity,
    String? unit,
    String? condition,
    String? availabilityType,
    double? price,
    String? imageUrl,
    String? location,
    String? supplierName,
    String? supplierPhone,
    String? status,
  }) {
    return MaterialModel(
      id: id,
      name: name ?? this.name,
      category: category ?? this.category,
      description: description ?? this.description,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      condition: condition ?? this.condition,
      availabilityType: availabilityType ?? this.availabilityType,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
      location: location ?? this.location,
      supplierId: supplierId,
      supplierName: supplierName ?? this.supplierName,
      supplierPhone: supplierPhone ?? this.supplierPhone,
      status: status ?? this.status,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
}
