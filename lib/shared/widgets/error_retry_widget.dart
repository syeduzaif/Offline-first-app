import 'package:flutter/material.dart';
import 'package:offline_first_app/core/constants/app_colors.dart';
import 'package:offline_first_app/core/constants/app_text_styles.dart';
import 'package:offline_first_app/core/constants/strings/common_strings.dart';

class ErrorRetry extends StatelessWidget {
  const ErrorRetry({super.key, required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, size: 48, color: AppColors.red),
          const SizedBox(height: 12),
          Text(message, style: AppTextStyles.bodyMd.withColor(AppColors.grayMedium)),
          const SizedBox(height: 16),
          TextButton(
            onPressed: onRetry,
            child: Text(CommonStrings.retry, style: AppTextStyles.labelMd.withColor(AppColors.primary)),
          ),
        ],
      ),
    );
  }
}
