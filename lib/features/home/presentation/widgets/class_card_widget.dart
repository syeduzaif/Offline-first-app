import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:offline_first_app/core/constants/app_colors.dart';
import 'package:offline_first_app/core/constants/app_layout.dart';
import 'package:offline_first_app/core/constants/app_text_styles.dart';
import 'package:offline_first_app/core/constants/strings/app_strings.dart';
import 'package:offline_first_app/features/lms/domain/entities/lms_class.dart';

class HomeClassCardWidget extends StatelessWidget {
  const HomeClassCardWidget({super.key, required this.lmsClass});

  final LmsClass lmsClass;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/lms/${lmsClass.id}'),
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
                  SizedBox(height: 2.h),
                  Text(
                    '${lmsClass.subject} • ${lmsClass.studentCount} ${LmsStrings.students}',
                    style: AppTextStyles.captionMd.withColor(AppColors.grayMedium),
                  ),
                ],
              ),
            ),
            Icon(Iconsax.arrow_right_3, size: AppLayout.iconSizeSm, color: AppColors.grayLight),
          ],
        ),
      ),
    );
  }
}
