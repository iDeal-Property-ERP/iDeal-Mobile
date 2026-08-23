// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _i34;

import 'package:auto_route/auto_route.dart' as _i23;
import 'package:collection/collection.dart' as _i33;
import 'package:flutter/material.dart' as _i24;
import 'package:ideal_mobile/presentation/booking/booking_screen.dart' as _i1;
import 'package:ideal_mobile/presentation/booking/booking_status_screen.dart'
    as _i2;
import 'package:ideal_mobile/presentation/booking/bookings_screen.dart' as _i3;
import 'package:ideal_mobile/presentation/booking/domain/entities/booking.dart'
    as _i25;
import 'package:ideal_mobile/presentation/booking/payment_return_screen.dart'
    as _i18;
import 'package:ideal_mobile/presentation/change_theme/change_theme_screen.dart'
    as _i4;
import 'package:ideal_mobile/presentation/chat/bloc/chats_bloc.dart' as _i28;
import 'package:ideal_mobile/presentation/chat/bloc/listing_chat_conversation_bloc.dart'
    as _i27;
import 'package:ideal_mobile/presentation/chat/chat_conversation_screen.dart'
    as _i5;
import 'package:ideal_mobile/presentation/chat/chats_screen.dart' as _i6;
import 'package:ideal_mobile/presentation/chat/domain/entities/chat_conversation.dart'
    as _i26;
import 'package:ideal_mobile/presentation/home/home_screen.dart' as _i7;
import 'package:ideal_mobile/presentation/initial/initial_screen.dart' as _i8;
import 'package:ideal_mobile/presentation/list_property/list_property_wizard_screen.dart'
    as _i9;
import 'package:ideal_mobile/presentation/listing_detail/listing_detail_screen.dart'
    as _i10;
import 'package:ideal_mobile/presentation/listing_map/bloc/listing_map_bloc.dart'
    as _i30;
import 'package:ideal_mobile/presentation/listing_map/listing_discovery_map_screen.dart'
    as _i11;
import 'package:ideal_mobile/presentation/listings/domain/entities/listing_card.dart'
    as _i29;
import 'package:ideal_mobile/presentation/listings/domain/entities/listing_filter_options.dart'
    as _i13;
import 'package:ideal_mobile/presentation/listings/domain/entities/listing_filters.dart'
    as _i12;
import 'package:ideal_mobile/presentation/login/bloc/login_bloc.dart' as _i40;
import 'package:ideal_mobile/presentation/login/screens/login_with_phone_number/login_with_phone_number_screen.dart'
    as _i14;
import 'package:ideal_mobile/presentation/login/screens/phone_num_otp_screen/phone_number_otp_screen.dart'
    as _i20;
import 'package:ideal_mobile/presentation/map/services/property_map_location_service.dart'
    as _i32;
import 'package:ideal_mobile/presentation/map/widgets/property_map_view.dart'
    as _i31;
import 'package:ideal_mobile/presentation/notification_settings/notification_settings_screen.dart'
    as _i16;
import 'package:ideal_mobile/presentation/notifications/bloc/notification_bloc.dart'
    as _i38;
import 'package:ideal_mobile/presentation/notifications/domain/usecases/get_notification_settings.dart'
    as _i36;
import 'package:ideal_mobile/presentation/notifications/domain/usecases/update_notification_settings.dart'
    as _i37;
import 'package:ideal_mobile/presentation/notifications/notifications_screen.dart'
    as _i17;
import 'package:ideal_mobile/presentation/profile/bloc/profile_bloc.dart'
    as _i39;
import 'package:ideal_mobile/presentation/profile/personal_details_screen.dart'
    as _i19;
import 'package:ideal_mobile/presentation/settings/settings_screen.dart'
    as _i21;
import 'package:ideal_mobile/presentation/ssl_pinning/ssl_connection_failed_screen.dart'
    as _i22;
import 'package:ideal_mobile/services/push/notification_permission_status.dart'
    as _i35;
import 'package:ideal_mobile/widgets/attachment_view.dart' as _i15;

