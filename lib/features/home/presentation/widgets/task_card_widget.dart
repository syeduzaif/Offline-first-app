import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:offline_first_app/core/constants/app_colors.dart';
import 'package:offline_first_app/core/constants/app_layout.dart';
import 'package:offline_first_app/core/constants/app_text_styles.dart';
import 'package:offline_first_app/core/constants/strings/app_strings.dart';
import 'package:offline_first_app/features/lms/domain/entities/lms_classwork_item.dart';

class TaskCardWidget extends StatelessWidget {
  const TaskCardWidget({super.key, required this.item});

  final LmsClassworkItem item;

  @override
  Widget build(BuildContext context) {
    final hasDue = item.dueDate != null;
    final isOverdue = hasDue && item.dueDate!.isBefore(DateTime.now());

    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppLayout.radiusMd),
        boxShadow: AppLayout.shadowSm,
        border: Border.all(
          color: isOverdue ? AppColors.red.withValues(alpha: 0.3) : AppColors.grayVeryLight,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40.w,
            height: 40.w,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppLayout.radiusSm),
            ),
            child: Icon(Iconsax.document_text, color: AppColors.primary, size: AppLayout.iconSizeMdSm),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: AppTextStyles.labelMd,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 2.h),
                Text(
                  '${item.submittedCount}/${item.totalCount} ${LmsStrings.submitted}',
                  style: AppTextStyles.captionMd.withColor(AppColors.grayMedium),
                ),
              ],
            ),
          ),
          if (hasDue)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: isOverdue ? AppColors.redLight : AppColors.orangeLight,
                borderRadius: BorderRadius.circular(AppLayout.radiusFull),
              ),
              child: Text(
                DateFormat('MMM d').format(item.dueDate!),
                style: AppTextStyles.captionSm.withColor(
                  isOverdue ? AppColors.red : AppColors.orangeMedium,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
