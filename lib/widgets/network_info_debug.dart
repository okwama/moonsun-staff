import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/network_service.dart';

class NetworkInfoDebug extends StatefulWidget {
  const NetworkInfoDebug({super.key});

  @override
  State<NetworkInfoDebug> createState() => _NetworkInfoDebugState();
}

class _NetworkInfoDebugState extends State<NetworkInfoDebug> {
  Map<String, String>? _networkInfo;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadNetworkInfo();
  }

  Future<void> _loadNetworkInfo() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final info = await NetworkService.getNetworkInfo();
      setState(() {
        _networkInfo = info;
      });
    } catch (e) {
      setState(() {
        _networkInfo = {'error': e.toString()};
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(
                  Icons.wifi,
                  color: Theme.of(context).primaryColor,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Network Information',
                  style: GoogleFonts.interTight(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: _isLoading ? null : _loadNetworkInfo,
                  tooltip: 'Refresh',
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else if (_networkInfo != null) ...[
              _buildInfoRow(
                  'Public IP', _networkInfo!['publicIP'] ?? 'Unknown'),
              _buildInfoRow('Local IP', _networkInfo!['localIP'] ?? 'Unknown'),
              _buildInfoRow(
                  'Timestamp', _networkInfo!['timestamp'] ?? 'Unknown'),
              if (_networkInfo!.containsKey('error'))
                _buildInfoRow('Error', _networkInfo!['error']!, isError: true),
            ] else
              const Text('No network information available'),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  final ip = await NetworkService.getDeviceIPAddress();
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Current IP: ${ip ?? 'Unknown'}'),
                        duration: const Duration(seconds: 3),
                      ),
                    );
                  }
                },
                icon: const Icon(Icons.info_outline),
                label: const Text('Get Current IP'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isError = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w500,
                fontSize: 12,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: isError ? Colors.red : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
