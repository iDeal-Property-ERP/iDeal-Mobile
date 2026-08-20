import 'dart:async';

import 'package:debounce_throttle/debounce_throttle.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:ideal_mobile/common/theme/text_style/app_text_styles.dart';
import 'package:ideal_mobile/core/services/injection_container.dart';
import 'package:ideal_mobile/i18n/localization.dart';
import 'package:ideal_mobile/services/recent_searches_service.dart';
import 'package:ideal_mobile/utils/theme/extension/theme_extension.dart';
import 'package:ideal_mobile/widgets/styling/app_radius.dart';

class ListingsSearchBar extends StatefulWidget {
  const ListingsSearchBar({
    super.key,
    this.query = '',
    this.onQueryChanged,
    this.enableRecentSearches = true,
    this.recentSearchesService,
  });

  /// The active query. External changes (e.g. cleared filters) update the
  /// field text without emitting another [onQueryChanged].
  final String query;
  final ValueChanged<String>? onQueryChanged;
  final bool enableRecentSearches;
  final RecentSearchesService? recentSearchesService;

  @override
  State<ListingsSearchBar> createState() => _ListingsSearchBarState();
}

class _ListingsSearchBarState extends State<ListingsSearchBar> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final LayerLink _layerLink = LayerLink();
  final OverlayPortalController _overlayPortalController =
      OverlayPortalController();

  final Debouncer<String> _debouncer = Debouncer<String>(
    const Duration(milliseconds: 500),
    initialValue: '',
  );
  StreamSubscription<String>? _debouncerSubscription;
  List<String> _recentSearches = const [];

  RecentSearchesService get _recentSearchesService =>
      widget.recentSearchesService ??
      (sl.isRegistered<RecentSearchesService>()
          ? sl<RecentSearchesService>()
          : RecentSearchesService());

  @override
  void initState() {
    super.initState();
    if (widget.query.isNotEmpty) {
      _searchController.text = widget.query;
    }
    _searchController.addListener(_onSearchTextChanged);
    _focusNode.addListener(_onFocusChanged);
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
    _focusNode.removeListener(_onFocusChanged);
    _searchController.removeListener(_onSearchTextChanged);
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _loadRecentSearches() async {
    if (!widget.enableRecentSearches) return;
    final searches = await _recentSearchesService.getRecentSearches();
    if (!mounted) return;

    setState(() {
      _recentSearches = searches;
    });

    if (_focusNode.hasFocus &&
        _searchController.text.trim().isEmpty &&
        _recentSearches.isNotEmpty) {
      if (!_overlayPortalController.isShowing) {
        _overlayPortalController.show();
      }
    } else {
      if (_overlayPortalController.isShowing) {
        _overlayPortalController.hide();
      }
    }
  }

  void _onFocusChanged() {
    if (_focusNode.hasFocus) {
      unawaited(_loadRecentSearches());
    } else {
      if (_overlayPortalController.isShowing) {
        _overlayPortalController.hide();
      }
    }
  }

  void _onSearchTextChanged() {
    _debouncer.value = _searchController.text;
    if (_searchController.text.trim().isNotEmpty) {
      if (_overlayPortalController.isShowing) {
        _overlayPortalController.hide();
      }
    } else if (_focusNode.hasFocus && _recentSearches.isNotEmpty) {
      if (!_overlayPortalController.isShowing) {
        _overlayPortalController.show();
      }
    }
  }

  void _dispatchSearch(String value) {
    if (!mounted) return;

    final query = value.trim();
    if (query.isEmpty) {
      FocusManager.instance.primaryFocus?.unfocus();
    } else if (widget.enableRecentSearches) {
      unawaited(_recentSearchesService.saveSearch(query));
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
    if (_focusNode.hasFocus && _recentSearches.isNotEmpty) {
      if (!_overlayPortalController.isShowing) {
        _overlayPortalController.show();
      }
    }
  }

  void _onSelectRecentSearch(String query) {
    _setTextWithoutDebouncing(query);
    _debouncer.value = query;
    if (_overlayPortalController.isShowing) {
      _overlayPortalController.hide();
    }
    _focusNode.unfocus();
    if (widget.enableRecentSearches) {
      unawaited(_recentSearchesService.saveSearch(query));
    }
    widget.onQueryChanged?.call(query);
  }

  Future<void> _removeRecentSearch(String query) async {
    await _recentSearchesService.removeSearch(query);
    await _loadRecentSearches();
  }

  Future<void> _clearAllRecentSearches() async {
    await _recentSearchesService.clearAll();
    if (!mounted) return;
    setState(() {
      _recentSearches = const [];
    });
    if (_overlayPortalController.isShowing) {
      _overlayPortalController.hide();
    }
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: OverlayPortal(
        controller: _overlayPortalController,
        overlayChildBuilder: (context) {
          return CompositedTransformFollower(
            link: _layerLink,
            targetAnchor: Alignment.bottomLeft,
            offset: const Offset(0, 8),
            showWhenUnlinked: false,
            child: Align(
              alignment: Alignment.topLeft,
              child: SizedBox(
                width: _layerLink.leaderSize?.width,
                child: _buildRecentSearchesCard(context),
              ),
            ),
          );
        },
        child: ValueListenableBuilder<TextEditingValue>(
          valueListenable: _searchController,
          builder: (context, value, child) {
            final hasSearchText = value.text.isNotEmpty;

            return TextField(
              controller: _searchController,
              focusNode: _focusNode,
              onSubmitted: (submittedValue) {
                final query = submittedValue.trim();
                if (query.isNotEmpty && widget.enableRecentSearches) {
                  unawaited(_recentSearchesService.saveSearch(query));
                }
                _dispatchSearch(submittedValue);
              },
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
                focusedBorder: _buildOutlineInputBorder(
                  context,
                  hasFocus: true,
                ),
                errorBorder: _buildOutlineInputBorder(
                  context,
                  isErrorBorder: true,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 15),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildRecentSearchesCard(BuildContext context) {
    if (_recentSearches.isEmpty) {
      return const SizedBox.shrink();
    }

    final theme = context.currentTheme;

    return FocusScope(
      canRequestFocus: false,
      child: Material(
        elevation: 6,
        shadowColor: theme.strokeShadesBlack.withValues(alpha: 0.12),
        color: theme.bgSurfaceBase2,
        borderRadius: BorderRadius.circular(AppRadius.card),
        clipBehavior: Clip.antiAlias,
        child: Container(
          decoration: BoxDecoration(
            color: theme.bgSurfaceBase2,
            borderRadius: BorderRadius.circular(AppRadius.card),
            border: Border.all(color: theme.strokeNeutralLight200),
          ),
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 8, 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      context.localization.recent_searches,
                      style: AppTextStyles.p4SemiBold.copyWith(
                        color: theme.textNeutralSecondary,
                      ),
                    ),
                    InkWell(
                      onTap: _clearAllRecentSearches,
                      borderRadius: BorderRadius.circular(AppRadius.input),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        child: Text(
                          context.localization.listings_clear_all,
                          style: AppTextStyles.p4Medium.copyWith(
                            color: theme.textBrandPrimary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Divider(
                height: 8,
                thickness: 1,
                color: theme.strokeNeutralLight200,
              ),
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: EdgeInsets.zero,
                  itemCount: _recentSearches.length,
                  separatorBuilder: (context, index) => Divider(
                    height: 1,
                    thickness: 1,
                    indent: 16,
                    endIndent: 16,
                    color: theme.strokeNeutralLight200,
                  ),
                  itemBuilder: (context, index) {
                    final item = _recentSearches[index];
                    return InkWell(
                      onTap: () => _onSelectRecentSearch(item),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              TablerIcons.history,
                              size: 18,
                              color: theme.iconNeutralDefault,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                item,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTextStyles.p3Medium.copyWith(
                                  color: theme.textNeutralPrimary,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: Icon(
                                TablerIcons.x,
                                size: 16,
                                color: theme.iconNeutralDefault,
                              ),
                              onPressed: () =>
                                  unawaited(_removeRecentSearch(item)),
                              splashRadius: 18,
                              constraints: const BoxConstraints(
                                minWidth: 28,
                                minHeight: 28,
                              ),
                              padding: EdgeInsets.zero,
                              tooltip: 'Remove',
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
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