/// generated route for
/// [_i1.BookingScreen]
class BookingRoute extends _i23.PageRouteInfo<BookingRouteArgs> {
  BookingRoute({
    _i24.Key? key,
    required int listingId,
    _i25.BookingOptions? initialOptions,
    List<_i23.PageRouteInfo>? children,
  }) : super(
         BookingRoute.name,
         args: BookingRouteArgs(
           key: key,
           listingId: listingId,
           initialOptions: initialOptions,
         ),
         rawPathParams: {'listingId': listingId},
         initialChildren: children,
       );

  static const String name = 'BookingRoute';

  static _i23.PageInfo page = _i23.PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<BookingRouteArgs>(
        orElse: () =>
            BookingRouteArgs(listingId: pathParams.getInt('listingId')),
      );
      return _i1.BookingScreen(
        key: args.key,
        listingId: args.listingId,
        initialOptions: args.initialOptions,
      );
    },
  );
}

class BookingRouteArgs {
  const BookingRouteArgs({
    this.key,
    required this.listingId,
    this.initialOptions,
  });

  final _i24.Key? key;

  final int listingId;

  final _i25.BookingOptions? initialOptions;

  @override
  String toString() {
    return 'BookingRouteArgs{key: $key, listingId: $listingId, initialOptions: $initialOptions}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! BookingRouteArgs) return false;
    return key == other.key &&
        listingId == other.listingId &&
        initialOptions == other.initialOptions;
  }

  @override
  int get hashCode =>
      key.hashCode ^ listingId.hashCode ^ initialOptions.hashCode;
}

/// generated route for
/// [_i2.BookingStatusScreen]
class BookingStatusRoute extends _i23.PageRouteInfo<BookingStatusRouteArgs> {
  BookingStatusRoute({
    _i24.Key? key,
    required int bookingId,
    _i25.PaymentCheckout? initialCheckout,
    List<_i23.PageRouteInfo>? children,
  }) : super(
         BookingStatusRoute.name,
         args: BookingStatusRouteArgs(
           key: key,
           bookingId: bookingId,
           initialCheckout: initialCheckout,
         ),
         rawPathParams: {'bookingId': bookingId},
         initialChildren: children,
       );

  static const String name = 'BookingStatusRoute';

  static _i23.PageInfo page = _i23.PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<BookingStatusRouteArgs>(
        orElse: () =>
            BookingStatusRouteArgs(bookingId: pathParams.getInt('bookingId')),
      );
      return _i2.BookingStatusScreen(
        key: args.key,
        bookingId: args.bookingId,
        initialCheckout: args.initialCheckout,
      );
    },
  );
}

class BookingStatusRouteArgs {
  const BookingStatusRouteArgs({
    this.key,
    required this.bookingId,
    this.initialCheckout,
  });

  final _i24.Key? key;

  final int bookingId;

  final _i25.PaymentCheckout? initialCheckout;

  @override
  String toString() {
    return 'BookingStatusRouteArgs{key: $key, bookingId: $bookingId, initialCheckout: $initialCheckout}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! BookingStatusRouteArgs) return false;
    return key == other.key &&
        bookingId == other.bookingId &&
        initialCheckout == other.initialCheckout;
  }

  @override
  int get hashCode =>
      key.hashCode ^ bookingId.hashCode ^ initialCheckout.hashCode;
}

/// generated route for
/// [_i3.BookingsScreen]
class BookingsRoute extends _i23.PageRouteInfo<void> {
  const BookingsRoute({List<_i23.PageRouteInfo>? children})
    : super(BookingsRoute.name, initialChildren: children);

  static const String name = 'BookingsRoute';

  static _i23.PageInfo page = _i23.PageInfo(
    name,
    builder: (data) {
      return const _i3.BookingsScreen();
    },
  );
}

/// generated route for
/// [_i4.ChangeThemeScreen]
class ChangeThemeRoute extends _i23.PageRouteInfo<void> {
  const ChangeThemeRoute({List<_i23.PageRouteInfo>? children})
    : super(ChangeThemeRoute.name, initialChildren: children);

  static const String name = 'ChangeThemeRoute';

  static _i23.PageInfo page = _i23.PageInfo(
    name,
    builder: (data) {
      return const _i4.ChangeThemeScreen();
    },
  );
}

