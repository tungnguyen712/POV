import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../constants/api.dart';

class LandmarkService {
  Future<Map<String, dynamic>> identifyLandmark({
    required File imageFile,
    String? userId,
    String? ageBracket,
    String? interests,
    double? lat,
    double? lng,
  }) async {
    try {
      var uri = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.identifyEndpoint}');
      var request = http.MultipartRequest('POST', uri);

      // Add image file
      request.files.add(
        await http.MultipartFile.fromPath('image', imageFile.path),
      );

      // Add optional fields
      if (userId != null) request.fields['user_id'] = userId;
      if (ageBracket != null) request.fields['age_bracket'] = ageBracket;
      if (interests != null) request.fields['interests'] = interests;
      if (lat != null) request.fields['lat'] = lat.toString();
      if (lng != null) request.fields['lng'] = lng.toString();

      var response = await request.send();
      var responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        return json.decode(responseBody);
      } else {
        throw Exception('Failed to identify landmark: ${response.statusCode}\n$responseBody');
      }
    } catch (e) {
      throw Exception('Error identifying landmark: $e');
    }
  }
}