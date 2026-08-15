import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:ideal_mobile/common/theme/text_style/app_text_styles.dart';
import 'package:ideal_mobile/core/services/injection_container.dart';
import 'package:ideal_mobile/i18n/localization.dart';
import 'package:ideal_mobile/presentation/listing_map/bloc/listing_map_bloc.dart';
import 'package:ideal_mobile/presentation/listing_map/bloc/listing_map_event.dart';
import 'package:ideal_mobile/presentation/listing_map/bloc/listing_map_state.dart';
import 'package:ideal_mobile/presentation/listing_map/domain/repositories/listing_map_repository.dart';
import 'package:ideal_mobile/presentation/listing_map/widgets/listing_map_preview_card.dart';
import 'package:ideal_mobile/presentation/listing_map/widgets/listing_map_price_formatter.dart';
import 'package:ideal_mobile/presentation/listing_map/widgets/listing_map_toolbar.dart';
import 'package:ideal_mobile/presentation/listings/domain/entities/listing_card.dart';
import 'package:ideal_mobile/presentation/listings/domain/entities/listing_filter_options.dart';
import 'package:ideal_mobile/presentation/listings/domain/entities/listing_filters.dart';
import 'package:ideal_mobile/presentation/listings/widgets/listings_filter_sheet.dart';
import 'package:ideal_mobile/presentation/map/services/property_map_location_service.dart';
import 'package:ideal_mobile/presentation/map/widgets/property_map_view.dart';
import 'package:ideal_mobile/routes.gr.dart';
import 'package:ideal_mobile/utils/theme/extension/theme_extension.dart';
import 'package:url_launcher/url_launcher.dart';

typedef ListingMapUriLauncher = Future<bool> Function(Uri uri);

@RoutePage()
class ListingDiscoveryMapScreen extends StatefulWidget {
  const ListingDiscoveryMapScreen({
    super.key,
    this.initialFilters = const ListingFilters.empty(),
    this.filterOptions = const ListingFilterOptions.empty(),
    this.seedListings = const [],
    this.onFiltersChanged,
    this.bloc,
    this.providerSelector,
    this.providerViewBuilder,
    this.uriLauncher,
    this.locationService,
  });

  final ListingFilters initialFilters;
  final ListingFilterOptions filterOptions;
  final List<ListingCard> seedListings;
  final ValueChanged<ListingFilters>? onFiltersChanged;

  @visibleForTesting
  final ListingMapBloc? bloc;

  @visibleForTesting
  final PropertyMapProviderSelector? providerSelector;

  @visibleForTesting
  final PropertyMapProviderViewBuilder? providerViewBuilder;

  @visibleForTesting
  final ListingMapUriLauncher? uriLauncher;

  @visibleForTesting
  final PropertyMapLocationService? locationService;

  @override
  State<ListingDiscoveryMapScreen> createState() =>
      _ListingDiscoveryMapScreenState();
}

class _ListingDiscoveryMapScreenState extends State<ListingDiscoveryMapScreen> {
  static const _previewHeight = 360.0;
  static const _tashkentCamera = CameraTarget(
    latitude: 41.311081,
    longitude: 69.240562,
    zoom: 11,
  );

  late final ListingMapBloc _bloc;
  late final bool _ownsBloc;
  late final PageController _previewController;
  late final PropertyMapController _mapController;
  late final PropertyMapLocationService _locationService;
  String? _scheduledPreviewSignature;
  int? _lastSyncedPreviewId;
  bool _returnedFilters = false;
  bool _isLocating = false;
  bool _isFilterSheetOpen = false;

  @override
  void initState() {
    super.initState();
    _ownsBloc = widget.bloc == null;
    _bloc =
        widget.bloc ?? ListingMapBloc(repository: sl<ListingMapRepository>());
    _previewController = PageController();
    _mapController = PropertyMapController();
    _locationService =
        widget.locationService ?? const GeolocatorPropertyMapLocationService();
    _bloc.add(
      InitializeListingMap(
        filters: widget.initialFilters,
        seedListings: widget.seedListings,
      ),
    );
  }

