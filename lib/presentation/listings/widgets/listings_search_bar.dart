import 'dart:async';

import 'package:debounce_throttle/debounce_throttle.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:ideal_mobile/common/theme/text_style/app_text_styles.dart';
import 'package:ideal_mobile/i18n/localization.dart';
import 'package:ideal_mobile/utils/theme/extension/theme_extension.dart';
import 'package:ideal_mobile/widgets/styling/app_radius.dart';

class ListingsSearchBar extends StatefulWidget {
  const ListingsSearchBar({super.key, this.query = '', this.onQueryChanged});

  /// The active query. External changes (e.g. cleared filters) update the
  /// field text without emitting another [onQueryChanged].
  final String query;
  final ValueChanged<String>? onQueryChanged;

  @override
  State<ListingsSearchBar> createState() => _ListingsSearchBarState();
}

class _ListingsSearchBarState extends State<ListingsSearchBar> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final Debouncer<String> _debouncer = Debouncer<String>(
    const Duration(milliseconds: 500),
    initialValue: '',
  );
  StreamSubscription<String>? _debouncerSubscription;

  @override
  void initState() {
    super.initState();
    if (widget.query.isNotEmpty) {
      _searchController.text = widget.query;
    }
    _searchController.addListener(_onSearchTextChanged);
    _debouncerSubscription = _debouncer.values.listen(_dispatchSearch);
  }

  @override
  void didUpdateWidget(covariant ListingsSearchBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.query != oldWidget.query &&
        widget.query != _searchController.text) {
      _setTextWithoutDebouncing(widget.query);
    }
  }

  @override
  void dispose() {
    _debouncerSubscription?.cancel();
    _debouncer.cancel();
    _searchController.removeListener(_onSearchTextChanged);
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onSearchTextChanged() {
    _debouncer.value = _searchController.text;
  }

  void _dispatchSearch(String value) {
    if (!mounted) return;

    final query = value.trim();
    if (query.isEmpty) {
      FocusManager.instance.primaryFocus?.unfocus();
    }
    widget.onQueryChanged?.call(query);
  }

  void _setTextWithoutDebouncing(String value) {
    _searchController.removeListener(_onSearchTextChanged);
    _searchController.value = TextEditingValue(
      text: value,
      selection: TextSelection.collapsed(offset: value.length),
    );
    _searchController.addListener(_onSearchTextChanged);
  }

  void _clearSearch() {
    _setTextWithoutDebouncing('');
    _debouncer.value = '';
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: _searchController,
      builder: (context, value, child) {
        final hasSearchText = value.text.isNotEmpty;

        return TextField(
          controller: _searchController,
          focusNode: _focusNode,
          style: AppTextStyles.p3Medium.copyWith(
            color: context.currentTheme.textNeutralPrimary,
          ),
          decoration: InputDecoration(
            hintText: context.localization.listings_search_placeholder,
            hintStyle: AppTextStyles.p3Medium.copyWith(
              color: context.currentTheme.textNeutralDisable,
            ),
            prefixIcon: Icon(
              TablerIcons.search,
              color: context.currentTheme.iconNeutralDefault,
            ),
            filled: true,
            fillColor: context.currentTheme.bgSurfaceBase2,
            suffixIcon: hasSearchText
                ? IconButton(
                    onPressed: _clearSearch,
                    icon: Icon(
                      TablerIcons.x,
                      color: context.currentTheme.iconNeutralDefault,
                    ),
                  )
                : null,
            border: _buildOutlineInputBorder(context),
            enabledBorder: _buildOutlineInputBorder(context),
            focusedBorder: _buildOutlineInputBorder(context, hasFocus: true),
            errorBorder: _buildOutlineInputBorder(context, isErrorBorder: true),
            contentPadding: const EdgeInsets.symmetric(vertical: 15),
          ),
        );
      },
    );
  }

  OutlineInputBorder _buildOutlineInputBorder(
    BuildContext context, {
    bool hasFocus = false,
    bool isErrorBorder = false,
  }) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.input),
      borderSide: BorderSide(
        color: isErrorBorder
            ? context.currentTheme.strokeErrorDefault
            : hasFocus
            ? context.currentTheme.strokeBrandHover
            : context.currentTheme.strokeNeutralLight200,
      ),
    );
  }
}
