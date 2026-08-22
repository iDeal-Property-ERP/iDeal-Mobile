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
import 'package:ideal_mobile/presentation/home/widgets/home_listing_rail.dart';
import 'package:ideal_mobile/presentation/home/widgets/home_quick_filter_sheet.dart';
import 'package:ideal_mobile/presentation/listings/bloc/listings_bloc.dart';
import 'package:ideal_mobile/presentation/listings/bloc/listings_event.dart';
import 'package:ideal_mobile/presentation/listings/bloc/listings_state.dart';
import 'package:ideal_mobile/presentation/listings/domain/entities/listing_filter_options.dart';
import 'package:ideal_mobile/presentation/listings/domain/entities/listing_filters.dart';
import 'package:ideal_mobile/presentation/listings/widgets/listing_card_shimmer.dart';
import 'package:ideal_mobile/presentation/listings/widgets/listings_empty_view.dart';
import 'package:ideal_mobile/presentation/listings/widgets/listings_error_view.dart';
import 'package:ideal_mobile/presentation/listings/widgets/listings_feed.dart';
import 'package:ideal_mobile/presentation/listings/widgets/listings_filter_sheet.dart';
import 'package:ideal_mobile/presentation/listings/widgets/listings_search_bar.dart';
import 'package:ideal_mobile/presentation/listings/widgets/map_pill_button.dart';
import 'package:ideal_mobile/presentation/notifications/bloc/notification_badge_cubit.dart';
import 'package:ideal_mobile/routes.gr.dart';
import 'package:ideal_mobile/utils/extensions/build_context_ext.dart';
import 'package:ideal_mobile/utils/theme/extension/theme_extension.dart';
import 'package:ideal_mobile/widgets/app_top_bar.dart';

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
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadRecommendations());
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _loadRecommendations() {
    context.read<ListingsBloc>().add(const LoadHomeRecommendationsEvent());
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
    _loadRecommendations();
  }

  Future<void> _openQuickFilterSheet(
    HomeQuickFilterKind kind,
    ListingFilters currentFilters,
    ListingFilterOptions filterOptions,
  ) async {
    final updatedFilters = await showHomeQuickFilterSheet(
      context,
      kind: kind,
      filters: currentFilters,
      filterOptions: filterOptions,
    );
    if (updatedFilters != null && mounted) {
      context.read<ListingsBloc>().add(
        ApplyListingFiltersEvent(updatedFilters),
      );
    }
  }

  void _clearDistrict(ListingFilters filters) {
    context.read<ListingsBloc>().add(
      ApplyListingFiltersEvent(filters.copyWith(clearDistrictId: true)),
    );
  }

  void _clearRooms(ListingFilters filters) {
    context.read<ListingsBloc>().add(
      ApplyListingFiltersEvent(
        filters.copyWith(clearRoomsMin: true, clearRoomsMax: true),
      ),
    );
  }

  void _clearPrice(ListingFilters filters) {
    context.read<ListingsBloc>().add(
      ApplyListingFiltersEvent(
        filters.copyWith(clearPriceMin: true, clearPriceMax: true),
      ),
    );
  }

  void _clearTariff(ListingFilters filters) {
    context.read<ListingsBloc>().add(
      ApplyListingFiltersEvent(filters.copyWith(clearTariff: true)),
    );
  }

  String _districtChipLabel(
    BuildContext context,
    int? districtId,
    List<ListingDistrict> districts,
  ) {
    if (districtId == null) {
      return context.localization.home_quick_filter_district;
    }
    for (final district in districts) {
      if (district.id == districtId) return district.name;
    }
    return districtId.toString();
  }

  String _roomsChipLabel(BuildContext context, int? roomsMin, int? roomsMax) {
    if (roomsMin == null && roomsMax == null) {
      return context.localization.home_quick_filter_rooms;
    }
    if (roomsMin != null && roomsMin == roomsMax) {
      return roomsMin.toString();
    }
    if (roomsMin != null && roomsMax != null) {
      return '$roomsMin–$roomsMax';
    }
    if (roomsMin != null) {
      return '$roomsMin+';
    }
    return '≤$roomsMax';
  }

  String _priceChipLabel(
    BuildContext context,
    double? priceMin,
    double? priceMax,
  ) {
    if (priceMin == null && priceMax == null) {
      return context.localization.home_quick_filter_price;
    }

    String formatPrice(double val) {
      if (val == val.roundToDouble()) return val.toInt().toString();
      return val.toString();
    }

    if (priceMin != null && priceMin == priceMax) {
      return '\$${formatPrice(priceMin)}';
    }
    if (priceMin != null && priceMax != null) {
      return '\$${formatPrice(priceMin)}–\$${formatPrice(priceMax)}';
    }
    if (priceMin != null) {
      return '\$${formatPrice(priceMin)}+';
    }
    return '≤\$${formatPrice(priceMax!)}';
  }

  String _tariffChipLabel(
    BuildContext context,
    String? tariff,
    List<ListingChoice> tariffs,
  ) {
    if (tariff == null || tariff.isEmpty) {
      return context.localization.home_quick_filter_tariff;
    }
    for (final choice in tariffs) {
      if (choice.value.toLowerCase() == tariff.toLowerCase()) {
        return choice.label;
      }
    }
    switch (tariff.toLowerCase()) {
      case 'comfort':
        return context.localization.listings_tariff_comfort;
      case 'premium':
        return context.localization.listings_tariff_premium;
      case 'standard':
        return context.localization.listings_tariff_standard;
      default:
        return tariff;
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
                                  ({
                                    String query,
                                    ListingFilters filters,
                                    ListingFilterOptions filterOptions,
                                  })
                                >(
                                  selector: (state) => (
                                    query: state.searchQuery,
                                    filters: state.filters,
                                    filterOptions: state.filterOptions,
                                  ),
                                  builder: (context, value) {
                                    final loc = context.localization;
                                    final clearDistrictA11y = loc
                                        .home_quick_filter_clear_district_a11y;
                                    final clearRoomsA11y =
                                        loc.home_quick_filter_clear_rooms_a11y;
                                    final clearPriceA11y =
                                        loc.home_quick_filter_clear_price_a11y;
                                    final clearTariffA11y =
                                        loc.home_quick_filter_clear_tariff_a11y;
                                    final hasDistrict =
                                        value.filters.districtId != null;
                                    final hasRooms =
                                        value.filters.roomsMin != null ||
                                        value.filters.roomsMax != null;
                                    final hasPrice =
                                        value.filters.priceMin != null ||
                                        value.filters.priceMax != null;
                                    final hasTariff =
                                        value.filters.tariff != null &&
                                        value.filters.tariff!.isNotEmpty;

                                    return Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        ListingsSearchBar(
                                          query: value.query,
                                          activeFiltersCount:
                                              value.filters.activeCount,
                                          onQueryChanged: (query) => context
                                              .read<ListingsBloc>()
                                              .add(SearchListingsEvent(query)),
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
                                                label: _districtChipLabel(
                                                  context,
                                                  value.filters.districtId,
                                                  value.filterOptions.districts,
                                                ),
                                                isActive: hasDistrict,
                                                onTap: () =>
                                                    _openQuickFilterSheet(
                                                      HomeQuickFilterKind
                                                          .district,
                                                      value.filters,
                                                      value.filterOptions,
                                                    ),
                                                onClear: hasDistrict
                                                    ? () => _clearDistrict(
                                                        value.filters,
                                                      )
                                                    : null,
                                                clearSemanticLabel:
                                                    clearDistrictA11y,
                                              ),
                                              const SizedBox(width: 8),
                                              _QuickFilterChip(
                                                label: _roomsChipLabel(
                                                  context,
                                                  value.filters.roomsMin,
                                                  value.filters.roomsMax,
                                                ),
                                                isActive: hasRooms,
                                                onTap: () =>
                                                    _openQuickFilterSheet(
                                                      HomeQuickFilterKind.rooms,
                                                      value.filters,
                                                      value.filterOptions,
                                                    ),
                                                onClear: hasRooms
                                                    ? () => _clearRooms(
                                                        value.filters,
                                                      )
                                                    : null,
                                                clearSemanticLabel:
                                                    clearRoomsA11y,
                                              ),
                                              const SizedBox(width: 8),
                                              _QuickFilterChip(
                                                label: _priceChipLabel(
                                                  context,
                                                  value.filters.priceMin,
                                                  value.filters.priceMax,
                                                ),
                                                isActive: hasPrice,
                                                onTap: () =>
                                                    _openQuickFilterSheet(
                                                      HomeQuickFilterKind.price,
                                                      value.filters,
                                                      value.filterOptions,
                                                    ),
                                                onClear: hasPrice
                                                    ? () => _clearPrice(
                                                        value.filters,
                                                      )
                                                    : null,
                                                clearSemanticLabel:
                                                    clearPriceA11y,
                                              ),
                                              const SizedBox(width: 8),
                                              _QuickFilterChip(
                                                label: _tariffChipLabel(
                                                  context,
                                                  value.filters.tariff,
                                                  value.filterOptions.tariffs,
                                                ),
                                                isActive: hasTariff,
                                                onTap: () =>
                                                    _openQuickFilterSheet(
                                                      HomeQuickFilterKind
                                                          .tariff,
                                                      value.filters,
                                                      value.filterOptions,
                                                    ),
                                                onClear: hasTariff
                                                    ? () => _clearTariff(
                                                        value.filters,
                                                      )
                                                    : null,
                                                clearSemanticLabel:
                                                    clearTariffA11y,
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
                            if (!state.isBaseline ||
                                state.recommendedListings.isEmpty) {
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
                                      .home_recommended_heading,
                                  listings: state.recommendedListings,
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
                            if (!state.isBaseline) {
                              return const SliverToBoxAdapter(
                                child: SizedBox(height: 16),
                              );
                            }
                            return SliverToBoxAdapter(
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(
                                  16,
                                  20,
                                  16,
                                  10,
                                ),
                                child: Text(
                                  context
                                      .localization
                                      .home_highly_rated_heading,
                                  style: AppTextStyles.h2Bold.copyWith(
                                    color:
                                        context.currentTheme.textNeutralPrimary,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                              ),
                            );
                          },
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

class _QuickFilterChip extends StatelessWidget {
  const _QuickFilterChip({
    required this.label,
    required this.isActive,
    required this.onTap,
    this.onClear,
    this.clearSemanticLabel,
  });

  final String label;
  final bool isActive;
  final VoidCallback onTap;
  final VoidCallback? onClear;
  final String? clearSemanticLabel;

  @override
  Widget build(BuildContext context) {
    final backgroundColor = isActive
        ? context.currentTheme.textNeutralPrimary
        : context.currentTheme.bgSurfaceBase2;
    final borderColor = isActive
        ? context.currentTheme.textNeutralPrimary
        : context.currentTheme.strokeNeutralLight100;
    final textColor = isActive
        ? context.currentTheme.bgSurfaceBase2
        : context.currentTheme.textNeutralPrimary;

    return Material(
      color: backgroundColor,
      shape: StadiumBorder(side: BorderSide(color: borderColor)),
      child: isActive && onClear != null
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                InkWell(
                  customBorder: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.horizontal(
                      left: Radius.circular(999),
                    ),
                  ),
                  onTap: onTap,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(14, 8, 4, 8),
                    child: Text(
                      label,
                      style: AppTextStyles.p3Medium.copyWith(color: textColor),
                    ),
                  ),
                ),
                Semantics(
                  button: true,
                  label: clearSemanticLabel,
                  child: InkResponse(
                    customBorder: const CircleBorder(),
                    onTap: onClear,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(2, 8, 12, 8),
                      child: Icon(TablerIcons.x, size: 14, color: textColor),
                    ),
                  ),
                ),
              ],
            )
          : InkWell(
              customBorder: const StadiumBorder(),
              onTap: onTap,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      label,
                      style: AppTextStyles.p3Medium.copyWith(color: textColor),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      TablerIcons.chevron_down,
                      size: 14,
                      color: context.currentTheme.iconNeutralDefault,
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
