import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../services/supabase_service.dart';
import '../theme/app_colors.dart';
import '../widgets/custom_app_bar.dart';
import 'auth/login_screen.dart';
import 'menu_screen.dart';

class SettingsScreen extends StatefulWidget {
  final Function(int)? onSwitchTab;

  const SettingsScreen({super.key, this.onSwitchTab});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(ImageSource source, AppState appState) async {
    try {
      final XFile? picked = await _picker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (picked != null) {
        appState.setProfileImagePath(picked.path);
        // Upload to remote Supabase storage
        await SupabaseService.uploadProfileImage(File(picked.path));
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile image updated successfully!'),
              backgroundColor: AppColors.secondary,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to pick image: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _showImageSourceSheet(BuildContext context, AppState appState) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Change Profile Photo',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                ListTile(
                  leading: const Icon(Icons.camera_alt_outlined, color: AppColors.primaryContainer),
                  title: const Text('Take Photo from Camera'),
                  onTap: () {
                    Navigator.pop(ctx);
                    _pickImage(ImageSource.camera, appState);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.photo_library_outlined, color: AppColors.primaryContainer),
                  title: const Text('Choose from Gallery'),
                  onTap: () {
                    Navigator.pop(ctx);
                    _pickImage(ImageSource.gallery, appState);
                  },
                ),
                if (appState.profileImagePath != null)
                  ListTile(
                    leading: const Icon(Icons.delete_outline, color: AppColors.error),
                    title: const Text('Remove Photo', style: TextStyle(color: AppColors.error)),
                    onTap: () {
                      Navigator.pop(ctx);
                      appState.setProfileImagePath(null);
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showEditNameDialog(BuildContext context) {
    final nameCtrl = TextEditingController(text: SupabaseService.userName);
    final messenger = ScaffoldMessenger.of(context);

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Edit Profile Name'),
          content: TextField(
            controller: nameCtrl,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
              labelText: 'Full Name',
              hintText: 'Enter your name',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                final newName = nameCtrl.text.trim();
                if (newName.isEmpty) return;
                Navigator.pop(ctx);
                try {
                  await SupabaseService.updateUserName(newName);
                  if (mounted) {
                    setState(() {});
                    messenger.showSnackBar(
                      const SnackBar(
                        content: Text('Name updated successfully!'),
                        backgroundColor: AppColors.secondary,
                      ),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    messenger.showSnackBar(
                      SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error),
                    );
                  }
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _showChangePasswordDialog(BuildContext context) {
    final newPassCtrl = TextEditingController();
    final confirmPassCtrl = TextEditingController();
    final messenger = ScaffoldMessenger.of(context);

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Change Password'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: newPassCtrl,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'New Password',
                  hintText: 'Minimum 6 characters',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: confirmPassCtrl,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Confirm New Password',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                final pass = newPassCtrl.text;
                final confirm = confirmPassCtrl.text;
                if (pass.length < 6) {
                  messenger.showSnackBar(
                    const SnackBar(content: Text('Password must be at least 6 characters')),
                  );
                  return;
                }
                if (pass != confirm) {
                  messenger.showSnackBar(
                    const SnackBar(content: Text('Passwords do not match')),
                  );
                  return;
                }
                Navigator.pop(ctx);
                try {
                  await SupabaseService.updatePassword(pass);
                  if (mounted) {
                    messenger.showSnackBar(
                      const SnackBar(
                        content: Text('Password changed successfully!'),
                        backgroundColor: AppColors.secondary,
                      ),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    messenger.showSnackBar(
                      SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error),
                    );
                  }
                }
              },
              child: const Text('Update Password'),
            ),
          ],
        );
      },
    );
  }

  void _confirmClearCache(BuildContext context, AppState appState) {
    final messenger = ScaffoldMessenger.of(context);

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: AppColors.error),
              SizedBox(width: 8),
              Text('Clear Cache & Downloads?'),
            ],
          ),
          content: const Text(
            'Are you sure you want to clear all temporary reader files and delete all downloaded textbooks? You can re-download them anytime when online.',
            style: TextStyle(fontSize: 13, height: 1.4),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: AppColors.error),
              onPressed: () async {
                Navigator.pop(ctx);
                final double freedMB = await appState.clearAllCacheAndDownloads();
                if (mounted) {
                  messenger.showSnackBar(
                    SnackBar(
                      content: Text('Cache and downloads cleared successfully (${freedMB.toStringAsFixed(1)} MB freed).'),
                      backgroundColor: AppColors.secondary,
                    ),
                  );
                }
              },
              child: const Text('Clear All'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);

    return Scaffold(
      appBar: CustomAppBar(
        tag: 'Settings',
        title: 'Settings & Preferences',
        subtitle: 'App configuration & profile',
        showBackButton: true,
        showDownloadManager: false,
        showNotification: false,
        onBackPressed: () {
          if (Navigator.canPop(context)) {
            Navigator.pop(context);
          } else if (widget.onSwitchTab != null) {
            widget.onSwitchTab!(0); // Return to Home screen
          }
        },
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 1. User Profile Section with photo upload, name edit & password change
          _buildUserAccountSection(context, appState),

          const SizedBox(height: 24),

          // 2. Display & Night Mode (Low Data Saver removed as requested)
          _buildSectionHeader('DISPLAY'),
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
                  subtitle: const Text('High contrast dark theme for night reading', style: TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant)),
                  value: appState.isDarkMode,
                  activeThumbColor: AppColors.secondary,
                  activeTrackColor: AppColors.secondaryContainer,
                  onChanged: (val) => appState.toggleDarkMode(val),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // 3. Offline Storage & Cache (Fully functional with confirmation popup)
          _buildSectionHeader('STORAGE & CACHE'),
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
                  title: const Text('Clear Temporary Cache & Downloads', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                  subtitle: Text(
                    'Frees ${appState.totalStorageUsedFormatted} of cached files and saved textbooks',
                    style: const TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant),
                  ),
                  trailing: TextButton(
                    onPressed: () => _confirmClearCache(context, appState),
                    child: const Text('Clear', style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.error)),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // 4. Navigation Menu & Community
          _buildSectionHeader('COMMUNITY & RESOURCES'),
          Container(
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: ListTile(
              leading: const Icon(Icons.menu_book_rounded, color: AppColors.primaryContainer),
              title: const Text('Navigation Menu & Community', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
              subtitle: const Text('Connect with us, academic resources, app actions & policies', style: TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant)),
              trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.outline),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const MenuScreen()),
                );
              },
            ),
          ),

          const SizedBox(height: 24),

          // 5. Curriculum Edition Information (About & Contact Us removed as requested)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: const Row(
              children: [
                Icon(Icons.verified_outlined, color: AppColors.secondary, size: 24),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Official Curriculum 2024–25',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.onSurface),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Khyber Pakhtunkhwa Textbook Board • Peshawar',
                        style: TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
                Text('v1.0.8', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.outline)),
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

  Widget _buildUserAccountSection(BuildContext context, AppState appState) {
    final bool isLoggedIn = SupabaseService.isAuthenticated;
    final String name = SupabaseService.userName;
    final String email = SupabaseService.userEmail ?? 'Signed in User';
    final avatarPath = appState.profileImagePath;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Avatar with camera icon overlay
              Stack(
                children: [
                  Container(
                    width: 58,
                    height: 58,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primaryContainer.withValues(alpha: 0.12),
                      border: Border.all(color: AppColors.primaryContainer.withValues(alpha: 0.4), width: 1.5),
                    ),
                    child: ClipOval(
                      child: avatarPath != null && avatarPath.isNotEmpty
                          ? (avatarPath.startsWith('http')
                              ? Image.network(
                                  avatarPath,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => _buildFallbackAvatar(name),
                                )
                              : Image.file(
                                  File(avatarPath),
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => _buildFallbackAvatar(name),
                                ))
                          : _buildFallbackAvatar(name),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: InkWell(
                      onTap: () => _showImageSourceSheet(context, appState),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: AppColors.primaryContainer,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.camera_alt_rounded, size: 12, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      email,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.onSurfaceVariant,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),
          const Divider(height: 1, color: AppColors.cardBorder),
          const SizedBox(height: 8),

          // Profile Actions (Edit Name, Change Password, Sign Out)
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.cardBorder),
                    visualDensity: VisualDensity.compact,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () => _showEditNameDialog(context),
                  icon: const Icon(Icons.edit_outlined, size: 14),
                  label: const Text('Edit Name', style: TextStyle(fontSize: 12)),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.cardBorder),
                    visualDensity: VisualDensity.compact,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () => _showChangePasswordDialog(context),
                  icon: const Icon(Icons.lock_reset_outlined, size: 14),
                  label: const Text('Password', style: TextStyle(fontSize: 12)),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.cardBorder),
                foregroundColor: isLoggedIn ? AppColors.error : AppColors.primaryContainer,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () async {
                if (isLoggedIn) {
                  await SupabaseService.signOut();
                }
                if (context.mounted) {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                    (route) => false,
                  );
                }
              },
              icon: Icon(isLoggedIn ? Icons.logout_rounded : Icons.login_rounded, size: 16),
              label: Text(
                isLoggedIn ? 'Sign Out of Account' : 'Sign In',
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFallbackAvatar(String name) {
    final initial = name.isNotEmpty ? name[0].toUpperCase() : 'S';
    return Center(
      child: Text(
        initial,
        style: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w800,
          color: AppColors.primaryContainer,
        ),
      ),
    );
  }
}
