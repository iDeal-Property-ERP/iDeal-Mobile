import 'package:flutter/foundation.dart';
import 'package:ideal_mobile/i18n/app_localizations.dart';
import 'package:ideal_mobile/presentation/subscription/model/subscription_package_model.dart';

/// Subscription facade kept ready for the backend billing implementation.
///
/// Store billing was removed from the mobile client. Keeping this small
/// interface lets the existing subscription screens compile while backend
/// subscription endpoints are introduced.
class SubscriptionService {
  factory SubscriptionService() => _instance;

  SubscriptionService._internal();

  static final _instance = SubscriptionService._internal();

  final ValueNotifier<bool> isUserSubscribed = ValueNotifier<bool>(false);
  AppLocalizations? _localization;

  void setLocalization(AppLocalizations localization) {
    _localization = localization;
  }

  Future<List<SubscriptionPackageModel>> getPackages() async => const [];

  Future<bool> restorePurchases() async => false;

  Future<bool> purchasePackage(
    SubscriptionPackageModel package, {
    required Function(String, {StackTrace? stackTrace}) onError,
  }) async {
    onError(
      _localization?.something_went_wrong ??
          'Subscriptions are unavailable until backend billing is connected.',
    );
    return false;
  }

  Future<String?> getUserManagementUrl() async => null;
}
