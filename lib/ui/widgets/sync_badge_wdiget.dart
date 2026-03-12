import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:offline_first_app/core/constants/app_colors.dart';
import 'package:offline_first_app/core/constants/app_layout.dart';
import 'package:offline_first_app/core/constants/app_paddings.dart';
import 'package:offline_first_app/core/constants/app_text_styles.dart';
import 'package:offline_first_app/core/constants/strings/app_strings.dart';
import 'package:offline_first_app/domain/models/sync_status.dart';

class SyncBadge extends StatelessWidget {
  const SyncBadge({super.key, required this.status});

  final SyncStatus status;

  @override
  Widget build(BuildContext context) {
    final (bg, text, label) = switch (status) {
      SyncStatus.synced => (
          AppColors.syncedBg,
          AppColors.syncedText,
          SyncStrings.statusSynced,
        ),
      SyncStatus.pending => (
          AppColors.pendingBg,
          AppColors.pendingText,
          SyncStrings.statusPending,
        ),
      SyncStatus.failed => (
          AppColors.failedBg,
          AppColors.failedText,
          SyncStrings.statusFailed,
        ),
    };

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppPaddings.small,
        vertical: 2.h,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius:
            BorderRadius.circular(AppLayout.radiusSm),
      ),
      child: Text(
        label,
        style: AppTextStyles.captionSm
            .semiBold
            .withColor(text),
      ),
    );
  }
}
