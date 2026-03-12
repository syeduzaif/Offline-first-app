import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:offline_first_app/core/constants/app_colors.dart';
import 'package:offline_first_app/core/constants/app_layout.dart';
import 'package:offline_first_app/core/constants/app_paddings.dart';
import 'package:offline_first_app/core/constants/app_text_styles.dart';
import 'package:offline_first_app/core/constants/strings/app_strings.dart';
import 'package:offline_first_app/domain/models/sync_operation.dart';

class SyncOperationCard extends StatelessWidget {
  const SyncOperationCard({
    super.key,
    required this.operation,
    required this.onRetry,
  });

  final SyncOperation operation;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final (opColor, opLabel) = switch (operation.operation) {
      SyncOperationType.create => (
          AppColors.stockGreen,
          SyncStrings.operationCreate,
        ),
      SyncOperationType.update => (
          AppColors.primary,
          SyncStrings.operationUpdate,
        ),
      SyncOperationType.delete => (
          AppColors.failedText,
          SyncStrings.operationDelete,
        ),
    };

    final (statusBg, statusColor, statusLabel) =
        switch (operation.status) {
      SyncOperationStatus.pending => (
          AppColors.pendingBg,
          AppColors.pendingText,
          SyncStrings.statusPending,
        ),
      SyncOperationStatus.inProgress => (
          AppColors.primaryLighter,
          AppColors.primary,
          SyncStrings.statusInProgress,
        ),
      SyncOperationStatus.failed => (
          AppColors.failedBg,
          AppColors.failedText,
          SyncStrings.statusFailed,
        ),
      SyncOperationStatus.completed => (
          AppColors.syncedBg,
          AppColors.syncedText,
          SyncStrings.statusSynced,
        ),
    };

    return Container(
      margin: AppPaddings.bottomSmall,
      padding: AppPaddings.allMediumSmall,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius:
            BorderRadius.circular(AppLayout.radiusMd),
        boxShadow: AppLayout.shadowSm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Operation type badge
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppPaddings.small,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: opColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(
                      AppLayout.radiusSm),
                ),
                child: Text(
                  opLabel,
                  style: AppTextStyles.captionLg.bold
                      .withColor(opColor),
                ),
              ),
              SizedBox(width: AppLayout.width8),
              // Entity info
              Expanded(
                child: Text(
                  '${operation.entityType} #${operation.entityId}',
                  style:
                      AppTextStyles.titleSm.semiBold,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              // Status badge
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppPaddings.small,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: statusBg,
                  borderRadius: BorderRadius.circular(
                      AppLayout.radiusSm),
                ),
                child: Text(
                  statusLabel,
                  style: AppTextStyles.captionSm.semiBold
                      .withColor(statusColor),
                ),
              ),
            ],
          ),
          if (operation.retryCount > 0) ...[
            SizedBox(height: AppLayout.height8),
            Text(
              SyncStrings.retryCount(
                  operation.retryCount),
              style: AppTextStyles.captionLg
                  .withColor(AppColors.grayMedium),
            ),
          ],
          if (operation.errorMessage != null &&
              operation.errorMessage!.isNotEmpty) ...[
            SizedBox(height: AppLayout.height4),
            Text(
              operation.errorMessage!,
              style: AppTextStyles.captionLg
                  .withColor(AppColors.failedText),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          if (operation.status ==
              SyncOperationStatus.failed) ...[
            SizedBox(height: AppLayout.height8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: onRetry,
                icon: Icon(
                  Iconsax.refresh,
                  size: AppLayout.iconSizeSm,
                ),
                label: Text(CommonStrings.actionRetry),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primary,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
