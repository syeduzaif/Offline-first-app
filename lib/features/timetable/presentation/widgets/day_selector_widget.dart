import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:offline_first_app/core/constants/app_colors.dart';
import 'package:offline_first_app/core/constants/app_layout.dart';
import 'package:offline_first_app/core/constants/app_text_styles.dart';
import 'package:offline_first_app/features/timetable/presentation/timetable_providers.dart';

class DaySelectorWidget extends ConsumerWidget {
  const DaySelectorWidget({super.key});

  static const _days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri'];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDay = ref.watch(timetableSelectedDayProvider);

    return Container(
      color: AppColors.white,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Row(
        children: _days.map((day) {
          final isSelected = day == selectedDay;
          return Expanded(
            child: GestureDetector(
              onTap: () =>
                  ref.read(timetableSelectedDayProvider.notifier).state = day,
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 3.w),
                padding: EdgeInsets.symmetric(vertical: 8.h),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(AppLayout.radiusSm),
                ),
                child: Text(
                  day,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.labelSm.withColor(
                    isSelected ? AppColors.white : AppColors.grayMedium,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
