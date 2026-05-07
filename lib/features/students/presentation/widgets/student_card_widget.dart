import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:offline_first_app/core/constants/app_colors.dart';
import 'package:offline_first_app/core/constants/app_layout.dart';
import 'package:offline_first_app/core/constants/app_text_styles.dart';
import 'package:offline_first_app/core/services/database.dart';
import 'package:offline_first_app/features/students/domain/entities/student.dart';

class StudentCardWidget extends StatelessWidget {
  const StudentCardWidget({super.key, required this.student});

  final Student student;

  @override
  Widget build(BuildContext context) {
    final isPending = student.syncStatus == SyncStatus.pending;

    return GestureDetector(
      onTap: () => context.push('/students/${student.id}'),
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
            CircleAvatar(
              radius: AppLayout.avatarMd,
              backgroundColor: AppColors.primaryLighter,
              child: Text(
                student.name.isNotEmpty ? student.name[0].toUpperCase() : '?',
                style: AppTextStyles.titleSm.withColor(AppColors.primary),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    student.name,
                    style: AppTextStyles.labelMd,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    'Grade ${student.grade} • Section ${student.section}',
                    style: AppTextStyles.captionMd.withColor(AppColors.grayMedium),
                  ),
                ],
              ),
            ),
            if (isPending)
              Container(
                width: 8.w,
                height: 8.w,
                decoration: const BoxDecoration(
                  color: AppColors.orange,
                  shape: BoxShape.circle,
                ),
              ),
            SizedBox(width: 8.w),
            Icon(Iconsax.arrow_right_3, size: AppLayout.iconSizeSm, color: AppColors.grayLight),
          ],
        ),
      ),
    );
  }
}
