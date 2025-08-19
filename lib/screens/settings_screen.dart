import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/authProvider.dart';
import '../providers/settings_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isLoggingOut = false;

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isMobile = screenSize.width < 600;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: Text(
          'Settings',
          style: GoogleFonts.interTight(
            fontWeight: FontWeight.w600,
            fontSize: isMobile ? 20 : 24,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(isMobile ? 20 : 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Section
              _buildSectionHeader('Profile', Icons.person),
              const SizedBox(height: 16),
              _buildSettingsCard([
                _buildSettingsTile(
                  'View Profile',
                  'Manage your personal information',
                  Icons.person_outline,
                  () => Navigator.pushNamed(context, '/profile'),
                ),
                _buildSettingsTile(
                  'Change Password',
                  'Update your account password',
                  Icons.lock_outline,
                  () {
                    // Navigate to profile screen and show password dialog
                    Navigator.pushNamed(context, '/profile');
                  },
                ),
              ]),
              const SizedBox(height: 32),

              // App Settings Section
              _buildSectionHeader('App Settings', Icons.settings),
              const SizedBox(height: 16),
              Consumer<SettingsProvider>(
                builder: (context, settingsProvider, child) {
                  return _buildSettingsCard([
                    _buildSwitchTile(
                      'Push Notifications',
                      'Receive notifications for important updates',
                      Icons.notifications_outlined,
                      settingsProvider.notificationsEnabled,
                      (value) {
                        settingsProvider.setNotificationsEnabled(value);
                      },
                    ),
                    _buildSwitchTile(
                      'Dark Mode',
                      'Use dark theme for the app',
                      Icons.dark_mode_outlined,
                      settingsProvider.isDarkMode,
                      (value) {
                        settingsProvider.setDarkMode(value);
                      },
                    ),
                    _buildSwitchTile(
                      'Biometric Login',
                      'Use fingerprint or face ID to login',
                      Icons.fingerprint_outlined,
                      settingsProvider.biometricEnabled,
                      (value) {
                        settingsProvider.setBiometricEnabled(value);
                      },
                    ),
                    _buildDropdownTile(
                      'Language',
                      'Choose your preferred language',
                      Icons.language_outlined,
                      settingsProvider.selectedLanguage,
                      ['English', 'Spanish', 'French', 'German'],
                      (value) {
                        settingsProvider.setSelectedLanguage(value);
                      },
                    ),
                  ]);
                },
              ),
              const SizedBox(height: 32),

              // Privacy & Security Section
              _buildSectionHeader('Privacy & Security', Icons.security),
              const SizedBox(height: 16),
              _buildSettingsCard([
                _buildSettingsTile(
                  'Privacy Policy',
                  'Read our privacy policy',
                  Icons.privacy_tip_outlined,
                  () {
                    // TODO: Navigate to privacy policy
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Privacy Policy - Coming Soon'),
                      ),
                    );
                  },
                ),
                _buildSettingsTile(
                  'Terms of Service',
                  'Read our terms of service',
                  Icons.description_outlined,
                  () {
                    // TODO: Navigate to terms of service
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Terms of Service - Coming Soon'),
                      ),
                    );
                  },
                ),
                _buildSettingsTile(
                  'Data Usage',
                  'Manage your data usage',
                  Icons.data_usage_outlined,
                  () {
                    // TODO: Navigate to data usage
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Data Usage - Coming Soon'),
                      ),
                    );
                  },
                ),
                _buildSettingsTile(
                  'Delete Account',
                  'Permanently delete your account',
                  Icons.delete_forever_outlined,
                  () => _showDeleteAccountDialog(),
                  Colors.red,
                  Colors.red,
                ),
              ]),
              const SizedBox(height: 32),

              // Support Section
              _buildSectionHeader('Support', Icons.help_outline),
              const SizedBox(height: 16),
              _buildSettingsCard([
                _buildSettingsTile(
                  'Help & FAQ',
                  'Get help and find answers',
                  Icons.help_outline,
                  () {
                    // TODO: Navigate to help screen
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Help & FAQ - Coming Soon'),
                      ),
                    );
                  },
                ),
                _buildSettingsTile(
                  'Contact Support',
                  'Get in touch with our support team',
                  Icons.support_agent_outlined,
                  () {
                    // TODO: Navigate to contact support
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Contact Support - Coming Soon'),
                      ),
                    );
                  },
                ),
                _buildSettingsTile(
                  'Report a Bug',
                  'Report issues or bugs',
                  Icons.bug_report_outlined,
                  () {
                    // TODO: Navigate to bug report
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Report a Bug - Coming Soon'),
                      ),
                    );
                  },
                ),
              ]),
              const SizedBox(height: 32),

              // About Section
              _buildSectionHeader('About', Icons.info_outline),
              const SizedBox(height: 16),
              _buildSettingsCard([
                _buildSettingsTile(
                  'App Version',
                  'Version 1.0.0',
                  Icons.info_outline,
                  null,
                  null,
                  null,
                  false,
                ),
                _buildSettingsTile(
                  'Build Number',
                  'Build 1',
                  Icons.build_outlined,
                  null,
                  null,
                  null,
                  false,
                ),
                _buildSettingsTile(
                  'Licenses',
                  'View third-party licenses',
                  Icons.article_outlined,
                  () {
                    showLicensePage(context: context);
                  },
                ),
              ]),
              const SizedBox(height: 32),

              // Logout Section
              _buildSettingsCard([
                _buildSettingsTile(
                  'Logout',
                  'Sign out of your account',
                  Icons.logout,
                  () => _showLogoutDialog(),
                  Colors.red,
                  Colors.red,
                ),
              ]),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(
          icon,
          color: Theme.of(context).primaryColor,
          size: 24,
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: GoogleFonts.interTight(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildSettingsTile(
    String title,
    String subtitle,
    IconData icon, [
    VoidCallback? onTap,
    Color? textColor,
    Color? iconColor,
    bool showArrow = true,
  ]) {
    return ListTile(
      leading: Icon(
        icon,
        color: iconColor ?? Theme.of(context).primaryColor,
      ),
      title: Text(
        title,
        style: GoogleFonts.inter(
          fontWeight: FontWeight.w500,
          color: textColor ?? Theme.of(context).colorScheme.onSurface,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: GoogleFonts.inter(
          fontSize: 12,
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
        ),
      ),
      trailing: showArrow
          ? Icon(
              Icons.chevron_right,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
            )
          : null,
      onTap: onTap,
    );
  }

  Widget _buildSwitchTile(
    String title,
    String subtitle,
    IconData icon,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return ListTile(
      leading: Icon(
        icon,
        color: Theme.of(context).primaryColor,
      ),
      title: Text(
        title,
        style: GoogleFonts.inter(
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: GoogleFonts.inter(
          fontSize: 12,
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
        ),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: Theme.of(context).primaryColor,
      ),
    );
  }

  Widget _buildDropdownTile(
    String title,
    String subtitle,
    IconData icon,
    String value,
    List<String> options,
    ValueChanged<String> onChanged,
  ) {
    return ListTile(
      leading: Icon(
        icon,
        color: Theme.of(context).primaryColor,
      ),
      title: Text(
        title,
        style: GoogleFonts.inter(
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: GoogleFonts.inter(
          fontSize: 12,
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
        ),
      ),
      trailing: DropdownButton<String>(
        value: value,
        onChanged: (newValue) {
          if (newValue != null) {
            onChanged(newValue);
          }
        },
        items: options.map((String option) {
          return DropdownMenuItem<String>(
            value: option,
            child: Text(option),
          );
        }).toList(),
        underline: Container(),
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      barrierDismissible: !_isLoggingOut, // Prevent dismissal while loading
      builder: (context) => AlertDialog(
        title: Text(
          'Logout',
          style: GoogleFonts.interTight(fontWeight: FontWeight.w600),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_isLoggingOut) ...[
              const SizedBox(height: 16),
              SizedBox(
                height: 32,
                width: 32,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                      Theme.of(context).primaryColor),
                  strokeWidth: 3,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Logging out...',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color:
                      Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
            ] else ...[
              const Text(
                'Are you sure you want to logout? You will need to login again to access your account.',
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: _isLoggingOut ? null : () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: _isLoggingOut
                ? null
                : () async {
                    setState(() {
                      _isLoggingOut = true;
                    });

                    try {
                      final authProvider = context.read<AuthProvider>();
                      await authProvider.logout();

                      // Check if widget is still mounted before navigation
                      if (mounted && context.mounted) {
                        Navigator.of(context).pop(); // Close dialog
                        Navigator.pushReplacementNamed(context, '/login');
                      }
                    } catch (e) {
                      // Handle logout error
                      if (mounted && context.mounted) {
                        Navigator.of(context).pop(); // Close dialog
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Logout failed: ${e.toString()}'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    } finally {
                      // Reset loading state if widget is still mounted
                      if (mounted) {
                        setState(() {
                          _isLoggingOut = false;
                        });
                      }
                    }
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(
          'Delete Account',
          style: GoogleFonts.interTight(fontWeight: FontWeight.w600, color: Colors.red),
        ),
        content: const Text(
          'Are you sure you want to permanently delete your account? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              setState(() { _isLoggingOut = true; });
              try {
                final authProvider = context.read<AuthProvider>();
                await authProvider.deleteAccount();
                if (mounted && context.mounted) {
                  Navigator.pushReplacementNamed(context, '/login');
                }
              } catch (e) {
                if (mounted && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Account deletion failed'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              } finally {
                if (mounted) {
                  setState(() { _isLoggingOut = false; });
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
