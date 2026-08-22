import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:ideal_mobile/common/theme/text_style/app_text_styles.dart';
import 'package:ideal_mobile/widgets/styling/app_colors.dart';

/// The visual treatment used by an [AppTopBarAction].
enum AppTopBarActionStyle { neutral, brand, overlay, surface }

/// A compact, accessible action for an iDeal top bar.
class AppTopBarAction extends StatelessWidget {
  const AppTopBarAction({
    super.key,
    required this.icon,
    required this.tooltip,
    this.onPressed,
    this.badge,
    this.enabled = true,
    this.style = AppTopBarActionStyle.neutral,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;
  final String? badge;
  final bool enabled;
  final AppTopBarActionStyle style;

  @override
  Widget build(BuildContext context) {
    final colors = _TopBarColors.of(context, style);
    final isEnabled = enabled && onPressed != null;
    final iconSize = style == AppTopBarActionStyle.overlay
        ? 20.0
        : AppTopBar.iconSize;

    return Tooltip(
      message: tooltip,
      child: Semantics(
        button: true,
        enabled: isEnabled,
        label: tooltip,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            IconButton(
              onPressed: isEnabled ? onPressed : null,
              icon: Icon(icon, size: iconSize),
              iconSize: iconSize,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints.tightFor(
                width: AppTopBar.controlSize,
                height: AppTopBar.controlSize,
              ),
              style: IconButton.styleFrom(
                backgroundColor: colors.background,
                foregroundColor: colors.foreground,
                disabledBackgroundColor: colors.background,
                disabledForegroundColor: colors.foreground.withValues(
                  alpha: 0.4,
                ),
                overlayColor: colors.foreground.withValues(alpha: 0.08),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppTopBar.controlRadius),
                ),
              ),
            ),
            if (badge case final badge? when badge.isNotEmpty)
              Positioned(
                top: -4,
                right: -3,
                child: _TopBarBadge(label: badge, color: colors.badge),
              ),
          ],
        ),
      ),
    );
  }
}

/// The standard pushed-page top bar.
class AppTopBar extends StatelessWidget implements PreferredSizeWidget {
  const AppTopBar.page({
    super.key,
    required this.title,
    this.onBack,
    this.actions = const <AppTopBarAction>[],
    this.contextualTitle,
    this.bottom,
    this.bottomHeight,
    this.showBackButton = true,
  });

  static const double height = 56;
  static const double controlSize = 44;
  static const double iconSize = 22;
  static const double controlRadius = 14;

  final String title;
  final VoidCallback? onBack;
  final List<AppTopBarAction> actions;
  final String? contextualTitle;
  final Widget? bottom;
  final double? bottomHeight;
  final bool showBackButton;

  double get _bottomExtent {
    if (bottom == null) return 0;
    if (bottomHeight != null) return bottomHeight!;
    return bottom is PreferredSizeWidget
        ? (bottom! as PreferredSizeWidget).preferredSize.height
        : 32;
  }

  @override
  Size get preferredSize => Size.fromHeight(height + _bottomExtent);

  @override
  Widget build(BuildContext context) {
    final colors = _TopBarColors.of(context, AppTopBarActionStyle.neutral);
    final topInset = MediaQueryData.fromView(View.of(context)).padding.top;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: _TopBarColors.overlayStyle(context),
      child: Material(
        color: colors.surface,
        child: Column(
          children: [
            SizedBox(height: topInset),
            _TopBarContent(
              title: title,
              contextualTitle: contextualTitle,
              onBack: onBack,
              actions: actions,
              showBackButton: showBackButton,
            ),
            if (bottom != null) SizedBox(height: _bottomExtent, child: bottom),
          ],
        ),
      ),
    );
  }
}

/// A fixed, pinned root bar that does not react visually to scrolling.
class AppSliverTopBar extends StatelessWidget {
  const AppSliverTopBar.root({
    super.key,
    required this.title,
    this.leading,
    this.onBack,
    this.actions = const <AppTopBarAction>[],
    this.bottom,
    this.bottomHeight,
    this.showBackButton = false,
  });

  static const double height = AppTopBar.height;

  final String title;
  final Widget? leading;
  final VoidCallback? onBack;
  final List<AppTopBarAction> actions;
  final Widget? bottom;
  final double? bottomHeight;
  final bool showBackButton;

  double get _bottomExtent {
    if (bottom == null) return 0;
    if (bottomHeight != null) return bottomHeight!;
    return bottom is PreferredSizeWidget
        ? (bottom! as PreferredSizeWidget).preferredSize.height
        : 48;
  }

  @override
  Widget build(BuildContext context) {
    final colors = _TopBarColors.of(context, AppTopBarActionStyle.neutral);
    final topInset = MediaQuery.paddingOf(context).top;
    final extent = height + topInset + _bottomExtent;

    return SliverAppBar(
      primary: false,
      pinned: true,
      automaticallyImplyLeading: false,
      expandedHeight: extent,
      collapsedHeight: extent,
      toolbarHeight: extent,
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: colors.surface,
      surfaceTintColor: Colors.transparent,
      foregroundColor: colors.foreground,
      systemOverlayStyle: _TopBarColors.overlayStyle(context),
      flexibleSpace: Padding(
        padding: EdgeInsets.only(top: topInset),
        child: Column(
          children: [
            _TopBarContent(
              title: title,
              leading: leading,
              onBack: onBack,
              actions: actions,
              showBackButton: showBackButton,
            ),
            if (bottom != null) SizedBox(height: _bottomExtent, child: bottom),
          ],
        ),
      ),
    );
  }
}

