import 'package:flutter/material.dart';
import 'package:ideal_mobile/common/theme/text_style/app_text_styles.dart';
import 'package:ideal_mobile/utils/theme/extension/theme_extension.dart';

class DateSeparatorText extends StatelessWidget {
  const DateSeparatorText({super.key, required this.date});

  final String date;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      alignment: Alignment.center,
      child: Text(
        date,
        style: AppTextStyles.p4Regular.copyWith(
          color: context.currentTheme.textNeutralSecondary,
        ),
      ),
    );
  }
}
