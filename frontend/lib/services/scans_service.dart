import 'dart:convert';
import 'package:http/http.dart' as http;

import '../constants/api.dart';

class ScansService {
  Future<List<Map<String, dynamic>>> fetchScans({
    required String userId,
    int limit = 200,
  }) async {
    final uri = Uri.parse(
      '${ApiConstants.baseUrl}${ApiConstants.scansEndpoint}/$userId?limit=$limit',
    );

    final res = await http.get(uri);

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      if (data is List) {
        return data
            .whereType<Map>()
            .map((item) => Map<String, dynamic>.from(item))
            .toList();
      }
      return [];
    } else {
      throw Exception('Failed to load scans: ${res.statusCode}\n${res.body}');
    }
  }
}