/// generated route for
/// [_i5.ChatConversationScreen]
class ChatConversationRoute
    extends _i23.PageRouteInfo<ChatConversationRouteArgs> {
  ChatConversationRoute({
    _i24.Key? key,
    required int conversationId,
    _i26.ChatConversation? initialConversation,
    _i27.ListingChatConversationBloc? bloc,
    List<_i23.PageRouteInfo>? children,
  }) : super(
         ChatConversationRoute.name,
         args: ChatConversationRouteArgs(
           key: key,
           conversationId: conversationId,
           initialConversation: initialConversation,
           bloc: bloc,
         ),
         rawPathParams: {'conversationId': conversationId},
         initialChildren: children,
       );

  static const String name = 'ChatConversationRoute';

  static _i23.PageInfo page = _i23.PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<ChatConversationRouteArgs>(
        orElse: () => ChatConversationRouteArgs(
          conversationId: pathParams.getInt('conversationId'),
        ),
      );
      return _i5.ChatConversationScreen(
        key: args.key,
        conversationId: args.conversationId,
        initialConversation: args.initialConversation,
        bloc: args.bloc,
      );
    },
  );
}

class ChatConversationRouteArgs {
  const ChatConversationRouteArgs({
    this.key,
    required this.conversationId,
    this.initialConversation,
    this.bloc,
  });

  final _i24.Key? key;

  final int conversationId;

  final _i26.ChatConversation? initialConversation;

  final _i27.ListingChatConversationBloc? bloc;

  @override
  String toString() {
    return 'ChatConversationRouteArgs{key: $key, conversationId: $conversationId, initialConversation: $initialConversation, bloc: $bloc}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! ChatConversationRouteArgs) return false;
    return key == other.key &&
        conversationId == other.conversationId &&
        initialConversation == other.initialConversation &&
        bloc == other.bloc;
  }

  @override
  int get hashCode =>
      key.hashCode ^
      conversationId.hashCode ^
      initialConversation.hashCode ^
      bloc.hashCode;
}

/// generated route for
/// [_i6.ChatsScreen]
class ChatsRoute extends _i23.PageRouteInfo<ChatsRouteArgs> {
  ChatsRoute({
    _i24.Key? key,
    _i28.ChatsBloc? bloc,
    bool startImmediately = false,
    List<_i23.PageRouteInfo>? children,
  }) : super(
         ChatsRoute.name,
         args: ChatsRouteArgs(
           key: key,
           bloc: bloc,
           startImmediately: startImmediately,
         ),
         initialChildren: children,
       );

  static const String name = 'ChatsRoute';

  static _i23.PageInfo page = _i23.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<ChatsRouteArgs>(
        orElse: () => const ChatsRouteArgs(),
      );
      return _i6.ChatsScreen(
        key: args.key,
        bloc: args.bloc,
        startImmediately: args.startImmediately,
      );
    },
  );
}

class ChatsRouteArgs {
  const ChatsRouteArgs({this.key, this.bloc, this.startImmediately = false});

  final _i24.Key? key;

  final _i28.ChatsBloc? bloc;

  final bool startImmediately;

  @override
  String toString() {
    return 'ChatsRouteArgs{key: $key, bloc: $bloc, startImmediately: $startImmediately}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! ChatsRouteArgs) return false;
    return key == other.key &&
        bloc == other.bloc &&
        startImmediately == other.startImmediately;
  }

  @override
  int get hashCode => key.hashCode ^ bloc.hashCode ^ startImmediately.hashCode;
}

/// generated route for
/// [_i7.HomeScreen]
class HomeRoute extends _i23.PageRouteInfo<void> {
  const HomeRoute({List<_i23.PageRouteInfo>? children})
    : super(HomeRoute.name, initialChildren: children);

  static const String name = 'HomeRoute';

  static _i23.PageInfo page = _i23.PageInfo(
    name,
    builder: (data) {
      return const _i7.HomeScreen();
    },
  );
}

/// generated route for
/// [_i8.InitialScreen]
class InitialRoute extends _i23.PageRouteInfo<void> {
  const InitialRoute({List<_i23.PageRouteInfo>? children})
    : super(InitialRoute.name, initialChildren: children);

  static const String name = 'InitialRoute';

  static _i23.PageInfo page = _i23.PageInfo(
    name,
    builder: (data) {
      return const _i8.InitialScreen();
    },
  );
}

/// generated route for
/// [_i9.ListPropertyWizardScreen]
class ListPropertyWizardRoute extends _i23.PageRouteInfo<void> {
  const ListPropertyWizardRoute({List<_i23.PageRouteInfo>? children})
    : super(ListPropertyWizardRoute.name, initialChildren: children);

