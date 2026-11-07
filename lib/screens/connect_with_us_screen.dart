import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class ConnectWithUsScreen extends StatelessWidget {
  const ConnectWithUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'App Information & Support',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.onSurface),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Header Hero Emblem Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.2),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                      border: Border.all(color: AppColors.cardBorder, width: 1.5),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: Image.asset(
                        'assets/images/app_logo.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'KPK E-Textbooks',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.onSurface),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Khyber Pakhtunkhwa Textbook Board (KPTBB)',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.primaryContainer),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'Elementary & Secondary Education Department\nGovernment of Khyber Pakhtunkhwa',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant, height: 1.4),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // Contact Information
            _buildInfoCard(
              title: 'OFFICIAL HEADQUARTERS & CONTACT',
              children: [
                _buildContactTile(
                  icon: Icons.location_on_outlined,
                  title: 'Address',
                  subtitle: 'Plot No. 18, Sector B-1, Phase-V, Hayatabad, Peshawar, Khyber Pakhtunkhwa',
                ),
                const Divider(height: 1, color: AppColors.cardBorder),
                _buildContactTile(
                  icon: Icons.phone_in_talk_outlined,
                  title: 'Helpline & Telephone',
                  subtitle: '+92 (091) 9217158 / +92 (091) 9217159',
                ),
                const Divider(height: 1, color: AppColors.cardBorder),
                _buildContactTile(
                  icon: Icons.email_outlined,
                  title: 'Official Email Support',
                  subtitle: 'info@kptbb.gov.pk | curriculum@kptbb.gov.pk',
                ),
                const Divider(height: 1, color: AppColors.cardBorder),
                _buildContactTile(
                  icon: Icons.language_rounded,
                  title: 'Official Portal',
                  subtitle: 'https://kptbb.gov.pk',
                ),
              ],
            ),

            const SizedBox(height: 18),

            // Curriculum Feedback Button
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.rate_review_outlined, color: AppColors.secondary, size: 22),
                      SizedBox(width: 8),
                      Text(
                        'Curriculum & Typo Feedback',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.onSurface),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'If you notice any typographical error or syllabus discrepancy in an official textbook, submit feedback directly to the Curriculum Review Committee.',
                    style: TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant, height: 1.4),
                  ),
                  const SizedBox(height: 14),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.secondary,
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(40),
                    ),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Feedback form opened. Thank you for contributing!')),
                      );
                    },
                    icon: const Icon(Icons.send_rounded, size: 16),
                    label: const Text('Submit Textbook Feedback'),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Tech Specs
            const Text(
              'Pakhtunkhwa Ilm • Flutter & Dart Native Edition\nVersion 1.0.1 (Build 2)',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 11, color: AppColors.outline),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard({required String title, required List<Widget> children}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
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
        ),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.cardBorder),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildContactTile({required IconData icon, required String title, required String subtitle}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 22, color: AppColors.primaryContainer),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.onSurface)),
                const SizedBox(height: 2),
                Text(subtitle, style: const TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant, height: 1.3)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

