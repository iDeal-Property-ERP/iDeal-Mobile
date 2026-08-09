enum NotificationKind {
  paymentDue('payment_due'),
  paymentPaid('payment_paid'),
  payoutPaid('payout_paid'),
  bookingStatus('booking_status'),
  serviceRequestStatus('service_request_status'),
  serviceOrderStatus('service_order_status'),
  leaseRenewal('lease_renewal'),
  ownerOnboarding('owner_onboarding'),
  general('general'),
  unknown('unknown');

  const NotificationKind(this._apiValue);

  final String _apiValue;

  String get apiValue => _apiValue;

  static NotificationKind fromApi(String value) {
    for (final kind in values) {
      if (kind.apiValue == value) return kind;
    }
    return NotificationKind.unknown;
  }
}

enum NotificationCategory {
  payments('payments'),
  bookings('bookings'),
  maintenance('maintenance'),
  leases('leases'),
  general('general');

  const NotificationCategory(this._apiValue);

  final String _apiValue;

  String get apiValue => _apiValue;

  static NotificationCategory fromApi(String value) {
    for (final category in values) {
      if (category.apiValue == value) return category;
    }
    return NotificationCategory.general;
  }
}
