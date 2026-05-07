import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:offline_first_app/core/constants/app_colors.dart';
import 'package:offline_first_app/core/constants/app_layout.dart';
import 'package:offline_first_app/core/constants/app_text_styles.dart';
import 'package:offline_first_app/core/constants/strings/app_strings.dart';
import 'package:offline_first_app/features/attendance/domain/entities/attendance_record.dart';
import 'package:offline_first_app/features/attendance/presentation/attendance_providers.dart';
import 'package:offline_first_app/features/attendance/presentation/widgets/attendance_student_row_widget.dart';
import 'package:offline_first_app/features/attendance/presentation/widgets/class_selector_widget.dart';
import 'package:offline_first_app/features/students/presentation/students_providers.dart';

class AttendancePage extends ConsumerStatefulWidget {
  const AttendancePage({super.key});

  @override
  ConsumerState<AttendancePage> createState() => _AttendancePageState();
}

class _AttendancePageState extends ConsumerState<AttendancePage> {
  final Map<int, String> _marks = {}; // studentId → status

  @override
  Widget build(BuildContext context) {
    final selectedClass = ref.watch(attendanceSelectedClassProvider);
    final selectedDate = ref.watch(attendanceDateProvider);
    final studentsAsync = ref.watch(studentsStreamProvider);

    // Load existing attendance for pre-filling marks
    if (selectedClass != null) {
      final dateStr = DateFormat('yyyy-MM-dd').format(selectedDate);
      final existingAsync = ref.watch(attendanceForClassProvider(selectedClass.id, dateStr));
      existingAsync.whenData((records) {
        for (final r in records) {
          if (!_marks.containsKey(r.studentId)) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              setState(() => _marks[r.studentId] = r.status);
            });
          }
        }
      });
    }

    return Scaffold(
      backgroundColor: AppColors.grayVeryLight,
      appBar: AppBar(
        title: Text(AttendanceStrings.title, style: AppTextStyles.titleMd),
        backgroundColor: AppColors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Class selector
          const ClassSelectorWidget(),

          // Date selector row
          _DateSelectorRow(
            selectedDate: selectedDate,
            onDateSelected: (d) =>
                ref.read(attendanceDateProvider.notifier).state = d,
          ),

          // Student list
          Expanded(
            child: selectedClass == null
                ? Center(
                    child: Text(
                      AttendanceStrings.noClassSelected,
                      style: AppTextStyles.bodyMd.withColor(AppColors.grayLight),
                      textAlign: TextAlign.center,
                    ),
                  )
                : studentsAsync.when(
                    data: (students) {
                      if (students.isEmpty) {
                        return Center(
                          child: Text(AttendanceStrings.noStudents,
                              style: AppTextStyles.bodyMd.withColor(AppColors.grayLight)),
                        );
                      }
                      return ListView.builder(
                        padding: EdgeInsets.all(16.w),
                        itemCount: students.length,
                        itemBuilder: (_, i) {
                          final student = students[i];
                          return AttendanceStudentRowWidget(
                            student: student,
                            status: _marks[student.id] ?? '',
                            onStatusChanged: (s) =>
                                setState(() => _marks[student.id] = s),
                          );
                        },
                      );
                    },
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (e, _) => Center(child: Text('Error: $e')),
                  ),
          ),

          // Save button
          if (selectedClass != null)
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
                    onPressed: () => _saveAttendance(context),
                    child: Text(
                      AttendanceStrings.saveAll,
                      style: AppTextStyles.labelMd.withColor(AppColors.white),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _saveAttendance(BuildContext context) async {
    final selectedClass = ref.read(attendanceSelectedClassProvider);
    final selectedDate = ref.read(attendanceDateProvider);
    if (selectedClass == null) return;

    final repo = ref.read(attendanceRepositoryProvider);
    final dateStr = DateFormat('yyyy-MM-dd').format(selectedDate);

    for (final entry in _marks.entries) {
      if (entry.value.isEmpty) continue;
      await repo.upsertRecord(AttendanceRecord(
        id: 0,
        studentId: entry.key,
        classId: selectedClass.id,
        date: DateTime.tryParse(dateStr) ?? selectedDate,
        status: entry.value,
      ));
    }

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AttendanceStrings.savedSuccess),
          backgroundColor: AppColors.greenDeep,
        ),
      );
    }
  }
}

class _DateSelectorRow extends StatelessWidget {
  const _DateSelectorRow({
    required this.selectedDate,
    required this.onDateSelected,
  });

  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateSelected;

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final dates = List.generate(7, (i) => today.subtract(Duration(days: 6 - i)));

    return Container(
      height: 70.h,
      color: AppColors.white,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        itemCount: dates.length,
        itemBuilder: (_, i) {
          final date = dates[i];
          final isSelected = DateFormat('yyyy-MM-dd').format(date) ==
              DateFormat('yyyy-MM-dd').format(selectedDate);
          return GestureDetector(
            onTap: () => onDateSelected(date),
            child: Container(
              width: 42.w,
              margin: EdgeInsets.symmetric(horizontal: 4.w),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : AppColors.grayVeryLight,
                borderRadius: BorderRadius.circular(AppLayout.radiusSm),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    DateFormat('EEE').format(date).substring(0, 1),
                    style: AppTextStyles.captionSm.withColor(
                      isSelected ? AppColors.white.withValues(alpha: 0.8) : AppColors.grayMedium,
                    ),
                  ),
                  Text(
                    '${date.day}',
                    style: AppTextStyles.labelSm.withColor(
                      isSelected ? AppColors.white : AppColors.primaryText,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
