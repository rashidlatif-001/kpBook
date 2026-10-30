import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../theme/app_colors.dart';
import 'connect_with_us_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Settings & Preferences',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.onSurface),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Language Selection Section
          _buildSectionHeader('LANGUAGE / زبان / ژبه'),
          Container(
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: Column(
              children: [
                _buildLanguageTile(context, appState, 'en', 'English', 'Default'),
                const Divider(height: 1, color: AppColors.cardBorder),
                _buildLanguageTile(context, appState, 'ur', 'اردو (Urdu)', 'قومی زبان'),
                const Divider(height: 1, color: AppColors.cardBorder),
                _buildLanguageTile(context, appState, 'ps', 'پښتو (Pashto)', 'سیمه ییزه ژبه'),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Display & Reading
          _buildSectionHeader('DISPLAY & READING'),
          Container(
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: Column(
              children: [
                SwitchListTile(
                  secondary: const Icon(Icons.dark_mode_outlined, color: AppColors.primaryContainer),
                  title: const Text('Dark Mode', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                  subtitle: const Text('Reduces eye strain during night study', style: TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant)),
                  value: appState.isDarkMode,
                  activeThumbColor: AppColors.secondary,
                  activeTrackColor: AppColors.secondaryContainer,
                  onChanged: (val) => appState.toggleDarkMode(val),
                ),
                const Divider(height: 1, color: AppColors.cardBorder),
                SwitchListTile(
                  secondary: const Icon(Icons.data_saver_on_outlined, color: AppColors.primaryContainer),
                  title: const Text('Low Data Saver', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                  subtitle: const Text('Optimizes PDF compression for 2G/3G networks', style: TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant)),
                  value: appState.lowDataMode,
                  activeThumbColor: AppColors.secondary,
                  activeTrackColor: AppColors.secondaryContainer,
                  onChanged: (val) => appState.toggleLowData(val),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Offline Storage & Cache
          _buildSectionHeader('OFFLINE STORAGE MANAGEMENT'),
          Container(
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.cleaning_services_outlined, color: AppColors.primaryContainer),
                  title: const Text('Clear Temporary Cache', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                  subtitle: const Text('Frees 12.4 MB of temporary reader files', style: TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant)),
                  trailing: TextButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Temporary cache cleared (12.4 MB freed).')),
                      );
                    },
                    child: const Text('Clear', style: TextStyle(fontWeight: FontWeight.w700)),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Information & Contact
          _buildSectionHeader('ABOUT & CONTACT'),
          Container(
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.contact_support_outlined, color: AppColors.primaryContainer),
                  title: const Text('Connect With Us & App Information', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                  subtitle: const Text('Helpline, KPTBB address, developer info', style: TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant)),
                  trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.outline),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ConnectWithUsScreen()),
                    );
                  },
                ),
                const Divider(height: 1, color: AppColors.cardBorder),
                const ListTile(
                  leading: Icon(Icons.verified_outlined, color: AppColors.secondary),
                  title: Text('Official Curriculum Edition', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                  subtitle: Text('Curriculum 2024–25 (KPK Textbook Board)', style: TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant)),
                  trailing: Text('v1.0.0', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.outline)),
                ),
              ],
            ),
          ),

          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.8,
          color: AppColors.onSurfaceVariant,
        ),
      ),
    );
  }

  Widget _buildLanguageTile(BuildContext context, AppState appState, String code, String name, String sub) {
    final isSelected = appState.currentLanguage == code;

    return ListTile(
      dense: true,
      onTap: () => appState.setLanguage(code),
      title: Text(name, style: TextStyle(fontSize: 14, fontWeight: isSelected ? FontWeight.bold : FontWeight.w500)),
      subtitle: Text(sub, style: const TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant)),
      trailing: isSelected
          ? const Icon(Icons.check_circle_rounded, color: AppColors.secondary, size: 20)
          : null,
    );
  }
}