class _TopBarContent extends StatelessWidget {
  const _TopBarContent({
    required this.title,
    required this.actions,
    required this.showBackButton,
    this.leading,
    this.contextualTitle,
    this.onBack,
  });

  final String title;
  final Widget? leading;
  final String? contextualTitle;
  final VoidCallback? onBack;
  final List<AppTopBarAction> actions;
  final bool showBackButton;

  @override
  Widget build(BuildContext context) {
    final hasLeading = leading != null || showBackButton;
    final leadingInset = hasLeading ? 60.0 : 16.0;
    final actionsInset = actions.isEmpty
        ? 16.0
        : 16.0 +
              actions.length * AppTopBar.controlSize +
              (actions.length - 1) * 4;
    final titleInset = leadingInset > actionsInset
        ? leadingInset
        : actionsInset;

    return SizedBox(
      height: AppTopBar.height,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: titleInset),
              child: _TopBarTitle(
                title: title,
                contextualTitle: contextualTitle,
              ),
            ),
          ),
          if (hasLeading)
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 8),
                child: leading == null
                    ? _BackButton(onPressed: onBack)
                    : SizedBox.square(
                        dimension: AppTopBar.controlSize,
                        child: Center(child: leading),
                      ),
              ),
            ),
          if (actions.isNotEmpty)
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (var index = 0; index < actions.length; index++) ...[
                      if (index > 0) const SizedBox(width: 4),
                      actions[index],
                    ],
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _TopBarTitle extends StatelessWidget {
  const _TopBarTitle({required this.title, this.contextualTitle});

  final String title;
  final String? contextualTitle;

  @override
  Widget build(BuildContext context) {
    final foreground = _TopBarColors.of(
      context,
      AppTopBarActionStyle.neutral,
    ).foreground;
    final titleStyle = AppTextStyles.p1SemiBold.copyWith(
      height: 1.2,
      color: foreground,
    );
    final titleText = Semantics(
      header: true,
      child: Text(
        title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.center,
        style: titleStyle,
      ),
    );

    if (contextualTitle == null) return titleText;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          contextualTitle!,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.p4Medium.copyWith(
            height: 1.2,
            color: foreground.withValues(alpha: 0.7),
          ),
        ),
        const SizedBox(height: 2),
        titleText,
      ],
    );
  }
}

class _BackButton extends StatelessWidget {
  const _BackButton({this.onPressed});

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = _TopBarColors.of(context, AppTopBarActionStyle.neutral);
    final tooltip = MaterialLocalizations.of(context).backButtonTooltip;
    return Tooltip(
      message: tooltip,
      child: Semantics(
        button: true,
        label: tooltip,
        child: IconButton(
          onPressed: onPressed ?? () => Navigator.of(context).maybePop(),
          icon: const Icon(TablerIcons.arrow_left, size: AppTopBar.iconSize),
          iconSize: AppTopBar.iconSize,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints.tightFor(
            width: AppTopBar.controlSize,
            height: AppTopBar.controlSize,
          ),
          style: IconButton.styleFrom(
            backgroundColor: Colors.transparent,
            foregroundColor: colors.foreground,
            overlayColor: colors.foreground.withValues(alpha: 0.08),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppTopBar.controlRadius),
            ),
          ),
        ),
      ),
    );
  }
}

class _TopBarBadge extends StatelessWidget {
  const _TopBarBadge({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final textColor = Theme.of(context).brightness == Brightness.dark
        ? AppColors.neutral900
        : AppColors.white;
    return Container(
      constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
      padding: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      alignment: Alignment.center,
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          color: AppColors.white,
          fontSize: 9,
          fontWeight: FontWeight.w700,
          height: 1,
        ).copyWith(color: textColor),
      ),
    );
  }
}

class _TopBarColors {
  const _TopBarColors({
    required this.surface,
    required this.foreground,
    required this.background,
    required this.badge,
  });

  final Color surface;
  final Color foreground;
  final Color background;
  final Color badge;

  factory _TopBarColors.of(BuildContext context, AppTopBarActionStyle style) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final foreground = isDark ? AppColors.neutral50 : AppColors.neutral900;
    final surface = isDark
        ? AppColors.bgSurfaceBaseDark
        : AppColors.bgSurfaceBase;

    return switch (style) {
      AppTopBarActionStyle.neutral => _TopBarColors(
        surface: surface,
        foreground: foreground,
        background: Colors.transparent,
        badge: isDark ? AppColors.brand400 : AppColors.brand600,
      ),
      AppTopBarActionStyle.brand => _TopBarColors(
        surface: surface,
        foreground: AppColors.white,
        background: Theme.of(context).colorScheme.primary,
        badge: isDark ? AppColors.brand200 : AppColors.brand800,
      ),
      AppTopBarActionStyle.overlay => _TopBarColors(
        surface: Colors.transparent,
        foreground: AppColors.white,
        background: Colors.white.withValues(alpha: 0.18),
        badge: AppColors.brand500,
      ),
      AppTopBarActionStyle.surface => _TopBarColors(
        surface: surface,
        foreground: foreground,
        background: isDark
            ? AppColors.bgSurfaceBase2dark
            : AppColors.bgSurfaceBase2,
        badge: isDark ? AppColors.brand400 : AppColors.brand600,
      ),
    };
  }

  static SystemUiOverlayStyle overlayStyle(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = isDark
        ? AppColors.bgSurfaceBaseDark
        : AppColors.bgSurfaceBase;
    return SystemUiOverlayStyle(
      statusBarColor: surface,
      statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
      statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
      systemNavigationBarColor: surface,
      systemNavigationBarIconBrightness: isDark
          ? Brightness.light
          : Brightness.dark,
    );
  }
}
