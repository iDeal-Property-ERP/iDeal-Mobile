// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:auto_route/auto_route.dart' as _i35;
import 'package:flutter/material.dart' as _i36;
import 'package:ideal_mobile/presentation/account_delete_success/account_delete_success_screen.dart'
    as _i1;
import 'package:ideal_mobile/presentation/biometric_auth/biometric_auth_screen.dart'
    as _i3;
import 'package:ideal_mobile/presentation/change_theme/change_theme_screen.dart'
    as _i4;
import 'package:ideal_mobile/presentation/chat/bloc/chats_bloc.dart' as _i39;
import 'package:ideal_mobile/presentation/chat/bloc/listing_chat_conversation_bloc.dart'
    as _i38;
import 'package:ideal_mobile/presentation/chat/chat_conversation_screen.dart'
    as _i5;
import 'package:ideal_mobile/presentation/chat/chats_screen.dart' as _i6;
import 'package:ideal_mobile/presentation/contact_us/contact_us_screen.dart'
    as _i8;
import 'package:ideal_mobile/presentation/contact_us/contact_us_submitted_screen.dart'
    as _i9;
import 'package:ideal_mobile/presentation/delete_account/delete_account_screen.dart'
    as _i11;
import 'package:ideal_mobile/presentation/empty_screens/empty_view_screens.dart'
    as _i12;
import 'package:ideal_mobile/presentation/feedback/screens/feedback_screen.dart'
    as _i13;
import 'package:ideal_mobile/presentation/force_update/force_update_screen.dart'
    as _i14;
import 'package:ideal_mobile/presentation/home/home_screen.dart' as _i16;
import 'package:ideal_mobile/presentation/initial/initial_screen.dart' as _i17;
import 'package:ideal_mobile/presentation/listing_detail/listing_detail_screen.dart'
    as _i18;
import 'package:ideal_mobile/presentation/login/bloc/login_bloc.dart' as _i37;
import 'package:ideal_mobile/presentation/login/screens/check_your_email/check_your_email_screen.dart'
    as _i7;
import 'package:ideal_mobile/presentation/login/screens/forgot_password/forgot_password_screen.dart'
    as _i15;
import 'package:ideal_mobile/presentation/login/screens/login_with_email/login_with_email_password_screen.dart'
    as _i19;
import 'package:ideal_mobile/presentation/login/screens/login_with_phone_number/login_with_phone_number_screen.dart'
    as _i20;
import 'package:ideal_mobile/presentation/login/screens/phone_num_otp_screen/phone_number_otp_screen.dart'
    as _i26;
import 'package:ideal_mobile/presentation/no_internet/no_internet_screen.dart'
    as _i22;
import 'package:ideal_mobile/presentation/notification_settings/notification_settings_screen.dart'
    as _i23;
import 'package:ideal_mobile/presentation/notifications/bloc/notification_bloc.dart'
    as _i41;
import 'package:ideal_mobile/presentation/notifications/notifications_screen.dart'
    as _i24;
import 'package:ideal_mobile/presentation/profile/bloc/profile_bloc.dart'
    as _i42;
import 'package:ideal_mobile/presentation/profile/personal_details_screen.dart'
    as _i25;
import 'package:ideal_mobile/presentation/reminder/reminder_screen.dart'
    as _i28;
import 'package:ideal_mobile/presentation/server_error/server_error_screen.dart'
    as _i29;
import 'package:ideal_mobile/presentation/settings/settings_screen.dart'
    as _i30;
import 'package:ideal_mobile/presentation/signup/bloc/signup_bloc.dart' as _i40;
import 'package:ideal_mobile/presentation/signup/screens/phone_num_verified_page/phone_number_verified_screen.dart'
    as _i27;
import 'package:ideal_mobile/presentation/signup/screens/profile_picture/add_profile_picture_screen.dart'
    as _i2;
import 'package:ideal_mobile/presentation/signup/screens/signup_with_email/create_your_password_screen.dart'
    as _i10;
import 'package:ideal_mobile/presentation/signup/screens/signup_with_email/signup_with_email_password_screen.dart'
    as _i31;
import 'package:ideal_mobile/presentation/ssl_pinning/ssl_connection_failed_screen.dart'
    as _i32;
import 'package:ideal_mobile/presentation/under_maintainace/under_maintenance_screen.dart'
    as _i33;
import 'package:ideal_mobile/presentation/verify_email/screens/verify_email_screen.dart'
    as _i34;
