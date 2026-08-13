import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ideal_mobile/common/theme/text_style/app_text_styles.dart';
import 'package:ideal_mobile/constants/integration_test_keys.dart';
import 'package:ideal_mobile/i18n/localization.dart';
import 'package:ideal_mobile/presentation/listing_detail/bloc/listing_detail_bloc.dart';
import 'package:ideal_mobile/presentation/listing_detail/bloc/listing_detail_event.dart';
import 'package:ideal_mobile/presentation/listing_detail/domain/entities/listing_detail.dart';
import 'package:ideal_mobile/presentation/booking/domain/entities/booking.dart';
import 'package:ideal_mobile/presentation/listings/domain/entities/listing_card.dart';
import 'package:ideal_mobile/presentation/listing_detail/widgets/listing_detail_about.dart';
import 'package:ideal_mobile/presentation/listing_detail/widgets/listing_detail_amenities.dart';
import 'package:ideal_mobile/presentation/listing_detail/widgets/listing_detail_bottom_bar.dart';
import 'package:ideal_mobile/presentation/listing_detail/widgets/listing_detail_error.dart';
import 'package:ideal_mobile/presentation/listing_detail/widgets/listing_detail_hero.dart';
import 'package:ideal_mobile/presentation/listing_detail/widgets/listing_detail_map.dart';
import 'package:ideal_mobile/presentation/listing_detail/widgets/listing_detail_neighborhood.dart';
import 'package:ideal_mobile/presentation/listing_detail/widgets/listing_detail_not_found.dart';
import 'package:ideal_mobile/presentation/listing_detail/widgets/listing_detail_shimmer.dart';
import 'package:ideal_mobile/presentation/listing_detail/widgets/listing_detail_spec_chips.dart';
import 'package:ideal_mobile/presentation/listing_detail/widgets/listing_detail_thumb_strip.dart';
import 'package:ideal_mobile/presentation/listing_detail/widgets/listing_detail_title_block.dart';
import 'package:ideal_mobile/presentation/listing_detail/widgets/listing_detail_trust_card.dart';
import 'package:ideal_mobile/presentation/map/listing_map_screen.dart';
import 'package:ideal_mobile/utils/theme/extension/theme_extension.dart';

class ListingDetailBody extends StatelessWidget {
  const ListingDetailBody({super.key, this.listingId});

  final int? listingId;

