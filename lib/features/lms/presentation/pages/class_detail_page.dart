import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:offline_first_app/core/constants/app_colors.dart';
import 'package:offline_first_app/core/constants/app_text_styles.dart';
import 'package:offline_first_app/core/constants/strings/app_strings.dart';
import 'package:offline_first_app/features/lms/presentation/lms_providers.dart';
import 'package:offline_first_app/features/lms/presentation/widgets/classwork_item_widget.dart';

class ClassDetailPage extends ConsumerWidget {
  const ClassDetailPage({super.key, required this.classId});

  final int classId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final classAsync = ref.watch(lmsClassDetailProvider(classId));
    final classworkAsync = ref.watch(lmsClassworkForClassProvider(classId));

    return classAsync.when(
      data: (lmsClass) => DefaultTabController(
        length: 2,
        child: Scaffold(
          backgroundColor: AppColors.grayVeryLight,
          appBar: AppBar(
            title: Text(
              lmsClass?.name ?? LmsStrings.title,
              style: AppTextStyles.titleMd,
            ),
            backgroundColor: AppColors.white,
            elevation: 0,
            bottom: TabBar(
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.grayMedium,
              indicatorColor: AppColors.primary,
              tabs: const [
                Tab(text: LmsStrings.classwork),
                Tab(text: LmsStrings.grading),
              ],
            ),
          ),
          body: TabBarView(
            children: [
              // Classwork Tab
              classworkAsync.when(
                data: (items) {
                  if (items.isEmpty) {
                    return Center(
                      child: Text(LmsStrings.noClasswork,
                          style: AppTextStyles.bodyMd.withColor(AppColors.grayLight)),
                    );
                  }
                  return ListView.builder(
                    padding: EdgeInsets.all(16.w),
                    itemCount: items.length,
                    itemBuilder: (_, i) => ClassworkItemWidget(item: items[i]),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('Error: $e')),
              ),

              // Grading Tab
              classworkAsync.when(
                data: (items) {
                  final assignments =
                      items.where((i) => i.type == 'assignment').toList();
                  if (assignments.isEmpty) {
                    return Center(
                      child: Text(LmsStrings.noClasswork,
                          style: AppTextStyles.bodyMd.withColor(AppColors.grayLight)),
                    );
                  }
                  return ListView.builder(
                    padding: EdgeInsets.all(16.w),
                    itemCount: assignments.length,
                    itemBuilder: (_, i) {
                      final item = assignments[i];
                      return ClassworkItemWidget(
                        item: item,
                        onTap: () => context.push('/lms/$classId/grading/${item.id}'),
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('Error: $e')),
              ),
            ],
          ),
        ),
      ),
      loading: () => Scaffold(
        appBar: AppBar(title: Text(LmsStrings.title)),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        appBar: AppBar(title: Text(LmsStrings.title)),
        body: Center(child: Text('Error: $e')),
      ),
    );
  }
}
