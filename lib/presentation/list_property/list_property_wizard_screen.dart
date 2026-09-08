import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:ideal_mobile/common/theme/text_style/app_text_styles.dart';
import 'package:ideal_mobile/core/services/injection_container.dart';
import 'package:ideal_mobile/presentation/list_property/bloc/list_property_wizard_bloc.dart';
import 'package:ideal_mobile/presentation/list_property/bloc/list_property_wizard_event.dart';
import 'package:ideal_mobile/presentation/list_property/bloc/list_property_wizard_state.dart';
import 'package:ideal_mobile/presentation/list_property/domain/usecases/get_property_upload_config.dart';
import 'package:ideal_mobile/presentation/list_property/domain/usecases/submit_property_upload.dart';
import 'package:ideal_mobile/presentation/list_property/widgets/list_property_onboarding_view.dart';
import 'package:ideal_mobile/presentation/list_property/widgets/steps/contact_step_view.dart';
import 'package:ideal_mobile/presentation/list_property/widgets/steps/details_step_view.dart';
import 'package:ideal_mobile/presentation/list_property/widgets/steps/location_step_view.dart';
import 'package:ideal_mobile/presentation/list_property/widgets/steps/photos_step_view.dart';
import 'package:ideal_mobile/presentation/list_property/widgets/steps/pricing_step_view.dart';
import 'package:ideal_mobile/presentation/list_property/widgets/steps/review_step_view.dart';
import 'package:ideal_mobile/presentation/list_property/widgets/steps/success_step_view.dart';
import 'package:ideal_mobile/presentation/list_property/widgets/wizard_step_header.dart';
import 'package:ideal_mobile/utils/extensions/build_context_ext.dart';
import 'package:ideal_mobile/utils/theme/extension/theme_extension.dart';
import 'package:ideal_mobile/widgets/app_button/app_button.dart';
import 'package:ideal_mobile/widgets/app_button/enums/app_button_size_enum.dart';
import 'package:ideal_mobile/widgets/app_button/enums/app_button_style_enum.dart';

@RoutePage()
class ListPropertyWizardScreen extends StatefulWidget {
  const ListPropertyWizardScreen({super.key});

  @override
  State<ListPropertyWizardScreen> createState() =>
      _ListPropertyWizardScreenState();
}

class _ListPropertyWizardScreenState extends State<ListPropertyWizardScreen> {
  bool _showOnboarding = true;

  @override
  Widget build(BuildContext context) {
    if (_showOnboarding) {
      return ListPropertyOnboardingView(
        onComplete: () {
          setState(() {
            _showOnboarding = false;
          });
        },
      );
    }

    return BlocProvider<ListPropertyWizardBloc>(
      create: (_) => ListPropertyWizardBloc(
        getConfig: sl<GetPropertyUploadConfig>(),
        submitProperty: sl<SubmitPropertyUpload>(),
      )..add(const ListPropertyWizardStarted()),
      child: const _ListPropertyWizardView(),
    );
  }
}

class _ListPropertyWizardView extends StatelessWidget {
  const _ListPropertyWizardView();

  static const _stepTitles = [
    'Property Details',
    'Location & Map',
    'Photos & Media',
    'Pricing & Terms',
    'Contact Information',
    'Review & Publish',
  ];

  static const _stepSubtitles = [
    'Step 1 of 6 — the basics renters search by.',
    'Step 2 of 6 — pin your property on the map.',
    'Step 3 of 6 — show the place at its best.',
    'Step 4 of 6 — set your rent, deposit and terms.',
    'Step 5 of 6 — contact info for inquiries.',
    'Step 6 of 6 — review and submit for verification.',
  ];

  @override
  Widget build(BuildContext context) {
    final theme = context.currentTheme;

    return BlocConsumer<ListPropertyWizardBloc, ListPropertyWizardState>(
      listenWhen: (prev, curr) =>
          prev.errorMessage != curr.errorMessage && curr.errorMessage != null,
      listener: (context, state) {
        if (state.errorMessage != null) {
          context.showSnackBar(state.errorMessage!, isDisplayingError: true);
        }
      },
      builder: (context, state) {
        final currentStep = state.currentStep;
        final isSuccess = currentStep == 6;

        return Scaffold(
          backgroundColor: theme.bgSurfaceBase,
          appBar: AppBar(
            backgroundColor: theme.bgSurfaceBase,
            elevation: 0,
            leading: isSuccess
                ? const SizedBox.shrink()
                : IconButton(
                    icon: Icon(
                      TablerIcons.chevron_left,
                      color: theme.textNeutralPrimary,
                    ),
                    onPressed: () {
                      if (currentStep > 0) {
                        context.read<ListPropertyWizardBloc>().add(
                          ListPropertyStepChanged(currentStep - 1),
                        );
                      } else {
                        context.router.maybePop();
                      }
                    },
                  ),
            title: Text(
              'List Your Property',
              style: AppTextStyles.h6SemiBold.copyWith(
                color: theme.textNeutralPrimary,
              ),
            ),
            centerTitle: true,
            actions: [
              if (!isSuccess)
                IconButton(
                  icon: Icon(TablerIcons.x, color: theme.textNeutralSecondary),
                  onPressed: () => context.router.maybePop(),
                ),
            ],
          ),
          bottomNavigationBar: isSuccess
              ? null
              : SafeArea(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: theme.bgSurfaceBase,
                      border: Border(
                        top: BorderSide(color: theme.strokeNeutralLight200),
                      ),
                    ),
                    child: Row(
                      children: [
                        if (currentStep > 0) ...[
                          Expanded(
                            child: AppButton(
                              label: 'Back',
                              size: AppButtonSize.large,
                              style: AppButtonStyle.outline,
                              shouldSetFullWidth: true,
                              onPressed: () =>
                                  context.read<ListPropertyWizardBloc>().add(
                                    ListPropertyStepChanged(currentStep - 1),
                                  ),
                            ),
                          ),
                          const SizedBox(width: 12),
                        ],
                        Expanded(
                          flex: currentStep > 0 ? 2 : 1,
                          child: AppButton(
                            label: currentStep == 5
                                ? 'Submit Listing'
                                : 'Continue',
                            size: AppButtonSize.large,
                            shouldSetFullWidth: true,
                            isLoading:
                                state.status == WizardStatus.submitting ||
                                state.status == WizardStatus.loadingConfig,
                            onPressed: () => context
                                .read<ListPropertyWizardBloc>()
                                .add(const ListPropertyStepAdvanceRequested()),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
          body: SafeArea(
            child: isSuccess
                ? const SuccessStepView()
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      WizardStepHeader(
                        currentStep: currentStep,
                        totalSteps: 6,
                        title: _stepTitles[currentStep],
                        subtitle: _stepSubtitles[currentStep],
                      ),
                      const Divider(height: 1),
                      Expanded(
                        child: switch (currentStep) {
                          0 => const DetailsStepView(),
                          1 => const LocationStepView(),
                          2 => const PhotosStepView(),
                          3 => const PricingStepView(),
                          4 => const ContactStepView(),
                          5 => const ReviewStepView(),
                          _ => const SizedBox.shrink(),
                        },
                      ),
                    ],
                  ),
          ),
        );
      },
    );
  }
}
