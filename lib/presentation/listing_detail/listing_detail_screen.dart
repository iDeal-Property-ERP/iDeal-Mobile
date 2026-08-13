import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ideal_mobile/core/services/injection_container.dart';
import 'package:ideal_mobile/i18n/localization.dart';
import 'package:ideal_mobile/presentation/listing_detail/bloc/listing_detail_bloc.dart';
import 'package:ideal_mobile/presentation/listing_detail/bloc/listing_detail_event.dart';
import 'package:ideal_mobile/presentation/listing_detail/bloc/listing_detail_state.dart';
import 'package:ideal_mobile/presentation/listing_detail/widgets/listing_detail_body.dart';
import 'package:ideal_mobile/presentation/listings/domain/entities/listing_card.dart';
import 'package:ideal_mobile/utils/extensions/build_context_ext.dart';

@RoutePage()
class ListingDetailScreen extends StatelessWidget {
  const ListingDetailScreen({
    super.key,
    @PathParam('listingId') required this.listingId,
    this.initialListing,
  });

  final int listingId;
  final ListingCard? initialListing;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ListingDetailBloc>(
      create: (_) => ListingDetailBloc(getListingDetail: sl())
        ..add(
          LoadListingDetailEvent(
            listingId,
            initialListing: initialListing?.id == listingId
                ? initialListing
                : null,
          ),
        ),
      child: BlocListener<ListingDetailBloc, ListingDetailState>(
        listener: _listenStateChanged,
        child: ListingDetailBody(listingId: listingId),
      ),
    );
  }

  void _listenStateChanged(BuildContext context, ListingDetailState state) {
    if (state is ListingDetailErrorState) {
      context.showSnackBar(
        state.errorMessage ?? context.localization.opps_something_went_wrong,
      );
    }
  }
}
