import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/app_models.dart';

class IncidentCard extends StatelessWidget {
  final Incident incident;
  final VoidCallback onTap;
  
  const IncidentCard({
    super.key,
    required this.incident,
    required this.onTap,
  });

  Color _getSeverityColor() {
    switch (incident.severity) {
      case SeverityLevel.critical:
        return AppColors.emergencyRed;
      case SeverityLevel.high:
        return AppColors.amber;
      case SeverityLevel.medium:
        return AppColors.info;
      case SeverityLevel.low:
        return AppColors.success;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row
              Row(
                children: [
                  // Emergency type icon
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: _getSeverityColor().withOpacity(0.2),
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                    child: Text(
                      incident.type.icon,
                      style: const TextStyle(fontSize: 24),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  
                  // Title and ID
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          incident.type.displayName,
                          style: AppTextStyles.titleMedium,
                        ),
                        Text(
                          incident.id,
                          style: AppTextStyles.labelMedium,
                        ),
                      ],
                    ),
                  ),
                  
                  // Severity badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: _getSeverityColor(),
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                    child: Text(
                      incident.severity.displayName.toUpperCase(),
                      style: AppTextStyles.labelMedium.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              
              // Location
              Row(
                children: [
                  const Icon(
                    Icons.location_on_rounded,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Expanded(
                    child: Text(
                      incident.location,
                      style: AppTextStyles.bodyMedium,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              
              // Status and time
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Status badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.electricBlue.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.electricBlue,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Text(
                          incident.status.displayName,
                          style: AppTextStyles.labelMedium.copyWith(
                            color: AppColors.electricBlue,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Time ago
                  Text(
                    incident.timeAgo,
                    style: AppTextStyles.labelMedium,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
