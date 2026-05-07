import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:offline_first_app/core/constants/app_colors.dart';
import 'package:offline_first_app/core/constants/app_text_styles.dart';
import 'package:offline_first_app/core/constants/strings/app_strings.dart';
import 'package:offline_first_app/features/timetable/presentation/timetable_providers.dart';
import 'package:offline_first_app/features/timetable/presentation/widgets/day_selector_widget.dart';
import 'package:offline_first_app/features/timetable/presentation/widgets/period_card_widget.dart';

class TimetablePage extends ConsumerWidget {
  const TimetablePage({super.key});

  static const _days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri'];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDay = ref.watch(timetableSelectedDayProvider);

    return Scaffold(
      backgroundColor: AppColors.grayVeryLight,
      appBar: AppBar(
        title: Text(TimetableStrings.title, style: AppTextStyles.titleMd),
        backgroundColor: AppColors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          const DaySelectorWidget(),
          Expanded(
            child: PageView.builder(
              itemCount: _days.length,
              controller: PageController(
                initialPage: _days.indexOf(selectedDay),
              ),
              onPageChanged: (i) =>
                  ref.read(timetableSelectedDayProvider.notifier).state = _days[i],
              itemBuilder: (_, i) => _DayPage(day: _days[i]),
            ),
          ),
        ],
      ),
    );
  }
}

class _DayPage extends ConsumerWidget {
  const _DayPage({required this.day});
  final String day;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entriesAsync = ref.watch(timetableForDayProvider(day));

    return entriesAsync.when(
      data: (entries) {
        if (entries.isEmpty) {
          return Center(
            child: Text(
              TimetableStrings.noClasses,
              style: AppTextStyles.bodyMd.withColor(AppColors.grayLight),
            ),
          );
        }
        return ListView.builder(
          padding: EdgeInsets.all(16.w),
          itemCount: entries.length,
          itemBuilder: (_, i) => PeriodCardWidget(entry: entries[i]),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
    );
  }
}
