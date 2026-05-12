import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';

class NoApiKeyBanner extends StatelessWidget {
  const NoApiKeyBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppColors.warning.withValues(alpha: 0.15),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          const Icon(Icons.warning_amber, color: AppColors.warning),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'coach.apiKeyRequired'.tr(),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          TextButton(
            onPressed: () => context.push(AppRoutes.settings),
            child: Text('coach.openSettings'.tr()),
          ),
        ],
      ),
    );
  }
}
