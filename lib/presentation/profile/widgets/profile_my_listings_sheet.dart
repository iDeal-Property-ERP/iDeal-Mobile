import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:ideal_mobile/common/theme/text_style/app_text_styles.dart';
import 'package:ideal_mobile/core/services/injection_container.dart';
import 'package:ideal_mobile/i18n/localization.dart';
import 'package:ideal_mobile/presentation/listings/widgets/listing_card_image.dart';
import 'package:ideal_mobile/presentation/my_listings/bloc/my_listings_bloc.dart';
import 'package:ideal_mobile/presentation/my_listings/bloc/my_listings_event.dart';
import 'package:ideal_mobile/presentation/my_listings/bloc/my_listings_state.dart';
import 'package:ideal_mobile/presentation/my_listings/domain/entities/my_listing_item.dart';
import 'package:ideal_mobile/routes.gr.dart';
import 'package:ideal_mobile/utils/theme/extension/theme_extension.dart';
import 'package:shimmer/shimmer.dart';

class ProfileMyListingsSheet extends StatelessWidget {
  const ProfileMyListingsSheet({super.key});

  static const Color _accentColor = Color(0xFF3B82F6);
  static const Color _pendingColor = Color(0xFFD97706);
  static const Color _rentedColor = Color(0xFF16A34A);
  static const Color _rejectedColor = Color(0xFFDC2626);

