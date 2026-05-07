import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';
import 'package:offline_first_app/core/constants/app_colors.dart';
import 'package:offline_first_app/core/constants/app_layout.dart';
import 'package:offline_first_app/core/constants/app_text_styles.dart';
import 'package:offline_first_app/core/constants/strings/app_strings.dart';
import 'package:offline_first_app/features/timetable/domain/entities/timetable_entry.dart';

class PeriodCardWidget extends StatelessWidget {
  const PeriodCardWidget({super.key, required this.entry});

  final TimetableEntry entry;

  @override
  Widget build(BuildContext context) {
    final typeColor = _typeColor(entry.type);
    final typeLabel = _typeLabel(entry.type);

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppLayout.radiusMd),
        boxShadow: AppLayout.shadowSm,
        border: Border(left: BorderSide(color: typeColor, width: 4)),
      ),
      child: Padding(
        padding: EdgeInsets.all(14.w),
        child: Row(
          children: [
            // Time column
            SizedBox(
              width: 52.w,
              child: Column(
                children: [
                  Text(
                    entry.startTime,
                    style: AppTextStyles.labelSm.withColor(AppColors.grayMedium),
                  ),
                  SizedBox(height: 4.h),
                  Container(width: 1, height: 16.h, color: AppColors.grayVeryLight),
                  SizedBox(height: 4.h),
                  Text(
                    entry.endTime,
                    style: AppTextStyles.captionSm.withColor(AppColors.grayLight),
                  ),
                ],
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          entry.subject,
                          style: AppTextStyles.labelMd,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                        decoration: BoxDecoration(
                          color: typeColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(AppLayout.radiusFull),
                        ),
                        child: Text(
                          typeLabel,
                          style: AppTextStyles.captionSm.withColor(typeColor),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    entry.className,
                    style: AppTextStyles.captionMd.withColor(AppColors.grayMedium),
                  ),
                  SizedBox(height: 2.h),
                  Row(
                    children: [
                      if (entry.room.isNotEmpty) ...[
                        Icon(Iconsax.location, size: 12.w, color: AppColors.grayLight),
                        SizedBox(width: 4.w),
                        Text(entry.room, style: AppTextStyles.captionSm.withColor(AppColors.grayLight)),
                        SizedBox(width: 8.w),
                      ],
                      if (entry.campus.isNotEmpty)
                        Text(entry.campus, style: AppTextStyles.captionSm.withColor(AppColors.grayLight)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _typeColor(String type) {
    switch (type) {
      case 'lesson': return AppColors.primary;
      case 'break':  return AppColors.orange;
      default:       return AppColors.grayLight;
    }
  }

  String _typeLabel(String type) {
    switch (type) {
      case 'lesson': return TimetableStrings.lesson;
      case 'break':  return TimetableStrings.breakLabel;
      default:       return TimetableStrings.free;
    }
  }
}