import 'package:ideal_mobile/widgets/attachment_view.dart' as _i21;

/// generated route for
/// [_i1.AccountDeleteSuccessScreen]
class AccountDeleteSuccessRoute extends _i35.PageRouteInfo<void> {
  const AccountDeleteSuccessRoute({List<_i35.PageRouteInfo>? children})
    : super(AccountDeleteSuccessRoute.name, initialChildren: children);

  static const String name = 'AccountDeleteSuccessRoute';

  static _i35.PageInfo page = _i35.PageInfo(
    name,
    builder: (data) {
      return const _i1.AccountDeleteSuccessScreen();
    },
  );
}

/// generated route for
/// [_i2.AddProfilePictureScreen]
class AddProfilePictureRoute
    extends _i35.PageRouteInfo<AddProfilePictureRouteArgs> {
  AddProfilePictureRoute({
    _i36.Key? key,
    required _i37.LoginBloc loginBloc,
    List<_i35.PageRouteInfo>? children,
  }) : super(
         AddProfilePictureRoute.name,
         args: AddProfilePictureRouteArgs(key: key, loginBloc: loginBloc),
         initialChildren: children,
       );

  static const String name = 'AddProfilePictureRoute';

  static _i35.PageInfo page = _i35.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<AddProfilePictureRouteArgs>();
      return _i2.AddProfilePictureScreen(
        key: args.key,
        loginBloc: args.loginBloc,
      );
    },
  );
}

class AddProfilePictureRouteArgs {
  const AddProfilePictureRouteArgs({this.key, required this.loginBloc});

  final _i36.Key? key;

  final _i37.LoginBloc loginBloc;

  @override
  String toString() {
    return 'AddProfilePictureRouteArgs{key: $key, loginBloc: $loginBloc}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! AddProfilePictureRouteArgs) return false;
    return key == other.key && loginBloc == other.loginBloc;
  }

  @override
  int get hashCode => key.hashCode ^ loginBloc.hashCode;
}

/// generated route for
/// [_i3.BiometricAuthScreen]
class BiometricAuthRoute extends _i35.PageRouteInfo<void> {
  const BiometricAuthRoute({List<_i35.PageRouteInfo>? children})
    : super(BiometricAuthRoute.name, initialChildren: children);

  static const String name = 'BiometricAuthRoute';

  static _i35.PageInfo page = _i35.PageInfo(
    name,
    builder: (data) {
      return const _i3.BiometricAuthScreen();
    },
  );
}

/// generated route for
/// [_i4.ChangeThemeScreen]
class ChangeThemeRoute extends _i35.PageRouteInfo<void> {
  const ChangeThemeRoute({List<_i35.PageRouteInfo>? children})
    : super(ChangeThemeRoute.name, initialChildren: children);

  static const String name = 'ChangeThemeRoute';

  static _i35.PageInfo page = _i35.PageInfo(
    name,
    builder: (data) {
      return const _i4.ChangeThemeScreen();
    },
  );
}

/// generated route for
/// [_i5.ChatConversationScreen]
class ChatConversationRoute
    extends _i35.PageRouteInfo<ChatConversationRouteArgs> {
  ChatConversationRoute({
    _i36.Key? key,
    required int conversationId,
    _i38.ListingChatConversationBloc? bloc,
    List<_i35.PageRouteInfo>? children,
  }) : super(
         ChatConversationRoute.name,
         args: ChatConversationRouteArgs(
           key: key,
           conversationId: conversationId,
           bloc: bloc,
         ),
         initialChildren: children,
       );

  static const String name = 'ChatConversationRoute';

  static _i35.PageInfo page = _i35.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<ChatConversationRouteArgs>();
      return _i5.ChatConversationScreen(
        key: args.key,
        conversationId: args.conversationId,
        bloc: args.bloc,
      );
    },
  );
}

class ChatConversationRouteArgs {
  const ChatConversationRouteArgs({
    this.key,
    required this.conversationId,
    this.bloc,
  });

  final _i36.Key? key;

  final int conversationId;

  final _i38.ListingChatConversationBloc? bloc;

  @override
  String toString() {
    return 'ChatConversationRouteArgs{key: $key, conversationId: $conversationId, bloc: $bloc}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! ChatConversationRouteArgs) return false;
    return key == other.key &&
        conversationId == other.conversationId &&
        bloc == other.bloc;
  }

