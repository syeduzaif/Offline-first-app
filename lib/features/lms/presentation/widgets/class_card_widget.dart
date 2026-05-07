import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:offline_first_app/core/constants/app_colors.dart';
import 'package:offline_first_app/core/constants/app_layout.dart';
import 'package:offline_first_app/core/constants/app_text_styles.dart';
import 'package:offline_first_app/core/constants/strings/app_strings.dart';
import 'package:offline_first_app/features/lms/domain/entities/lms_class.dart';

class LmsClassCardWidget extends StatelessWidget {
  const LmsClassCardWidget({super.key, required this.lmsClass});

  final LmsClass lmsClass;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/lms/${lmsClass.id}'),
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppLayout.radiusMd),
          boxShadow: AppLayout.shadowSm,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44.w,
                  height: 44.w,
                  decoration: BoxDecoration(
                    color: AppColors.primaryLighter,
                    borderRadius: BorderRadius.circular(AppLayout.radiusSm),
                  ),
                  child: Icon(Iconsax.book, color: AppColors.primary, size: AppLayout.iconSizeMd),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        lmsClass.name,
                        style: AppTextStyles.labelMd,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        lmsClass.subject,
                        style: AppTextStyles.captionMd.withColor(AppColors.grayMedium),
                      ),
                    ],
                  ),
                ),
                Icon(Iconsax.arrow_right_3, size: AppLayout.iconSizeSm, color: AppColors.grayLight),
              ],
            ),
            SizedBox(height: 12.h),
            Row(
              children: [
                _Chip(label: 'Grade ${lmsClass.grade}', color: AppColors.purpleLight),
                SizedBox(width: 6.w),
                _Chip(label: lmsClass.section, color: AppColors.aquaLight),
                SizedBox(width: 6.w),
                if (lmsClass.campus.isNotEmpty)
                  _Chip(label: lmsClass.campus, color: AppColors.lavenderLight),
                const Spacer(),
                Icon(Iconsax.people, size: AppLayout.iconSizeSm, color: AppColors.grayMedium),
                SizedBox(width: 4.w),
                Text(
                  '${lmsClass.studentCount} ${LmsStrings.students}',
                  style: AppTextStyles.captionMd.withColor(AppColors.grayMedium),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(AppLayout.radiusFull),
      ),
      child: Text(label, style: AppTextStyles.captionSm.withColor(AppColors.grayDark)),
    );
  }
}
