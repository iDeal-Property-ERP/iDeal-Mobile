import 'dart:async';
import 'dart:math';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ideal_mobile/common/theme/text_style/app_text_styles.dart';
import 'package:ideal_mobile/constants/integration_test_keys.dart';
import 'package:ideal_mobile/core/services/injection_container.dart';
import 'package:ideal_mobile/i18n/localization.dart';
import 'package:ideal_mobile/presentation/home/widgets/home_all_filters_button.dart';
import 'package:ideal_mobile/presentation/home/widgets/home_banner_carousel.dart';
import 'package:ideal_mobile/presentation/home/widgets/home_date_filter_button.dart';
import 'package:ideal_mobile/presentation/home/widgets/home_listing_rail.dart';
import 'package:ideal_mobile/presentation/home/widgets/home_top_bar.dart';
import 'package:ideal_mobile/presentation/listings/bloc/listings_bloc.dart';
import 'package:ideal_mobile/presentation/listings/bloc/listings_event.dart';
import 'package:ideal_mobile/presentation/listings/bloc/listings_state.dart';
import 'package:ideal_mobile/presentation/listings/domain/entities/listing_filter_options.dart';
import 'package:ideal_mobile/presentation/listings/domain/entities/listing_filters.dart';
import 'package:ideal_mobile/presentation/listings/widgets/listing_card_shimmer.dart';
import 'package:ideal_mobile/presentation/listings/widgets/listing_date_filter_sheet.dart';
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

/// Distance from the bottom of the feed at which the next page is requested.
const _kLoadMoreThreshold = 400.0;

class HomeScreenBody extends StatefulWidget {
  const HomeScreenBody({this.initialMottoIndex, super.key});

  final int? initialMottoIndex;

  @override
  State<HomeScreenBody> createState() => _HomeScreenBodyState();
}

class _HomeScreenBodyState extends State<HomeScreenBody> {
  final ScrollController _scrollController = ScrollController();
  late int _mottoIndex;

  @override
  void initState() {
    super.initState();
    _mottoIndex = widget.initialMottoIndex ?? Random().nextInt(10);
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
    setState(() {
      _mottoIndex = Random().nextInt(10);
    });
    context.read<ListingsBloc>().add(const LoadListingsEvent());
    _loadRecommendations();
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
                        HomeSliverTopBar(
                          mottoIndex: _mottoIndex,
                          unreadCount: unreadCount,
                          onNotificationTap: () =>
                              context.pushRoute(NotificationsRoute()),
                        ),
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
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
                                    return Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        ListingsSearchBar(
                                          query: value.query,
                                          onQueryChanged: (query) => context
                                              .read<ListingsBloc>()
                                              .add(SearchListingsEvent(query)),
                                        ),
                                        const SizedBox(height: 14),
                                        const HomeBannerCarousel(),
                                        const SizedBox(height: 14),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: HomeAllFiltersButton(
                                                key: keys
                                                    .homePage
                                                    .allFiltersButtonKey,
                                                onTap: () =>
                                                    showListingsFilterSheet(
                                                      context,
                                                    ),
                                                activeFiltersCount:
                                                    value.filters.activeCount,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            HomeDateFilterButton(
                                              onTap: _openDateFilter,
                                              isActive:
                                                  value.filters.hasDateRange,
                                            ),
                                          ],
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

  Future<void> _openDateFilter() async {
    await showListingDateFilterSheet(context);
  }

  void _applyReturnedFilters(
    ListingsBloc listingsBloc,
    ListingFilters filters,
  ) {
    if (listingsBloc.isClosed || filters == listingsBloc.state.filters) return;
    listingsBloc.add(ApplyListingFiltersEvent(filters));
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
