import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/appConfig.dart';
import 'authService.dart';
import '../models/out_of_office.dart';

class OutOfOfficeService {
  static Future<bool> apply(String title, String reason, DateTime date) async {
    final token = await AuthService.getToken();
    final requestBody = {
      'title': title,
      'reason': reason,
      'date': date.toIso8601String().split('T')[0],
    };
    print('OutOfOffice APPLY request body: ${jsonEncode(requestBody)}');
    final response = await http.post(
      Uri.parse('${AppConfig.outOfOfficeEndpoint}'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(requestBody),
    );
    print('OutOfOffice APPLY response status: ${response.statusCode}');
    print('OutOfOffice APPLY response body: ${response.body}');
    return response.statusCode == 200 || response.statusCode == 201;
  }

  static Future<List<OutOfOffice>> getMyRequests() async {
    final token = await AuthService.getToken();
    final response = await http.get(
      Uri.parse('${AppConfig.outOfOfficeEndpoint}'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return List<OutOfOffice>.from(data.map((x) => OutOfOffice.fromJson(x)));
    }
    return [];
  }
}
