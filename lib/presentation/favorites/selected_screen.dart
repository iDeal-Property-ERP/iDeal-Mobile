import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ideal_mobile/common/theme/text_style/app_text_styles.dart';
import 'package:ideal_mobile/i18n/localization.dart';
import 'package:ideal_mobile/presentation/favorites/bloc/selected_bloc.dart';
import 'package:ideal_mobile/presentation/favorites/bloc/selected_event.dart';
import 'package:ideal_mobile/presentation/favorites/bloc/selected_state.dart';
import 'package:ideal_mobile/presentation/favorites/domain/entities/selected_sort.dart';
import 'package:ideal_mobile/presentation/listings/domain/entities/listing_filter_options.dart';
import 'package:ideal_mobile/presentation/listings/domain/entities/listing_filters.dart';
import 'package:ideal_mobile/presentation/listings/widgets/listing_card.dart';
import 'package:ideal_mobile/presentation/listings/widgets/listing_card_shimmer.dart';
import 'package:ideal_mobile/presentation/listings/widgets/listings_feed.dart';
import 'package:ideal_mobile/presentation/listings/widgets/listings_filter_chips.dart';
import 'package:ideal_mobile/presentation/listings/widgets/listings_filter_dropdown_chip.dart';
import 'package:ideal_mobile/presentation/listings/widgets/listings_filter_sheet.dart';
import 'package:ideal_mobile/presentation/listings/widgets/listings_search_bar.dart';
import 'package:ideal_mobile/presentation/listings/widgets/map_pill_button.dart';
import 'package:ideal_mobile/routes.gr.dart';
import 'package:ideal_mobile/utils/extensions/build_context_ext.dart';
import 'package:ideal_mobile/utils/responsive.dart';
import 'package:ideal_mobile/utils/theme/extension/theme_extension.dart';
import 'package:ideal_mobile/widgets/app_top_bar.dart';
import 'package:ideal_mobile/widgets/images/prioritized_image_scheduler.dart';

const _kSelectedLoadMoreThreshold = 400.0;

String _selectedErrorMessage(BuildContext context, String message) {
  switch (message) {
    case selectedLoadErrorKey:
      return context.localization.selected_load_error;
    case selectedMutationErrorKey:
      return context.localization.selected_mutation_error;
    case selectedPageOutOfDateErrorKey:
      return context.localization.selected_page_out_of_date;
    default:
      return context.localization.selected_unknown_error;
  }
}

String _selectedSortLabel(BuildContext context, SelectedSort sort) {
  switch (sort) {
    case SelectedSort.priceAsc:
      return context.localization.selected_sort_price_asc;
    case SelectedSort.priceDesc:
      return context.localization.selected_sort_price_desc;
    case SelectedSort.recent:
      return context.localization.selected_sort_recent;
  }
}

class SelectedScreen extends StatefulWidget {
  const SelectedScreen({super.key});

  @override
  State<SelectedScreen> createState() => _SelectedScreenState();
}

class _SelectedScreenState extends State<SelectedScreen> {
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
    if (position.pixels <
        position.maxScrollExtent - _kSelectedLoadMoreThreshold) {
      return;
    }

    final bloc = context.read<SelectedBloc>();
    if (bloc.state.isLoading ||
        bloc.state.isLoadingMore ||
        bloc.state.hasReachedMax) {
      return;
    }

