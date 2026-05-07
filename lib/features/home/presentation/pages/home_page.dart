import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:offline_first_app/core/constants/app_colors.dart';
import 'package:offline_first_app/core/constants/app_text_styles.dart';
import 'package:offline_first_app/core/constants/strings/app_strings.dart';
import 'package:offline_first_app/features/home/presentation/widgets/class_card_widget.dart';
import 'package:offline_first_app/features/home/presentation/widgets/home_header_widget.dart';
import 'package:offline_first_app/features/home/presentation/widgets/quick_actions_widget.dart';
import 'package:offline_first_app/features/home/presentation/widgets/task_card_widget.dart';
import 'package:offline_first_app/features/lms/presentation/lms_providers.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final classesAsync = ref.watch(lmsClassesStreamProvider);
    final allClassworkAsync = ref.watch(lmsClassworkForClassProvider(1));

    return Scaffold(
      backgroundColor: AppColors.grayVeryLight,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            const SliverToBoxAdapter(child: HomeHeaderWidget()),
            SliverToBoxAdapter(child: SizedBox(height: 20.h)),

            // Quick Actions
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Text(HomeStrings.quickActions, style: AppTextStyles.titleSm),
              ),
            ),
            SliverToBoxAdapter(child: SizedBox(height: 12.h)),
            const SliverToBoxAdapter(child: QuickActionsWidget()),
            SliverToBoxAdapter(child: SizedBox(height: 24.h)),

            // Pending Tasks
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Text(HomeStrings.pendingTasks, style: AppTextStyles.titleSm),
              ),
            ),
            SliverToBoxAdapter(child: SizedBox(height: 12.h)),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: allClassworkAsync.when(
                  data: (items) {
                    final pending =
                        items.where((i) => i.status == 'pending').toList();
                    if (pending.isEmpty) {
                      return _EmptyState(label: HomeStrings.noPendingTasks);
                    }
                    return Column(
                      children: pending
                          .take(4)
                          .map((item) => TaskCardWidget(item: item))
                          .toList(),
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, _) =>
                      _EmptyState(label: HomeStrings.noPendingTasks),
                ),
              ),
            ),
            SliverToBoxAdapter(child: SizedBox(height: 24.h)),

            // Recent Classes
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Text(HomeStrings.recentClasses, style: AppTextStyles.titleSm),
              ),
            ),
            SliverToBoxAdapter(child: SizedBox(height: 12.h)),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: classesAsync.when(
                  data: (classes) {
                    if (classes.isEmpty) {
                      return _EmptyState(label: HomeStrings.noRecentClasses);
                    }
                    return Column(
                      children: classes
                          .take(3)
                          .map((c) => HomeClassCardWidget(lmsClass: c))
                          .toList(),
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, _) =>
                      _EmptyState(label: HomeStrings.noRecentClasses),
                ),
              ),
            ),
            SliverToBoxAdapter(child: SizedBox(height: 32.h)),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 16.h),
        child: Text(
          label,
          style: AppTextStyles.bodyMd.withColor(AppColors.grayLight),
        ),
      ),
    );
  }
}
