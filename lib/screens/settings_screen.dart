import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/settings_provider.dart';
import '../services/auth_provider.dart';
import '../theme/neo_theme.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NeoTheme.background,
      body: Consumer<SettingsProvider>(
        builder: (context, settingsProvider, child) {
          if (settingsProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: NeoTheme.accent),
            );
          }

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 28),
                        onPressed: () => Navigator.of(context).pop(),
                        padding: EdgeInsets.zero,
                        alignment: Alignment.centerLeft,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Settings',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -1,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionHeader('Account'),
                      Consumer<AuthProvider>(
                        builder: (context, auth, _) => Column(
                          children: [
                            _buildListTile(
                              icon: Icons.person_outline_rounded,
                              title: 'Username',
                              subtitle: auth.currentUser?.displayName ?? 'User',
                              onTap: () {},
                            ),
                            _buildListTile(
                              icon: Icons.email_outlined,
                              title: 'Email',
                              subtitle: auth.currentUser?.email ?? 'user@neo.audio',
                              onTap: () {},
                            ),
                          ],
                        ),
                      ),
                      _buildSwitchTile(
                        icon: Icons.lock_outline_rounded,
                        title: 'Private Session',
                        subtitle: 'Hide your listening activity from followers',
                        value: settingsProvider.privateSession,
                        onChanged: (val) => settingsProvider.setPrivateSession(val),
                      ),
                      const SizedBox(height: 32),
                      
                      _buildSectionHeader('Playback'),
                      _buildDropdownTile(
                        icon: Icons.high_quality_outlined,
                        title: 'Audio Quality',
                        value: settingsProvider.audioQuality,
                        items: const ['High', 'Medium', 'Low'],
                        onChanged: (val) {
                          if (val != null) settingsProvider.setAudioQuality(val);
                        },
                      ),
                      _buildSwitchTile(
                        icon: Icons.skip_next_outlined,
                        title: 'Gapless Playback',
                        subtitle: 'Seamless transitions between tracks',
                        value: settingsProvider.gaplessPlayback,
                        onChanged: (val) => settingsProvider.setGaplessPlayback(val),
                      ),
                      const SizedBox(height: 32),

                      _buildSectionHeader('Downloads & Cache'),
                      _buildDropdownTile(
                        icon: Icons.download_outlined,
                        title: 'Download Quality',
                        value: settingsProvider.downloadQuality,
                        items: const ['High', 'Medium', 'Low'],
                        onChanged: (val) {
                          if (val != null) settingsProvider.setDownloadQuality(val);
                        },
                      ),
                      _buildListTile(
                        icon: Icons.delete_outline_rounded,
                        title: 'Clear Cache',
                        subtitle: 'Free up local storage',
                        trailing: const Icon(Icons.chevron_right_rounded, color: NeoTheme.textSecondary),
                        onTap: () async {
                          await settingsProvider.clearCache();
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Cache cleared successfully.')),
                            );
                          }
                        },
                      ),
                      const SizedBox(height: 32),

                      _buildSectionHeader('Notifications'),
                      _buildSwitchTile(
                        icon: Icons.notifications_none_rounded,
                        title: 'Push Notifications',
                        value: settingsProvider.pushNotifications,
                        onChanged: (val) => settingsProvider.setPushNotifications(val),
                      ),
                      _buildSwitchTile(
                        icon: Icons.mail_outline_rounded,
                        title: 'Email Notifications',
                        value: settingsProvider.emailNotifications,
                        onChanged: (val) => settingsProvider.setEmailNotifications(val),
                      ),
                      const SizedBox(height: 32),

                      _buildSectionHeader('Other'),
                      _buildListTile(
                        icon: Icons.info_outline_rounded,
                        title: 'About NEO',
                        subtitle: 'Version 1.0.0',
                        onTap: () {},
                      ),
                      const SizedBox(height: 16),
                      Center(
                        child: OutlinedButton(
                          onPressed: () {
                            context.read<AuthProvider>().logout();
                            Navigator.of(context, rootNavigator: true).popUntil((route) => route.isFirst);
                          },
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                            side: const BorderSide(color: Color(0xFF727272), width: 1),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(32),
                            ),
                            foregroundColor: Colors.white,
                          ),
                          child: const Text(
                            'Log out',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 64),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 24.0, bottom: 8.0, left: 16.0),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildListTile({
    required IconData icon, // Kept for compatibility but unused in Spotify UI
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: subtitle != null
          ? Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Text(
                subtitle,
                style: const TextStyle(
                  color: Color(0xFFA7A7A7),
                  fontSize: 14,
                ),
              ),
            )
          : null,
      trailing: trailing,
      onTap: onTap,
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    String? subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return _buildListTile(
      icon: icon,
      title: title,
      subtitle: subtitle,
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeThumbColor: const Color(0xFF1DB954),
        activeTrackColor: const Color(0xFF1DB954).withValues(alpha: 0.5),
        inactiveThumbColor: const Color(0xFFB3B3B3),
        inactiveTrackColor: const Color(0xFF535353),
      ),
    );
  }

  Widget _buildDropdownTile({
    required IconData icon,
    required String title,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return _buildListTile(
      icon: icon,
      title: title,
      trailing: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          icon: const Icon(Icons.arrow_drop_down_rounded, color: Colors.white),
          dropdownColor: const Color(0xFF282828),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          onChanged: onChanged,
          items: items.map<DropdownMenuItem<String>>((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item),
            );
          }).toList(),
        ),
      ),
    );
  }
}