  static Future<void> show(BuildContext context, {MyListingsBloc? bloc}) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.currentTheme.bgSurfaceSheet,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.0)),
      ),
      builder: (_) => BlocProvider<MyListingsBloc>(
        create: (_) =>
            (bloc ?? sl<MyListingsBloc>())..add(const LoadMyListingsEvent()),
        child: const ProfileMyListingsSheet(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.82,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Column(
          children: [
            const SizedBox(height: 12.0),
            Center(
              child: Container(
                width: 40.0,
                height: 4.0,
                decoration: BoxDecoration(
                  color: context.currentTheme.strokeNeutralLight200,
                  borderRadius: BorderRadius.circular(4.0),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20.0, 16.0, 16.0, 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    context.localization.my_listings,
                    style: AppTextStyles.h6Bold.copyWith(
                      color: context.currentTheme.textNeutralPrimary,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(TablerIcons.x),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            // Filter chips
            BlocBuilder<MyListingsBloc, MyListingsState>(
              buildWhen: (p, c) =>
                  p.stats != c.stats ||
                  p.selectedStatus != c.selectedStatus ||
                  p.isLoadingListings != c.isLoadingListings,
              builder: (context, state) {
                final stats = state.stats;
                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  child: Row(
                    children: [
                      _FilterChip(
                        label: context.localization.view_all,
                        count: stats.totalCount,
                        isSelected: state.selectedStatus == 'all',
                        onTap: () => context.read<MyListingsBloc>().add(
                          const ChangeStatusFilterEvent('all'),
                        ),
                      ),
                      const SizedBox(width: 8.0),
                      _FilterChip(
                        label: context.localization.status_approved,
                        count: stats.approvedCount,
                        isSelected: state.selectedStatus == 'approved',
                        onTap: () => context.read<MyListingsBloc>().add(
                          const ChangeStatusFilterEvent('approved'),
                        ),
                      ),
                      const SizedBox(width: 8.0),
                      _FilterChip(
                        label: context.localization.status_pending,
                        count: stats.pendingCount,
                        isSelected: state.selectedStatus == 'pending',
                        onTap: () => context.read<MyListingsBloc>().add(
                          const ChangeStatusFilterEvent('pending'),
                        ),
                      ),
                      const SizedBox(width: 8.0),
                      _FilterChip(
                        label: context.localization.status_rented,
                        count: stats.rentedCount,
                        isSelected: state.selectedStatus == 'rented',
                        onTap: () => context.read<MyListingsBloc>().add(
                          const ChangeStatusFilterEvent('rented'),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            const Divider(height: 1.0),
            Expanded(
              child: BlocBuilder<MyListingsBloc, MyListingsState>(
                buildWhen: (p, c) =>
                    p.listings != c.listings ||
                    p.isLoadingListings != c.isLoadingListings ||
                    p.errorMessage != c.errorMessage,
                builder: (context, state) {
                  if (state.isLoadingListings) {
                    return _LoadingShimmer(scrollController: scrollController);
                  }

                  if (state.errorMessage != null) {
                    return _ErrorState(
                      message: state.errorMessage!,
                      onRetry: () => context.read<MyListingsBloc>().add(
                        const RefreshMyListingsEvent(),
                      ),
                    );
                  }

                  if (state.listings.isEmpty) {
                    return _EmptyState(scrollController: scrollController);
                  }

                  return RefreshIndicator(
                    onRefresh: () async {
                      context.read<MyListingsBloc>().add(
                        const RefreshMyListingsEvent(),
                      );
                    },
                    child: ListView.builder(
                      controller: scrollController,
                      padding: const EdgeInsets.all(16.0),
                      itemCount: state.listings.length,
                      itemBuilder: (context, index) {
                        return _ListingCard(item: state.listings[index]);
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

class _ListingCard extends StatelessWidget {
  const _ListingCard({required this.item});

  final MyListingItem item;

  static const Color _accentColor = ProfileMyListingsSheet._accentColor;
  static const Color _pendingColor = ProfileMyListingsSheet._pendingColor;
  static const Color _rentedColor = ProfileMyListingsSheet._rentedColor;
  static const Color _rejectedColor = ProfileMyListingsSheet._rejectedColor;

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final cardBg = isDark ? context.currentTheme.bgSurfaceBase2 : Colors.white;

    Color statusColor;
    switch (item.status) {
      case 'approved':
        statusColor = _accentColor;
      case 'pending':
        statusColor = _pendingColor;
      case 'rented':
        statusColor = _rentedColor;
      case 'rejected':
        statusColor = _rejectedColor;
      default:
        statusColor = context.currentTheme.textNeutralSecondary;
    }

    final priceText = item.price != null
        ? '${item.price!.toStringAsFixed(0)} ${item.currency} / mo'
        : '—';

    return GestureDetector(
      onTap: () => _onTap(context),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12.0),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(16.0),
          border: Border.all(color: context.currentTheme.strokeNeutralLight200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cover image
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(15.0),
              ),
              child: SizedBox(
                height: 140,
                child: ListingCardImage(
                  imageUrl: item.coverImageUrl,
                  previewUrl: item.coverPreviewUrl,
                  displayUrl: item.coverDisplayUrl,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(14.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.title,
                              style: AppTextStyles.p2SemiBold.copyWith(
                                color: context.currentTheme.textNeutralPrimary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (item.address != null ||
                                item.district != null) ...[
                              const SizedBox(height: 3.0),
                              Text(
                                item.district ?? item.address ?? '',
                                style: AppTextStyles.p4Regular.copyWith(
                                  color:
                                      context.currentTheme.textNeutralSecondary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ],
                        ),
                      ),
                      // Status badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10.0,
                          vertical: 4.0,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: Text(
                          item.statusDisplay,
                          style: AppTextStyles.c1SemiBold.copyWith(
                            color: statusColor,
                            fontSize: 11.0,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        priceText,
                        style: AppTextStyles.p2Bold.copyWith(
                          color: _accentColor,
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            TablerIcons.eye,
                            size: 14,
                            color: context.currentTheme.textNeutralSecondary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${item.viewsCount}',
                            style: AppTextStyles.p4Regular.copyWith(
                              color: context.currentTheme.textNeutralSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  if (item.isRejected && item.rejectionReason != null) ...[
                    const SizedBox(height: 8.0),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(10.0),
                      decoration: BoxDecoration(
                        color: _rejectedColor.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Text(
                        item.rejectionReason!,
                        style: AppTextStyles.p4Regular.copyWith(
                          color: _rejectedColor,
                          fontSize: 12,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onTap(BuildContext context) {
    if (item.isApproved && item.id != null) {
      Navigator.of(context).pop();
      context.router.push(ListingDetailRoute(listingId: item.id!));
    } else {
      _showStatusSheet(context);
    }
  }

  void _showStatusSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: context.currentTheme.bgSurfaceSheet,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.0)),
      ),
      builder: (_) => _ListingStatusSheet(item: item),
    );
  }
}

class _ListingStatusSheet extends StatelessWidget {
  const _ListingStatusSheet({required this.item});

  final MyListingItem item;

  @override
  Widget build(BuildContext context) {
    final theme = context.currentTheme;
    final loc = context.localization;

    Color statusColor;
    IconData statusIcon;
    String description;

    switch (item.status) {
      case 'pending':
        statusColor = const Color(0xFFD97706);
        statusIcon = TablerIcons.clock;
        description = loc.status_review_desc;
      case 'rented':
        statusColor = const Color(0xFF16A34A);
        statusIcon = TablerIcons.home_check;
        description = item.statusDisplay;
      case 'rejected':
        statusColor = const Color(0xFFDC2626);
        statusIcon = TablerIcons.circle_x;
        description = item.rejectionReason ?? item.statusDisplay;
      default:
        statusColor = theme.textNeutralSecondary;
        statusIcon = TablerIcons.info_circle;
        description = item.statusDisplay;
    }

    return Padding(
      padding: EdgeInsets.fromLTRB(
        24,
        24,
        24,
        24 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(statusIcon, color: statusColor, size: 28),
          ),
          const SizedBox(height: 16),
          Text(
            item.title,
            style: AppTextStyles.h6Bold.copyWith(
              color: theme.textNeutralPrimary,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              item.statusDisplay,
              style: AppTextStyles.c1SemiBold.copyWith(color: statusColor),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            description,
            style: AppTextStyles.p3Regular.copyWith(
              color: theme.textNeutralSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'OK',
                style: AppTextStyles.p2SemiBold.copyWith(
                  color: const Color(0xFF3B82F6),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.scrollController});

  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    final theme = context.currentTheme;
    return ListView(
      controller: scrollController,
      padding: const EdgeInsets.all(32),
      children: [
        const SizedBox(height: 40),
        Icon(
          TablerIcons.building_off,
          size: 56,
          color: theme.textNeutralDisable,
        ),
        const SizedBox(height: 16),
        Text(
          context.localization.no_listings_found,
          style: AppTextStyles.p2SemiBold.copyWith(
            color: theme.textNeutralSecondary,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        Center(
          child: ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.router.push(const ListPropertyWizardRoute());
            },
            child: Text(context.localization.list_first_property),
          ),
        ),
      ],
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              TablerIcons.wifi_off,
              size: 48,
              color: context.currentTheme.textNeutralDisable,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: AppTextStyles.p3Regular.copyWith(
                color: context.currentTheme.textNeutralSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}

class _LoadingShimmer extends StatelessWidget {
  const _LoadingShimmer({required this.scrollController});

  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    final base = context.currentTheme.bgNeutralLight100;
    final highlight = base.withValues(alpha: 0.5);

    return Shimmer.fromColors(
      baseColor: base,
      highlightColor: highlight,
      child: ListView.builder(
        controller: scrollController,
        padding: const EdgeInsets.all(16),
        itemCount: 4,
        itemBuilder: (_, _) => Container(
          margin: const EdgeInsets.only(bottom: 12),
          height: 200,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.count,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final int count;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 7.0),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF0F2A5C)
              : (context.isDark
                    ? context.currentTheme.bgSurfaceBase2
                    : const Color(0xFFF0F2F6)),
          borderRadius: BorderRadius.circular(20.0),
        ),
        child: Text(
          '$label · $count',
          style: AppTextStyles.p4SemiBold.copyWith(
            color: isSelected
                ? Colors.white
                : context.currentTheme.textNeutralPrimary,
            fontSize: 12.0,
          ),
        ),
      ),
    );
  }
}