  static const String name = 'ListPropertyWizardRoute';

  static _i23.PageInfo page = _i23.PageInfo(
    name,
    builder: (data) {
      return const _i9.ListPropertyWizardScreen();
    },
  );
}

/// generated route for
/// [_i10.ListingDetailScreen]
class ListingDetailRoute extends _i23.PageRouteInfo<ListingDetailRouteArgs> {
  ListingDetailRoute({
    _i24.Key? key,
    required int listingId,
    _i29.ListingCard? initialListing,
    List<_i23.PageRouteInfo>? children,
  }) : super(
         ListingDetailRoute.name,
         args: ListingDetailRouteArgs(
           key: key,
           listingId: listingId,
           initialListing: initialListing,
         ),
         rawPathParams: {'listingId': listingId},
         initialChildren: children,
       );

  static const String name = 'ListingDetailRoute';

  static _i23.PageInfo page = _i23.PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<ListingDetailRouteArgs>(
        orElse: () =>
            ListingDetailRouteArgs(listingId: pathParams.getInt('listingId')),
      );
      return _i10.ListingDetailScreen(
        key: args.key,
        listingId: args.listingId,
        initialListing: args.initialListing,
      );
    },
  );
}

class ListingDetailRouteArgs {
  const ListingDetailRouteArgs({
    this.key,
    required this.listingId,
    this.initialListing,
  });

  final _i24.Key? key;

  final int listingId;

  final _i29.ListingCard? initialListing;

  @override
  String toString() {
    return 'ListingDetailRouteArgs{key: $key, listingId: $listingId, initialListing: $initialListing}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! ListingDetailRouteArgs) return false;
    return key == other.key &&
        listingId == other.listingId &&
        initialListing == other.initialListing;
  }

  @override
  int get hashCode =>
      key.hashCode ^ listingId.hashCode ^ initialListing.hashCode;
}

/// generated route for
/// [_i11.ListingDiscoveryMapScreen]
class ListingDiscoveryMapRoute
    extends _i23.PageRouteInfo<ListingDiscoveryMapRouteArgs> {
  ListingDiscoveryMapRoute({
    _i24.Key? key,
    _i12.ListingFilters initialFilters = const _i12.ListingFilters.empty(),
    _i13.ListingFilterOptions filterOptions =
        const _i13.ListingFilterOptions.empty(),
    List<_i29.ListingCard> seedListings = const [],
    bool favoritesOnly = false,
    _i24.ValueChanged<_i12.ListingFilters>? onFiltersChanged,
    _i30.ListingMapBloc? bloc,
    _i31.PropertyMapProviderSelector? providerSelector,
    _i31.PropertyMapProviderViewBuilder? providerViewBuilder,
    _i11.ListingMapUriLauncher? uriLauncher,
    _i32.PropertyMapLocationService? locationService,
    List<_i23.PageRouteInfo>? children,
  }) : super(
         ListingDiscoveryMapRoute.name,
         args: ListingDiscoveryMapRouteArgs(
           key: key,
           initialFilters: initialFilters,
           filterOptions: filterOptions,
           seedListings: seedListings,
           favoritesOnly: favoritesOnly,
           onFiltersChanged: onFiltersChanged,
           bloc: bloc,
           providerSelector: providerSelector,
           providerViewBuilder: providerViewBuilder,
           uriLauncher: uriLauncher,
           locationService: locationService,
         ),
         initialChildren: children,
       );

  static const String name = 'ListingDiscoveryMapRoute';

  static _i23.PageInfo page = _i23.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<ListingDiscoveryMapRouteArgs>(
        orElse: () => const ListingDiscoveryMapRouteArgs(),
      );
      return _i11.ListingDiscoveryMapScreen(
        key: args.key,
        initialFilters: args.initialFilters,
        filterOptions: args.filterOptions,
        seedListings: args.seedListings,
        favoritesOnly: args.favoritesOnly,
        onFiltersChanged: args.onFiltersChanged,
        bloc: args.bloc,
        providerSelector: args.providerSelector,
        providerViewBuilder: args.providerViewBuilder,
        uriLauncher: args.uriLauncher,
        locationService: args.locationService,
      );
    },
  );
}

