import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:ideal_mobile/common/theme/text_style/app_text_styles.dart';
import 'package:ideal_mobile/i18n/localization.dart';
import 'package:ideal_mobile/utils/theme/extension/theme_extension.dart';
import 'package:ideal_mobile/widgets/app_button/app_button.dart';
import 'package:ideal_mobile/widgets/app_button/enums/app_button_size_enum.dart';

class ListPropertyOnboardingView extends StatefulWidget {
  final VoidCallback onComplete;

  const ListPropertyOnboardingView({super.key, required this.onComplete});

  @override
  State<ListPropertyOnboardingView> createState() =>
      _ListPropertyOnboardingViewState();
}

class _ListPropertyOnboardingViewState
    extends State<ListPropertyOnboardingView> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < 2) {
      _pageController.animateToPage(
        _currentPage + 1,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      widget.onComplete();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.currentTheme;
    final loc = context.localization;

    final pages = [
      _OnboardingPageData(
        title: loc.listPropertyOnboardingTitle1,
        description: loc.listPropertyOnboardingDesc1,
        badge: loc.listPropertyOnboardingBadge1,
        icon: TablerIcons.shield_check,
      ),
      _OnboardingPageData(
        title: loc.listPropertyOnboardingTitle2,
        description: loc.listPropertyOnboardingDesc2,
        badge: loc.listPropertyOnboardingBadge2,
        icon: TablerIcons.chart_arrows_vertical,
      ),
      _OnboardingPageData(
        title: loc.listPropertyOnboardingTitle3,
        description: loc.listPropertyOnboardingDesc3,
        badge: loc.listPropertyOnboardingBadge3,
        icon: TablerIcons.percentage,
      ),
    ];

    return Scaffold(
      backgroundColor: theme.bgSurfaceBase,
      body: SafeArea(
        child: Column(
          children: [
            // Skip Button
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: widget.onComplete,
                style: TextButton.styleFrom(
                  foregroundColor: theme.textNeutralSecondary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                ),
                child: Text(
                  loc.listPropertyOnboardingSkip,
                  style: AppTextStyles.p2SemiBold,
                ),
              ),
            ),
            // Pages
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemCount: pages.length,
                itemBuilder: (context, index) {
                  return _OnboardingPageView(data: pages[index]);
                },
              ),
            ),
            // Bottom Area (Indicators & Button)
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Indicators
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(pages.length, (index) {
                      final isActive = index == _currentPage;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        height: 8,
                        width: isActive ? 24 : 8,
                        decoration: BoxDecoration(
                          color: isActive ? theme.bgBrandDefault : theme.strokeNeutralLight200,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 32),
                  // Button
                  AppButton(
                    label: loc.listPropertyOnboardingContinue,
                    shouldSetFullWidth: true,
                    size: AppButtonSize.large,
                    onPressed: _nextPage,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingPageData {
  final String title;
  final String description;
  final String badge;
  final IconData icon;

  _OnboardingPageData({
    required this.title,
    required this.description,
    required this.badge,
    required this.icon,
  });
}

class _OnboardingPageView extends StatelessWidget {
  final _OnboardingPageData data;

  const _OnboardingPageView({required this.data});

  @override
  Widget build(BuildContext context) {
    final theme = context.currentTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Illustration / Icon
          Expanded(
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      theme.bgBrandDefault.withOpacity(0.2),
                      theme.bgBrandDefault.withOpacity(0.05),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Icon(
                  data.icon,
                  size: 100,
                  color: theme.iconBrandPrimary,
                ),
              ),
            ),
          ),
          // Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: theme.bgBrandDefault.withOpacity(0.1),
              borderRadius: BorderRadius.circular(100),
            ),
            child: Text(
              data.badge.toUpperCase(),
              style: AppTextStyles.c1SemiBold.copyWith(
                color: theme.textBrandPrimary,
                letterSpacing: 0.5,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 24),
          // Title
          Text(
            data.title,
            style: AppTextStyles.h4SemiBold.copyWith(
              color: theme.textNeutralPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          // Description
          Text(
            data.description,
            style: AppTextStyles.p2Regular.copyWith(
              color: theme.textNeutralSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 48),
        ],
      ),
    );
  }
}
