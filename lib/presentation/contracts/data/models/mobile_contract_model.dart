import 'package:ideal_mobile/presentation/contracts/domain/entities/mobile_contract.dart';

class MobileContractModel extends MobileContract {
  const MobileContractModel({
    required super.id,
    required super.reference,
    required super.propertyId,
    required super.propertyTitle,
    required super.propertyAddress,
    required super.startDate,
    required super.endDate,
    required super.monthlyRent,
    required super.currency,
    required super.status,
    required super.statusDisplay,
    super.documentUrl,
  });

  factory MobileContractModel.fromJson(Map<String, dynamic> json) {
    final property = json['property'];
    final monthlyRent = json['monthly_rent'];
    if (json['id'] is! int ||
        json['reference'] is! String ||
        property is! Map ||
        property['id'] is! int ||
        property['title'] is! String ||
        property['address'] is! String ||
        json['start_date'] is! String ||
        json['end_date'] is! String ||
        json['currency'] is! String ||
        json['status'] is! String ||
        json['status_display'] is! String) {
      throw const FormatException('Invalid mobile contract data.');
    }

    final parsedMonthlyRent = switch (monthlyRent) {
      final num value => value.toDouble(),
      final String value => double.tryParse(value),
      _ => null,
    };
    if (parsedMonthlyRent == null) {
      throw const FormatException('Invalid mobile contract monthly rent.');
    }

    return MobileContractModel(
      id: json['id'] as int,
      reference: json['reference'] as String,
      propertyId: property['id'] as int,
      propertyTitle: property['title'] as String,
      propertyAddress: property['address'] as String,
      startDate: json['start_date'] as String,
      endDate: json['end_date'] as String,
      monthlyRent: parsedMonthlyRent,
      currency: json['currency'] as String,
      status: json['status'] as String,
      statusDisplay: json['status_display'] as String,
      documentUrl: json['document_url'] as String?,
    );
  }
}
