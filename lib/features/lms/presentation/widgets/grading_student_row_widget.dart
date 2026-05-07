import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:offline_first_app/core/constants/app_colors.dart';
import 'package:offline_first_app/core/constants/app_layout.dart';
import 'package:offline_first_app/core/constants/app_text_styles.dart';
import 'package:offline_first_app/features/students/domain/entities/student.dart';

class GradingStudentRowWidget extends StatelessWidget {
  const GradingStudentRowWidget({
    super.key,
    required this.student,
    required this.totalPoints,
    required this.score,
    required this.onScoreChanged,
  });

  final Student student;
  final int totalPoints;
  final String score;
  final ValueChanged<String> onScoreChanged;

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
          SizedBox(
            width: 60.w,
            child: TextField(
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              style: AppTextStyles.labelMd,
              controller: TextEditingController(text: score)
                ..selection = TextSelection.fromPosition(
                  TextPosition(offset: score.length),
                ),
              decoration: InputDecoration(
                isDense: true,
                contentPadding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
                hintText: '—',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppLayout.radiusXs),
                  borderSide: BorderSide(color: AppColors.grayVeryLight),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppLayout.radiusXs),
                  borderSide: BorderSide(color: AppColors.grayVeryLight),
                ),
              ),
              onChanged: onScoreChanged,
            ),
          ),
          SizedBox(width: 8.w),
          Text('/$totalPoints', style: AppTextStyles.captionMd.withColor(AppColors.grayMedium)),
        ],
      ),
    );
  }
}
