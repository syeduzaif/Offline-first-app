import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:offline_first_app/core/constants/app_colors.dart';
import 'package:offline_first_app/core/constants/app_layout.dart';
import 'package:offline_first_app/core/constants/app_text_styles.dart';
import 'package:offline_first_app/core/constants/strings/app_strings.dart';
import 'package:offline_first_app/features/attendance/presentation/attendance_providers.dart';
import 'package:offline_first_app/features/lms/domain/entities/lms_class.dart';
import 'package:offline_first_app/features/lms/presentation/lms_providers.dart';

class ClassSelectorWidget extends ConsumerWidget {
  const ClassSelectorWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final classesAsync = ref.watch(lmsClassesStreamProvider);
    final selectedClass = ref.watch(attendanceSelectedClassProvider);

    return classesAsync.when(
      data: (classes) => Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: AppColors.white,
          border: Border(bottom: BorderSide(color: AppColors.grayVeryLight)),
        ),
        child: DropdownButton<LmsClass>(
          isExpanded: true,
          value: selectedClass,
          hint: Text(AttendanceStrings.selectClass, style: AppTextStyles.bodyMd.withColor(AppColors.grayLight)),
          underline: const SizedBox.shrink(),
          icon: const Icon(Icons.keyboard_arrow_down),
          borderRadius: BorderRadius.circular(AppLayout.radiusMd),
          items: classes.map((c) => DropdownMenuItem(
            value: c,
            child: Text(c.name, style: AppTextStyles.bodyMd),
          )).toList(),
          onChanged: (c) => ref.read(attendanceSelectedClassProvider.notifier).state = c,
        ),
      ),
      loading: () => const SizedBox(height: 48),
      error: (e, _) => const SizedBox.shrink(),
    );
  }
}
