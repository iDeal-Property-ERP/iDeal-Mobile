import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ideal_mobile/common/theme/text_style/app_text_styles.dart';
import 'package:ideal_mobile/gen/assets.gen.dart';
import 'package:ideal_mobile/i18n/localization.dart';
import 'package:ideal_mobile/presentation/home/bloc/home_bloc.dart';
import 'package:ideal_mobile/utils/theme/extension/theme_extension.dart';

class EmptySearchView extends StatelessWidget {
  const EmptySearchView({super.key});

  @override
  Widget build(BuildContext context) {
    final searchQuery = context.select<HomeBloc, String>(
      (bloc) => bloc.state.searchQuery,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        mainAxisAlignment: .center,
        children: [
          SvgPicture.asset(Assets.icons.userNotFound, height: 150, width: 150),
          const SizedBox(height: 24),
          Text(
            context.localization.no_result_for(searchQuery),
            style: AppTextStyles.p1SemiBold.copyWith(
              color: context.currentTheme.textNeutralPrimary,
            ),
            textAlign: .center,
            maxLines: 2,
          ),
          const SizedBox(height: 8),
          Text(
            context.localization.no_search_result_message,
            style: AppTextStyles.p2Regular.copyWith(
              color: context.currentTheme.textNeutralSecondary,
            ),
            textAlign: .center,
          ),
        ],
      ),
    );
  }
}
