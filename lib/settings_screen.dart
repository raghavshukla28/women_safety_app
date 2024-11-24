import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _darkMode = false;
  bool _soundAlerts = true;
  bool _vibration = true;
  double _sosRadius = 5.0;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _darkMode = prefs.getBool('darkMode') ?? false;
      _soundAlerts = prefs.getBool('soundAlerts') ?? true;
      _vibration = prefs.getBool('vibration') ?? true;
      _sosRadius = prefs.getDouble('sosRadius') ?? 5.0;
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('darkMode', _darkMode);
    await prefs.setBool('soundAlerts', _soundAlerts);
    await prefs.setBool('vibration', _vibration);
    await prefs.setDouble('sosRadius', _sosRadius);
  }

  Widget _buildSettingTile({
    required String title,
    required String subtitle,
    required Widget trailing,
  }) {
    return Card(
      color: Theme.of(context).cardColor,
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        title: Text(
          title,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: Theme.of(context).textTheme.titleLarge?.color,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: Theme.of(context).textTheme.bodyMedium?.color,
          ),
        ),
        trailing: trailing,
      ),
    );
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).dialogBackgroundColor,
        title: Text(
          'About Developer',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).textTheme.titleLarge?.color,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: Text(
                'RS',
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  color: Theme.of(context).colorScheme.onPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Raghav Shukla',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.titleLarge?.color,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Flutter Developer',
              style: GoogleFonts.poppins(
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Passionate about creating technology solutions that make a positive impact on society. Specialized in mobile app development and user-centric design.',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Close',
              style: TextStyle(color: Theme.of(context).colorScheme.primary),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Settings',
          style: GoogleFonts.poppins(
            color: Theme.of(context).appBarTheme.titleTextStyle?.color ?? Theme.of(context).colorScheme.onPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        elevation: 0,
      ),
      body: ListView(
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'App Settings',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.titleLarge?.color,
              ),
            ),
          ),
          _buildSettingTile(
            title: 'Dark Mode',
            subtitle: 'Enable dark theme for the app',
            trailing: Switch(
              value: _darkMode,
              onChanged: (value) {
                setState(() {
                  _darkMode = value;
                  _saveSettings();
                });
              },
              activeColor: Theme.of(context).colorScheme.primary,
            ),
          ),
          _buildSettingTile(
            title: 'Sound Alerts',
            subtitle: 'Play sound during emergency alerts',
            trailing: Switch(
              value: _soundAlerts,
              onChanged: (value) {
                setState(() {
                  _soundAlerts = value;
                  _saveSettings();
                });
              },
              activeColor: Theme.of(context).colorScheme.primary,
            ),
          ),
          _buildSettingTile(
            title: 'Vibration',
            subtitle: 'Enable vibration for alerts',
            trailing: Switch(
              value: _vibration,
              onChanged: (value) {
                setState(() {
                  _vibration = value;
                  _saveSettings();
                });
              },
              activeColor: Theme.of(context).colorScheme.primary,
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'SOS Radius: ${_sosRadius.toStringAsFixed(1)} km',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).textTheme.titleMedium?.color,
                  ),
                ),
                Slider(
                  value: _sosRadius,
                  min: 1,
                  max: 10,
                  divisions: 18,
                  label: '${_sosRadius.toStringAsFixed(1)} km',
                  onChanged: (value) {
                    setState(() {
                      _sosRadius = value;
                      _saveSettings();
                    });
                  },
                  activeColor: Theme.of(context).colorScheme.primary,
                ),
              ],
            ),
          ),
          Divider(color: Theme.of(context).dividerColor),
          ListTile(
            leading: Icon(
              Icons.info_outline,
              color: Theme.of(context).colorScheme.primary,
            ),
            title: Text(
              'About Developer',
              style: GoogleFonts.poppins(
                color: Theme.of(context).textTheme.titleMedium?.color,
              ),
            ),
            onTap: _showAboutDialog,
          ),
          ListTile(
            leading: Icon(
              Icons.help_outline,
              color: Theme.of(context).colorScheme.primary,
            ),
            title: Text(
              'Help & Support',
              style: GoogleFonts.poppins(
                color: Theme.of(context).textTheme.titleMedium?.color,
              ),
            ),
            onTap: () {
              // Add help & support functionality
            },
          ),
          ListTile(
            leading: Icon(
              Icons.privacy_tip_outlined,
              color: Theme.of(context).colorScheme.primary,
            ),
            title: Text(
              'Privacy Policy',
              style: GoogleFonts.poppins(
                color: Theme.of(context).textTheme.titleMedium?.color,
              ),
            ),
            onTap: () {
              // Add privacy policy functionality
            },
          ),
        ],
      ),
    );
  }
}