class ListingDiscoveryMapRouteArgs {
  const ListingDiscoveryMapRouteArgs({
    this.key,
    this.initialFilters = const _i12.ListingFilters.empty(),
    this.filterOptions = const _i13.ListingFilterOptions.empty(),
    this.seedListings = const [],
    this.favoritesOnly = false,
    this.onFiltersChanged,
    this.bloc,
    this.providerSelector,
    this.providerViewBuilder,
    this.uriLauncher,
    this.locationService,
  });

  final _i24.Key? key;

  final _i12.ListingFilters initialFilters;

  final _i13.ListingFilterOptions filterOptions;

  final List<_i29.ListingCard> seedListings;

  final bool favoritesOnly;

  final _i24.ValueChanged<_i12.ListingFilters>? onFiltersChanged;

  final _i30.ListingMapBloc? bloc;

  final _i31.PropertyMapProviderSelector? providerSelector;

  final _i31.PropertyMapProviderViewBuilder? providerViewBuilder;

  final _i11.ListingMapUriLauncher? uriLauncher;

  final _i32.PropertyMapLocationService? locationService;

  @override
  String toString() {
    return 'ListingDiscoveryMapRouteArgs{key: $key, initialFilters: $initialFilters, filterOptions: $filterOptions, seedListings: $seedListings, favoritesOnly: $favoritesOnly, onFiltersChanged: $onFiltersChanged, bloc: $bloc, providerSelector: $providerSelector, providerViewBuilder: $providerViewBuilder, uriLauncher: $uriLauncher, locationService: $locationService}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! ListingDiscoveryMapRouteArgs) return false;
    return key == other.key &&
        initialFilters == other.initialFilters &&
        filterOptions == other.filterOptions &&
        const _i33.ListEquality<_i29.ListingCard>().equals(
          seedListings,
          other.seedListings,
        ) &&
        favoritesOnly == other.favoritesOnly &&
        onFiltersChanged == other.onFiltersChanged &&
        bloc == other.bloc &&
        providerSelector == other.providerSelector &&
        providerViewBuilder == other.providerViewBuilder &&
        uriLauncher == other.uriLauncher &&
        locationService == other.locationService;
  }

  @override
  int get hashCode =>
      key.hashCode ^
      initialFilters.hashCode ^
      filterOptions.hashCode ^
      const _i33.ListEquality<_i29.ListingCard>().hash(seedListings) ^
      favoritesOnly.hashCode ^
      onFiltersChanged.hashCode ^
      bloc.hashCode ^
      providerSelector.hashCode ^
      providerViewBuilder.hashCode ^
      uriLauncher.hashCode ^
      locationService.hashCode;
}

/// generated route for
/// [_i14.LoginWithPhoneNumberScreen]
class LoginWithPhoneNumberRoute extends _i23.PageRouteInfo<void> {
  const LoginWithPhoneNumberRoute({List<_i23.PageRouteInfo>? children})
    : super(LoginWithPhoneNumberRoute.name, initialChildren: children);

  static const String name = 'LoginWithPhoneNumberRoute';

  static _i23.PageInfo page = _i23.PageInfo(
    name,
    builder: (data) {
      return const _i14.LoginWithPhoneNumberScreen();
    },
  );
}

/// generated route for
/// [_i15.NetworkImageScreen]
class NetworkImageRoute extends _i23.PageRouteInfo<NetworkImageRouteArgs> {
  NetworkImageRoute({
    _i24.Key? key,
    required String link,
    List<_i23.PageRouteInfo>? children,
  }) : super(
         NetworkImageRoute.name,
         args: NetworkImageRouteArgs(key: key, link: link),
         initialChildren: children,
       );

  static const String name = 'NetworkImageRoute';

  static _i23.PageInfo page = _i23.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<NetworkImageRouteArgs>();
      return _i15.NetworkImageScreen(key: args.key, link: args.link);
    },
  );
}

class NetworkImageRouteArgs {
  const NetworkImageRouteArgs({this.key, required this.link});

  final _i24.Key? key;

  final String link;

  @override
  String toString() {
    return 'NetworkImageRouteArgs{key: $key, link: $link}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! NetworkImageRouteArgs) return false;
    return key == other.key && link == other.link;
  }

  @override
  int get hashCode => key.hashCode ^ link.hashCode;
}