    bloc.add(const LoadMoreSelectedEvent());
  }

  Future<void> _onRefresh() async {
    final bloc = context.read<SelectedBloc>();
    bloc.add(const LoadSelectedEvent(refresh: true));
    await bloc.stream.firstWhere((state) => !state.isLoading);
  }

  void _openMap() {
    final bloc = context.read<SelectedBloc>();
    final state = bloc.state;
    context.router.push(
      ListingDiscoveryMapRoute(
        initialFilters: state.filters,
        filterOptions: state.filterOptions,
        seedListings: state.items,
        favoritesOnly: true,
        onFiltersChanged: (filters) {
          if (bloc.isClosed || filters == bloc.state.filters) return;
          bloc.add(ApplySelectedFiltersEvent(filters));
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<SelectedBloc, SelectedState>(
          listenWhen: (previous, current) =>
              previous.removedListing != current.removedListing &&
              current.removedListing != null,
          listener: (context, state) {
            final removed = state.removedListing;
            if (removed == null) return;
            context.showSnackBar(
              context.localization.selected_removed,
              action: SnackBarAction(
                label: context.localization.selected_undo,
                onPressed: () => context.read<SelectedBloc>().add(
                  RestoreSelectedFavoriteEvent(removed.listingId),
                ),
              ),
              duration: const Duration(seconds: 4),
            );
          },
        ),
        BlocListener<SelectedBloc, SelectedState>(
          listenWhen: (previous, current) =>
              previous.favoriteMutationErrorMessage !=
              current.favoriteMutationErrorMessage,
          listener: (context, state) {
            final rawMessage = state.favoriteMutationErrorMessage;
            final message = rawMessage == null
                ? null
                : _selectedErrorMessage(context, rawMessage);
            if (message == null || message.isEmpty) return;
            context.showSnackBar(message, isDisplayingError: true);
            context.read<SelectedBloc>().add(
              const ClearSelectedFeedbackEvent(),
            );
          },
        ),
        BlocListener<SelectedBloc, SelectedState>(
          listenWhen: (previous, current) =>
              current.items.isNotEmpty &&
              previous.errorMessage != current.errorMessage,
          listener: (context, state) {
            final message = state.errorMessage;
            if (message == null || message.isEmpty) return;
            context.showSnackBar(
              _selectedErrorMessage(context, message),
              isDisplayingError: true,
            );
          },
        ),
      ],
      child: Stack(
        children: [
          RefreshIndicator(
            onRefresh: _onRefresh,
            child: CustomScrollView(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                AppSliverTopBar.root(title: context.localization.selected),
                const _SelectedSearchBarSection(),
                const SliverToBoxAdapter(child: SizedBox(height: 4)),
                const _SelectedFilterChipsSection(),
                const SliverToBoxAdapter(child: SizedBox(height: 12)),
                const _SelectedResultsHeader(),
                const _SelectedBody(),
              ],
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 24,
            child: BlocSelector<SelectedBloc, SelectedState, bool>(
              selector: (state) => state.items.isNotEmpty,
              builder: (context, hasItems) {
                if (!hasItems) return const SizedBox.shrink();
                return Center(child: MapPillButton(onTap: _openMap));
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _SelectedSearchBarSection extends StatelessWidget {
  const _SelectedSearchBarSection();

  @override
  Widget build(BuildContext context) {
    final query = context.select<SelectedBloc, String>(
      (bloc) => bloc.state.filters.query ?? '',
    );

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
        child: ListingsSearchBar(
          query: query,
          onQueryChanged: (value) =>
              context.read<SelectedBloc>().add(SearchSelectedEvent(value)),
        ),
      ),
    );
  }
}

class _SelectedFilterChipsSection extends StatelessWidget {
  const _SelectedFilterChipsSection();

  @override
  Widget build(BuildContext context) {
    final selection = context
        .select<
          SelectedBloc,
          ({ListingFilters filters, ListingFilterOptions options})
        >(
          (bloc) =>
              (filters: bloc.state.filters, options: bloc.state.filterOptions),
        );

    return SliverToBoxAdapter(
      child: ListingsFilterChips(
        filters: selection.filters,
        filterOptions: selection.options,
        onFiltersChanged: (filters) => context.read<SelectedBloc>().add(
          ApplySelectedFiltersEvent(filters),
        ),
        onOpenFilters: () =>
            _openFilters(context, selection.filters, selection.options),
      ),
    );
  }

  void _openFilters(
    BuildContext context,
    ListingFilters filters,
    ListingFilterOptions options,
  ) {
    final bloc = context.read<SelectedBloc>();
    showListingsFilterSheet(
      context,
      initialFilters: filters,
      filterOptions: options,
      applyToListingsBloc: false,
    ).then((result) {
      if (result == null || bloc.isClosed) return;
      if (result == bloc.state.filters) return;
      bloc.add(ApplySelectedFiltersEvent(result));
    });
  }
}

class _SelectedResultsHeader extends StatelessWidget {
  const _SelectedResultsHeader();

  @override
  Widget build(BuildContext context) {
    final status = context
        .select<SelectedBloc, ({int count, SelectedSort sort})>(
          (bloc) => (count: bloc.state.count, sort: bloc.state.sort),
        );
    final hasItems = context.select<SelectedBloc, bool>(
      (bloc) => bloc.state.items.isNotEmpty,
    );
    if (!hasItems) return const SliverToBoxAdapter(child: SizedBox.shrink());

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
        child: Row(
          children: [
            Expanded(
              child: Text(
                context.localization.selected_result_count(status.count),
                style: AppTextStyles.p3Medium.copyWith(
                  color: context.currentTheme.textNeutralSecondary,
                ),
              ),
            ),
            ListingsFilterDropdownChip<SelectedSort>(
              label: context.localization.selected_sort,
              options: [
                for (final sort in SelectedSort.values)
                  ListingsFilterDropdownOption<SelectedSort>(
                    value: sort,
                    label: _selectedSortLabel(context, sort),
                  ),
              ],
              selected: status.sort,
              selectedLabel: _selectedSortLabel(context, status.sort),
              onSelected: (sort) {
                if (sort == null) return;
                context.read<SelectedBloc>().add(ChangeSelectedSortEvent(sort));
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _SelectedBody extends StatelessWidget {
  const _SelectedBody();

  @override
  Widget build(BuildContext context) {
    final state = context.select<SelectedBloc, SelectedState>(
      (bloc) => bloc.state,
    );

    if ((state.isLoading || !state.hasLoaded) && state.items.isEmpty) {
      return const ListingCardShimmerGrid();
    }

    if (state.errorMessage != null && state.items.isEmpty) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: _SelectedStateView(
          icon: Icons.error_outline,
          title: context.localization.selected_error_title,
          subtitle: _selectedErrorMessage(context, state.errorMessage!),
          actionLabel: context.localization.selected_retry,
          onAction: () => context.read<SelectedBloc>().add(
            const LoadSelectedEvent(refresh: true),
          ),
        ),
      );
    }

    if (state.items.isEmpty) {
      if (state.hasActiveFilters) {
        return SliverFillRemaining(
          hasScrollBody: false,
          child: _SelectedStateView(
            icon: Icons.search_off,
            title: context.localization.selected_no_matches_title,
            subtitle: context.localization.selected_no_matches_subtitle,
            actionLabel: context.localization.selected_clear_filters,
            onAction: () => context.read<SelectedBloc>().add(
              const ClearSelectedFiltersEvent(),
            ),
          ),
        );
      }
      return SliverFillRemaining(
        hasScrollBody: false,
        child: _SelectedStateView(
          icon: Icons.favorite_border,
          title: context.localization.selected_empty_title,
          subtitle: context.localization.selected_empty_subtitle,
        ),
      );
    }

    return SliverMainAxisGroup(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.symmetric(
            horizontal: kListingsFeedHorizontalPadding,
          ),
          sliver: SliverLayoutBuilder(
            builder: (context, constraints) {
              final availableWidth = constraints.crossAxisExtent;
              final crossAxisCount = listingColumns(availableWidth);
              final tileWidth =
                  (availableWidth -
                      kListingsGridSpacing * (crossAxisCount - 1)) /
                  crossAxisCount;
              final mainAxisExtent = tileWidth + kListingInfoExtent;

              return SliverGrid(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: kListingsGridSpacing,
                  mainAxisSpacing: kListingsGridSpacing,
                  mainAxisExtent: mainAxisExtent,
                ),
                delegate: SliverChildBuilderDelegate((context, index) {
                  final item = state.items[index];
                  return ListingCardTile(
                    key: ValueKey('selected_listing_${item.id}'),
                    listing: item,
                    isFavorite: item.isFavorite,
                    imagePriority: index < crossAxisCount * 2
                        ? ImageLoadPriority.high
                        : ImageLoadPriority.normal,
                    onTap: () => context.router.push(
                      ListingDetailRoute(
                        listingId: item.id,
                        initialListing: item,
                      ),
                    ),
                    onFavoriteToggle: () {
                      unawaited(_toggleFavorite(context, item.id));
                    },
                  );
                }, childCount: state.items.length),
              );
            },
          ),
        ),
        if (state.isLoadingMore)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Column(
                children: [
                  const CircularProgressIndicator.adaptive(),
                  const SizedBox(height: 12),
                  Text(
                    context.localization.selected_loading_more,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: context.currentTheme.textNeutralSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        if (state.errorMessage != null &&
            state.failedPage != null &&
            state.items.isNotEmpty)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: _SelectedInlineRetryCard(
                message: _selectedErrorMessage(context, state.errorMessage!),
                onRetry: () {
                  final bloc = context.read<SelectedBloc>();
                  bloc
                    ..add(const ClearSelectedLoadErrorEvent())
                    ..add(const LoadMoreSelectedEvent());
                },
              ),
            ),
          ),
        const SliverToBoxAdapter(child: SizedBox(height: 96)),
      ],
    );
  }

  Future<void> _toggleFavorite(BuildContext context, int listingId) async {
    context.read<SelectedBloc>().add(ToggleSelectedFavoriteEvent(listingId));
  }
}

class _SelectedInlineRetryCard extends StatelessWidget {
  const _SelectedInlineRetryCard({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return MaterialBanner(
      content: Text(message),
      actions: [
        TextButton(
          onPressed: onRetry,
          child: Text(context.localization.selected_retry),
        ),
      ],
    );
  }
}

class _SelectedStateView extends StatelessWidget {
  const _SelectedStateView({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 42, color: context.currentTheme.textBrandPrimary),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: context.currentTheme.textNeutralPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: context.currentTheme.textNeutralSecondary,
              ),
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 20),
              FilledButton(onPressed: onAction, child: Text(actionLabel!)),
            ],
          ],
        ),
      ),
    );
  }
}
