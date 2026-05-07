import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:offline_first_app/core/constants/app_colors.dart';
import 'package:offline_first_app/core/constants/app_layout.dart';
import 'package:offline_first_app/core/constants/app_text_styles.dart';
import 'package:offline_first_app/core/constants/strings/app_strings.dart';
import 'package:offline_first_app/features/lms/presentation/lms_providers.dart';
import 'package:offline_first_app/features/lms/presentation/widgets/grading_student_row_widget.dart';
import 'package:offline_first_app/features/students/presentation/students_providers.dart';

class GradingDetailPage extends ConsumerStatefulWidget {
  const GradingDetailPage({
    super.key,
    required this.classId,
    required this.classworkItemId,
  });

  final int classId;
  final int classworkItemId;

  @override
  ConsumerState<GradingDetailPage> createState() => _GradingDetailPageState();
}

class _GradingDetailPageState extends ConsumerState<GradingDetailPage> {
  final Map<int, String> _scores = {}; // studentId → score string

  @override
  Widget build(BuildContext context) {
    final itemAsync = ref.watch(lmsClassworkItemDetailProvider(widget.classworkItemId));
    final studentsAsync = ref.watch(studentsStreamProvider);

    return itemAsync.when(
      data: (item) => Scaffold(
        backgroundColor: AppColors.grayVeryLight,
        appBar: AppBar(
          title: Text(
            item?.title ?? LmsStrings.grading,
            style: AppTextStyles.titleMd,
          ),
          backgroundColor: AppColors.white,
          elevation: 0,
        ),
        body: Column(
          children: [
            if (item != null)
              Container(
                color: AppColors.white,
                padding: EdgeInsets.all(16.w),
                child: Row(
                  children: [
                    Text(
                      '${item.gradedCount}/${item.totalCount} ${LmsStrings.graded}',
                      style: AppTextStyles.bodyMd.withColor(AppColors.grayMedium),
                    ),
                    const Spacer(),
                    Text(
                      '${item.totalPoints} ${LmsStrings.points}',
                      style: AppTextStyles.labelMd.withColor(AppColors.primary),
                    ),
                  ],
                ),
              ),
            Expanded(
              child: studentsAsync.when(
                data: (students) => ListView.builder(
                  padding: EdgeInsets.all(16.w),
                  itemCount: students.length,
                  itemBuilder: (_, i) {
                    final student = students[i];
                    return GradingStudentRowWidget(
                      student: student,
                      totalPoints: item?.totalPoints ?? 100,
                      score: _scores[student.id] ?? '',
                      onScoreChanged: (v) =>
                          setState(() => _scores[student.id] = v),
                    );
                  },
                ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('Error: $e')),
              ),
            ),
            SafeArea(
              child: Padding(
                padding: EdgeInsets.all(16.w),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppLayout.radiusMd),
                      ),
                    ),
                    onPressed: item != null ? () => _saveGrades(context, item.totalPoints) : null,
                    child: Text(
                      LmsStrings.saveGrades,
                      style: AppTextStyles.labelMd.withColor(AppColors.white),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      loading: () => Scaffold(
        appBar: AppBar(title: Text(LmsStrings.grading)),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        appBar: AppBar(title: Text(LmsStrings.grading)),
        body: Center(child: Text('Error: $e')),
      ),
    );
  }

  Future<void> _saveGrades(BuildContext context, int totalPoints) async {
    final item = ref.read(lmsClassworkItemDetailProvider(widget.classworkItemId)).value;
    if (item == null) return;

    final gradedCount = _scores.values.where((s) => s.isNotEmpty).length;
    await ref.read(lmsRepositoryProvider).updateClassworkItem(
          item.copyWith(gradedCount: gradedCount),
        );

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(LmsStrings.gradeSaved),
          backgroundColor: AppColors.greenDeep,
        ),
      );
    }
  }
}