  @override
  int get hashCode => key.hashCode ^ conversationId.hashCode ^ bloc.hashCode;
}

/// generated route for
/// [_i6.ChatsScreen]
class ChatsRoute extends _i35.PageRouteInfo<ChatsRouteArgs> {
  ChatsRoute({
    _i36.Key? key,
    _i39.ChatsBloc? bloc,
    bool startImmediately = false,
    List<_i35.PageRouteInfo>? children,
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

  static _i35.PageInfo page = _i35.PageInfo(
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

  final _i36.Key? key;

  final _i39.ChatsBloc? bloc;

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
/// [_i7.CheckYourEmailScreen]
class CheckYourEmailRoute extends _i35.PageRouteInfo<CheckYourEmailRouteArgs> {
  CheckYourEmailRoute({
    _i36.Key? key,
    required _i37.LoginBloc loginBloc,
    List<_i35.PageRouteInfo>? children,
  }) : super(
         CheckYourEmailRoute.name,
         args: CheckYourEmailRouteArgs(key: key, loginBloc: loginBloc),
         initialChildren: children,
       );

  static const String name = 'CheckYourEmailRoute';

  static _i35.PageInfo page = _i35.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<CheckYourEmailRouteArgs>();
      return _i7.CheckYourEmailScreen(key: args.key, loginBloc: args.loginBloc);
    },
  );
}

class CheckYourEmailRouteArgs {
  const CheckYourEmailRouteArgs({this.key, required this.loginBloc});

  final _i36.Key? key;

  final _i37.LoginBloc loginBloc;

  @override
  String toString() {
    return 'CheckYourEmailRouteArgs{key: $key, loginBloc: $loginBloc}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! CheckYourEmailRouteArgs) return false;
    return key == other.key && loginBloc == other.loginBloc;
  }

  @override
  int get hashCode => key.hashCode ^ loginBloc.hashCode;
}

/// generated route for
/// [_i8.ContactUsScreen]
class ContactUsRoute extends _i35.PageRouteInfo<void> {
  const ContactUsRoute({List<_i35.PageRouteInfo>? children})
    : super(ContactUsRoute.name, initialChildren: children);

  static const String name = 'ContactUsRoute';

  static _i35.PageInfo page = _i35.PageInfo(
    name,
    builder: (data) {
      return const _i8.ContactUsScreen();
    },
  );
}

/// generated route for
/// [_i9.ContactUsSubmittedScreen]
class ContactUsSubmittedRoute extends _i35.PageRouteInfo<void> {
  const ContactUsSubmittedRoute({List<_i35.PageRouteInfo>? children})
    : super(ContactUsSubmittedRoute.name, initialChildren: children);

  static const String name = 'ContactUsSubmittedRoute';

  static _i35.PageInfo page = _i35.PageInfo(
    name,
    builder: (data) {
      return const _i9.ContactUsSubmittedScreen();
    },
  );
}

/// generated route for
/// [_i10.CreateYourPasswordScreen]
class CreateYourPasswordRoute
    extends _i35.PageRouteInfo<CreateYourPasswordRouteArgs> {
  CreateYourPasswordRoute({
    _i36.Key? key,
    required _i40.SignupBloc signupBloc,
    List<_i35.PageRouteInfo>? children,
  }) : super(
         CreateYourPasswordRoute.name,
         args: CreateYourPasswordRouteArgs(key: key, signupBloc: signupBloc),
         initialChildren: children,
       );

  static const String name = 'CreateYourPasswordRoute';

  static _i35.PageInfo page = _i35.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<CreateYourPasswordRouteArgs>();
      return _i10.CreateYourPasswordScreen(
        key: args.key,
        signupBloc: args.signupBloc,
      );
    },
  );
}

class CreateYourPasswordRouteArgs {
  const CreateYourPasswordRouteArgs({this.key, required this.signupBloc});

  final _i36.Key? key;

  final _i40.SignupBloc signupBloc;

  @override
  String toString() {
    return 'CreateYourPasswordRouteArgs{key: $key, signupBloc: $signupBloc}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! CreateYourPasswordRouteArgs) return false;
    return key == other.key && signupBloc == other.signupBloc;
  }

  @override
  int get hashCode => key.hashCode ^ signupBloc.hashCode;
}

/// generated route for
/// [_i11.DeleteAccountScreen]
class DeleteAccountRoute extends _i35.PageRouteInfo<void> {
  const DeleteAccountRoute({List<_i35.PageRouteInfo>? children})
    : super(DeleteAccountRoute.name, initialChildren: children);

