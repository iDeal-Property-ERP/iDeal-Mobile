import 'package:auto_route/annotations.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:ideal_mobile/common/theme/text_style/app_text_styles.dart';
import 'package:ideal_mobile/gen/assets.gen.dart';
import 'package:ideal_mobile/i18n/localization.dart';
import 'package:ideal_mobile/presentation/under_maintainace/widgets/app_under_maintainace_app_bar.dart';
import 'package:ideal_mobile/utils/theme/extension/theme_extension.dart';

@RoutePage()
class UnderMaintenanceScreen extends StatelessWidget {
  const UnderMaintenanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppUnderMaintainaceAppBar(),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          mainAxisAlignment: .center,
          children: [
            Transform.scale(
              scale: 1.4,
              child: Lottie.asset(
                Assets.animations.appUnderMaintenance,
                width: 160,
                height: 160,
                repeat: false,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              context.localization.under_maintenance,
              style: AppTextStyles.p1SemiBold.copyWith(
                color: context.currentTheme.textNeutralPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              context.localization.under_maintenance_message,
              style: AppTextStyles.p3Regular.copyWith(
                color: context.currentTheme.textNeutralSecondary,
              ),
              textAlign: .center,
            ),
          ],
        ),
      ),
    );
  }
}
