import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/app_models.dart';

class TaskCard extends StatelessWidget {
  final VolunteerTask task;
  final VoidCallback? onAccept;
  final VoidCallback? onComplete;
  
  const TaskCard({
    super.key,
    required this.task,
    this.onAccept,
    this.onComplete,
  });

  Color _getStatusColor() {
    switch (task.status) {
      case TaskStatus.pending:
        return AppColors.amber;
      case TaskStatus.active:
        return AppColors.electricBlue;
      case TaskStatus.completed:
        return AppColors.success;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    task.title,
                    style: AppTextStyles.titleMedium,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor().withOpacity(0.2),
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: Text(
                    task.status.displayName.toUpperCase(),
                    style: AppTextStyles.labelMedium.copyWith(
                      color: _getStatusColor(),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            
            // Description
            Text(
              task.description,
              style: AppTextStyles.bodyMedium,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: AppSpacing.md),
            
            // Location and distance
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
                    task.location,
                    style: AppTextStyles.bodyMedium,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
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
                      const Icon(
                        Icons.directions_walk_rounded,
                        size: 14,
                        color: AppColors.electricBlue,
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        '${task.distance.toStringAsFixed(1)} km',
                        style: AppTextStyles.labelMedium.copyWith(
                          color: AppColors.electricBlue,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            // Action buttons
            if (task.status == TaskStatus.pending || task.status == TaskStatus.active)
              Padding(
                padding: const EdgeInsets.only(top: AppSpacing.md),
                child: Row(
                  children: [
                    if (task.status == TaskStatus.pending && onAccept != null)
                      Expanded(
                        child: ElevatedButton(
                          onPressed: onAccept,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.electricBlue,
                            minimumSize: const Size(0, 48),
                          ),
                          child: const Text('Accept Task'),
                        ),
                      ),
                    if (task.status == TaskStatus.active && onComplete != null)
                      Expanded(
                        child: ElevatedButton(
                          onPressed: onComplete,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.success,
                            minimumSize: const Size(0, 48),
                          ),
                          child: const Text('Mark Complete'),
                        ),
                      ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
