import 'package:equatable/equatable.dart';

class SubscriptionPackageModel extends Equatable {
  final String identifier;
  final String price;
  final String title;
  final String description;

  const SubscriptionPackageModel({
    required this.identifier,
    required this.price,
    required this.title,
    required this.description,
  });

  @override
  List<Object?> get props => [identifier, price, title, description];
}
