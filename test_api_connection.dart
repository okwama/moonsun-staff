import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiConnectionTest {
  static const String baseUrl = 'http://localhost:5000/api';

  static Future<void> testConnection() async {
    print('🔍 Testing API Connection to: $baseUrl');
    print('');

    // Test 1: Check if server is running
    print('1. Testing server availability...');
    try {
      final response = await http.get(Uri.parse('$baseUrl/auth/profile'));
      print('   Status Code: ${response.statusCode}');
      print('   Response: ${response.body}');
    } catch (e) {
      print('   ❌ Error: $e');
    }
    print('');

    // Test 2: Test login endpoint
    print('2. Testing login endpoint...');
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'phone': '0790333333',
          'password': 'testpass',
        }),
      );
      print('   Status Code: ${response.statusCode}');
      print('   Response: ${response.body}');
    } catch (e) {
      print('   ❌ Error: $e');
    }
    print('');

    // Test 3: Test registration endpoint
    print('3. Testing registration endpoint...');
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': 'Flutter Test User',
          'photoUrl': 'https://randomuser.me/api/portraits/lego/1.jpg',
          'emplNo': 'FLUTTER001',
          'idNo': '12345678',
          'role': 'staff',
          'phoneNumber': '0790444444',
          'password': 'testpass',
          'department': 'IT',
          'businessEmail': 'flutter@test.com',
          'salary': 45000,
          'employmentType': 'Permanent',
        }),
      );
      print('   Status Code: ${response.statusCode}');
      print('   Response: ${response.body}');
    } catch (e) {
      print('   ❌ Error: $e');
    }
    print('');

    print('✅ API Connection Test Completed!');
  }
}

void main() async {
  await ApiConnectionTest.testConnection();
}
