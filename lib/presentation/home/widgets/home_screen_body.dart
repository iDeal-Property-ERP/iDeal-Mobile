import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:ideal_mobile/common/theme/text_style/app_text_styles.dart';
import 'package:ideal_mobile/constants/integration_test_keys.dart';
import 'package:ideal_mobile/core/services/injection_container.dart';
import 'package:ideal_mobile/gen/assets.gen.dart';
import 'package:ideal_mobile/i18n/localization.dart';
import 'package:ideal_mobile/presentation/favorites/bloc/selected_bloc.dart';
import 'package:ideal_mobile/presentation/home/widgets/home_listing_rail.dart';
import 'package:ideal_mobile/presentation/home/widgets/home_search_sheet.dart';
import 'package:ideal_mobile/presentation/home/widgets/tariff_filter_sheet.dart';
import 'package:ideal_mobile/presentation/listings/bloc/listings_bloc.dart';
import 'package:ideal_mobile/presentation/listings/bloc/listings_event.dart';
import 'package:ideal_mobile/presentation/listings/bloc/listings_state.dart';
import 'package:ideal_mobile/presentation/listings/domain/entities/listing_filters.dart';
import 'package:ideal_mobile/presentation/listings/widgets/listing_card_shimmer.dart';
import 'package:ideal_mobile/presentation/listings/widgets/listings_empty_view.dart';
import 'package:ideal_mobile/presentation/listings/widgets/listings_error_view.dart';
import 'package:ideal_mobile/presentation/listings/widgets/listings_feed.dart';
import 'package:ideal_mobile/presentation/listings/widgets/listings_filter_sheet.dart';
import 'package:ideal_mobile/presentation/listings/widgets/map_pill_button.dart';
import 'package:ideal_mobile/presentation/notifications/bloc/notification_badge_cubit.dart';
import 'package:ideal_mobile/routes.gr.dart';
import 'package:ideal_mobile/services/recent_searches_service.dart';
import 'package:ideal_mobile/utils/extensions/build_context_ext.dart';
import 'package:ideal_mobile/utils/theme/extension/theme_extension.dart';
import 'package:ideal_mobile/widgets/app_top_bar.dart';
import 'package:ideal_mobile/widgets/styling/app_colors.dart';

/// Distance from the bottom of the feed at which the next page is requested.
const _kLoadMoreThreshold = 400.0;

class HomeScreenBody extends StatefulWidget {
  const HomeScreenBody({super.key});

  @override
  State<HomeScreenBody> createState() => _HomeScreenBodyState();
}

