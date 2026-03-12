import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:offline_first_app/core/constants/app_animations.dart';
import 'package:offline_first_app/core/constants/app_colors.dart';
import 'package:offline_first_app/core/constants/app_layout.dart';
import 'package:offline_first_app/core/constants/app_paddings.dart';
import 'package:offline_first_app/core/constants/app_text_styles.dart';
import 'package:offline_first_app/core/constants/strings/app_strings.dart';

class ConnectivityBanner extends StatelessWidget {
  const ConnectivityBanner({super.key, required this.isOnline});

  final bool isOnline;

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      duration: AppAnimations.durationBase,
      curve: AppAnimations.curveDefault,
      child: isOnline
          ? const SizedBox.shrink()
          : Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                horizontal: AppPaddings.base,
                vertical: AppPaddings.verticalBase,
              ),
              color: AppColors.offlineBannerBg,
              child: Row(
                children: [
                  Icon(
                    Iconsax.wifi_square,
                    size: AppLayout.iconSizeSm,
                    color: AppColors.offlineBannerText,
                  ),
                  SizedBox(width: AppLayout.width8),
                  Text(
                    CommonStrings.labelOffline,
                    style: AppTextStyles.labelMd.semiBold
                        .withColor(
                            AppColors.offlineBannerText),
                  ),
                ],
              ),
            ),
    );
  }
}
