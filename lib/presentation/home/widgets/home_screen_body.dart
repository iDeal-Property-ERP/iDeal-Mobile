import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ideal_mobile/constants/integration_test_keys.dart';
import 'package:ideal_mobile/presentation/home/widgets/home_app_bar.dart';
import 'package:ideal_mobile/presentation/listings/bloc/listings_bloc.dart';
import 'package:ideal_mobile/presentation/listings/bloc/listings_event.dart';
import 'package:ideal_mobile/presentation/listings/bloc/listings_state.dart';
import 'package:ideal_mobile/presentation/listings/widgets/listing_card_shimmer.dart';
import 'package:ideal_mobile/presentation/listings/widgets/listings_empty_view.dart';
import 'package:ideal_mobile/presentation/listings/widgets/listings_error_view.dart';
import 'package:ideal_mobile/presentation/listings/widgets/listings_feed.dart';
import 'package:ideal_mobile/presentation/listings/widgets/listings_filter_chips.dart';
import 'package:ideal_mobile/presentation/listings/widgets/listings_filter_sheet.dart';
import 'package:ideal_mobile/presentation/listings/widgets/listings_search_bar.dart';
import 'package:ideal_mobile/presentation/listings/widgets/map_pill_button.dart';

/// Distance from the bottom of the feed at which the next page is requested.
const _kLoadMoreThreshold = 400.0;

class HomeScreenBody extends StatefulWidget {
  const HomeScreenBody({super.key});

  @override
  State<HomeScreenBody> createState() => _HomeScreenBodyState();
}

class _HomeScreenBodyState extends State<HomeScreenBody> {
  final GlobalKey _searchBarKey = GlobalKey();
  final ScrollController _scrollController = ScrollController();
  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;

    final position = _scrollController.position;
    if (position.pixels < position.maxScrollExtent - _kLoadMoreThreshold) {
      return;
    }

    final bloc = context.read<ListingsBloc>();
    if (bloc.state.isLoadingMore || bloc.state.hasReachedMax) return;

    bloc.add(const LoadMoreListingsEvent());
  }

  Future<void> _onRefresh() async {
    context.read<ListingsBloc>().add(const LoadListingsEvent());
  }

  @override
  Widget build(BuildContext context) {
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
                const SliverToBoxAdapter(child: HomeAppBar()),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                    child: ListingsSearchBar(key: _searchBarKey),
                  ),
                ),
                SliverToBoxAdapter(
                  child: ListingsFilterChips(
                    onOpenFilters: () => showListingsFilterSheet(context),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 12)),
                const _ListingsFeedSection(),
                // Keeps the last row clear of the floating map pill.
                const SliverToBoxAdapter(child: SizedBox(height: 96)),
              ],
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 24,
            child: Center(
              child: MapPillButton(
                // TODO(listings): wire up the map view — inert for now.
                onTap: () {},
              ),
            ),
          ),
        ],
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
        .select<ListingsBloc, ({bool isEmpty, bool hasError, bool isLoading})>(
          (bloc) => (
            isEmpty: bloc.state.items.isEmpty,
            hasError: bloc.state.errorMessage != null,
            isLoading: bloc.state is ListingsLoadingState,
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

    if (status.isLoading && status.isEmpty) {
      return const SliverToBoxAdapter(child: ListingCardShimmerGrid());
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
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(child: CircularProgressIndicator.adaptive()),
            ),
          ),
      ],
    );
  }
}