  @override
  void dispose() {
    _returnFiltersIfChanged();
    _previewController.dispose();
    if (_ownsBloc) unawaited(_bloc.close());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ListingMapBloc>.value(
      value: _bloc,
      child: BlocBuilder<ListingMapBloc, ListingMapState>(
        builder: (context, state) {
          _schedulePreviewSync(state);
          final markers = state.items
              .where((item) => item.mapLat != null && item.mapLon != null)
              .map(
                (item) => PropertyMapMarker(
                  id: item.id,
                  latitude: item.mapLat!,
                  longitude: item.mapLon!,
                  label: item.title,
                  priceLabel: _pinPrice(item),
                  semanticsLabel: '${item.title}, ${item.address}',
                  isSelected: item.id == state.selectedListingId,
                ),
              )
              .toList(growable: false);

          return Scaffold(
            backgroundColor: context.currentTheme.bgSurfaceBase,
            body: Stack(
              fit: StackFit.expand,
              children: [
                PropertyMapView(
                  markers: markers,
                  initialCamera: _initialCamera(markers),
                  interactive: true,
                  fitMarkersOnCreate: markers.length > 1,
                  controller: _mapController,
                  providerSelector: widget.providerSelector,
                  providerViewBuilder: widget.providerViewBuilder,
                  onMarkerTap: (id) => context.read<ListingMapBloc>().add(
                    SelectListingMapItem(id),
                  ),
                  onClusterTap: (_) => context.read<ListingMapBloc>().add(
                    const SelectListingMapItem(null),
                  ),
                  onMapTap: (_) => context.read<ListingMapBloc>().add(
                    const SelectListingMapItem(null),
                  ),
                  onCameraSettled: (camera) =>
                      context.read<ListingMapBloc>().add(
                        ListingMapCameraSettled(
                          bounds: camera.bounds,
                          reason: camera.reason,
                        ),
                      ),
                ),
                _topOverlay(context, state),
                if (!state.isLoading &&
                    state.hasLoadedBounds &&
                    state.items.isEmpty &&
                    state.errorMessage == null)
                  Center(
                    child: _MapNotice(
                      key: const ValueKey('listing_map_empty_notice'),
                      icon: TablerIcons.home_off,
                      text: context.localization.listing_map_no_results,
                    ),
                  ),
                if (state.selectedListingId != null)
                  _previewPager(context, state)
                else
                  _listButton(context),
                if (state.selectedListingId == null && !_isFilterSheetOpen)
                  _nearMeButton(context),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _topOverlay(BuildContext context, ListingMapState state) {
    final statusWidgets = <Widget>[
      if (state.showSearchThisArea) _searchAreaButton(context),
      if (state.isLoading)
        _MapNotice(
          key: const ValueKey('listing_map_loading_notice'),
          leading: const SizedBox.square(
            dimension: 22,
            child: CircularProgressIndicator.adaptive(strokeWidth: 3),
          ),
          text: context.localization.listing_map_loading,
        ),
      if (state.errorMessage != null) _errorNotice(context),
      if (state.truncated)
        _MapNotice(
          key: const ValueKey('listing_map_truncated_notice'),
          icon: TablerIcons.zoom_in,
          text: context.localization.listing_map_zoom_in,
        ),
    ];

    return Positioned(
      top: 0,
      right: 0,
      left: 0,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListingMapToolbar(
                key: const ValueKey('listing_map_toolbar'),
                filters: state.filters,
                filterOptions: widget.filterOptions,
                onBack: _close,
                onSearchChanged: (query) => context.read<ListingMapBloc>().add(
                  ChangeListingMapSearch(query),
                ),
                onFiltersChanged: (filters) => context
                    .read<ListingMapBloc>()
                    .add(ChangeListingMapFilters(filters)),
                onOpenFullFilters: () => _openFullFilters(context, state),
              ),
              for (final status in statusWidgets) ...[
                const SizedBox(height: 8),
                Align(alignment: Alignment.topCenter, child: status),
              ],
            ],
          ),
        ),
      ),
    );
  }

  CameraTarget _initialCamera(List<PropertyMapMarker> markers) {
    if (markers.isEmpty) return _tashkentCamera;
    final first = markers.first;
    return CameraTarget(
      latitude: first.latitude,
      longitude: first.longitude,
      zoom: markers.length == 1 ? 14 : 11,
    );
  }

  Widget _searchAreaButton(BuildContext context) {
    return Semantics(
      liveRegion: true,
      child: FilledButton.icon(
        key: const ValueKey('listing_map_search_area'),
        style: FilledButton.styleFrom(minimumSize: const Size(0, 44)),
        onPressed: () =>
            context.read<ListingMapBloc>().add(const SearchListingMapArea()),
        icon: const Icon(TablerIcons.search, size: 18),
        label: Text(context.localization.listing_map_search_this_area),
      ),
    );
  }

  Widget _errorNotice(BuildContext context) {
    return _MapNotice(
      key: const ValueKey('listing_map_error_notice'),
      icon: TablerIcons.alert_circle,
      text: context.localization.listing_map_error_title,
      action: TextButton(
        style: TextButton.styleFrom(minimumSize: const Size(44, 44)),
        onPressed: () =>
            context.read<ListingMapBloc>().add(const RetryListingMap()),
        child: Text(context.localization.listing_map_retry),
      ),
    );
  }

  Widget _listButton(BuildContext context) {
    return Positioned(
      bottom: MediaQuery.paddingOf(context).bottom + 16,
      left: 0,
      right: 0,
      child: Center(
        child: FilledButton.icon(
          key: const ValueKey('listing_map_list_button'),
          style: FilledButton.styleFrom(minimumSize: const Size(0, 44)),
          onPressed: _close,
          icon: const Icon(TablerIcons.list, size: 19),
          label: Text(context.localization.listing_map_list),
        ),
      ),
    );
  }

  Widget _nearMeButton(BuildContext context) {
    return Positioned(
      right: 16,
      bottom: MediaQuery.paddingOf(context).bottom + 16,
      child: Semantics(
        button: true,
        label: context.localization.listing_map_near_me,
        child: Material(
          color: context.currentTheme.bgSurfaceBase2,
          elevation: 8,
          shape: const CircleBorder(),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            key: const ValueKey('listing_map_near_me_button'),
            onTap: _isLocating ? null : _recenterOnUser,
            customBorder: const CircleBorder(),
            child: SizedBox.square(
              dimension: 48,
              child: Center(
                child: _isLocating
                    ? const SizedBox.square(
                        dimension: 20,
                        child: CircularProgressIndicator.adaptive(
                          strokeWidth: 2.5,
                        ),
                      )
                    : const Icon(Icons.my_location, size: 22),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _previewPager(BuildContext context, ListingMapState state) {
    return Positioned(
      right: 16,
      bottom: MediaQuery.paddingOf(context).bottom + 16,
      left: 16,
      height: _previewHeight,
      child: PageView.builder(
        key: const ValueKey('listing_map_previews'),
        controller: _previewController,
        itemCount: state.items.length,
        onPageChanged: (index) => context.read<ListingMapBloc>().add(
          SelectListingMapItem(state.items[index].id),
        ),
        itemBuilder: (context, index) {
          final listing = state.items[index];
          return ListingMapPreviewCard(
            key: ValueKey('listing_map_preview_${listing.id}'),
            listing: listing,
            propertyTypeLabel: _propertyTypeLabel(listing.propertyType),
            onTap: () => context.router.push(
              ListingDetailRoute(
                listingId: listing.id,
                initialListing: listing,
              ),
            ),
            onCall: listing.contactPhone == null
                ? null
                : () => _call(listing.contactPhone!),
          );
        },
      ),
    );
  }

  Future<void> _openFullFilters(
    BuildContext context,
    ListingMapState state,
  ) async {
    setState(() => _isFilterSheetOpen = true);
    try {
      final filters = await showListingsFilterSheet(
        context,
        initialFilters: state.filters,
        filterOptions: widget.filterOptions,
        applyToListingsBloc: false,
      );
      if (filters != null && context.mounted) {
        context.read<ListingMapBloc>().add(ChangeListingMapFilters(filters));
      }
    } finally {
      if (mounted) setState(() => _isFilterSheetOpen = false);
    }
  }

  void _schedulePreviewSync(ListingMapState state) {
    final selectedId = state.selectedListingId;
    if (selectedId == null) {
      _scheduledPreviewSignature = null;
      _lastSyncedPreviewId = null;
      return;
    }
    final signature =
        '$selectedId:${state.items.map((item) => item.id).join(',')}';
    if (_scheduledPreviewSignature == signature) return;
    _scheduledPreviewSignature = signature;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_previewController.hasClients) {
        _scheduledPreviewSignature = null;
        return;
      }
      final currentState = _bloc.state;
      final currentSelectedId = currentState.selectedListingId;
      final index = currentState.items.indexWhere(
        (item) => item.id == currentSelectedId,
      );
      if (index < 0) return;
      final currentPage = _previewController.page?.round();
      if (currentPage == index) {
        _lastSyncedPreviewId = currentSelectedId;
        return;
      }
      if (_lastSyncedPreviewId == null ||
          _lastSyncedPreviewId == currentSelectedId) {
        _previewController.jumpToPage(index);
      } else {
        unawaited(
          _previewController.animateToPage(
            index,
            duration: const Duration(milliseconds: 240),
            curve: Curves.easeOutCubic,
          ),
        );
      }
      _lastSyncedPreviewId = currentSelectedId;
    });
  }

  Future<void> _call(String phone) async {
    try {
      final uri = Uri(scheme: 'tel', path: phone);
      final launched = await (widget.uriLauncher?.call(uri) ?? launchUrl(uri));
      if (!launched && mounted) _showCallFailure();
    } on Object {
      if (mounted) _showCallFailure();
    }
  }

  Future<void> _recenterOnUser() async {
    if (_isLocating) return;
    setState(() => _isLocating = true);
    try {
      final coordinate = await _locationService.getCurrentLocation();
      if (!mounted) return;
      if (coordinate == null) {
        _showLocationFailure();
        return;
      }
      await _mapController.moveCamera(
        CameraTarget(
          latitude: coordinate.latitude,
          longitude: coordinate.longitude,
          zoom: 14,
        ),
      );
    } on Object {
      if (mounted) _showLocationFailure();
    } finally {
      if (mounted) setState(() => _isLocating = false);
    }
  }

  void _showLocationFailure() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(context.localization.listing_map_location_unavailable),
      ),
    );
  }

  void _showCallFailure() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(context.localization.listing_map_call_failed)),
    );
  }

