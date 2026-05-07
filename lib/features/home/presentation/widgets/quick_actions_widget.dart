import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:offline_first_app/core/constants/app_colors.dart';
import 'package:offline_first_app/core/constants/app_layout.dart';
import 'package:offline_first_app/core/constants/app_text_styles.dart';
import 'package:offline_first_app/core/constants/strings/app_strings.dart';

class QuickActionsWidget extends StatelessWidget {
  const QuickActionsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 88.h,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        children: [
          _QuickActionItem(
            icon: Iconsax.task_square,
            label: HomeStrings.takeAttendance,
            color: AppColors.primary,
            onTap: () => context.push('/attendance'),
          ),
          SizedBox(width: 12.w),
          _QuickActionItem(
            icon: Iconsax.document_text,
            label: HomeStrings.addAssignment,
            color: AppColors.emerald,
            onTap: () => context.push('/lms'),
          ),
          SizedBox(width: 12.w),
          _QuickActionItem(
            icon: Iconsax.calendar,
            label: HomeStrings.viewTimetable,
            color: AppColors.orange,
            onTap: () => context.push('/timetable'),
          ),
          SizedBox(width: 12.w),
          _QuickActionItem(
            icon: Iconsax.book,
            label: HomeStrings.lms,
            color: AppColors.blue,
            onTap: () => context.push('/lms'),
          ),
        ],
      ),
    );
  }
}

class _QuickActionItem extends StatelessWidget {
  const _QuickActionItem({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 72.w,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppLayout.radiusMd),
          boxShadow: AppLayout.shadowSm,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 40.w,
              height: 40.w,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(AppLayout.radiusSm),
              ),
              child: Icon(icon, color: color, size: AppLayout.iconSizeMdSm),
            ),
            SizedBox(height: 6.h),
            Text(
              label,
              style: AppTextStyles.captionMd,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
