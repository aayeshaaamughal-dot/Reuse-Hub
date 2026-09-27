import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/constants/api_constants.dart';
import '../models/place_model.dart';

class PlacesService {
  final http.Client _client;

  PlacesService({http.Client? client}) : _client = client ?? http.Client();

  /// Search real industries, factories, recycling companies, metal industries,
  /// or scrap dealers in Gujranwala, Pakistan using Google Places API (New)
  Future<List<PlaceModel>> searchPlaces({String? query}) async {
    final String textQuery = (query != null && query.trim().isNotEmpty)
        ? query.trim()
        : ApiConstants.defaultCityQuery;

    final Uri url = Uri.parse(ApiConstants.placesApiSearchUrl);

    try {
      final response = await _client.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'X-Goog-Api-Key': ApiConstants.googlePlacesApiKey,
          'X-Goog-FieldMask': ApiConstants.defaultPlacesFieldMask,
        },
        body: jsonEncode({
          'textQuery': textQuery,
        }),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final List<dynamic>? placesJson = data['places'] as List<dynamic>?;

        if (placesJson == null || placesJson.isEmpty) {
          return [];
        }

        return placesJson
            .map((json) => PlaceModel.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        throw 'Failed to fetch places (Error ${response.statusCode})';
      }
    } catch (e) {
      if (e is FormatException) {
        throw 'Invalid data format received from Google Places API.';
      }
      throw 'Unable to connect to Google Places API. Please check your internet connection.';
    }
  }
}
