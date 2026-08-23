import 'package:equatable/equatable.dart';

class MobileContract extends Equatable {
  const MobileContract({
    required this.id,
    required this.reference,
    required this.propertyId,
    required this.propertyTitle,
    required this.propertyAddress,
    required this.startDate,
    required this.endDate,
    required this.monthlyRent,
    required this.currency,
    required this.status,
    required this.statusDisplay,
    this.documentUrl,
  });

  final int id;
  final String reference;
  final int propertyId;
  final String propertyTitle;
  final String propertyAddress;
  final String startDate;
  final String endDate;
  final double monthlyRent;
  final String currency;
  final String status;
  final String statusDisplay;
  final String? documentUrl;

  @override
  List<Object?> get props => [
    id,
    reference,
    propertyId,
    propertyTitle,
    propertyAddress,
    startDate,
    endDate,
    monthlyRent,
    currency,
    status,
    statusDisplay,
    documentUrl,
  ];
}
