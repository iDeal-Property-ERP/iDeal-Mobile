import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:ideal_mobile/common/theme/text_style/app_text_styles.dart';
import 'package:ideal_mobile/core/services/injection_container.dart';
import 'package:ideal_mobile/i18n/localization.dart';
import 'package:ideal_mobile/services/recent_searches_service.dart';
import 'package:ideal_mobile/utils/theme/extension/theme_extension.dart';
import 'package:ideal_mobile/widgets/app_button/app_button.dart';
import 'package:ideal_mobile/widgets/app_button/enums/app_button_size_enum.dart';
import 'package:ideal_mobile/widgets/styling/app_radius.dart';

Future<String?> showHomeSearchSheet(
  BuildContext context, {
  String? currentQuery,
}) {
  return showModalBottomSheet<String?>(
    context: context,
    isScrollControlled: true,
    backgroundColor: context.currentTheme.bgSurfaceSheet,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(AppRadius.sheet),
      ),
    ),
    clipBehavior: Clip.antiAlias,
    builder: (sheetContext) => Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
      ),
      child: HomeSearchSheet(
        initialQuery: currentQuery,
        onSearchSubmitted: (query) => Navigator.of(sheetContext).pop(query),
      ),
    ),
  );
}

class HomeSearchSheet extends StatefulWidget {
  const HomeSearchSheet({
    super.key,
    this.initialQuery,
    required this.onSearchSubmitted,
  });

  final String? initialQuery;
  final ValueChanged<String> onSearchSubmitted;

  @override
  State<HomeSearchSheet> createState() => _HomeSearchSheetState();
}

class _HomeSearchSheetState extends State<HomeSearchSheet> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;
  final RecentSearchesService _recentSearchesService =
      sl.isRegistered<RecentSearchesService>()
      ? sl<RecentSearchesService>()
      : RecentSearchesService();

  List<String> _recentSearches = [];

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialQuery ?? '');
    _focusNode = FocusNode();
    _loadRecentSearches();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _loadRecentSearches() async {
    final recents = await _recentSearchesService.getRecentSearches();
    if (mounted) {
      setState(() {
        _recentSearches = recents;
      });
    }
  }

  void _submit(String value) {
    final trimmed = value.trim();
    if (trimmed.isNotEmpty) {
      _recentSearchesService.saveSearch(trimmed);
    }
    widget.onSearchSubmitted(trimmed);
  }

  @override
  Widget build(BuildContext context) {
    final examples = _recentSearches.isNotEmpty
        ? _recentSearches
        : ['Yunusobod', 'Near a park'];

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: context.currentTheme.strokeNeutralLight200,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  context.localization.home_search_sheet_title,
                  style: AppTextStyles.h2Bold.copyWith(
                    color: context.currentTheme.textNeutralPrimary,
                  ),
                ),
                IconButton(
                  icon: const Icon(TablerIcons.x),
                  color: context.currentTheme.iconNeutralDefault,
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              context.localization.home_search_sheet_field_label,
              style: AppTextStyles.p3Medium.copyWith(
                color: context.currentTheme.textNeutralSecondary,
              ),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _controller,
              focusNode: _focusNode,
              textInputAction: TextInputAction.search,
              onSubmitted: _submit,
              decoration: InputDecoration(
                hintText: context.localization.home_search_sheet_placeholder,
                hintStyle: AppTextStyles.p2Regular.copyWith(
                  color: context.currentTheme.textNeutralSecondary,
                ),
                prefixIcon: Icon(
                  TablerIcons.search,
                  color: context.currentTheme.iconNeutralDefault,
                  size: 20,
                ),
                suffixIcon: ValueListenableBuilder<TextEditingValue>(
                  valueListenable: _controller,
                  builder: (context, value, _) {
                    if (value.text.isEmpty) return const SizedBox.shrink();
                    return IconButton(
                      icon: const Icon(TablerIcons.circle_x_filled, size: 18),
                      color: context.currentTheme.iconNeutralDefault,
                      onPressed: () => _controller.clear(),
                    );
                  },
                ),
                filled: true,
                fillColor: context.currentTheme.bgSurfaceBase2,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.card),
                  borderSide: BorderSide(
                    color: context.currentTheme.strokeNeutralLight100,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.card),
                  borderSide: BorderSide(
                    color: context.currentTheme.strokeNeutralLight100,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.card),
                  borderSide: BorderSide(
                    color: context.currentTheme.strokeBrandDefault,
                    width: 1.5,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              context.localization.home_search_sheet_example_recent,
              style: AppTextStyles.c1SemiBold.copyWith(
                color: context.currentTheme.textNeutralSecondary,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 8),
            ...examples.map((item) {
              return Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(AppRadius.card),
                  onTap: () {
                    _controller.text = item;
                    _submit(item);
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 4,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          TablerIcons.clock,
                          size: 18,
                          color: context.currentTheme.iconNeutralDefault,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            item,
                            style: AppTextStyles.p2Medium.copyWith(
                              color: context.currentTheme.textNeutralPrimary,
                            ),
                          ),
                        ),
                        Icon(
                          TablerIcons.chevron_right,
                          size: 18,
                          color: context.currentTheme.iconNeutralDefault,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
            const SizedBox(height: 20),
            AppButton(
              label: context.localization.home_search_sheet_action,
              size: AppButtonSize.large,
              onPressed: () => _submit(_controller.text),
            ),
          ],
        ),
      ),
    );
  }
}
