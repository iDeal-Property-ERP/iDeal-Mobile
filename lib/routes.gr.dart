// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _i31;

import 'package:auto_route/auto_route.dart' as _i21;
import 'package:collection/collection.dart' as _i30;
import 'package:flutter/material.dart' as _i22;
import 'package:ideal_mobile/presentation/booking/booking_screen.dart' as _i1;
import 'package:ideal_mobile/presentation/booking/booking_status_screen.dart'
    as _i2;
import 'package:ideal_mobile/presentation/booking/domain/entities/booking.dart'
    as _i23;
import 'package:ideal_mobile/presentation/booking/payment_return_screen.dart'
    as _i16;
import 'package:ideal_mobile/presentation/change_theme/change_theme_screen.dart'
    as _i3;
import 'package:ideal_mobile/presentation/chat/bloc/chats_bloc.dart' as _i26;
import 'package:ideal_mobile/presentation/chat/bloc/listing_chat_conversation_bloc.dart'
    as _i25;
import 'package:ideal_mobile/presentation/chat/chat_conversation_screen.dart'
    as _i4;
import 'package:ideal_mobile/presentation/chat/chats_screen.dart' as _i5;
import 'package:ideal_mobile/presentation/chat/domain/entities/chat_conversation.dart'
    as _i24;
import 'package:ideal_mobile/presentation/home/home_screen.dart' as _i6;
import 'package:ideal_mobile/presentation/initial/initial_screen.dart' as _i7;
import 'package:ideal_mobile/presentation/listing_detail/listing_detail_screen.dart'
    as _i8;
import 'package:ideal_mobile/presentation/listing_map/bloc/listing_map_bloc.dart'
    as _i28;
import 'package:ideal_mobile/presentation/listing_map/listing_discovery_map_screen.dart'
    as _i9;
import 'package:ideal_mobile/presentation/listings/domain/entities/listing_card.dart'
    as _i27;
import 'package:ideal_mobile/presentation/listings/domain/entities/listing_filter_options.dart'
    as _i11;
import 'package:ideal_mobile/presentation/listings/domain/entities/listing_filters.dart'
    as _i10;
import 'package:ideal_mobile/presentation/login/bloc/login_bloc.dart' as _i37;
import 'package:ideal_mobile/presentation/login/screens/login_with_phone_number/login_with_phone_number_screen.dart'
    as _i12;
import 'package:ideal_mobile/presentation/login/screens/phone_num_otp_screen/phone_number_otp_screen.dart'
    as _i18;
import 'package:ideal_mobile/presentation/map/widgets/property_map_view.dart'
    as _i29;
import 'package:ideal_mobile/presentation/notification_settings/notification_settings_screen.dart'
    as _i14;
import 'package:ideal_mobile/presentation/notifications/bloc/notification_bloc.dart'
    as _i35;
import 'package:ideal_mobile/presentation/notifications/domain/usecases/get_notification_settings.dart'
    as _i33;
import 'package:ideal_mobile/presentation/notifications/domain/usecases/update_notification_settings.dart'
    as _i34;
import 'package:ideal_mobile/presentation/notifications/notifications_screen.dart'
    as _i15;
import 'package:ideal_mobile/presentation/profile/bloc/profile_bloc.dart'
    as _i36;
import 'package:ideal_mobile/presentation/profile/personal_details_screen.dart'
    as _i17;
import 'package:ideal_mobile/presentation/settings/settings_screen.dart'
    as _i19;
import 'package:ideal_mobile/presentation/ssl_pinning/ssl_connection_failed_screen.dart'
    as _i20;
import 'package:ideal_mobile/services/push/notification_permission_status.dart'
    as _i32;
import 'package:ideal_mobile/widgets/attachment_view.dart' as _i13;

