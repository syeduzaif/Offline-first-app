import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:offline_first_app/core/constants/app_colors.dart';
import 'package:offline_first_app/core/constants/app_layout.dart';
import 'package:offline_first_app/core/constants/app_paddings.dart';
import 'package:offline_first_app/core/constants/app_text_styles.dart';
import 'package:offline_first_app/core/constants/strings/app_strings.dart';

class ErrorRetry extends StatelessWidget {
  const ErrorRetry({
    super.key,
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Iconsax.warning_2,
            size: AppLayout.iconSizeXl,
            color: AppColors.failedText,
          ),
          SizedBox(height: AppLayout.height12),
          Text(
            message,
            style: AppTextStyles.bodyMd
                .withColor(AppColors.grayMedium),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: AppLayout.height16),
          TextButton.icon(
            onPressed: onRetry,
            icon: const Icon(Iconsax.refresh),
            label: Padding(
              padding: AppPaddings.horizontalSmall,
              child: Text(CommonStrings.actionRetry),
            ),
          ),
        ],
      ),
    );
  }
}