  static const String name = 'DeleteAccountRoute';

  static _i35.PageInfo page = _i35.PageInfo(
    name,
    builder: (data) {
      return const _i11.DeleteAccountScreen();
    },
  );
}

/// generated route for
/// [_i12.EmptyViewsScreen]
class EmptyViewsRoute extends _i35.PageRouteInfo<void> {
  const EmptyViewsRoute({List<_i35.PageRouteInfo>? children})
    : super(EmptyViewsRoute.name, initialChildren: children);

  static const String name = 'EmptyViewsRoute';

  static _i35.PageInfo page = _i35.PageInfo(
    name,
    builder: (data) {
      return const _i12.EmptyViewsScreen();
    },
  );
}

/// generated route for
/// [_i13.FeedbackScreen]
class FeedbackRoute extends _i35.PageRouteInfo<void> {
  const FeedbackRoute({List<_i35.PageRouteInfo>? children})
    : super(FeedbackRoute.name, initialChildren: children);

  static const String name = 'FeedbackRoute';

  static _i35.PageInfo page = _i35.PageInfo(
    name,
    builder: (data) {
      return const _i13.FeedbackScreen();
    },
  );
}

/// generated route for
/// [_i14.ForceUpdateScreen]
class ForceUpdateRoute extends _i35.PageRouteInfo<ForceUpdateRouteArgs> {
  ForceUpdateRoute({
    _i36.Key? key,
    required bool isMandatoryUpdate,
    List<_i35.PageRouteInfo>? children,
  }) : super(
         ForceUpdateRoute.name,
         args: ForceUpdateRouteArgs(
           key: key,
           isMandatoryUpdate: isMandatoryUpdate,
         ),
         initialChildren: children,
       );

  static const String name = 'ForceUpdateRoute';

  static _i35.PageInfo page = _i35.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<ForceUpdateRouteArgs>();
      return _i14.ForceUpdateScreen(
        key: args.key,
        isMandatoryUpdate: args.isMandatoryUpdate,
      );
    },
  );
}

class ForceUpdateRouteArgs {
  const ForceUpdateRouteArgs({this.key, required this.isMandatoryUpdate});

  final _i36.Key? key;

  final bool isMandatoryUpdate;

  @override
  String toString() {
    return 'ForceUpdateRouteArgs{key: $key, isMandatoryUpdate: $isMandatoryUpdate}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! ForceUpdateRouteArgs) return false;
    return key == other.key && isMandatoryUpdate == other.isMandatoryUpdate;
  }

  @override
  int get hashCode => key.hashCode ^ isMandatoryUpdate.hashCode;
}

/// generated route for
/// [_i15.ForgotPasswordScreen]
class ForgotPasswordRoute extends _i35.PageRouteInfo<ForgotPasswordRouteArgs> {
  ForgotPasswordRoute({
    _i36.Key? key,
    required _i37.LoginBloc loginBloc,
    List<_i35.PageRouteInfo>? children,
  }) : super(
         ForgotPasswordRoute.name,
         args: ForgotPasswordRouteArgs(key: key, loginBloc: loginBloc),
         initialChildren: children,
       );

  static const String name = 'ForgotPasswordRoute';

  static _i35.PageInfo page = _i35.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<ForgotPasswordRouteArgs>();
      return _i15.ForgotPasswordScreen(
        key: args.key,
        loginBloc: args.loginBloc,
      );
    },
  );
}

class ForgotPasswordRouteArgs {
  const ForgotPasswordRouteArgs({this.key, required this.loginBloc});

  final _i36.Key? key;

  final _i37.LoginBloc loginBloc;

  @override
  String toString() {
    return 'ForgotPasswordRouteArgs{key: $key, loginBloc: $loginBloc}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! ForgotPasswordRouteArgs) return false;
    return key == other.key && loginBloc == other.loginBloc;
  }

  @override
  int get hashCode => key.hashCode ^ loginBloc.hashCode;
}

/// generated route for
/// [_i16.HomeScreen]
class HomeRoute extends _i35.PageRouteInfo<void> {
  const HomeRoute({List<_i35.PageRouteInfo>? children})
    : super(HomeRoute.name, initialChildren: children);

  static const String name = 'HomeRoute';

  static _i35.PageInfo page = _i35.PageInfo(
    name,
    builder: (data) {
      return const _i16.HomeScreen();
    },
  );
}

