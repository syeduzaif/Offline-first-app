import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:offline_first_app/core/constants/app_colors.dart';
import 'package:offline_first_app/core/constants/app_layout.dart';
import 'package:offline_first_app/core/constants/app_text_styles.dart';
import 'package:offline_first_app/core/constants/strings/app_strings.dart';
import 'package:offline_first_app/features/lms/presentation/lms_providers.dart';
import 'package:offline_first_app/features/lms/presentation/widgets/class_card_widget.dart';

class LmsPage extends ConsumerStatefulWidget {
  const LmsPage({super.key});

  @override
  ConsumerState<LmsPage> createState() => _LmsPageState();
}

class _LmsPageState extends ConsumerState<LmsPage> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final classesAsync = ref.watch(lmsClassesStreamProvider);

    return Scaffold(
      backgroundColor: AppColors.grayVeryLight,
      appBar: AppBar(
        title: Text(LmsStrings.title, style: AppTextStyles.titleMd),
        backgroundColor: AppColors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Search bar
          Container(
            color: AppColors.white,
            padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 16.h),
            child: TextField(
              onChanged: (v) => setState(() => _searchQuery = v.toLowerCase()),
              decoration: InputDecoration(
                hintText: LmsStrings.searchHint,
                hintStyle: AppTextStyles.bodyMd.withColor(AppColors.grayLight),
                prefixIcon: Icon(Icons.search, size: AppLayout.iconSizeMdSm, color: AppColors.grayLight),
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
            child: classesAsync.when(
              data: (classes) {
                final filtered = _searchQuery.isEmpty
                    ? classes
                    : classes
                        .where((c) =>
                            c.name.toLowerCase().contains(_searchQuery) ||
                            c.subject.toLowerCase().contains(_searchQuery) ||
                            c.grade.toLowerCase().contains(_searchQuery))
                        .toList();

                if (filtered.isEmpty) {
                  return Center(
                    child: Text(LmsStrings.noClasses,
                        style: AppTextStyles.bodyMd.withColor(AppColors.grayLight)),
                  );
                }
                return ListView.builder(
                  padding: EdgeInsets.all(16.w),
                  itemCount: filtered.length,
                  itemBuilder: (_, i) => LmsClassCardWidget(lmsClass: filtered[i]),
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
}
