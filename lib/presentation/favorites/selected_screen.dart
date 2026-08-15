import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ideal_mobile/i18n/localization.dart';
import 'package:ideal_mobile/presentation/favorites/bloc/selected_bloc.dart';
import 'package:ideal_mobile/presentation/favorites/bloc/selected_event.dart';
import 'package:ideal_mobile/presentation/favorites/bloc/selected_state.dart';
import 'package:ideal_mobile/presentation/listings/widgets/listing_card.dart';
import 'package:ideal_mobile/presentation/listings/widgets/listing_card_shimmer.dart';
import 'package:ideal_mobile/presentation/listings/widgets/listings_feed.dart';
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

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
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
      child: RefreshIndicator(
        onRefresh: _onRefresh,
        child: CustomScrollView(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            AppSliverTopBar.root(title: context.localization.selected),
            const _SelectedBody(),
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
              final mainAxisExtent = tileWidth * 210 / 388 + kListingInfoExtent;

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
        const SliverToBoxAdapter(child: SizedBox(height: 24)),
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
