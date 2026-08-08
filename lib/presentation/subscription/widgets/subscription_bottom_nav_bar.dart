import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ideal_mobile/i18n/localization.dart';
import 'package:ideal_mobile/presentation/subscription/bloc/subscription_bloc.dart';
import 'package:ideal_mobile/presentation/subscription/bloc/subscription_event.dart';
import 'package:ideal_mobile/presentation/subscription/bloc/subscription_state.dart';
import 'package:ideal_mobile/presentation/subscription/model/subscription_package_model.dart';
import 'package:ideal_mobile/presentation/subscription/widgets/restore_subscription.dart';
import 'package:ideal_mobile/utils/theme/extension/theme_extension.dart';
import 'package:ideal_mobile/widgets/app_button/app_button.dart';
import 'package:ideal_mobile/widgets/app_button/enums/app_button_size_enum.dart';

class SubscriptionBottomNavBar extends StatelessWidget {
  const SubscriptionBottomNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    final selectedPackage = context
        .select<SubscriptionBloc, SubscriptionPackageModel?>((bloc) {
          final state = bloc.state;
          return state is FetchSubscriptionPlanLoadedState
              ? state.selectedPackage
              : null;
        });
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        mainAxisSize: .min,
        children: [
          AppButton(
            label: context.localization.continue_to_payment,
            shouldSetFullWidth: true,
            size: AppButtonSize.extraLarge,
            foregroundColor: context.currentTheme.textNeutralLight,
            onPressed: selectedPackage == null
                ? null
                : () => context.read<SubscriptionBloc>().add(
                    PurchaseSubscriptionEvent(package: selectedPackage),
                  ),
          ),
          const SizedBox(height: 8),
          const RestoreSubscription(),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