/// generated route for
/// [_i17.InitialScreen]
class InitialRoute extends _i35.PageRouteInfo<void> {
  const InitialRoute({List<_i35.PageRouteInfo>? children})
    : super(InitialRoute.name, initialChildren: children);

  static const String name = 'InitialRoute';

  static _i35.PageInfo page = _i35.PageInfo(
    name,
    builder: (data) {
      return const _i17.InitialScreen();
    },
  );
}

/// generated route for
/// [_i18.ListingDetailScreen]
class ListingDetailRoute extends _i35.PageRouteInfo<ListingDetailRouteArgs> {
  ListingDetailRoute({
    _i36.Key? key,
    required int listingId,
    List<_i35.PageRouteInfo>? children,
  }) : super(
         ListingDetailRoute.name,
         args: ListingDetailRouteArgs(key: key, listingId: listingId),
         initialChildren: children,
       );

  static const String name = 'ListingDetailRoute';

  static _i35.PageInfo page = _i35.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<ListingDetailRouteArgs>();
      return _i18.ListingDetailScreen(key: args.key, listingId: args.listingId);
    },
  );
}

class ListingDetailRouteArgs {
  const ListingDetailRouteArgs({this.key, required this.listingId});

  final _i36.Key? key;

  final int listingId;

  @override
  String toString() {
    return 'ListingDetailRouteArgs{key: $key, listingId: $listingId}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! ListingDetailRouteArgs) return false;
    return key == other.key && listingId == other.listingId;
  }

  @override
  int get hashCode => key.hashCode ^ listingId.hashCode;
}

/// generated route for
/// [_i19.LoginWithEmailPasswordScreen]
class LoginWithEmailPasswordRoute
    extends _i35.PageRouteInfo<LoginWithEmailPasswordRouteArgs> {
  LoginWithEmailPasswordRoute({
    _i36.Key? key,
    required _i37.LoginBloc loginBloc,
    bool isFromDeleteAccount = false,
    List<_i35.PageRouteInfo>? children,
  }) : super(
         LoginWithEmailPasswordRoute.name,
         args: LoginWithEmailPasswordRouteArgs(
           key: key,
           loginBloc: loginBloc,
           isFromDeleteAccount: isFromDeleteAccount,
         ),
         initialChildren: children,
       );

  static const String name = 'LoginWithEmailPasswordRoute';

  static _i35.PageInfo page = _i35.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<LoginWithEmailPasswordRouteArgs>();
      return _i19.LoginWithEmailPasswordScreen(
        key: args.key,
        loginBloc: args.loginBloc,
        isFromDeleteAccount: args.isFromDeleteAccount,
      );
    },
  );
}

class LoginWithEmailPasswordRouteArgs {
  const LoginWithEmailPasswordRouteArgs({
    this.key,
    required this.loginBloc,
    this.isFromDeleteAccount = false,
  });

  final _i36.Key? key;

  final _i37.LoginBloc loginBloc;

  final bool isFromDeleteAccount;

  @override
  String toString() {
    return 'LoginWithEmailPasswordRouteArgs{key: $key, loginBloc: $loginBloc, isFromDeleteAccount: $isFromDeleteAccount}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! LoginWithEmailPasswordRouteArgs) return false;
    return key == other.key &&
        loginBloc == other.loginBloc &&
        isFromDeleteAccount == other.isFromDeleteAccount;
  }

  @override
  int get hashCode =>
      key.hashCode ^ loginBloc.hashCode ^ isFromDeleteAccount.hashCode;
}

/// generated route for
/// [_i20.LoginWithPhoneNumberScreen]
class LoginWithPhoneNumberRoute
    extends _i35.PageRouteInfo<LoginWithPhoneNumberRouteArgs> {
  LoginWithPhoneNumberRoute({
    _i36.Key? key,
    bool isFromDeleteAccount = false,
    List<_i35.PageRouteInfo>? children,
  }) : super(
         LoginWithPhoneNumberRoute.name,
         args: LoginWithPhoneNumberRouteArgs(
           key: key,
           isFromDeleteAccount: isFromDeleteAccount,
         ),
         initialChildren: children,
       );

  static const String name = 'LoginWithPhoneNumberRoute';

  static _i35.PageInfo page = _i35.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<LoginWithPhoneNumberRouteArgs>(
        orElse: () => const LoginWithPhoneNumberRouteArgs(),
      );
      return _i20.LoginWithPhoneNumberScreen(
        key: args.key,
        isFromDeleteAccount: args.isFromDeleteAccount,
      );
    },
  );
}

