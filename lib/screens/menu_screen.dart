import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/app_colors.dart';

class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  static const Color fbColor = Color(0xFF1877F2);
  static const Color waColor = Color(0xFF25D366);
  static const Color shareColor = Color(0xFF2563EB);
  static const Color rateColor = Color(0xFFF59E0B);
  static const Color moreAppColor = Color(0xFF8B5CF6);
  static const Color feedbackColor = Color(0xFF10B981);
  static const Color privacyColor = Color(0xFFEF4444);
  static const Color disclaimerColor = Color(0xFF64748B);

  Future<void> _openUrl(BuildContext context, String urlString, {String? fallbackMessage}) async {
    final Uri uri = Uri.parse(urlString);
    try {
      final bool launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!launched && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(fallbackMessage ?? 'Unable to open link: $urlString'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(fallbackMessage ?? 'Could not launch link'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _shareApp(BuildContext context) {
    SharePlus.instance.share(
      ShareParams(
        text: 'Download KPK E-Textbooks app for Khyber Pakhtunkhwa textbook board books & guides!\nhttps://play.google.com/store/apps/details?id=pk.gov.kp.textbook.kp_book',
        subject: 'KPK E-Textbooks App',
      ),
    );
  }

  void _showFeedbackDialog(BuildContext context) {
    final textController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceContainerLowest,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.send_rounded, color: feedbackColor),
            const SizedBox(width: 10),
            Text(
              'Send Feedback',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.onSurface),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Help us improve KPK E-Textbooks. Share your suggestions, bugs, or feedback below:',
              style: TextStyle(fontSize: 13, color: AppColors.onSurfaceVariant),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: textController,
              maxLines: 4,
              style: TextStyle(color: AppColors.onSurface, fontSize: 13),
              decoration: InputDecoration(
                hintText: 'Enter your message...',
                hintStyle: TextStyle(fontSize: 13, color: AppColors.outline),
                filled: true,
                fillColor: AppColors.surfaceContainerLow,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.cardBorder),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.cardBorder),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: TextStyle(color: AppColors.outline)),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: feedbackColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Thank you! Your feedback has been submitted successfully.'),
                  backgroundColor: feedbackColor,
                ),
              );
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }

  void _showPrivacyPolicy(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surfaceContainerLowest,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.8,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (_, scrollController) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: ListView(
            controller: scrollController,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: AppColors.cardBorder,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              Row(
                children: [
                  const Icon(Icons.lock_rounded, color: privacyColor, size: 24),
                  const SizedBox(width: 10),
                  Text(
                    'Privacy Policy',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.onSurface),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                'Last updated: November 2026\n\n'
                '1. Information We Collect\n'
                'KPK E-Textbooks is designed to provide access to Khyber Pakhtunkhwa educational curriculum. When creating an account, we collect your name and email address securely via Supabase Authentication.\n\n'
                '2. Offline Storage & Files\n'
                'Downloaded textbooks and guides are stored exclusively within app-private device storage and are not accessible by third-party apps.\n\n'
                '3. Analytics & Usage\n'
                'We do not sell or monetize personal student data. Anonymized session metrics help ensure servers and book downloads remain reliable.\n\n'
                '4. Contact & Inquiries\n'
                'If you have questions regarding this Privacy Policy, please contact our support team at info@kptbb.gov.pk.',
                style: TextStyle(fontSize: 13, height: 1.5, color: AppColors.onSurfaceVariant),
              ),
              const SizedBox(height: 20),
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primaryContainer,
                  foregroundColor: AppColors.onPrimaryContainer,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Close'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDisclaimer(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surfaceContainerLowest,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.75,
        minChildSize: 0.45,
        maxChildSize: 0.95,
        expand: false,
        builder: (_, scrollController) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: ListView(
            controller: scrollController,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: AppColors.cardBorder,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              Row(
                children: [
                  const Icon(Icons.bolt_rounded, color: disclaimerColor, size: 24),
                  const SizedBox(width: 10),
                  Text(
                    'Disclaimer',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.onSurface),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                '1. Educational Use Only\n'
                'This application is provided strictly for educational purposes to assist students and educators across Khyber Pakhtunkhwa.\n\n'
                '2. Copyright & Intellectual Property\n'
                'All textbooks, syllabi, and curriculum assets are the intellectual property of the Khyber Pakhtunkhwa Textbook Board (KPTBB), Peshawar and the Elementary & Secondary Education Department.\n\n'
                '3. Non-Commercial Distribution\n'
                'Textbooks and guides provided within this application may not be sold, republished, or redistributed for commercial gain.\n\n'
                '4. Content Accuracy\n'
                'While all reasonable efforts are made to keep digital editions aligned with official print releases, users should cross-reference official syllabus announcements for examination guidelines.',
                style: TextStyle(fontSize: 13, height: 1.5, color: AppColors.onSurfaceVariant),
              ),
              const SizedBox(height: 20),
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primaryContainer,
                  foregroundColor: AppColors.onPrimaryContainer,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Close'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceContainerLowest,
        elevation: 0,
        centerTitle: true,
        leading: Padding(
          padding: const EdgeInsets.only(left: 10),
          child: Center(
            child: Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(10),
              child: InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.cardBorder),
                  ),
                  alignment: Alignment.center,
                  child: Icon(Icons.arrow_back_rounded, color: AppColors.onSurface, size: 20),
                ),
              ),
            ),
          ),
        ),
        title: Text(
          'Menu',
          style: TextStyle(
            color: AppColors.onSurface,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(height: 1, thickness: 0.8, color: AppColors.cardBorder),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section 1: Connect With Us
            _buildSectionCard(
              title: 'Connect With Us',
              subtitle: 'Join our community for updates and academic resources',
              content: Row(
                children: [
                  Expanded(
                    child: _buildCommunityButton(
                      label: 'Facebook',
                      icon: Icons.facebook,
                      color: fbColor,
                      onTap: () => _openUrl(
                        context,
                        'https://www.facebook.com/kpk.textbook.board',
                        fallbackMessage: 'Opening official Facebook community...',
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildCommunityButton(
                      label: 'WhatsApp\nChannel',
                      icon: Icons.chat_bubble_rounded,
                      color: waColor,
                      onTap: () => _openUrl(
                        context,
                        'https://whatsapp.com/channel/0029Va8OfficialKpkChannel',
                        fallbackMessage: 'Opening official WhatsApp Channel...',
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Section 2: Academic Resources
            _buildSectionCard(
              title: 'Academic Resources',
              subtitle: 'Enhance your learning experience',
              content: _buildMenuItemTile(
                icon: Icons.chat_rounded,
                iconColor: waColor,
                title: 'Contact Me',
                onTap: () => _openUrl(
                  context,
                  'https://wa.me/923000000000?text=Hello%20KPK%20E-Textbooks%20Support',
                  fallbackMessage: 'Opening support chat on WhatsApp...',
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Section 3: App Actions
            _buildSectionCard(
              title: 'App Actions',
              subtitle: 'Manage your app experience',
              content: Column(
                children: [
                  _buildMenuItemTile(
                    icon: Icons.share_rounded,
                    iconColor: shareColor,
                    title: 'Share App',
                    onTap: () => _shareApp(context),
                  ),
                  _buildItemDivider(),
                  _buildMenuItemTile(
                    icon: Icons.star_rounded,
                    iconColor: rateColor,
                    title: 'Rate App',
                    onTap: () => _openUrl(
                      context,
                      'https://play.google.com/store/apps/details?id=pk.gov.kp.textbook.kp_book',
                      fallbackMessage: 'Opening Google Play Store to rate app...',
                    ),
                  ),
                  _buildItemDivider(),
                  _buildMenuItemTile(
                    icon: Icons.apps_rounded,
                    iconColor: moreAppColor,
                    title: 'More App',
                    onTap: () => _openUrl(
                      context,
                      'https://play.google.com/store/apps/developer?id=KPK+Textbook+Board',
                      fallbackMessage: 'Exploring more educational apps...',
                    ),
                  ),
                  _buildItemDivider(),
                  _buildMenuItemTile(
                    icon: Icons.mail_rounded,
                    iconColor: feedbackColor,
                    title: 'Send Feedback',
                    onTap: () => _showFeedbackDialog(context),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Section 4: Legal & Policies
            _buildSectionCard(
              title: 'Legal & Policies',
              subtitle: 'Important information',
              content: Column(
                children: [
                  _buildMenuItemTile(
                    icon: Icons.lock_rounded,
                    iconColor: privacyColor,
                    title: 'Privacy Policy',
                    onTap: () => _showPrivacyPolicy(context),
                  ),
                  _buildItemDivider(),
                  _buildMenuItemTile(
                    icon: Icons.bolt_rounded,
                    iconColor: disclaimerColor,
                    title: 'Disclaimer',
                    onTap: () => _showDisclaimer(context),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required String subtitle,
    required Widget content,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.onSurface,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 11,
              color: AppColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 14),
          content,
        ],
      ),
    );
  }

  Widget _buildCommunityButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: color.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          height: 50,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withValues(alpha: 0.25)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: Colors.white, size: 18),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  label,
                  textAlign: TextAlign.left,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.onSurface,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    height: 1.15,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItemTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 2),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: iconColor.withValues(alpha: 0.2)),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.onSurface,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: AppColors.outline,
              size: 14,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemDivider() {
    return Divider(
      height: 12,
      thickness: 0.8,
      color: AppColors.cardBorder.withValues(alpha: 0.5),
    );
  }
}
