import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class RoleCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final VoidCallback onTap;
  
  const RoleCard({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon container with background
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.electricBlue.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                ),
                child: Icon(
                  icon,
                  size: 40,
                  color: AppColors.electricBlue,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              
              // Title
              Text(
                title,
                style: AppTextStyles.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.sm),
              
              // Description
              Text(
                description,
                style: AppTextStyles.bodyMedium,
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: AppSpacing.md),
              
              // Arrow indicator
              Icon(
                Icons.arrow_forward_rounded,
                color: AppColors.electricBlue,
                size: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
