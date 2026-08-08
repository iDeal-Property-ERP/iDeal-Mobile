import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_rating_bar_plus/flutter_rating_bar_plus.dart';
import 'package:ideal_mobile/common/theme/text_style/app_text_styles.dart';
import 'package:ideal_mobile/i18n/localization.dart';
import 'package:ideal_mobile/presentation/feedback/bloc/feedback_bloc.dart';
import 'package:ideal_mobile/presentation/feedback/bloc/feedback_event.dart';
import 'package:ideal_mobile/utils/theme/extension/theme_extension.dart';
import 'package:ideal_mobile/widgets/styling/app_colors.dart';

class FeedbackRatingSection extends StatelessWidget {
  const FeedbackRatingSection({super.key});

  @override
  Widget build(BuildContext context) {
    final double rating = context.select<FeedbackBloc, double>(
      (bloc) => bloc.state.rating,
    );
    final String? ratingError = context.select<FeedbackBloc, String?>(
      (bloc) => bloc.state.ratingError,
    );

    return Column(
      crossAxisAlignment: .start,
      children: [
        Text(
          context.localization.rate_your_experience,
          style: AppTextStyles.p2SemiBold.copyWith(
            color: context.currentTheme.textNeutralPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Center(
          child: RatingBar.builder(
            initialRating: rating,
            minRating: 1,
            glow: false,
            unratedColor: context.currentTheme.strokeNeutralLight200,
            itemBuilder: (_, _) =>
                const Icon(Icons.star_rounded, color: AppColors.yellow),
            onRatingUpdate: (newRating) {
              context.read<FeedbackBloc>().add(
                FeedbackRatingChangedEvent(rating: newRating),
              );
            },
          ),
        ),
        if (ratingError != null && ratingError.isNotEmpty) ...[
          const SizedBox(height: 6),
          Center(
            child: Text(
              ratingError,
              style: AppTextStyles.p4Regular.copyWith(
                color: context.currentTheme.strokeErrorDefault,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
