class PlaceModel {
  final String name;
  final String formattedAddress;
  final double? latitude;
  final double? longitude;
  final String? websiteUri;

  const PlaceModel({
    required this.name,
    required this.formattedAddress,
    this.latitude,
    this.longitude,
    this.websiteUri,
  });

  factory PlaceModel.fromJson(Map<String, dynamic> json) {
    String name = 'Unknown Industry';
    if (json['displayName'] != null && json['displayName'] is Map) {
      name = json['displayName']['text'] ?? 'Unknown Industry';
    }

    double? lat;
    double? lng;
    if (json['location'] != null && json['location'] is Map) {
      lat = (json['location']['latitude'] as num?)?.toDouble();
      lng = (json['location']['longitude'] as num?)?.toDouble();
    }

    return PlaceModel(
      name: name,
      formattedAddress: json['formattedAddress'] as String? ?? 'Gujranwala, Pakistan',
      latitude: lat,
      longitude: lng,
      websiteUri: json['websiteUri'] as String?,
    );
  }
}
