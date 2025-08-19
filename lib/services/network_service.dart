import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class NetworkService {
  static Future<String?> getDeviceIPAddress() async {
    try {
      // Try to get IP from a public service
      final response = await http.get(
        Uri.parse('https://api.ipify.org'),
        headers: {'Accept': 'text/plain'},
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        return response.body.trim();
      }
    } catch (e) {
      // Fallback: try alternative IP service
      try {
        final response = await http.get(
          Uri.parse('https://httpbin.org/ip'),
          headers: {'Accept': 'application/json'},
        ).timeout(const Duration(seconds: 5));

        if (response.statusCode == 200) {
          final data = response.body;
          // Simple JSON parsing to extract IP
          final ipMatch = RegExp(r'"origin":\s*"([^"]+)"').firstMatch(data);
          if (ipMatch != null) {
            return ipMatch.group(1);
          }
        }
      } catch (e) {
        // If all else fails, return null
        return null;
      }
    }
    return null;
  }

  static Future<String?> getLocalIPAddress() async {
    // On web platform, we can't get local IP directly
    if (kIsWeb) {
      // For web, we'll use a different approach or return null
      // The backend will handle IP detection from the request
      return null;
    }

    try {
      // Get local network interfaces (only works on mobile/desktop)
      final interfaces = await NetworkInterface.list();

      // Priority order for network interfaces
      final priorityPatterns = [
        'en0', // WiFi on macOS
        'wlan0', // WiFi on Android/Linux
        'eth0', // Ethernet
        'en1', // Secondary interface
      ];

      // First, try to find interfaces matching priority patterns
      for (final pattern in priorityPatterns) {
        for (final interface in interfaces) {
          if (interface.name.toLowerCase().contains(pattern.toLowerCase())) {
            for (final addr in interface.addresses) {
              if (addr.type == InternetAddressType.IPv4) {
                final ip = addr.address;
                // Skip localhost and link-local addresses
                if (ip != '127.0.0.1' &&
                    !ip.startsWith('169.254.') &&
                    !ip.startsWith('0.0.0.0')) {
                  print(
                      'NetworkService: Found IP $ip on interface ${interface.name}');
                  return ip;
                }
              }
            }
          }
        }
      }

      // Fallback: find any non-loopback IPv4 address
      for (final interface in interfaces) {
        // Skip loopback and non-active interfaces
        if (interface.name.toLowerCase().contains('loopback') ||
            interface.name.toLowerCase().contains('vmnet') ||
            interface.name.toLowerCase().contains('docker')) {
          continue;
        }

        for (final addr in interface.addresses) {
          // Look for IPv4 addresses
          if (addr.type == InternetAddressType.IPv4) {
            final ip = addr.address;
            // Skip localhost and private network addresses
            if (ip != '127.0.0.1' &&
                !ip.startsWith('169.254.') && // Link-local
                !ip.startsWith('0.0.0.0')) {
              print(
                  'NetworkService: Fallback IP $ip on interface ${interface.name}');
              return ip;
            }
          }
        }
      }
    } catch (e) {
      print('NetworkService: Error getting local IP: $e');
      return null;
    }
    return null;
  }

  static Future<Map<String, String>> getNetworkInfo() async {
    final publicIP = await getDeviceIPAddress();
    final localIP = await getLocalIPAddress();

    return {
      'publicIP': publicIP ?? 'Unknown',
      'localIP': localIP ?? 'Unknown',
      'timestamp': DateTime.now().toIso8601String(),
    };
  }

  static Future<bool> isConnected() async {
    try {
      // Use a more reliable connectivity check that works on web
      final response = await http
          .get(
            Uri.parse('https://httpbin.org/status/200'),
          )
          .timeout(const Duration(seconds: 5));
      return response.statusCode == 200;
    } catch (e) {
      // Fallback: try a different endpoint
      try {
        final response = await http
            .get(
              Uri.parse('https://api.ipify.org'),
            )
            .timeout(const Duration(seconds: 3));
        return response.statusCode == 200;
      } catch (e) {
        return false;
      }
    }
  }

  static Future<String> getConnectionType() async {
    // For now, return a generic type since we don't have connectivity_plus
    return 'Unknown';
  }
}