class _HomeScreenBodyState extends State<HomeScreenBody> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadRails());
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  Future<void> _loadRails() async {
    final recentSearchesService = sl.isRegistered<RecentSearchesService>()
        ? sl<RecentSearchesService>()
        : RecentSearchesService();
    final recentSearches = await recentSearchesService.getRecentSearches();
    final topSearch = recentSearches.isNotEmpty ? recentSearches.first : null;

    List<int> favoriteIds = const [];
    try {
      final selectedBloc = context.read<SelectedBloc>();
      favoriteIds = selectedBloc.state.items.map((i) => i.id).toList();
    } catch (_) {
      // SelectedBloc not in tree in isolated widget tests
    }

    if (mounted) {
      context.read<ListingsBloc>().add(
        LoadHomeRailsEvent(
          recentSearchQuery: topSearch,
          favoriteListingIds: favoriteIds,
        ),
      );
    }
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;

    final position = _scrollController.position;
    if (position.pixels < position.maxScrollExtent - _kLoadMoreThreshold) {
      return;
    }

    final bloc = context.read<ListingsBloc>();
    if (bloc.state.isListingsLoading ||
        bloc.state.isLoadingMore ||
        bloc.state.hasReachedMax) {
      return;
    }

    bloc.add(const LoadMoreListingsEvent());
  }

  Future<void> _onRefresh() async {
    context.read<ListingsBloc>().add(const LoadListingsEvent());
    await _loadRails();
  }

  Future<void> _openSearchSheet(String currentQuery) async {
    final query = await showHomeSearchSheet(
      context,
      currentQuery: currentQuery,
    );
    if (query != null && mounted) {
      context.read<ListingsBloc>().add(SearchListingsEvent(query));
      unawaited(_loadRails());
    }
  }

  Future<void> _openTariffSheet(String? currentTariff) async {
    final tariff = await showTariffFilterSheet(
      context,
      selectedTariff: currentTariff,
    );
    if (mounted) {
      final bloc = context.read<ListingsBloc>();
      final updatedFilters = bloc.state.filters.copyWith(
        tariff: tariff,
        clearTariff: tariff == null || tariff.isEmpty,
      );
      bloc.add(ApplyListingFiltersEvent(updatedFilters));
    }
  }

  String _tariffChipLabel(BuildContext context, String? tariff) {
    if (tariff == null || tariff.isEmpty) {
      return context.localization.home_quick_filter_tariff;
    }
    switch (tariff.toLowerCase()) {
      case 'comfort':
        return context.localization.listings_tariff_comfort;
      case 'premium':
        return context.localization.listings_tariff_premium;
      case 'standard':
      default:
        return context.localization.listings_tariff_standard;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ListingsBloc, ListingsState>(
      listenWhen: (previous, current) =>
          previous.favoriteMutationErrorMessage !=
          current.favoriteMutationErrorMessage,
      listener: (context, state) {
        final message = state.favoriteMutationErrorMessage;
        if (message == null || message.isEmpty) return;
        context.showSnackBar(message, isDisplayingError: true);
        context.read<ListingsBloc>().add(const ClearFavoriteFeedbackEvent());
      },
      child: BlocProvider.value(
        value: sl<NotificationBadgeCubit>()..initialize(),
        child: BlocBuilder<NotificationBadgeCubit, int>(
          builder: (context, unreadCount) {
            return GestureDetector(
              onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
              child: Stack(
                children: [
                  RefreshIndicator(
                    onRefresh: _onRefresh,
                    child: CustomScrollView(
                      key: keys.homePage.listingsFeedKey,
                      controller: _scrollController,
                      physics: const AlwaysScrollableScrollPhysics(),
                      slivers: [
                        AppSliverTopBar.root(
                          title: context.localization.home,
                          leading: const _HomeLogo(),
                          actions: [
                            AppTopBarAction(
                              icon: TablerIcons.bell,
                              tooltip: context.localization.notifications,
                              badge: _notificationBadge(unreadCount),
                              onPressed: () =>
                                  context.pushRoute(NotificationsRoute()),
                            ),
                          ],
                        ),
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
                            child: Text(
                              context.localization.home_heading,
                              style: AppTextStyles.h1.copyWith(
                                color: context.currentTheme.textNeutralPrimary,
                                fontWeight: FontWeight.w800,
                                fontSize: 27,
                                letterSpacing: -0.5,
                              ),
                            ),
                          ),
                        ),
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child:
                                BlocSelector<
                                  ListingsBloc,
                                  ListingsState,
                                  ({String query, ListingFilters filters})
                                >(
                                  selector: (state) => (
                                    query: state.searchQuery,
                                    filters: state.filters,
                                  ),
                                  builder: (context, value) {
                                    return Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        _HomeSearchCard(
                                          query: value.query,
                                          activeFiltersCount:
                                              value.filters.activeCount,
                                          onSearchTap: () =>
                                              _openSearchSheet(value.query),
                                          onFiltersTap: () =>
                                              showListingsFilterSheet(context),
                                        ),
                                        const SizedBox(height: 10),
                                        SingleChildScrollView(
                                          scrollDirection: Axis.horizontal,
                                          physics:
                                              const BouncingScrollPhysics(),
                                          child: Row(
                                            children: [
                                              _QuickFilterChip(
                                                label: context
                                                    .localization
                                                    .home_quick_filter_district,
                                                isActive:
                                                    value.filters.districtId !=
                                                    null,
                                                onTap: () =>
                                                    showListingsFilterSheet(
                                                      context,
                                                    ),
                                              ),
                                              const SizedBox(width: 8),
                                              _QuickFilterChip(
                                                label: context
                                                    .localization
                                                    .home_quick_filter_rooms,
                                                isActive:
                                                    value.filters.roomsMin !=
                                                        null ||
                                                    value.filters.roomsMax !=
                                                        null,
                                                onTap: () =>
                                                    showListingsFilterSheet(
                                                      context,
                                                    ),
                                              ),
                                              const SizedBox(width: 8),
                                              _QuickFilterChip(
                                                label: context
                                                    .localization
                                                    .home_quick_filter_price,
                                                isActive:
                                                    value.filters.priceMin !=
                                                        null ||
                                                    value.filters.priceMax !=
                                                        null,
                                                onTap: () =>
                                                    showListingsFilterSheet(
                                                      context,
                                                    ),
                                              ),
                                              const SizedBox(width: 8),
                                              _QuickFilterChip(
                                                label: _tariffChipLabel(
                                                  context,
                                                  value.filters.tariff,
                                                ),
                                                isActive:
                                                    value.filters.tariff !=
                                                        null &&
                                                    value
                                                        .filters
                                                        .tariff!
                                                        .isNotEmpty,
                                                onTap: () => _openTariffSheet(
                                                  value.filters.tariff,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                ),
                          ),
                        ),
                        BlocBuilder<ListingsBloc, ListingsState>(
                          builder: (context, state) {
                            final hasRecent =
                                state.recentSearchRailListings.isNotEmpty;
                            if (!hasRecent) {
                              return const SliverToBoxAdapter(
                                child: SizedBox.shrink(),
                              );
                            }
                            final recentContext = state.recentSearchContext;
                            final subtitle = recentContext != null
                                ? context.localization
                                      .home_recent_search_context(recentContext)
                                : null;
                            return SliverToBoxAdapter(
                              child: Padding(
                                padding: const EdgeInsets.only(top: 20),
                                child: HomeListingRail(
                                  title: context
                                      .localization
                                      .home_recent_search_heading,
                                  contextSubtitle: subtitle,
                                  listings: state.recentSearchRailListings,
                                  onListingTap: (listing) =>
                                      context.router.push(
                                        ListingDetailRoute(
                                          listingId: listing.id,
                                          initialListing: listing,
                                        ),
                                      ),
                                  onFavoriteToggle: (id) => context
                                      .read<ListingsBloc>()
                                      .add(ToggleFavoriteEvent(id)),
                                ),
                              ),
                            );
                          },
                        ),
                        BlocBuilder<ListingsBloc, ListingsState>(
                          builder: (context, state) {
                            final hasSelected =
                                state.selectedInspiredRailListings.isNotEmpty;
                            if (!hasSelected) {
                              return const SliverToBoxAdapter(
                                child: SizedBox.shrink(),
                              );
                            }
                            return SliverToBoxAdapter(
                              child: Padding(
                                padding: const EdgeInsets.only(top: 20),
                                child: HomeListingRail(
                                  title: context
                                      .localization
                                      .home_selected_heading,
                                  contextSubtitle: context
                                      .localization
                                      .home_selected_context,
                                  listings: state.selectedInspiredRailListings,
                                  onListingTap: (listing) =>
                                      context.router.push(
                                        ListingDetailRoute(
                                          listingId: listing.id,
                                          initialListing: listing,
                                        ),
                                      ),
                                  onFavoriteToggle: (id) => context
                                      .read<ListingsBloc>()
                                      .add(ToggleFavoriteEvent(id)),
                                ),
                              ),
                            );
                          },
                        ),
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
                            child: Text(
                              context.localization.home_highly_rated_heading,
                              style: AppTextStyles.h2Bold.copyWith(
                                color: context.currentTheme.textNeutralPrimary,
                                letterSpacing: -0.5,
                              ),
                            ),
                          ),
                        ),
                        const _ListingsFeedSection(),
                        const SliverToBoxAdapter(child: SizedBox(height: 96)),
                      ],
                    ),
                  ),
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 24,
                    child: Center(child: MapPillButton(onTap: _openMap)),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  String? _notificationBadge(int unreadCount) {
    if (unreadCount <= 0) return null;
    return unreadCount > 9 ? '9+' : '•';
  }

  void _openMap() {
    final listingsBloc = context.read<ListingsBloc>();
    final state = listingsBloc.state;
    context.router.push(
      ListingDiscoveryMapRoute(
        initialFilters: state.filters,
        filterOptions: state.filterOptions,
        seedListings: state.items,
        onFiltersChanged: (filters) =>
            _applyReturnedFilters(listingsBloc, filters),
      ),
    );
  }

  void _applyReturnedFilters(
    ListingsBloc listingsBloc,
    ListingFilters filters,
  ) {
    if (listingsBloc.isClosed || filters == listingsBloc.state.filters) return;
    listingsBloc.add(ApplyListingFiltersEvent(filters));
  }
}

class _HomeSearchCard extends StatelessWidget {
  const _HomeSearchCard({
    required this.query,
    required this.activeFiltersCount,
    required this.onSearchTap,
    required this.onFiltersTap,
  });

  final String query;
  final int activeFiltersCount;
  final VoidCallback onSearchTap;
  final VoidCallback onFiltersTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: context.currentTheme.bgSurfaceBase2,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.currentTheme.strokeNeutralLight100),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowColor3,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Material(
              color: context.currentTheme.bgNeutralLight50,
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: onSearchTap,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 13,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        TablerIcons.search,
                        size: 20,
                        color: context.currentTheme.iconNeutralDefault,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          query.isNotEmpty
                              ? query
                              : context
                                    .localization
                                    .listings_search_placeholder,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: query.isNotEmpty
                              ? AppTextStyles.p2SemiBold.copyWith(
                                  color:
                                      context.currentTheme.textNeutralPrimary,
                                )
                              : AppTextStyles.p2Regular.copyWith(
                                  color:
                                      context.currentTheme.textNeutralSecondary,
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 6),
          Material(
            color: context.currentTheme.bgNeutralLight50,
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: onFiltersTap,
              child: SizedBox(
                width: 48,
                height: 48,
                child: Stack(
                  alignment: Alignment.center,
                  clipBehavior: Clip.none,
                  children: [
                    Icon(
                      TablerIcons.adjustments_horizontal,
                      size: 20,
                      color: context.currentTheme.iconNeutralDefault,
                    ),
                    if (activeFiltersCount > 0)
                      Positioned(
                        top: 6,
                        right: 6,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 1,
                          ),
                          decoration: BoxDecoration(
                            color: context.currentTheme.bgBrandDefault,
                            shape: BoxShape.circle,
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 16,
                            minHeight: 16,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            activeFiltersCount.toString(),
                            style: AppTextStyles.c2SemiBold.copyWith(
                              color: context.currentTheme.textNeutralWhite,
                              fontSize: 9,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickFilterChip extends StatelessWidget {
  const _QuickFilterChip({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isActive
          ? context.currentTheme.textNeutralPrimary
          : context.currentTheme.bgSurfaceBase2,
      shape: StadiumBorder(
        side: BorderSide(
          color: isActive
              ? context.currentTheme.textNeutralPrimary
              : context.currentTheme.strokeNeutralLight100,
        ),
      ),
      child: InkWell(
        customBorder: const StadiumBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: AppTextStyles.p3Medium.copyWith(
                  color: isActive
                      ? context.currentTheme.bgSurfaceBase2
                      : context.currentTheme.textNeutralPrimary,
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                TablerIcons.chevron_down,
                size: 14,
                color: isActive
                    ? context.currentTheme.bgSurfaceBase2
                    : context.currentTheme.iconNeutralDefault,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HomeLogo extends StatelessWidget {
  const _HomeLogo();

  @override
  Widget build(BuildContext context) {
    return Semantics(
      image: true,
      label: 'iDeal',
      child: ExcludeSemantics(
        child: Image.asset(
          context.themeAsset(
            light: Assets.icons.companyLogoLt.path,
            dark: Assets.icons.companyLogoDt.path,
          ),
          width: 28,
          height: 28,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}

/// Chooses between the shimmer, error, empty and loaded feed states.
class _ListingsFeedSection extends StatelessWidget {
  const _ListingsFeedSection();

  @override
  Widget build(BuildContext context) {
    final status = context
        .select<
          ListingsBloc,
          ({
            bool isEmpty,
            bool hasError,
            bool isLoading,
            bool hasLoadedListings,
          })
        >(
          (bloc) => (
            isEmpty: bloc.state.items.isEmpty,
            hasError: bloc.state.errorMessage != null,
            isLoading: bloc.state.isListingsLoading,
            hasLoadedListings: bloc.state.hasLoadedListings,
          ),
        );

    // An error only takes over the feed when there is nothing to show; a failed
    // page-2 load keeps the already-loaded results visible.
    if (status.hasError && status.isEmpty) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: ListingsErrorView(
          onRetry: () =>
              context.read<ListingsBloc>().add(const LoadListingsEvent()),
        ),
      );
    }

    if ((status.isLoading || !status.hasLoadedListings) && status.isEmpty) {
      return const ListingCardShimmerGrid();
    }

    if (status.isEmpty) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: ListingsEmptyView(
          onClearFilters: () => context.read<ListingsBloc>().add(
            const ClearListingFiltersEvent(),
          ),
        ),
      );
    }

    return const _LoadedFeed();
  }
}

class _LoadedFeed extends StatelessWidget {
  const _LoadedFeed();

  @override
  Widget build(BuildContext context) {
    final isLoadingMore = context.select<ListingsBloc, bool>(
      (bloc) => bloc.state.isLoadingMore,
    );

    return SliverMainAxisGroup(
      slivers: [
        const ListingsFeedSliver(),
        if (isLoadingMore)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator.adaptive(strokeWidth: 2),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    context.localization.home_feed_status_loading,
                    style: AppTextStyles.p3Regular.copyWith(
                      color: context.currentTheme.textNeutralSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