class LoginWithPhoneNumberRouteArgs {
  const LoginWithPhoneNumberRouteArgs({
    this.key,
    this.isFromDeleteAccount = false,
  });

  final _i36.Key? key;

  final bool isFromDeleteAccount;

  @override
  String toString() {
    return 'LoginWithPhoneNumberRouteArgs{key: $key, isFromDeleteAccount: $isFromDeleteAccount}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! LoginWithPhoneNumberRouteArgs) return false;
    return key == other.key && isFromDeleteAccount == other.isFromDeleteAccount;
  }

  @override
  int get hashCode => key.hashCode ^ isFromDeleteAccount.hashCode;
}

/// generated route for
/// [_i21.NetworkImageScreen]
class NetworkImageRoute extends _i35.PageRouteInfo<NetworkImageRouteArgs> {
  NetworkImageRoute({
    _i36.Key? key,
    required String link,
    List<_i35.PageRouteInfo>? children,
  }) : super(
         NetworkImageRoute.name,
         args: NetworkImageRouteArgs(key: key, link: link),
         initialChildren: children,
       );

  static const String name = 'NetworkImageRoute';

  static _i35.PageInfo page = _i35.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<NetworkImageRouteArgs>();
      return _i21.NetworkImageScreen(key: args.key, link: args.link);
    },
  );
}

class NetworkImageRouteArgs {
  const NetworkImageRouteArgs({this.key, required this.link});

  final _i36.Key? key;

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
/// [_i22.NoInternetScreen]
class NoInternetRoute extends _i35.PageRouteInfo<void> {
  const NoInternetRoute({List<_i35.PageRouteInfo>? children})
    : super(NoInternetRoute.name, initialChildren: children);

  static const String name = 'NoInternetRoute';

  static _i35.PageInfo page = _i35.PageInfo(
    name,
    builder: (data) {
      return const _i22.NoInternetScreen();
    },
  );
}

/// generated route for
/// [_i23.NotificationSettingsScreen]
class NotificationSettingsRoute extends _i35.PageRouteInfo<void> {
  const NotificationSettingsRoute({List<_i35.PageRouteInfo>? children})
    : super(NotificationSettingsRoute.name, initialChildren: children);

  static const String name = 'NotificationSettingsRoute';

  static _i35.PageInfo page = _i35.PageInfo(
    name,
    builder: (data) {
      return const _i23.NotificationSettingsScreen();
    },
  );
}

/// generated route for
/// [_i24.NotificationsScreen]
class NotificationsRoute extends _i35.PageRouteInfo<NotificationsRouteArgs> {
  NotificationsRoute({
    _i41.NotificationBloc? bloc,
    _i36.Key? key,
    List<_i35.PageRouteInfo>? children,
  }) : super(
         NotificationsRoute.name,
         args: NotificationsRouteArgs(bloc: bloc, key: key),
         initialChildren: children,
       );

  static const String name = 'NotificationsRoute';

  static _i35.PageInfo page = _i35.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<NotificationsRouteArgs>(
        orElse: () => const NotificationsRouteArgs(),
      );
      return _i24.NotificationsScreen(bloc: args.bloc, key: args.key);
    },
  );
}

class NotificationsRouteArgs {
  const NotificationsRouteArgs({this.bloc, this.key});

  final _i41.NotificationBloc? bloc;

  final _i36.Key? key;

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
/// [_i25.PersonalDetailsScreen]
class PersonalDetailsRoute
    extends _i35.PageRouteInfo<PersonalDetailsRouteArgs> {
  PersonalDetailsRoute({
    _i36.Key? key,
    required _i42.ProfileBloc profileBloc,
    List<_i35.PageRouteInfo>? children,
  }) : super(
         PersonalDetailsRoute.name,
         args: PersonalDetailsRouteArgs(key: key, profileBloc: profileBloc),
         initialChildren: children,
       );

  static const String name = 'PersonalDetailsRoute';

  static _i35.PageInfo page = _i35.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<PersonalDetailsRouteArgs>();
      return _i25.PersonalDetailsScreen(
        key: args.key,
        profileBloc: args.profileBloc,
      );
    },
  );
}

class PersonalDetailsRouteArgs {
  const PersonalDetailsRouteArgs({this.key, required this.profileBloc});