/// generated route for
/// [_i1.BookingScreen]
class BookingRoute extends _i21.PageRouteInfo<BookingRouteArgs> {
  BookingRoute({
    _i22.Key? key,
    required int listingId,
    _i23.BookingOptions? initialOptions,
    List<_i21.PageRouteInfo>? children,
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

  static _i21.PageInfo page = _i21.PageInfo(
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

  final _i22.Key? key;

  final int listingId;

  final _i23.BookingOptions? initialOptions;

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
class BookingStatusRoute extends _i21.PageRouteInfo<BookingStatusRouteArgs> {
  BookingStatusRoute({
    _i22.Key? key,
    required int bookingId,
    _i23.PaymentCheckout? initialCheckout,
    List<_i21.PageRouteInfo>? children,
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

  static _i21.PageInfo page = _i21.PageInfo(
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

  final _i22.Key? key;

  final int bookingId;

  final _i23.PaymentCheckout? initialCheckout;

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
/// [_i3.ChangeThemeScreen]
class ChangeThemeRoute extends _i21.PageRouteInfo<void> {
  const ChangeThemeRoute({List<_i21.PageRouteInfo>? children})
    : super(ChangeThemeRoute.name, initialChildren: children);

  static const String name = 'ChangeThemeRoute';

  static _i21.PageInfo page = _i21.PageInfo(
    name,
    builder: (data) {
      return const _i3.ChangeThemeScreen();
    },
  );
}

/// generated route for
/// [_i4.ChatConversationScreen]
class ChatConversationRoute
    extends _i21.PageRouteInfo<ChatConversationRouteArgs> {
  ChatConversationRoute({
    _i22.Key? key,
    required int conversationId,
    _i24.ChatConversation? initialConversation,
    _i25.ListingChatConversationBloc? bloc,
    List<_i21.PageRouteInfo>? children,
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

  static _i21.PageInfo page = _i21.PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<ChatConversationRouteArgs>(
        orElse: () => ChatConversationRouteArgs(
          conversationId: pathParams.getInt('conversationId'),
        ),
      );
      return _i4.ChatConversationScreen(
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

  final _i22.Key? key;

  final int conversationId;

  final _i24.ChatConversation? initialConversation;

  final _i25.ListingChatConversationBloc? bloc;

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
/// [_i5.ChatsScreen]
class ChatsRoute extends _i21.PageRouteInfo<ChatsRouteArgs> {
  ChatsRoute({
    _i22.Key? key,
    _i26.ChatsBloc? bloc,
    bool startImmediately = false,
    List<_i21.PageRouteInfo>? children,
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

  static _i21.PageInfo page = _i21.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<ChatsRouteArgs>(
        orElse: () => const ChatsRouteArgs(),
      );
      return _i5.ChatsScreen(
        key: args.key,
        bloc: args.bloc,
        startImmediately: args.startImmediately,
      );
    },
  );
}

class ChatsRouteArgs {
  const ChatsRouteArgs({this.key, this.bloc, this.startImmediately = false});

  final _i22.Key? key;

  final _i26.ChatsBloc? bloc;

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
/// [_i6.HomeScreen]
class HomeRoute extends _i21.PageRouteInfo<void> {
  const HomeRoute({List<_i21.PageRouteInfo>? children})
    : super(HomeRoute.name, initialChildren: children);

  static const String name = 'HomeRoute';

  static _i21.PageInfo page = _i21.PageInfo(
    name,
    builder: (data) {
      return const _i6.HomeScreen();
    },
  );
}

/// generated route for
/// [_i7.InitialScreen]
class InitialRoute extends _i21.PageRouteInfo<void> {
  const InitialRoute({List<_i21.PageRouteInfo>? children})
    : super(InitialRoute.name, initialChildren: children);

  static const String name = 'InitialRoute';

  static _i21.PageInfo page = _i21.PageInfo(
    name,
    builder: (data) {
      return const _i7.InitialScreen();
    },
  );
}

/// generated route for
/// [_i8.ListingDetailScreen]
class ListingDetailRoute extends _i21.PageRouteInfo<ListingDetailRouteArgs> {
  ListingDetailRoute({
    _i22.Key? key,
    required int listingId,
    _i27.ListingCard? initialListing,
    List<_i21.PageRouteInfo>? children,
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

  static _i21.PageInfo page = _i21.PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<ListingDetailRouteArgs>(
        orElse: () =>
            ListingDetailRouteArgs(listingId: pathParams.getInt('listingId')),
      );
      return _i8.ListingDetailScreen(
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

  final _i22.Key? key;

  final int listingId;

  final _i27.ListingCard? initialListing;

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
/// [_i9.ListingDiscoveryMapScreen]
class ListingDiscoveryMapRoute
    extends _i21.PageRouteInfo<ListingDiscoveryMapRouteArgs> {
  ListingDiscoveryMapRoute({
    _i22.Key? key,
    _i10.ListingFilters initialFilters = const _i10.ListingFilters.empty(),
    _i11.ListingFilterOptions filterOptions =
        const _i11.ListingFilterOptions.empty(),
    List<_i27.ListingCard> seedListings = const [],
    _i22.ValueChanged<_i10.ListingFilters>? onFiltersChanged,
    _i28.ListingMapBloc? bloc,
    _i29.PropertyMapProviderSelector? providerSelector,
    _i29.PropertyMapProviderViewBuilder? providerViewBuilder,
    _i9.ListingMapUriLauncher? uriLauncher,
    List<_i21.PageRouteInfo>? children,
  }) : super(
         ListingDiscoveryMapRoute.name,
         args: ListingDiscoveryMapRouteArgs(
           key: key,
           initialFilters: initialFilters,
           filterOptions: filterOptions,
           seedListings: seedListings,
           onFiltersChanged: onFiltersChanged,
           bloc: bloc,
           providerSelector: providerSelector,
           providerViewBuilder: providerViewBuilder,
           uriLauncher: uriLauncher,
         ),
         initialChildren: children,
       );

  static const String name = 'ListingDiscoveryMapRoute';

  static _i21.PageInfo page = _i21.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<ListingDiscoveryMapRouteArgs>(
        orElse: () => const ListingDiscoveryMapRouteArgs(),
      );
      return _i9.ListingDiscoveryMapScreen(
        key: args.key,
        initialFilters: args.initialFilters,
        filterOptions: args.filterOptions,
        seedListings: args.seedListings,
        onFiltersChanged: args.onFiltersChanged,
        bloc: args.bloc,
        providerSelector: args.providerSelector,
        providerViewBuilder: args.providerViewBuilder,
        uriLauncher: args.uriLauncher,
      );
    },
  );
}

class ListingDiscoveryMapRouteArgs {
  const ListingDiscoveryMapRouteArgs({
    this.key,
    this.initialFilters = const _i10.ListingFilters.empty(),
    this.filterOptions = const _i11.ListingFilterOptions.empty(),
    this.seedListings = const [],
    this.onFiltersChanged,
    this.bloc,
    this.providerSelector,
    this.providerViewBuilder,
    this.uriLauncher,
  });

  final _i22.Key? key;

  final _i10.ListingFilters initialFilters;

  final _i11.ListingFilterOptions filterOptions;

  final List<_i27.ListingCard> seedListings;

  final _i22.ValueChanged<_i10.ListingFilters>? onFiltersChanged;

  final _i28.ListingMapBloc? bloc;

  final _i29.PropertyMapProviderSelector? providerSelector;

  final _i29.PropertyMapProviderViewBuilder? providerViewBuilder;

  final _i9.ListingMapUriLauncher? uriLauncher;

  @override
  String toString() {
    return 'ListingDiscoveryMapRouteArgs{key: $key, initialFilters: $initialFilters, filterOptions: $filterOptions, seedListings: $seedListings, onFiltersChanged: $onFiltersChanged, bloc: $bloc, providerSelector: $providerSelector, providerViewBuilder: $providerViewBuilder, uriLauncher: $uriLauncher}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! ListingDiscoveryMapRouteArgs) return false;
    return key == other.key &&
        initialFilters == other.initialFilters &&
        filterOptions == other.filterOptions &&
        const _i30.ListEquality<_i27.ListingCard>().equals(
          seedListings,
          other.seedListings,
        ) &&
        onFiltersChanged == other.onFiltersChanged &&
        bloc == other.bloc &&
        providerSelector == other.providerSelector &&
        providerViewBuilder == other.providerViewBuilder &&
        uriLauncher == other.uriLauncher;
  }

  @override
  int get hashCode =>
      key.hashCode ^
      initialFilters.hashCode ^
      filterOptions.hashCode ^
      const _i30.ListEquality<_i27.ListingCard>().hash(seedListings) ^
      onFiltersChanged.hashCode ^
      bloc.hashCode ^
      providerSelector.hashCode ^
      providerViewBuilder.hashCode ^
      uriLauncher.hashCode;
}

/// generated route for
/// [_i12.LoginWithPhoneNumberScreen]
class LoginWithPhoneNumberRoute extends _i21.PageRouteInfo<void> {
  const LoginWithPhoneNumberRoute({List<_i21.PageRouteInfo>? children})
    : super(LoginWithPhoneNumberRoute.name, initialChildren: children);

  static const String name = 'LoginWithPhoneNumberRoute';

  static _i21.PageInfo page = _i21.PageInfo(
    name,
    builder: (data) {
      return const _i12.LoginWithPhoneNumberScreen();
    },
  );
}

/// generated route for
/// [_i13.NetworkImageScreen]
class NetworkImageRoute extends _i21.PageRouteInfo<NetworkImageRouteArgs> {
  NetworkImageRoute({
    _i22.Key? key,
    required String link,
    List<_i21.PageRouteInfo>? children,
  }) : super(
         NetworkImageRoute.name,
         args: NetworkImageRouteArgs(key: key, link: link),
         initialChildren: children,
       );

  static const String name = 'NetworkImageRoute';

  static _i21.PageInfo page = _i21.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<NetworkImageRouteArgs>();
      return _i13.NetworkImageScreen(key: args.key, link: args.link);
    },
  );
}

class NetworkImageRouteArgs {
  const NetworkImageRouteArgs({this.key, required this.link});

  final _i22.Key? key;

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
/// [_i14.NotificationSettingsScreen]
class NotificationSettingsRoute
    extends _i21.PageRouteInfo<NotificationSettingsRouteArgs> {
  NotificationSettingsRoute({
    _i22.Key? key,
    _i31.Future<_i32.NotificationPermissionStatus> Function()? getPermission,
    _i33.GetNotificationSettings? getSettings,
    _i34.UpdateNotificationSettings? updateSettings,
    List<_i21.PageRouteInfo>? children,
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

  static _i21.PageInfo page = _i21.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<NotificationSettingsRouteArgs>(
        orElse: () => const NotificationSettingsRouteArgs(),
      );
      return _i14.NotificationSettingsScreen(
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

  final _i22.Key? key;

  final _i31.Future<_i32.NotificationPermissionStatus> Function()?
  getPermission;

  final _i33.GetNotificationSettings? getSettings;

  final _i34.UpdateNotificationSettings? updateSettings;

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
/// [_i15.NotificationsScreen]
class NotificationsRoute extends _i21.PageRouteInfo<NotificationsRouteArgs> {
  NotificationsRoute({
    _i35.NotificationBloc? bloc,
    _i22.Key? key,
    List<_i21.PageRouteInfo>? children,
  }) : super(
         NotificationsRoute.name,
         args: NotificationsRouteArgs(bloc: bloc, key: key),
         initialChildren: children,
       );

  static const String name = 'NotificationsRoute';

  static _i21.PageInfo page = _i21.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<NotificationsRouteArgs>(
        orElse: () => const NotificationsRouteArgs(),
      );
      return _i15.NotificationsScreen(bloc: args.bloc, key: args.key);
    },
  );
}

class NotificationsRouteArgs {
  const NotificationsRouteArgs({this.bloc, this.key});

  final _i35.NotificationBloc? bloc;

  final _i22.Key? key;

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
/// [_i16.PaymentReturnScreen]
class PaymentReturnRoute extends _i21.PageRouteInfo<PaymentReturnRouteArgs> {
  PaymentReturnRoute({
    _i22.Key? key,
    String? checkoutToken,
    List<_i21.PageRouteInfo>? children,
  }) : super(
         PaymentReturnRoute.name,
         args: PaymentReturnRouteArgs(key: key, checkoutToken: checkoutToken),
         rawQueryParams: {'checkout': checkoutToken},
         initialChildren: children,
       );

  static const String name = 'PaymentReturnRoute';

  static _i21.PageInfo page = _i21.PageInfo(
    name,
    builder: (data) {
      final queryParams = data.queryParams;
      final args = data.argsAs<PaymentReturnRouteArgs>(
        orElse: () => PaymentReturnRouteArgs(
          checkoutToken: queryParams.optString('checkout'),
        ),
      );
      return _i16.PaymentReturnScreen(
        key: args.key,
        checkoutToken: args.checkoutToken,
      );
    },
  );
}

class PaymentReturnRouteArgs {
  const PaymentReturnRouteArgs({this.key, this.checkoutToken});

  final _i22.Key? key;

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
/// [_i17.PersonalDetailsScreen]
class PersonalDetailsRoute
    extends _i21.PageRouteInfo<PersonalDetailsRouteArgs> {
  PersonalDetailsRoute({
    _i22.Key? key,
    required _i36.ProfileBloc profileBloc,
    List<_i21.PageRouteInfo>? children,
  }) : super(
         PersonalDetailsRoute.name,
         args: PersonalDetailsRouteArgs(key: key, profileBloc: profileBloc),
         initialChildren: children,
       );

  static const String name = 'PersonalDetailsRoute';

  static _i21.PageInfo page = _i21.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<PersonalDetailsRouteArgs>();
      return _i17.PersonalDetailsScreen(
        key: args.key,
        profileBloc: args.profileBloc,
      );
    },
  );
}

class PersonalDetailsRouteArgs {
  const PersonalDetailsRouteArgs({this.key, required this.profileBloc});

  final _i22.Key? key;

  final _i36.ProfileBloc profileBloc;

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
/// [_i18.PhoneNumberOTPScreen]
class PhoneNumberOTPRoute extends _i21.PageRouteInfo<PhoneNumberOTPRouteArgs> {
  PhoneNumberOTPRoute({
    _i22.Key? key,
    required _i37.LoginBloc loginBloc,
    List<_i21.PageRouteInfo>? children,
  }) : super(
         PhoneNumberOTPRoute.name,
         args: PhoneNumberOTPRouteArgs(key: key, loginBloc: loginBloc),
         initialChildren: children,
       );

  static const String name = 'PhoneNumberOTPRoute';

  static _i21.PageInfo page = _i21.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<PhoneNumberOTPRouteArgs>();
      return _i18.PhoneNumberOTPScreen(
        key: args.key,
        loginBloc: args.loginBloc,
      );
    },
  );
}

class PhoneNumberOTPRouteArgs {
  const PhoneNumberOTPRouteArgs({this.key, required this.loginBloc});

  final _i22.Key? key;

  final _i37.LoginBloc loginBloc;

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
/// [_i19.SettingsScreen]
class SettingsRoute extends _i21.PageRouteInfo<void> {
  const SettingsRoute({List<_i21.PageRouteInfo>? children})
    : super(SettingsRoute.name, initialChildren: children);

  static const String name = 'SettingsRoute';

  static _i21.PageInfo page = _i21.PageInfo(
    name,
    builder: (data) {
      return const _i19.SettingsScreen();
    },
  );
}

/// generated route for
/// [_i20.SslConnectionFailedScreen]
class SslConnectionFailedRoute extends _i21.PageRouteInfo<void> {
  const SslConnectionFailedRoute({List<_i21.PageRouteInfo>? children})
    : super(SslConnectionFailedRoute.name, initialChildren: children);

  static const String name = 'SslConnectionFailedRoute';

  static _i21.PageInfo page = _i21.PageInfo(
    name,
    builder: (data) {
      return const _i20.SslConnectionFailedScreen();
    },
  );
}
