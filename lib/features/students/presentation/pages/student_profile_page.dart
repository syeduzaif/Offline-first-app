import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';
import 'package:offline_first_app/core/constants/app_colors.dart';
import 'package:offline_first_app/core/constants/app_layout.dart';
import 'package:offline_first_app/core/constants/app_text_styles.dart';
import 'package:offline_first_app/core/constants/strings/app_strings.dart';
import 'package:offline_first_app/features/attendance/presentation/attendance_providers.dart';
import 'package:offline_first_app/features/students/presentation/students_providers.dart';

class StudentProfilePage extends ConsumerWidget {
  const StudentProfilePage({super.key, required this.studentId});

  final int studentId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final studentAsync = ref.watch(studentDetailProvider(studentId));

    return studentAsync.when(
      data: (student) {
        if (student == null) {
          return Scaffold(
            appBar: AppBar(title: Text(StudentsStrings.profileTitle)),
            body: const Center(child: Text('Student not found')),
          );
        }

        return DefaultTabController(
          length: 3,
          child: Scaffold(
            backgroundColor: AppColors.grayVeryLight,
            body: NestedScrollView(
              headerSliverBuilder: (ctx, _) => [
                SliverAppBar(
                  expandedHeight: 180.h,
                  pinned: true,
                  backgroundColor: AppColors.primary,
                  flexibleSpace: FlexibleSpaceBar(
                    background: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [AppColors.primary, AppColors.primaryMild],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: SafeArea(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(height: 40.h),
                            CircleAvatar(
                              radius: AppLayout.avatarLg,
                              backgroundColor: AppColors.white.withValues(alpha: 0.2),
                              child: Text(
                                student.name.isNotEmpty
                                    ? student.name[0].toUpperCase()
                                    : '?',
                                style: AppTextStyles.h2.withColor(AppColors.white),
                              ),
                            ),
                            SizedBox(height: 8.h),
                            Text(student.name, style: AppTextStyles.titleMd.withColor(AppColors.white)),
                            Text(
                              'Grade ${student.grade} • Section ${student.section}',
                              style: AppTextStyles.bodySm.withColor(AppColors.white.withValues(alpha: 0.8)),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  bottom: TabBar(
                    labelColor: AppColors.white,
                    unselectedLabelColor: AppColors.white.withValues(alpha: 0.6),
                    indicatorColor: AppColors.white,
                    tabs: const [
                      Tab(text: 'Profile'),
                      Tab(text: 'Attendance'),
                      Tab(text: 'Classes'),
                    ],
                  ),
                ),
              ],
              body: TabBarView(
                children: [
                  // Profile Tab
                  ListView(
                    padding: EdgeInsets.all(16.w),
                    children: [
                      _InfoCard(items: [
                        _InfoItem(icon: Iconsax.sms, label: StudentsStrings.email, value: student.email.isNotEmpty ? student.email : '—'),
                        _InfoItem(icon: Iconsax.call, label: StudentsStrings.phone, value: student.phone.isNotEmpty ? student.phone : '—'),
                        _InfoItem(icon: Iconsax.building, label: StudentsStrings.branch, value: student.branch.isNotEmpty ? student.branch : '—'),
                      ]),
                    ],
                  ),

                  // Attendance Tab
                  _AttendanceTab(studentId: studentId),

                  // Classes Tab
                  Center(
                    child: Text(
                      'Classes available after backend sync',
                      style: AppTextStyles.bodyMd.withColor(AppColors.grayMedium),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
      loading: () => Scaffold(
        appBar: AppBar(title: Text(StudentsStrings.profileTitle)),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        appBar: AppBar(title: Text(StudentsStrings.profileTitle)),
        body: Center(child: Text('Error: $e')),
      ),
    );
  }
}

class _AttendanceTab extends ConsumerWidget {
  const _AttendanceTab({required this.studentId});
  final int studentId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final attendanceAsync = ref.watch(attendanceForStudentProvider(studentId));

    return attendanceAsync.when(
      data: (records) {
        final present = records.where((r) => r.status == 'present').length;
        final absent = records.where((r) => r.status == 'absent').length;
        final late = records.where((r) => r.status == 'late').length;
        final total = records.length;
        final pct = total > 0 ? (present / total * 100).round() : 0;

        return ListView(
          padding: EdgeInsets.all(16.w),
          children: [
            _InfoCard(items: [
              _InfoItem(icon: Iconsax.tick_circle, label: StudentsStrings.present, value: '$present ($pct%)'),
              _InfoItem(icon: Iconsax.close_circle, label: StudentsStrings.absent, value: '$absent'),
              _InfoItem(icon: Iconsax.clock, label: StudentsStrings.late, value: '$late'),
            ]),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.items});
  final List<_InfoItem> items;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppLayout.radiusMd),
        boxShadow: AppLayout.shadowSm,
      ),
      child: Column(
        children: items.asMap().entries.map((entry) {
          final i = entry.key;
          final item = entry.value;
          return Column(
            children: [
              Padding(
                padding: EdgeInsets.all(14.w),
                child: Row(
                  children: [
                    Icon(item.icon, size: AppLayout.iconSizeMdSm, color: AppColors.primary),
                    SizedBox(width: 12.w),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item.label, style: AppTextStyles.captionMd.withColor(AppColors.grayMedium)),
                        Text(item.value, style: AppTextStyles.labelMd),
                      ],
                    ),
                  ],
                ),
              ),
              if (i < items.length - 1)
                Divider(height: 1, color: AppColors.grayVeryLight),
            ],
          );
        }).toList(),
      ),
    );
  }
}

class _InfoItem {
  const _InfoItem({required this.icon, required this.label, required this.value});
  final IconData icon;
  final String label;
  final String value;
}
