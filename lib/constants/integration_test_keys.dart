import 'package:flutter/foundation.dart';

class LoginPageKeys {
  final mobileNoTextField = const Key('mobileNoTextField');
  final otpTextField = const Key('otpTextField');
  final sendOTPButton = const Key('sendOTPButton');
  final emailTextField = const Key('emailTextField');
  final passwordTextField = const Key('passwordTextField');
  final loginWithEmailButton = const Key('loginWithEmailButton');
  final continueWithEmailButton = const Key('continueWithEmailButton');
  final continueWithGoogleButton = const Key('continueWithGoogleButton');
}

class SignupPageKeys {
  final signupEmailTextField = const Key('signupEmailTextField');
  final signupEmailNextButton = const Key('signupEmailNextButton');
  final signupPasswordTextField = const Key('signupPasswordTextField');
  final signupConfirmPasswordTextField = const Key(
    'signupConfirmPasswordTextField',
  );
  final signupPasswordNextButton = const Key('signupPasswordNextButton');
  final signupWithEmailButton = const Key('signupWithEmailButton');
}

class HomePageKeys {
  final productCardKey = const Key('productCardKey');
  final listingsFeedKey = const Key('listingsFeedKey');
  final bannerCarouselKey = const Key('homeBannerCarouselKey');
  final bannerIndicatorKey = const Key('homeBannerIndicatorKey');
  final allFiltersButtonKey = const Key('homeAllFiltersButtonKey');

  /// Per-listing so sibling tiles in the feed never share a key. Integration
  /// tests can target one card by id, or match the `listingCard_` prefix.
  Key listingCardKey(int listingId) => ValueKey('listingCard_$listingId');
}

class ListingDetailPageKeys {
  final screen = const Key('listingDetailScreen');
  final hero = const Key('listingDetailHero');
  final messageButton = const Key('listingDetailMessageButton');
  final callButton = const Key('listingDetailCallButton');
  final bookButton = const Key('listingDetailBookButton');
}

class ListingDateFilterKeys {
  final field = const Key('listingDateFilterField');
  final rangeSelector = const Key('listingDateRangeSelector');
  final flexibilityDecrease = const Key('listingFlexibilityDecrease');
  final flexibilityIncrease = const Key('listingFlexibilityIncrease');
  final flexibilityValue = const Key('listingFlexibilityValue');
  final clearDates = const Key('listingClearDatesButton');
  final sheet = const Key('listingDateFilterSheet');
  final cancel = const Key('listingDateFilterCancelButton');
}

class Keys {
  final signInPage = LoginPageKeys();
  final signupPage = SignupPageKeys();
  final homePage = HomePageKeys();
  final listingDetail = ListingDetailPageKeys();
  final dateFilter = ListingDateFilterKeys();
}

final keys = Keys();
