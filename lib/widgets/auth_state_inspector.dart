import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/authProvider.dart';

class AuthStateInspector extends StatelessWidget {
  const AuthStateInspector({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return Card(
          margin: const EdgeInsets.all(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Auth State Inspector',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 12),
                _buildStateRow('Initialized', authProvider.isInitialized),
                _buildStateRow('Authenticated', authProvider.isAuthenticated),
                _buildStateRow('Loading', authProvider.isLoading),
                _buildStateRow('Logged Out', authProvider.isLoggedOut),
                if (authProvider.user != null) ...[
                  const SizedBox(height: 8),
                  _buildStateRow('User Name', authProvider.getUserName()),
                  _buildStateRow('User Role', authProvider.getUserRole()),
                  _buildStateRow('User ID', authProvider.user!.id.toString()),
                ],
                if (authProvider.error != null) ...[
                  const SizedBox(height: 8),
                  _buildStateRow('Error', authProvider.error!, isError: true),
                ],
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => authProvider.refreshUser(),
                        child: const Text('Refresh User'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => authProvider.checkAuthStatus(),
                        child: const Text('Check Auth'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStateRow(String label, dynamic value, {bool isError = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          Expanded(
            child: Text(
              value.toString(),
              style: TextStyle(
                color: isError ? Colors.red : null,
                fontFamily: 'monospace',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
