import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';
import 'package:offline_first_app/core/constants/app_colors.dart';
import 'package:offline_first_app/core/constants/app_layout.dart';
import 'package:offline_first_app/core/constants/app_text_styles.dart';
import 'package:offline_first_app/core/providers/providers.dart';
import 'package:offline_first_app/features/home/presentation/home_providers.dart';

class HomeHeaderWidget extends ConsumerWidget {
  const HomeHeaderWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final greeting = ref.watch(currentGreetingProvider);
    final pendingCount = ref.watch(pendingSyncCountProvider);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primaryMild],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(AppLayout.radiusXxl),
          bottomRight: Radius.circular(AppLayout.radiusXxl),
        ),
      ),
      padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 24.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: AppLayout.avatarMd,
                backgroundColor: AppColors.white.withValues(alpha: 0.2),
                child: Icon(
                  Iconsax.user,
                  color: AppColors.white,
                  size: AppLayout.iconSizeMd,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      greeting,
                      style: AppTextStyles.labelSm.withColor(AppColors.white.withValues(alpha: 0.8)),
                    ),
                    Text(
                      'Teacher',
                      style: AppTextStyles.titleMd.withColor(AppColors.white),
                    ),
                  ],
                ),
              ),
              pendingCount.when(
                data: (count) => count > 0
                    ? Container(
                        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                        decoration: BoxDecoration(
                          color: AppColors.orange,
                          borderRadius: BorderRadius.circular(AppLayout.radiusFull),
                        ),
                        child: Text(
                          '$count pending',
                          style: AppTextStyles.captionMd.withColor(AppColors.white),
                        ),
                      )
                    : const SizedBox.shrink(),
                loading: () => const SizedBox.shrink(),
                error: (e, _) => const SizedBox.shrink(),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