  @override
  Widget build(BuildContext context) {
    final isLoading = context.select<ListingDetailBloc, bool>(
      (bloc) => bloc.state.isLoading,
    );
    final errorMessage = context.select<ListingDetailBloc, String?>(
      (bloc) => bloc.state.errorMessage,
    );
    final detail = context.select<ListingDetailBloc, ListingDetail?>(
      (bloc) => bloc.state.detail,
    );
    final preview = context.select<ListingDetailBloc, ListingCard?>(
      (bloc) => bloc.state.preview,
    );
    final isFreshDetail = context.select<ListingDetailBloc, bool>(
      (bloc) => bloc.state.isFreshDetail,
    );

    if (isLoading && detail == null && preview == null) {
      return Scaffold(
        key: keys.listingDetail.screen,
        backgroundColor: context.currentTheme.bgSurfaceBase,
        body: const SafeArea(child: ListingDetailShimmer()),
      );
    }

    if (errorMessage != null && detail == null && preview == null) {
      return Scaffold(
        key: keys.listingDetail.screen,
        backgroundColor: context.currentTheme.bgSurfaceBase,
        body: SafeArea(
          child: ListingDetailError(
            message: errorMessage,
            onRetry: () => _retry(context, detail),
          ),
        ),
      );
    }

    final visibleDetail = detail ?? _previewDetail(preview);
    if (visibleDetail == null) {
      return Scaffold(
        key: keys.listingDetail.screen,
        backgroundColor: context.currentTheme.bgSurfaceBase,
        body: const SafeArea(child: ListingDetailNotFound()),
      );
    }

    return Scaffold(
      key: keys.listingDetail.screen,
      backgroundColor: context.currentTheme.bgSurfaceBase,
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                _buildScrollContent(context, visibleDetail),
                if (isLoading && !isFreshDetail)
                  const Positioned(
                    top: 8,
                    right: 16,
                    child: SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                if (errorMessage != null)
                  Positioned(
                    right: 16,
                    bottom: 12,
                    child: TextButton(
                      onPressed: () => _retry(context, visibleDetail),
                      child: Text(context.localization.listing_detail_retry),
                    ),
                  ),
              ],
            ),
          ),
          ListingDetailBottomBar(
            detail: visibleDetail,
            actionsEnabled: isFreshDetail,
          ),
        ],
      ),
    );
  }

  Widget _buildScrollContent(BuildContext context, ListingDetail detail) {
    final sections = <Widget>[
      ListingDetailTitleBlock(detail: detail),
      const SizedBox(height: 14),
      ListingDetailSpecChips(detail: detail),
    ];

    if (!context.read<ListingDetailBloc>().state.isFreshDetail) {
      // Feed cards intentionally lack these detail-only fields. Keep their
      // space stable while an authoritative response is pending.
      sections.addAll(const [
        SizedBox(height: 14),
        _PreviewSectionPlaceholder(),
        SizedBox(height: 14),
        _PreviewSectionPlaceholder(lines: 2),
      ]);
    }

    if (detail.verificationIsVerified &&
        detail.verificationChecklist.isNotEmpty) {
      sections.add(const SizedBox(height: 14));
      sections.add(ListingDetailTrustCard(detail: detail));
    }

    if (detail.description?.trim().isNotEmpty ?? false) {
      sections.add(const SizedBox(height: 14));
      sections.add(ListingDetailAbout(description: detail.description!));
    }

    if (detail.amenities.isNotEmpty) {
      sections.add(const SizedBox(height: 14));
      sections.add(ListingDetailAmenities(amenities: detail.amenities));
    }

    final hasCoordinates = detail.mapLat != null && detail.mapLon != null;

    if (detail.district?.trim().isNotEmpty ?? false) {
      sections.add(const SizedBox(height: 14));
      sections.add(
        ListingDetailNeighborhood(
          district: detail.district,
          onTap: hasCoordinates ? () => _openMap(context, detail) : null,
        ),
      );
    }

    if (hasCoordinates) {
      sections.add(const SizedBox(height: 14));
      sections.add(
        ListingDetailMap(
          detail: detail,
          onTap: () => _openMap(context, detail),
        ),
      );
    }

    sections.add(const SizedBox(height: 14));
    sections.add(_buildFootnote(context, detail));

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(child: ListingDetailHero(detail: detail)),
        SliverToBoxAdapter(child: ListingDetailThumbStrip(detail: detail)),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: sections,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFootnote(BuildContext context, ListingDetail detail) {
    final segments = <String>[
      context.localization.listing_detail_no_obligation,
    ];

    if (detail.depositAmount != null) {
      segments.add(
        context.localization.listing_detail_deposit(
          _formatAmount(detail.depositAmount!, detail.currency),
        ),
      );
    }

    if (detail.minimumStay != null) {
      segments.add(
        context.localization.listing_detail_minimum_stay(detail.minimumStay!),
      );
    }

    return Text(
      segments.join(' · '),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      textAlign: TextAlign.left,
      style: AppTextStyles.p4Regular.copyWith(
        color: context.currentTheme.textNeutralSecondary,
      ),
    );
  }

  void _retry(BuildContext context, ListingDetail? detail) {
    final id = listingId ?? detail?.id;
    if (id == null) return;

    context.read<ListingDetailBloc>().add(RetryListingDetailEvent(id));
  }

  void _openMap(BuildContext context, ListingDetail detail) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => ListingMapScreen(detail: detail)),
    );
  }

  String _formatAmount(double amount, String currency) {
    final value = amount == amount.roundToDouble()
        ? amount.toInt().toString()
        : amount.toString();

    return currency == 'USD' ? '\$$value' : '$value $currency';
  }

  ListingDetail? _previewDetail(ListingCard? card) {
    if (card == null) return null;
    return ListingDetail(
      id: card.id,
      propertyId: card.propertyId,
      title: card.title,
      district: card.district,
      address: card.address,
      propertyType: card.propertyType,
      rooms: card.rooms,
      areaSqm: card.areaSqm,
      floor: card.floor,
      totalFloors: card.totalFloors,
      furnishing: card.furnishing,
      price: card.price,
      currency: card.currency,
      tariff: card.tariff,
      isVerified: card.isVerified,
      isFeatured: card.isFeatured,
      score: card.score,
      reviewCount: card.reviewCount,
      mapLat: card.mapLat,
      mapLon: card.mapLon,
      description: null,
      depositAmount: null,
      minimumStay: null,
      priceIncludes: const [],
      responseTime: '',
      createdAt: DateTime.fromMillisecondsSinceEpoch(0),
      photos: card.coverImageUrl == null
          ? const []
          : [
              ListingPhoto(
                id: -card.id,
                imageUrl: card.coverImageUrl!,
                previewUrl: card.coverPreviewUrl,
                displayUrl: card.coverDisplayUrl,
                caption: null,
                isPrimary: true,
                sortOrder: 0,
              ),
            ],
      amenities: const [],
      verificationIsVerified: false,
      verificationChecklist: const [],
      canMessage: false,
      contactPhone: null,
      booking: const BookingEligibility.ineligible(),
    );
  }
}

class _PreviewSectionPlaceholder extends StatelessWidget {
  const _PreviewSectionPlaceholder({this.lines = 3});

  final int lines;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: context.currentTheme.bgSurfaceBase2,
      borderRadius: BorderRadius.circular(12),
    ),
    child: SizedBox(height: 18.0 * lines + 22),
  );
}
