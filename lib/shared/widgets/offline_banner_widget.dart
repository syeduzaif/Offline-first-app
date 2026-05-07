import 'package:flutter/material.dart';
import 'package:flutter_offline/flutter_offline.dart';
import 'package:offline_first_app/core/constants/app_colors.dart';
import 'package:offline_first_app/core/constants/app_text_styles.dart';
import 'package:offline_first_app/core/constants/strings/common_strings.dart';

class OfflineBannerWrapper extends StatelessWidget {
  const OfflineBannerWrapper({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return OfflineBuilder(
      connectivityBuilder: (context, connectivity, child) {
        final isOffline = connectivity.every((r) => r.name == 'none');
        return Column(
          children: [
            if (isOffline)
              Container(
                width: double.infinity,
                color: AppColors.orangeDark,
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Text(
                  CommonStrings.offline,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.labelSm.withColor(AppColors.white),
                ),
              ),
            Expanded(child: child),
          ],
        );
      },
      child: child,
    );
  }
}
