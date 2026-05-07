import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:offline_first_app/core/constants/app_colors.dart';
import 'package:offline_first_app/core/constants/app_layout.dart';
import 'package:offline_first_app/core/constants/app_text_styles.dart';
import 'package:offline_first_app/core/constants/strings/app_strings.dart';
import 'package:offline_first_app/features/lms/domain/entities/lms_classwork_item.dart';

class ClassworkItemWidget extends StatelessWidget {
  const ClassworkItemWidget({
    super.key,
    required this.item,
    this.onTap,
  });

  final LmsClassworkItem item;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isAssignment = item.type == 'assignment';
    final hasDue = item.dueDate != null;
    final isOverdue = hasDue && item.dueDate!.isBefore(DateTime.now());

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 10.h),
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppLayout.radiusMd),
          boxShadow: AppLayout.shadowSm,
        ),
        child: Row(
          children: [
            Container(
              width: 40.w,
              height: 40.w,
              decoration: BoxDecoration(
                color: isAssignment
                    ? AppColors.primary.withValues(alpha: 0.1)
                    : AppColors.emerald.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppLayout.radiusSm),
              ),
              child: Icon(
                isAssignment ? Iconsax.document_text : Iconsax.book_saved,
                color: isAssignment ? AppColors.primary : AppColors.emerald,
                size: AppLayout.iconSizeMdSm,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.title, style: AppTextStyles.labelMd, maxLines: 1, overflow: TextOverflow.ellipsis),
                  SizedBox(height: 2.h),
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                        decoration: BoxDecoration(
                          color: isAssignment ? AppColors.primaryLighter : AppColors.mintLight,
                          borderRadius: BorderRadius.circular(AppLayout.radiusFull),
                        ),
                        child: Text(
                          isAssignment ? LmsStrings.assignment : LmsStrings.material,
                          style: AppTextStyles.captionSm.withColor(
                            isAssignment ? AppColors.primary : AppColors.emerald,
                          ),
                        ),
                      ),
                      if (isAssignment && item.totalCount > 0) ...[
                        SizedBox(width: 8.w),
                        Text(
                          '${item.submittedCount}/${item.totalCount} ${LmsStrings.submitted}',
                          style: AppTextStyles.captionSm.withColor(AppColors.grayMedium),
                        ),
                      ],
                    ],
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
            if (onTap != null) ...[
              SizedBox(width: 8.w),
              Icon(Iconsax.arrow_right_3, size: AppLayout.iconSizeSm, color: AppColors.grayLight),
            ],
          ],
        ),
      ),
    );
  }
}
