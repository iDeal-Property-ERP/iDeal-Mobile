import 'package:equatable/equatable.dart';
import 'package:ideal_mobile/presentation/subscription/model/subscription_package_model.dart';

abstract class SubscriptionEvent extends Equatable {
  const SubscriptionEvent();

  @override
  List<Object> get props => [];
}

class FetchSubscriptionPackagesEvent extends SubscriptionEvent {
  const FetchSubscriptionPackagesEvent();

  @override
  List<Object> get props => [];
}

class SelectSubscriptionPlanEvent extends SubscriptionEvent {
  const SelectSubscriptionPlanEvent({
    required this.selectedPackage,
    required this.packages,
  });

  final SubscriptionPackageModel selectedPackage;
  final List<SubscriptionPackageModel> packages;

  @override
  List<Object> get props => [selectedPackage, packages];
}

class PurchaseSubscriptionEvent extends SubscriptionEvent {
  const PurchaseSubscriptionEvent({required this.package});

  final SubscriptionPackageModel package;

  @override
  List<Object> get props => [package];
}

class RestoreSubscriptionEvent extends SubscriptionEvent {
  const RestoreSubscriptionEvent();

  @override
  List<Object> get props => [];
}

class ClearSnackBarMessageEvent extends SubscriptionEvent {
  const ClearSnackBarMessageEvent();

  @override
  List<Object> get props => [];
}
