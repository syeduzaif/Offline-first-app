import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import 'package:offline_first_app/core/constants/app_colors.dart';
import 'package:offline_first_app/core/constants/app_layout.dart';
import 'package:offline_first_app/core/constants/app_paddings.dart';
import 'package:offline_first_app/core/constants/app_text_styles.dart';
import 'package:offline_first_app/core/constants/strings/app_strings.dart';
import 'package:offline_first_app/providers/core_providers.dart';
import 'package:offline_first_app/ui/views/sync_queue/sync_queue_providers.dart';
import 'package:offline_first_app/ui/views/sync_queue/widgets/sync_operation_card_wdiget.dart';
import 'package:offline_first_app/ui/widgets/empty_state_wdiget.dart';

class SyncQueueView extends ConsumerWidget {
  const SyncQueueView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final operations =
        ref.watch(syncOperationsProvider).valueOrNull ?? [];
    final isSyncing =
        ref.watch(isSyncingProvider).valueOrNull ?? false;

    return Scaffold(
      backgroundColor: AppColors.primaryLighter,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(
                left: AppPaddings.base,
                right: AppPaddings.base,
                top: AppPaddings.verticalMedium,
                bottom: AppPaddings.verticalBase,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      SyncStrings.titleSyncQueue,
                      style: AppTextStyles.h3.bold,
                    ),
                  ),
                  if (isSyncing)
                    SizedBox(
                      width: AppLayout.iconSizeMdSm,
                      height: AppLayout.iconSizeMdSm,
                      child: const CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.primary,
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: AppPaddings.horizontalBase,
              child: Row(
                children: [
                  _ActionButton(
                    label: SyncStrings.syncNow,
                    icon: Iconsax.refresh,
                    onTap: () => ref
                        .read(syncServiceProvider)
                        .syncAll(),
                  ),
                  SizedBox(width: AppLayout.width12),
                  _ActionButton(
                    label: SyncStrings.clearCompleted,
                    icon: Iconsax.trash,
                    onTap: () => ref
                        .read(appDatabaseProvider)
                        .syncQueueDao
                        .clearCompleted(),
                  ),
                ],
              ),
            ),
            SizedBox(height: AppLayout.height12),
            Expanded(
              child: operations.isEmpty
                  ? EmptyState(
                      message: SyncStrings.noOperations,
                      icon: Iconsax.tick_circle,
                    )
                  : ListView.builder(
                      padding: AppPaddings.only(
                        left: AppPaddings.base,
                        right: AppPaddings.base,
                        bottom:
                            AppLayout.bottomNavBarHeight +
                                AppPaddings.base +
                                AppPaddings.large,
                      ),
                      itemCount: operations.length,
                      itemBuilder: (context, index) {
                        final op = operations[index];
                        return SyncOperationCard(
                          key: ValueKey(op.id),
                          operation: op,
                          onRetry: () async {
                            await ref
                                .read(appDatabaseProvider)
                                .syncQueueDao
                                .resetToPending(op.id);
                            await ref
                                .read(syncServiceProvider)
                                .syncAll();
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: AppPaddings.mediumSmall,
          vertical: AppPaddings.verticalBase,
        ),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius:
              BorderRadius.circular(AppLayout.radiusMd),
          boxShadow: AppLayout.shadowSm,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: AppLayout.iconSizeSm,
              color: AppColors.primary,
            ),
            SizedBox(width: AppLayout.width8),
            Text(
              label,
              style: AppTextStyles.labelMd.semiBold
                  .withColor(AppColors.primary),
            ),
          ],
        ),
      ),
    );
  }
}
