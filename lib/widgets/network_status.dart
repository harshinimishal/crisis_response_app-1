import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class NetworkStatusIndicator extends StatelessWidget {
  final bool isOnline;
  
  const NetworkStatusIndicator({
    super.key,
    this.isOnline = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: (isOnline ? AppColors.success : AppColors.error).withOpacity(0.2),
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: isOnline ? AppColors.success : AppColors.error,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          Text(
            isOnline ? 'Online' : 'Offline',
            style: AppTextStyles.labelMedium.copyWith(
              color: isOnline ? AppColors.success : AppColors.error,
            ),
          ),
        ],
      ),
    );
  }
}
