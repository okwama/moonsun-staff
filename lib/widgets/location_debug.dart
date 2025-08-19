import 'package:flutter/material.dart';
import '../services/geo_service.dart';

class LocationDebug extends StatefulWidget {
  const LocationDebug({super.key});

  @override
  State<LocationDebug> createState() => _LocationDebugState();
}

class _LocationDebugState extends State<LocationDebug> {
  final GeoService _geoService = GeoService();
  bool _isLoading = false;
  String? _locationString;
  Map<String, double>? _coordinates;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadLocation();
  }

  Future<void> _loadLocation() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final coordinates = await _geoService.getCoordinates();
      final locationString = await _geoService.getLocationString();

      setState(() {
        _coordinates = coordinates;
        _locationString = locationString;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
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
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Location Debug',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: _isLoading ? null : _loadLocation,
                  icon: _isLoading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.refresh),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else if (_errorMessage != null)
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Error: $_errorMessage',
                  style: const TextStyle(color: Colors.red),
                ),
              )
            else if (_coordinates != null) ...[
              _buildInfoRow('Latitude',
                  _coordinates!['latitude']?.toStringAsFixed(6) ?? 'N/A'),
              _buildInfoRow('Longitude',
                  _coordinates!['longitude']?.toStringAsFixed(6) ?? 'N/A'),
              _buildInfoRow('Location', _locationString ?? 'N/A'),
            ] else
              const Text('No location data available'),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
