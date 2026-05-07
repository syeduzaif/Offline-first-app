import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:offline_first_app/core/constants/app_colors.dart';
import 'package:offline_first_app/core/constants/app_layout.dart';
import 'package:offline_first_app/core/constants/app_text_styles.dart';
import 'package:offline_first_app/core/constants/strings/app_strings.dart';
import 'package:offline_first_app/features/students/domain/entities/student.dart';

class AttendanceStudentRowWidget extends StatelessWidget {
  const AttendanceStudentRowWidget({
    super.key,
    required this.student,
    required this.status,
    required this.onStatusChanged,
  });

  final Student student;
  final String status; // 'present' | 'absent' | 'late' | ''
  final ValueChanged<String> onStatusChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppLayout.radiusMd),
        boxShadow: AppLayout.shadowSm,
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: AppLayout.avatarSm,
            backgroundColor: AppColors.primaryLighter,
            child: Text(
              student.name.isNotEmpty ? student.name[0].toUpperCase() : '?',
              style: AppTextStyles.labelSm.withColor(AppColors.primary),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(student.name, style: AppTextStyles.labelMd, maxLines: 1, overflow: TextOverflow.ellipsis),
          ),
          Row(
            children: [
              _StatusButton(
                label: AttendanceStrings.present,
                isSelected: status == 'present',
                selectedColor: AppColors.greenDeep,
                onTap: () => onStatusChanged('present'),
              ),
              SizedBox(width: 6.w),
              _StatusButton(
                label: AttendanceStrings.absent,
                isSelected: status == 'absent',
                selectedColor: AppColors.red,
                onTap: () => onStatusChanged('absent'),
              ),
              SizedBox(width: 6.w),
              _StatusButton(
                label: AttendanceStrings.late,
                isSelected: status == 'late',
                selectedColor: AppColors.orange,
                onTap: () => onStatusChanged('late'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatusButton extends StatelessWidget {
  const _StatusButton({
    required this.label,
    required this.isSelected,
    required this.selectedColor,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final Color selectedColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28.w,
        height: 28.w,
        decoration: BoxDecoration(
          color: isSelected ? selectedColor : AppColors.grayVeryLight,
          borderRadius: BorderRadius.circular(AppLayout.radiusXs),
        ),
        child: Center(
          child: Text(
            label,
            style: AppTextStyles.captionSm.withColor(
              isSelected ? AppColors.white : AppColors.grayMedium,
            ),
          ),
        ),
      ),
    );
  }
}
