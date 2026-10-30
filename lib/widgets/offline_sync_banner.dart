import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class OfflineSyncBanner extends StatelessWidget {
  const OfflineSyncBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        border: const Border(
          bottom: BorderSide(color: AppColors.cardBorder, width: 0.8),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: AppColors.secondaryContainer,
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Icon(
              Icons.offline_pin_rounded,
              size: 16,
              color: AppColors.onSecondaryContainer,
            ),
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              'Offline-First Enabled • Village Study Mode Ready',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.primaryContainer,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: AppColors.cardBorder, width: 0.8),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.wifi_off_rounded, size: 12, color: AppColors.outline),
                SizedBox(width: 4),
                Text(
                  'No internet needed',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