  void _close() {
    _returnFiltersIfChanged();
    context.router.maybePop();
  }

  void _returnFiltersIfChanged() {
    final filters = _bloc.state.filters;
    if (_returnedFilters || filters == widget.initialFilters) return;
    _returnedFilters = true;
    widget.onFiltersChanged?.call(filters);
  }

  String _propertyTypeLabel(String value) {
    for (final choice in widget.filterOptions.propertyTypes) {
      if (choice.value == value) return choice.label;
    }
    return value
        .replaceAll('_', ' ')
        .split(' ')
        .where((part) => part.isNotEmpty)
        .map((part) => '${part[0].toUpperCase()}${part.substring(1)}')
        .join(' ');
  }
}

class _MapNotice extends StatelessWidget {
  const _MapNotice({
    super.key,
    required this.text,
    this.icon,
    this.leading,
    this.action,
  }) : assert(icon != null || leading != null);

  final IconData? icon;
  final Widget? leading;
  final String text;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      liveRegion: true,
      label: text,
      child: Material(
        color: context.currentTheme.bgSurfaceBase.withValues(alpha: 0.94),
        elevation: 6,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              leading ?? Icon(icon, size: 20),
              const SizedBox(width: 8),
              Flexible(
                child: ExcludeSemantics(
                  child: Text(
                    text,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.p3Medium.copyWith(
                      color: context.currentTheme.textNeutralPrimary,
                    ),
                  ),
                ),
              ),
              if (action != null) ...[const SizedBox(width: 4), action!],
            ],
          ),
        ),
      ),
    );
  }
}

String? _pinPrice(ListingCard item) {
  if (item.price == null) return null;
  return formatListingMapPrice(item.price, item.currency);
}
