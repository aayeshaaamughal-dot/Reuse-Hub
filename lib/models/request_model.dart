class RequestModel {
  final String id;
  final String materialId;
  final String materialName;
  final String materialImageUrl;
  final String supplierId;
  final String supplierName;
  final String makerId;
  final String makerName;
  final String makerPhone;
  final String requestedQuantity;
  final String purpose;
  final String message;
  final String status; // 'pending', 'accepted', 'rejected', 'completed'
  final DateTime createdAt;
  final DateTime updatedAt;

  RequestModel({
    required this.id,
    required this.materialId,
    required this.materialName,
    this.materialImageUrl = '',
    required this.supplierId,
    required this.supplierName,
    required this.makerId,
    required this.makerName,
    this.makerPhone = '',
    required this.requestedQuantity,
    required this.purpose,
    required this.message,
    this.status = 'pending',
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'materialId': materialId,
      'materialName': materialName,
      'materialImageUrl': materialImageUrl,
      'supplierId': supplierId,
      'supplierName': supplierName,
      'makerId': makerId,
      'makerName': makerName,
      'makerPhone': makerPhone,
      'requestedQuantity': requestedQuantity,
      'purpose': purpose,
      'message': message,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory RequestModel.fromMap(Map<String, dynamic> map, String docId) {
    return RequestModel(
      id: docId,
      materialId: map['materialId'] ?? '',
      materialName: map['materialName'] ?? '',
      materialImageUrl: map['materialImageUrl'] ?? '',
      supplierId: map['supplierId'] ?? '',
      supplierName: map['supplierName'] ?? 'Supplier',
      makerId: map['makerId'] ?? '',
      makerName: map['makerName'] ?? 'Maker',
      makerPhone: map['makerPhone'] ?? '',
      requestedQuantity: map['requestedQuantity'] ?? '1',
      purpose: map['purpose'] ?? '',
      message: map['message'] ?? '',
      status: map['status'] ?? 'pending',
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: map['updatedAt'] != null
          ? DateTime.tryParse(map['updatedAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  RequestModel copyWith({
    String? status,
  }) {
    return RequestModel(
      id: id,
      materialId: materialId,
      materialName: materialName,
      materialImageUrl: materialImageUrl,
      supplierId: supplierId,
      supplierName: supplierName,
      makerId: makerId,
      makerName: makerName,
      makerPhone: makerPhone,
      requestedQuantity: requestedQuantity,
      purpose: purpose,
      message: message,
      status: status ?? this.status,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
}