/// generated route for
/// [_i16.NotificationSettingsScreen]
class NotificationSettingsRoute
    extends _i23.PageRouteInfo<NotificationSettingsRouteArgs> {
  NotificationSettingsRoute({
    _i24.Key? key,
    _i34.Future<_i35.NotificationPermissionStatus> Function()? getPermission,
    _i36.GetNotificationSettings? getSettings,
    _i37.UpdateNotificationSettings? updateSettings,
    List<_i23.PageRouteInfo>? children,
  }) : super(
         NotificationSettingsRoute.name,
         args: NotificationSettingsRouteArgs(
           key: key,
           getPermission: getPermission,
           getSettings: getSettings,
           updateSettings: updateSettings,
         ),
         initialChildren: children,
       );

  static const String name = 'NotificationSettingsRoute';

  static _i23.PageInfo page = _i23.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<NotificationSettingsRouteArgs>(
        orElse: () => const NotificationSettingsRouteArgs(),
      );
      return _i16.NotificationSettingsScreen(
        key: args.key,
        getPermission: args.getPermission,
        getSettings: args.getSettings,
        updateSettings: args.updateSettings,
      );
    },
  );
}

class NotificationSettingsRouteArgs {
  const NotificationSettingsRouteArgs({
    this.key,
    this.getPermission,
    this.getSettings,
    this.updateSettings,
  });

  final _i24.Key? key;

  final _i34.Future<_i35.NotificationPermissionStatus> Function()?
  getPermission;

  final _i36.GetNotificationSettings? getSettings;

  final _i37.UpdateNotificationSettings? updateSettings;

  @override
  String toString() {
    return 'NotificationSettingsRouteArgs{key: $key, getPermission: $getPermission, getSettings: $getSettings, updateSettings: $updateSettings}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! NotificationSettingsRouteArgs) return false;
    return key == other.key &&
        getSettings == other.getSettings &&
        updateSettings == other.updateSettings;
  }

  @override
  int get hashCode =>
      key.hashCode ^ getSettings.hashCode ^ updateSettings.hashCode;
}

/// generated route for
/// [_i17.NotificationsScreen]
class NotificationsRoute extends _i23.PageRouteInfo<NotificationsRouteArgs> {
  NotificationsRoute({
    _i38.NotificationBloc? bloc,
    _i24.Key? key,
    List<_i23.PageRouteInfo>? children,
  }) : super(
         NotificationsRoute.name,
         args: NotificationsRouteArgs(bloc: bloc, key: key),
         initialChildren: children,
       );

  static const String name = 'NotificationsRoute';

  static _i23.PageInfo page = _i23.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<NotificationsRouteArgs>(
        orElse: () => const NotificationsRouteArgs(),
      );
      return _i17.NotificationsScreen(bloc: args.bloc, key: args.key);
    },
  );
}

class NotificationsRouteArgs {
  const NotificationsRouteArgs({this.bloc, this.key});

  final _i38.NotificationBloc? bloc;

  final _i24.Key? key;

  @override
  String toString() {
    return 'NotificationsRouteArgs{bloc: $bloc, key: $key}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! NotificationsRouteArgs) return false;
    return bloc == other.bloc && key == other.key;
  }

  @override
  int get hashCode => bloc.hashCode ^ key.hashCode;
}

/// generated route for
/// [_i18.PaymentReturnScreen]
class PaymentReturnRoute extends _i23.PageRouteInfo<PaymentReturnRouteArgs> {
  PaymentReturnRoute({
    _i24.Key? key,
    String? checkoutToken,
    List<_i23.PageRouteInfo>? children,
  }) : super(
         PaymentReturnRoute.name,
         args: PaymentReturnRouteArgs(key: key, checkoutToken: checkoutToken),
         rawQueryParams: {'checkout': checkoutToken},
         initialChildren: children,
       );

  static const String name = 'PaymentReturnRoute';

  static _i23.PageInfo page = _i23.PageInfo(
    name,
    builder: (data) {
      final queryParams = data.queryParams;
      final args = data.argsAs<PaymentReturnRouteArgs>(
        orElse: () => PaymentReturnRouteArgs(
          checkoutToken: queryParams.optString('checkout'),
        ),
      );
      return _i18.PaymentReturnScreen(
        key: args.key,
        checkoutToken: args.checkoutToken,
      );
    },
  );
}

