import 'package:flutter_test/flutter_test.dart';
import 'package:ideal_mobile/presentation/contracts/data/models/mobile_contract_model.dart';

void main() {
  test('parses the mobile contracts API payload', () {
    final contract = MobileContractModel.fromJson({
      'id': 42,
      'reference': '#42',
      'property': {
        'id': 7,
        'title': 'Tenant contract home',
        'address': '12 Amir Temur Street',
      },
      'start_date': '2026-02-01',
      'end_date': '2027-02-01',
      'monthly_rent': '850.00',
      'currency': 'USD',
      'status': 'active',
      'status_display': 'Active',
      'document_url': null,
    });

    expect(contract.id, 42);
    expect(contract.propertyTitle, 'Tenant contract home');
    expect(contract.monthlyRent, 850);
    expect(contract.documentUrl, isNull);
  });

  test(
    'rejects an API payload without the lease data required by the sheet',
    () {
      expect(
        () => MobileContractModel.fromJson({'id': 42, 'reference': '#42'}),
        throwsFormatException,
      );
    },
  );
}
