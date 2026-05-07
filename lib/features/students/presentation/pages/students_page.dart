import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';
import 'package:offline_first_app/core/constants/app_colors.dart';
import 'package:offline_first_app/core/constants/app_layout.dart';
import 'package:offline_first_app/core/constants/app_text_styles.dart';
import 'package:offline_first_app/core/constants/strings/app_strings.dart';
import 'package:offline_first_app/features/students/domain/entities/student.dart';
import 'package:offline_first_app/features/students/presentation/students_providers.dart';
import 'package:offline_first_app/features/students/presentation/widgets/student_card_widget.dart';

class StudentsPage extends ConsumerStatefulWidget {
  const StudentsPage({super.key});

  @override
  ConsumerState<StudentsPage> createState() => _StudentsPageState();
}

class _StudentsPageState extends ConsumerState<StudentsPage> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final studentsAsync = ref.watch(studentsStreamProvider);

    return Scaffold(
      backgroundColor: AppColors.grayVeryLight,
      appBar: AppBar(
        title: Text(StudentsStrings.title, style: AppTextStyles.titleMd),
        backgroundColor: AppColors.white,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddStudentDialog(context),
        backgroundColor: AppColors.primary,
        child: Icon(Iconsax.add, color: AppColors.white),
      ),
      body: Column(
        children: [
          // Search bar
          Container(
            color: AppColors.white,
            padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 16.h),
            child: TextField(
              controller: _searchController,
              onChanged: (v) => setState(() => _searchQuery = v.toLowerCase()),
              decoration: InputDecoration(
                hintText: StudentsStrings.searchHint,
                hintStyle: AppTextStyles.bodyMd.withColor(AppColors.grayLight),
                prefixIcon: Icon(Iconsax.search_normal, size: AppLayout.iconSizeMdSm, color: AppColors.grayLight),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: Icon(Iconsax.close_circle, size: AppLayout.iconSizeMdSm),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                filled: true,
                fillColor: AppColors.grayVeryLight,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppLayout.radiusMd),
                  borderSide: BorderSide.none,
                ),
                contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
              ),
            ),
          ),
          Expanded(
            child: studentsAsync.when(
              data: (students) {
                final filtered = _searchQuery.isEmpty
                    ? students
                    : students
                        .where((s) =>
                            s.name.toLowerCase().contains(_searchQuery) ||
                            s.grade.toLowerCase().contains(_searchQuery) ||
                            s.section.toLowerCase().contains(_searchQuery))
                        .toList();

                if (filtered.isEmpty) {
                  return Center(
                    child: Text(
                      StudentsStrings.noStudents,
                      style: AppTextStyles.bodyMd.withColor(AppColors.grayLight),
                    ),
                  );
                }

                return ListView.builder(
                  padding: EdgeInsets.all(16.w),
                  itemCount: filtered.length,
                  itemBuilder: (_, i) => StudentCardWidget(student: filtered[i]),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddStudentDialog(BuildContext context) {
    final nameController = TextEditingController();
    final gradeController = TextEditingController();
    final sectionController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(StudentsStrings.addStudent, style: AppTextStyles.titleSm),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _FormField(controller: nameController, label: StudentsStrings.nameLabel, required: true),
              SizedBox(height: 12.h),
              _FormField(controller: gradeController, label: StudentsStrings.grade),
              SizedBox(height: 12.h),
              _FormField(controller: sectionController, label: StudentsStrings.section),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(StudentsStrings.cancel),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            onPressed: () {
              if (!formKey.currentState!.validate()) return;
              ref.read(studentsRepositoryProvider).createStudent(Student(
                    id: 0,
                    name: nameController.text.trim(),
                    grade: gradeController.text.trim(),
                    section: sectionController.text.trim(),
                  ));
              Navigator.of(ctx).pop();
            },
            child: Text(StudentsStrings.saveStudent, style: AppTextStyles.labelMd.withColor(AppColors.white)),
          ),
        ],
      ),
    );
  }
}

class _FormField extends StatelessWidget {
  const _FormField({
    required this.controller,
    required this.label,
    this.required = false,
  });

  final TextEditingController controller;
  final String label;
  final bool required;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppLayout.radiusSm),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      ),
      validator: required
          ? (v) => (v == null || v.trim().isEmpty) ? 'Required' : null
          : null,
    );
  }
}
