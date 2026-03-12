import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:offline_first_app/core/constants/app_colors.dart';
import 'package:offline_first_app/core/constants/app_layout.dart';
import 'package:offline_first_app/core/constants/app_text_styles.dart';

class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.message,
    this.icon = Iconsax.box_1,
  });

  final String message;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: AppLayout.iconSizeXl,
            color: AppColors.grayLight,
          ),
          SizedBox(height: AppLayout.height12),
          Text(
            message,
            style: AppTextStyles.bodyMd
                .withColor(AppColors.grayMedium),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