class PaymentReturnRouteArgs {
  const PaymentReturnRouteArgs({this.key, this.checkoutToken});

  final _i24.Key? key;

  final String? checkoutToken;

  @override
  String toString() {
    return 'PaymentReturnRouteArgs{key: $key, checkoutToken: $checkoutToken}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! PaymentReturnRouteArgs) return false;
    return key == other.key && checkoutToken == other.checkoutToken;
  }

  @override
  int get hashCode => key.hashCode ^ checkoutToken.hashCode;
}

/// generated route for
/// [_i19.PersonalDetailsScreen]
class PersonalDetailsRoute
    extends _i23.PageRouteInfo<PersonalDetailsRouteArgs> {
  PersonalDetailsRoute({
    _i24.Key? key,
    required _i39.ProfileBloc profileBloc,
    List<_i23.PageRouteInfo>? children,
  }) : super(
         PersonalDetailsRoute.name,
         args: PersonalDetailsRouteArgs(key: key, profileBloc: profileBloc),
         initialChildren: children,
       );

  static const String name = 'PersonalDetailsRoute';

  static _i23.PageInfo page = _i23.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<PersonalDetailsRouteArgs>();
      return _i19.PersonalDetailsScreen(
        key: args.key,
        profileBloc: args.profileBloc,
      );
    },
  );
}

class PersonalDetailsRouteArgs {
  const PersonalDetailsRouteArgs({this.key, required this.profileBloc});

  final _i24.Key? key;

  final _i39.ProfileBloc profileBloc;

  @override
  String toString() {
    return 'PersonalDetailsRouteArgs{key: $key, profileBloc: $profileBloc}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! PersonalDetailsRouteArgs) return false;
    return key == other.key && profileBloc == other.profileBloc;
  }

  @override
  int get hashCode => key.hashCode ^ profileBloc.hashCode;
}

/// generated route for
/// [_i20.PhoneNumberOTPScreen]
class PhoneNumberOTPRoute extends _i23.PageRouteInfo<PhoneNumberOTPRouteArgs> {
  PhoneNumberOTPRoute({
    _i24.Key? key,
    required _i40.LoginBloc loginBloc,
    List<_i23.PageRouteInfo>? children,
  }) : super(
         PhoneNumberOTPRoute.name,
         args: PhoneNumberOTPRouteArgs(key: key, loginBloc: loginBloc),
         initialChildren: children,
       );

  static const String name = 'PhoneNumberOTPRoute';

  static _i23.PageInfo page = _i23.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<PhoneNumberOTPRouteArgs>();
      return _i20.PhoneNumberOTPScreen(
        key: args.key,
        loginBloc: args.loginBloc,
      );
    },
  );
}

class PhoneNumberOTPRouteArgs {
  const PhoneNumberOTPRouteArgs({this.key, required this.loginBloc});

  final _i24.Key? key;

  final _i40.LoginBloc loginBloc;

  @override
  String toString() {
    return 'PhoneNumberOTPRouteArgs{key: $key, loginBloc: $loginBloc}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! PhoneNumberOTPRouteArgs) return false;
    return key == other.key && loginBloc == other.loginBloc;
  }

  @override
  int get hashCode => key.hashCode ^ loginBloc.hashCode;
}

/// generated route for
/// [_i21.SettingsScreen]
class SettingsRoute extends _i23.PageRouteInfo<void> {
  const SettingsRoute({List<_i23.PageRouteInfo>? children})
    : super(SettingsRoute.name, initialChildren: children);

  static const String name = 'SettingsRoute';

  static _i23.PageInfo page = _i23.PageInfo(
    name,
    builder: (data) {
      return const _i21.SettingsScreen();
    },
  );
}

/// generated route for
/// [_i22.SslConnectionFailedScreen]
class SslConnectionFailedRoute extends _i23.PageRouteInfo<void> {
  const SslConnectionFailedRoute({List<_i23.PageRouteInfo>? children})
    : super(SslConnectionFailedRoute.name, initialChildren: children);

  static const String name = 'SslConnectionFailedRoute';

  static _i23.PageInfo page = _i23.PageInfo(
    name,
    builder: (data) {
      return const _i22.SslConnectionFailedScreen();
    },
  );
}
