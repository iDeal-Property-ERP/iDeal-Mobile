import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ideal_mobile/widgets/app_top_bar/app_top_bar.dart';
import 'package:ideal_mobile/widgets/styling/app_colors.dart';
import 'package:ideal_mobile/widgets/styling/app_theme_data.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AppSliverTopBar', () {
    test('interpolates the root title from expanded to compact size', () {
      expect(AppSliverTopBar.titleFontSizeForExtent(88), 22);
      expect(AppSliverTopBar.titleFontSizeForExtent(76), 20);
      expect(AppSliverTopBar.titleFontSizeForExtent(64), 18);
      expect(AppSliverTopBar.titleFontSizeForExtent(120), 22);
      expect(AppSliverTopBar.titleFontSizeForExtent(0), 18);
    });

    testWidgets('is pinned and collapses from 88px to 64px', (tester) async {
      await tester.binding.setSurfaceSize(const Size(375, 800));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(
        _testApp(
          CustomScrollView(
            slivers: [
              const AppSliverTopBar.root(title: 'Discover'),
              SliverList.builder(
                itemBuilder: (_, index) =>
                    SizedBox(height: 120, child: Text('Item $index')),
                itemCount: 10,
              ),
            ],
          ),
        ),
      );

      final appBar = tester.widget<SliverAppBar>(find.byType(SliverAppBar));
      expect(appBar.pinned, isTrue);
      expect(appBar.expandedHeight, 88);
      expect(appBar.collapsedHeight, 64);
      expect(tester.widget<Text>(find.text('Discover')).style!.fontSize, 22);

      await tester.drag(find.byType(CustomScrollView), const Offset(0, -40));
      await tester.pumpAndSettle();
      expect(tester.widget<Text>(find.text('Discover')).style!.fontSize, 18);
      final renderSliver = tester.renderObject<RenderSliver>(
        find.byType(SliverAppBar),
      );
      expect(renderSliver.geometry!.paintExtent, 64);
    });

    testWidgets('reserves the status-bar inset without shrinking the content', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(375, 800);
      tester.view.devicePixelRatio = 1;
      tester.view.padding = const FakeViewPadding(top: 24);
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        _testApp(
          CustomScrollView(
            slivers: [
              const AppSliverTopBar.root(
                title: 'Discover',
                actions: [
                  AppTopBarAction(
                    icon: Icons.refresh,
                    tooltip: 'Refresh',
                    onPressed: _noop,
                  ),
                ],
              ),
              SliverList.builder(
                itemBuilder: (_, index) =>
                    SizedBox(height: 120, child: Text('Item $index')),
                itemCount: 10,
              ),
            ],
          ),
        ),
      );

      final action = find.byTooltip('Refresh');
      expect(tester.getTopLeft(action).dy, greaterThanOrEqualTo(24));
      expect(tester.getBottomRight(action).dy, lessThanOrEqualTo(24 + 88));
      expect(tester.getTopLeft(find.text('Discover')).dy, greaterThan(24));

      await tester.drag(find.byType(CustomScrollView), const Offset(0, -40));
      await tester.pumpAndSettle();
      expect(tester.widget<Text>(find.text('Discover')).style!.fontSize, 18);
      expect(tester.getTopLeft(action).dy, greaterThanOrEqualTo(24));
    });
  });

  group('AppTopBar.page', () {
    testWidgets('uses a fixed 64px row and supports bottom content', (
      tester,
    ) async {
      const bottom = PreferredSize(
        preferredSize: Size.fromHeight(24),
        child: SizedBox(height: 24, child: Text('Context controls')),
      );
      const bar = AppTopBar.page(
        title: 'Details',
        contextualTitle: 'Apartment',
        bottom: bottom,
      );

      expect(bar.preferredSize, const Size.fromHeight(88));
      await tester.pumpWidget(_testApp(const Scaffold(appBar: bar)));
      expect(find.text('Apartment'), findsOneWidget);
      expect(find.text('Details'), findsOneWidget);
      expect(find.text('Context controls'), findsOneWidget);
      expect(find.byIcon(Icons.arrow_back_rounded), findsOneWidget);
    });

    testWidgets('back button pops the current route', (tester) async {
      await tester.pumpWidget(
        _testApp(
          Builder(
            builder: (context) => Center(
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).push<void>(
                  MaterialPageRoute<void>(
                    builder: (_) => const Scaffold(
                      appBar: AppTopBar.page(title: 'Details'),
                      body: Text('Pushed page'),
                    ),
                  ),
                ),
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      expect(find.text('Pushed page'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.arrow_back_rounded));
      await tester.pumpAndSettle();
      expect(find.text('Open'), findsOneWidget);
      expect(find.text('Pushed page'), findsNothing);
    });

    testWidgets('action callbacks, badges, tooltips, and enabled state work', (
      tester,
    ) async {
      var callbackCount = 0;
      await tester.pumpWidget(
        _testApp(
          Scaffold(
            appBar: AppTopBar.page(
              title: 'Actions',
              actions: [
                AppTopBarAction(
                  icon: Icons.notifications_none,
                  tooltip: 'Notifications',
                  badge: '3',
                  onPressed: () => callbackCount++,
                  style: AppTopBarActionStyle.brand,
                ),
                const AppTopBarAction(
                  icon: Icons.bookmark_border,
                  tooltip: 'Disabled saved homes',
                  enabled: false,
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.text('3'), findsOneWidget);
      expect(find.byTooltip('Notifications'), findsOneWidget);
      expect(find.byTooltip('Disabled saved homes'), findsOneWidget);
      await tester.tap(find.byTooltip('Notifications'));
      expect(callbackCount, 1);
      await tester.tap(find.byTooltip('Disabled saved homes'));
      expect(callbackCount, 1);
    });

    testWidgets('styles expose distinct appearance and accessible states', (
      tester,
    ) async {
      var neutralTaps = 0;
      var brandTaps = 0;
      var overlayTaps = 0;
      await tester.pumpWidget(
        _testApp(
          Scaffold(
            appBar: AppTopBar.page(
              title: 'Styles',
              actions: [
                AppTopBarAction(
                  key: const ValueKey('neutral-action'),
                  icon: Icons.home_outlined,
                  tooltip: 'Neutral action',
                  onPressed: () => neutralTaps++,
                ),
                AppTopBarAction(
                  key: const ValueKey('brand-action'),
                  icon: Icons.star_outline,
                  tooltip: 'Brand action',
                  onPressed: () => brandTaps++,
                  style: AppTopBarActionStyle.brand,
                ),
                AppTopBarAction(
                  key: const ValueKey('overlay-action'),
                  icon: Icons.image_outlined,
                  tooltip: 'Overlay action',
                  onPressed: () => overlayTaps++,
                  style: AppTopBarActionStyle.overlay,
                ),
                const AppTopBarAction(
                  key: ValueKey('disabled-action'),
                  icon: Icons.lock_outline,
                  tooltip: 'Disabled action',
                  enabled: false,
                ),
              ],
            ),
          ),
        ),
      );

      ButtonStyle styleFor(String tooltip) => tester
          .widget<IconButton>(
            find.descendant(
              of: find.byTooltip(tooltip),
              matching: find.byType(IconButton),
            ),
          )
          .style!;

      expect(
        styleFor('Neutral action').backgroundColor!.resolve(const {}),
        AppColors.neutral50,
      );
      expect(
        styleFor('Brand action').backgroundColor!.resolve(const {}),
        AppThemesData.themeData[AppThemeEnum.LightTheme]!.colorScheme.primary,
      );
      expect(
        styleFor('Overlay action').backgroundColor!.resolve(const {}),
        Colors.white.withValues(alpha: 0.18),
      );
      expect(
        styleFor(
          'Disabled action',
        ).foregroundColor!.resolve({WidgetState.disabled}),
        AppColors.neutral900.withValues(alpha: 0.4),
      );

      final neutralSemantics = tester.getSemantics(
        find.bySemanticsLabel('Neutral action'),
      );
      expect(neutralSemantics.label, 'Neutral action');
      expect(neutralSemantics.hasFlag(SemanticsFlag.isButton), isTrue);
      expect(neutralSemantics.hasFlag(SemanticsFlag.hasEnabledState), isTrue);
      expect(neutralSemantics.hasFlag(SemanticsFlag.isEnabled), isTrue);

      final disabledSemantics = tester.getSemantics(
        find.bySemanticsLabel('Disabled action'),
      );
      expect(disabledSemantics.label, 'Disabled action');
      expect(disabledSemantics.hasFlag(SemanticsFlag.isButton), isTrue);
      expect(disabledSemantics.hasFlag(SemanticsFlag.hasEnabledState), isTrue);
      expect(disabledSemantics.hasFlag(SemanticsFlag.isEnabled), isFalse);

      await tester.tap(find.byTooltip('Neutral action'));
      await tester.tap(find.byTooltip('Brand action'));
      await tester.tap(find.byTooltip('Overlay action'));
      await tester.tap(find.byTooltip('Disabled action'));
      expect(neutralTaps, 1);
      expect(brandTaps, 1);
      expect(overlayTaps, 1);
    });

    testWidgets('long titles remain bounded at narrow widths and 200% scale', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(320, 700));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(
        _testApp(
          const MediaQuery(
            data: MediaQueryData(textScaler: TextScaler.linear(2)),
            child: Scaffold(
              appBar: AppTopBar.page(
                title:
                    'A very long title that must stay on one line '
                    'without overflow',
                actions: [
                  AppTopBarAction(
                    icon: Icons.more_horiz,
                    tooltip: 'More options',
                    onPressed: _noop,
                  ),
                ],
              ),
            ),
          ),
        ),
      );
      expect(tester.takeException(), isNull);
      final title = tester.widget<Text>(find.byType(Text).first);
      expect(title.maxLines, 1);
      expect(title.overflow, TextOverflow.ellipsis);
    });

    testWidgets('page content remains below a nonzero status-bar inset', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(375, 800);
      tester.view.devicePixelRatio = 1;
      tester.view.padding = const FakeViewPadding(top: 24);
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        _testApp(const Scaffold(appBar: AppTopBar.page(title: 'Details'))),
      );

      expect(tester.getSize(find.byType(AppTopBar)).height, 24 + 64);
      expect(
        tester.getTopLeft(find.byIcon(Icons.arrow_back_rounded)).dy,
        greaterThanOrEqualTo(24),
      );
      expect(tester.getBottomRight(find.byType(IconButton)).dy, 24 + 54);
    });
  });

  group('theme fallback and status bar', () {
    testWidgets(
      'light and dark themes use surface2 and matching overlay style',
      (tester) async {
        await tester.pumpWidget(
          _testApp(const Scaffold(appBar: AppTopBar.page(title: 'Theme'))),
        );
        final lightRegion = tester
            .widget<AnnotatedRegion<SystemUiOverlayStyle>>(
              find.descendant(
                of: find.byType(AppTopBar),
                matching: find.byType(AnnotatedRegion<SystemUiOverlayStyle>),
              ),
            );
        expect(lightRegion.value.statusBarIconBrightness, Brightness.dark);
        expect(
          AppThemesData
              .themeData[AppThemeEnum.LightTheme]!
              .appBarTheme
              .backgroundColor,
          AppColors.bgSurfaceBase2,
        );

        await tester.pumpWidget(
          _testApp(
            const Scaffold(appBar: AppTopBar.page(title: 'Theme')),
            theme: AppThemeEnum.DarkTheme,
          ),
        );
        await tester.pumpAndSettle();
        final darkRegion = tester.widget<AnnotatedRegion<SystemUiOverlayStyle>>(
          find.descendant(
            of: find.byType(AppTopBar),
            matching: find.byType(AnnotatedRegion<SystemUiOverlayStyle>),
          ),
        );
        expect(darkRegion.value.statusBarIconBrightness, Brightness.light);
        expect(
          AppThemesData
              .themeData[AppThemeEnum.DarkTheme]!
              .appBarTheme
              .backgroundColor,
          AppColors.bgSurfaceBase2dark,
        );
      },
    );
  });
}

Widget _testApp(Widget child, {AppThemeEnum theme = AppThemeEnum.LightTheme}) {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: AppThemesData.themeData[theme],
    home: child,
  );
}

void _noop() {}
