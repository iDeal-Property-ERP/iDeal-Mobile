import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:ideal_mobile/common/theme/text_style/app_text_styles.dart';
import 'package:ideal_mobile/i18n/localization.dart';
import 'package:ideal_mobile/utils/theme/extension/theme_extension.dart';

class EmptyBookingsView extends StatelessWidget {
  const EmptyBookingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 96,
              width: 96,
              decoration: BoxDecoration(
                color: context.currentTheme.bgNeutralLight100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                TablerIcons.calendar_off,
                size: 44,
                color: context.currentTheme.iconNeutralDefault,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              context.localization.no_bookings_yet,
              style: AppTextStyles.p1SemiBold.copyWith(
                color: context.currentTheme.textNeutralPrimary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