  final _i36.Key? key;

  final _i42.ProfileBloc profileBloc;

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
/// [_i26.PhoneNumberOTPScreen]
class PhoneNumberOTPRoute extends _i35.PageRouteInfo<PhoneNumberOTPRouteArgs> {
  PhoneNumberOTPRoute({
    _i36.Key? key,
    required _i37.LoginBloc loginBloc,
    bool isFromDeleteAccount = false,
    List<_i35.PageRouteInfo>? children,
  }) : super(
         PhoneNumberOTPRoute.name,
         args: PhoneNumberOTPRouteArgs(
           key: key,
           loginBloc: loginBloc,
           isFromDeleteAccount: isFromDeleteAccount,
         ),
         initialChildren: children,
       );

  static const String name = 'PhoneNumberOTPRoute';

  static _i35.PageInfo page = _i35.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<PhoneNumberOTPRouteArgs>();
      return _i26.PhoneNumberOTPScreen(
        key: args.key,
        loginBloc: args.loginBloc,
        isFromDeleteAccount: args.isFromDeleteAccount,
      );
    },
  );
}

class PhoneNumberOTPRouteArgs {
  const PhoneNumberOTPRouteArgs({
    this.key,
    required this.loginBloc,
    this.isFromDeleteAccount = false,
  });

  final _i36.Key? key;

  final _i37.LoginBloc loginBloc;

  final bool isFromDeleteAccount;

  @override
  String toString() {
    return 'PhoneNumberOTPRouteArgs{key: $key, loginBloc: $loginBloc, isFromDeleteAccount: $isFromDeleteAccount}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! PhoneNumberOTPRouteArgs) return false;
    return key == other.key &&
        loginBloc == other.loginBloc &&
        isFromDeleteAccount == other.isFromDeleteAccount;
  }

  @override
  int get hashCode =>
      key.hashCode ^ loginBloc.hashCode ^ isFromDeleteAccount.hashCode;
}

/// generated route for
/// [_i27.PhoneNumberVerifiedScreen]
class PhoneNumberVerifiedRoute
    extends _i35.PageRouteInfo<PhoneNumberVerifiedRouteArgs> {
  PhoneNumberVerifiedRoute({
    _i36.Key? key,
    required _i37.LoginBloc loginBloc,
    List<_i35.PageRouteInfo>? children,
  }) : super(
         PhoneNumberVerifiedRoute.name,
         args: PhoneNumberVerifiedRouteArgs(key: key, loginBloc: loginBloc),
         initialChildren: children,
       );

  static const String name = 'PhoneNumberVerifiedRoute';

  static _i35.PageInfo page = _i35.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<PhoneNumberVerifiedRouteArgs>();
      return _i27.PhoneNumberVerifiedScreen(
        key: args.key,
        loginBloc: args.loginBloc,
      );
    },
  );
}

class PhoneNumberVerifiedRouteArgs {
  const PhoneNumberVerifiedRouteArgs({this.key, required this.loginBloc});

  final _i36.Key? key;

  final _i37.LoginBloc loginBloc;

  @override
  String toString() {
    return 'PhoneNumberVerifiedRouteArgs{key: $key, loginBloc: $loginBloc}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! PhoneNumberVerifiedRouteArgs) return false;
    return key == other.key && loginBloc == other.loginBloc;
  }

  @override
  int get hashCode => key.hashCode ^ loginBloc.hashCode;
}

/// generated route for
/// [_i28.ReminderScreen]
class ReminderRoute extends _i35.PageRouteInfo<void> {
  const ReminderRoute({List<_i35.PageRouteInfo>? children})
    : super(ReminderRoute.name, initialChildren: children);

  static const String name = 'ReminderRoute';

  static _i35.PageInfo page = _i35.PageInfo(
    name,
    builder: (data) {
      return const _i28.ReminderScreen();
    },
  );
}

/// generated route for
/// [_i29.ServerErrorScreen]
class ServerErrorRoute extends _i35.PageRouteInfo<void> {
  const ServerErrorRoute({List<_i35.PageRouteInfo>? children})
    : super(ServerErrorRoute.name, initialChildren: children);

  static const String name = 'ServerErrorRoute';

  static _i35.PageInfo page = _i35.PageInfo(
    name,
    builder: (data) {
      return const _i29.ServerErrorScreen();
    },
  );
}

