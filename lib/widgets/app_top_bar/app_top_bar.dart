import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ideal_mobile/widgets/styling/app_colors.dart';

/// The visual treatment used by an [AppTopBarAction].
enum AppTopBarActionStyle { neutral, brand, overlay }

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
              icon: Icon(icon, size: 20),
              iconSize: 20,
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

  static const double height = 64;
  static const double controlSize = 44;
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
    final overlayStyle = _TopBarColors.overlayStyle(context);
    final topInset = MediaQueryData.fromView(View.of(context)).padding.top;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: overlayStyle,
      child: Material(
        color: colors.surface,
        child: DecoratedBox(
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: colors.divider)),
          ),
          child: Column(
            children: [
              SizedBox(height: topInset),
              SizedBox(
                height: height,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Center(child: _title(context)),
                    Row(
                      children: [
                        if (showBackButton)
                          Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: _BackButton(onPressed: onBack),
                          )
                        else
                          const SizedBox(width: 60),
                        const Spacer(),
                        if (actions.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                for (final action in actions)
                                  Padding(
                                    padding: const EdgeInsets.only(left: 4),
                                    child: action,
                                  ),
                              ],
                            ),
                          )
                        else
                          const SizedBox(width: 8),
                      ],
                    ),
                  ],
                ),
              ),
              if (bottom != null)
                SizedBox(height: _bottomExtent, child: bottom),
            ],
          ),
        ),
      ),
    );
  }

  Widget _title(BuildContext context) {
    final titleStyle = Theme.of(context).textTheme.titleMedium?.copyWith(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      height: 1.2,
      color: _TopBarColors.of(context, AppTopBarActionStyle.neutral).foreground,
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

    final titleContent = contextualTitle == null
        ? titleText
        : Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                contextualTitle!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: titleStyle?.copyWith(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: titleStyle.color?.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: 2),
              titleText,
            ],
          );
    return Padding(
      padding: EdgeInsets.only(
        left: showBackButton ? 60 : 16,
        right: actions.isEmpty ? 16 : 60 + actions.length * 48,
      ),
      child: titleContent,
    );
  }
}

/// A pinned root bar that interpolates its centered title from 22px to 18px.
class AppSliverTopBar extends StatelessWidget {
  const AppSliverTopBar.root({
    super.key,
    required this.title,
    this.onBack,
    this.actions = const <AppTopBarAction>[],
    this.showBackButton = false,
  });

  static const double expandedHeight = 88;
  static const double collapsedHeight = 64;

  final String title;
  final VoidCallback? onBack;
  final List<AppTopBarAction> actions;
  final bool showBackButton;

  /// Returns the title size for a sliver extent between 64px and 88px.
  static double titleFontSizeForExtent(double extent) {
    final clampedExtent = extent.clamp(collapsedHeight, expandedHeight);
    final collapse =
        (expandedHeight - clampedExtent) / (expandedHeight - collapsedHeight);
    return lerpDouble(22, 18, collapse) ?? 18;
  }

  @override
  Widget build(BuildContext context) {
    final colors = _TopBarColors.of(context, AppTopBarActionStyle.neutral);
    final topInset = MediaQuery.paddingOf(context).top;
    return SliverAppBar(
      pinned: true,
      automaticallyImplyLeading: false,
      expandedHeight: expandedHeight,
      collapsedHeight: collapsedHeight,
      toolbarHeight: collapsedHeight,
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: colors.surface,
      surfaceTintColor: Colors.transparent,
      foregroundColor: colors.foreground,
      systemOverlayStyle: _TopBarColors.overlayStyle(context),
      shape: Border(bottom: BorderSide(color: colors.divider)),
      flexibleSpace: LayoutBuilder(
        builder: (context, constraints) {
          final extent = constraints.biggest.height - topInset;
          final titleStyle = Theme.of(context).textTheme.titleMedium?.copyWith(
            fontSize: titleFontSizeForExtent(extent),
            fontWeight: FontWeight.w600,
            height: 1.2,
            color: colors.foreground,
          );
          return Padding(
            padding: EdgeInsets.only(top: topInset),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Center(
                  child: Padding(
                    padding: EdgeInsets.only(
                      left: showBackButton ? 60 : 16,
                      right: actions.isEmpty ? 16 : 60 + actions.length * 48,
                    ),
                    child: Semantics(
                      header: true,
                      child: Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: titleStyle,
                      ),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: showBackButton
                      ? Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: _BackButton(onPressed: onBack),
                        )
                      : null,
                ),
                if (actions.isNotEmpty)
                  Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          for (final action in actions)
                            Padding(
                              padding: const EdgeInsets.only(left: 4),
                              child: action,
                            ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
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
          icon: const Icon(Icons.arrow_back_rounded, size: 20),
          iconSize: 20,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints.tightFor(
            width: AppTopBar.controlSize,
            height: AppTopBar.controlSize,
          ),
          style: IconButton.styleFrom(
            backgroundColor: colors.background,
            foregroundColor: colors.foreground,
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
        style: TextStyle(
          color: textColor,
          fontSize: 9,
          fontWeight: FontWeight.w700,
          height: 1,
        ),
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
    required this.divider,
  });

  final Color surface;
  final Color foreground;
  final Color background;
  final Color badge;
  final Color divider;

  factory _TopBarColors.of(BuildContext context, AppTopBarActionStyle style) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final foreground = isDark ? AppColors.neutral50 : AppColors.neutral900;
    final surface = isDark
        ? AppColors.bgSurfaceBase2dark
        : AppColors.bgSurfaceBase2;
    final divider = isDark ? AppColors.dark700 : AppColors.neutral100;

    return switch (style) {
      AppTopBarActionStyle.neutral => _TopBarColors(
        surface: surface,
        foreground: foreground,
        background: isDark ? AppColors.dark700 : AppColors.neutral50,
        badge: isDark ? AppColors.brand400 : AppColors.brand600,
        divider: divider,
      ),
      AppTopBarActionStyle.brand => _TopBarColors(
        surface: surface,
        foreground: foreground,
        background: Theme.of(context).colorScheme.primary,
        badge: isDark ? AppColors.brand200 : AppColors.brand800,
        divider: divider,
      ),
      AppTopBarActionStyle.overlay => _TopBarColors(
        surface: Colors.transparent,
        foreground: AppColors.white,
        background: Colors.white.withValues(alpha: 0.18),
        badge: AppColors.brand500,
        divider: Colors.transparent,
      ),
    };
  }

  static SystemUiOverlayStyle overlayStyle(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = isDark
        ? AppColors.bgSurfaceBase2dark
        : AppColors.bgSurfaceBase2;
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
