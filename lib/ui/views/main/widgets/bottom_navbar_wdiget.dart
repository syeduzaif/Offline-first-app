import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:iconsax/iconsax.dart';
import 'package:offline_first_app/core/constants/app_colors.dart';
import 'package:offline_first_app/core/constants/app_layout.dart';
import 'package:offline_first_app/core/constants/app_paddings.dart';
import 'package:offline_first_app/core/constants/app_text_styles.dart';
import 'package:offline_first_app/core/constants/strings/app_strings.dart';

class BottomNavBar extends StatelessWidget {
  const BottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onTabChange,
    required this.pendingSyncCount,
  });

  final int selectedIndex;
  final ValueChanged<int> onTabChange;
  final int pendingSyncCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: AppPaddings.base,
        vertical: AppPaddings.verticalMedium,
      ),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius:
            BorderRadius.circular(AppLayout.radiusXxl),
        boxShadow: AppLayout.shadowLg,
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: AppPaddings.mediumSmall,
          vertical: AppPaddings.verticalBase,
        ),
        child: GNav(
          selectedIndex: selectedIndex,
          onTabChange: onTabChange,
          gap: AppLayout.width8,
          activeColor: AppColors.white,
          tabBackgroundColor: AppColors.primary,
          padding: EdgeInsets.symmetric(
            horizontal: AppPaddings.base,
            vertical: AppPaddings.verticalBase,
          ),
          tabBorderRadius: AppLayout.radiusXxl,
          textStyle: AppTextStyles.labelMd.semiBold
              .withColor(AppColors.white),
          tabs: [
            const GButton(
              icon: Iconsax.box_1,
              text: CommonStrings.navProducts,
            ),
            GButton(
              icon: Iconsax.refresh_circle,
              text: CommonStrings.navSyncQueue,
              leading: pendingSyncCount > 0
                  ? Badge(
                      label: Text(
                        '$pendingSyncCount',
                        style: AppTextStyles.captionSm
                            .withColor(AppColors.white),
                      ),
                      child: Icon(
                        selectedIndex == 1
                            ? Iconsax.refresh_circle
                            : Iconsax.refresh_circle,
                        color: selectedIndex == 1
                            ? AppColors.white
                            : AppColors.grayMedium,
                      ),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