/// generated route for
/// [_i30.SettingsScreen]
class SettingsRoute extends _i35.PageRouteInfo<void> {
  const SettingsRoute({List<_i35.PageRouteInfo>? children})
    : super(SettingsRoute.name, initialChildren: children);

  static const String name = 'SettingsRoute';

  static _i35.PageInfo page = _i35.PageInfo(
    name,
    builder: (data) {
      return const _i30.SettingsScreen();
    },
  );
}

/// generated route for
/// [_i31.SignupWithEmailPasswordScreen]
class SignupWithEmailPasswordRoute
    extends _i35.PageRouteInfo<SignupWithEmailPasswordRouteArgs> {
  SignupWithEmailPasswordRoute({
    _i36.Key? key,
    _i40.SignupBloc? signupBloc,
    List<_i35.PageRouteInfo>? children,
  }) : super(
         SignupWithEmailPasswordRoute.name,
         args: SignupWithEmailPasswordRouteArgs(
           key: key,
           signupBloc: signupBloc,
         ),
         initialChildren: children,
       );

  static const String name = 'SignupWithEmailPasswordRoute';

  static _i35.PageInfo page = _i35.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<SignupWithEmailPasswordRouteArgs>(
        orElse: () => const SignupWithEmailPasswordRouteArgs(),
      );
      return _i31.SignupWithEmailPasswordScreen(
        key: args.key,
        signupBloc: args.signupBloc,
      );
    },
  );
}

class SignupWithEmailPasswordRouteArgs {
  const SignupWithEmailPasswordRouteArgs({this.key, this.signupBloc});

  final _i36.Key? key;

  final _i40.SignupBloc? signupBloc;

  @override
  String toString() {
    return 'SignupWithEmailPasswordRouteArgs{key: $key, signupBloc: $signupBloc}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! SignupWithEmailPasswordRouteArgs) return false;
    return key == other.key && signupBloc == other.signupBloc;
  }

  @override
  int get hashCode => key.hashCode ^ signupBloc.hashCode;
}

/// generated route for
/// [_i32.SslConnectionFailedScreen]
class SslConnectionFailedRoute extends _i35.PageRouteInfo<void> {
  const SslConnectionFailedRoute({List<_i35.PageRouteInfo>? children})
    : super(SslConnectionFailedRoute.name, initialChildren: children);

  static const String name = 'SslConnectionFailedRoute';

  static _i35.PageInfo page = _i35.PageInfo(
    name,
    builder: (data) {
      return const _i32.SslConnectionFailedScreen();
    },
  );
}

/// generated route for
/// [_i33.UnderMaintenanceScreen]
class UnderMaintenanceRoute extends _i35.PageRouteInfo<void> {
  const UnderMaintenanceRoute({List<_i35.PageRouteInfo>? children})
    : super(UnderMaintenanceRoute.name, initialChildren: children);

  static const String name = 'UnderMaintenanceRoute';

  static _i35.PageInfo page = _i35.PageInfo(
    name,
    builder: (data) {
      return const _i33.UnderMaintenanceScreen();
    },
  );
}

/// generated route for
/// [_i34.VerifyEmailScreen]
class VerifyEmailRoute extends _i35.PageRouteInfo<VerifyEmailRouteArgs> {
  VerifyEmailRoute({
    _i36.Key? key,
    required String email,
    bool isSignUp = false,
    List<_i35.PageRouteInfo>? children,
  }) : super(
         VerifyEmailRoute.name,
         args: VerifyEmailRouteArgs(key: key, email: email, isSignUp: isSignUp),
         initialChildren: children,
       );

  static const String name = 'VerifyEmailRoute';

  static _i35.PageInfo page = _i35.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<VerifyEmailRouteArgs>();
      return _i34.VerifyEmailScreen(
        key: args.key,
        email: args.email,
        isSignUp: args.isSignUp,
      );
    },
  );
}

class VerifyEmailRouteArgs {
  const VerifyEmailRouteArgs({
    this.key,
    required this.email,
    this.isSignUp = false,
  });

  final _i36.Key? key;

  final String email;

  final bool isSignUp;

  @override
  String toString() {
    return 'VerifyEmailRouteArgs{key: $key, email: $email, isSignUp: $isSignUp}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! VerifyEmailRouteArgs) return false;
    return key == other.key &&
        email == other.email &&
        isSignUp == other.isSignUp;
  }

  @override
  int get hashCode => key.hashCode ^ email.hashCode ^ isSignUp.hashCode;
}
