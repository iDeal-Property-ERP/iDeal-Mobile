import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_uz.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'i18n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ru'),
    Locale('uz'),
  ];

  /// No description provided for @common_keys.
  ///
  /// In en, this message translates to:
  /// **'================ COMMON KEYS ================'**
  String get common_keys;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @camera.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get camera;

  /// No description provided for @gallery.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get gallery;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @or.
  ///
  /// In en, this message translates to:
  /// **'Or'**
  String get or;

  /// No description provided for @remove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get remove;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @opps_something_went_wrong.
  ///
  /// In en, this message translates to:
  /// **'Opps Something Went Wrong'**
  String get opps_something_went_wrong;

  /// No description provided for @time_date_keys.
  ///
  /// In en, this message translates to:
  /// **'================ TIME & DATE KEYS ================'**
  String get time_date_keys;

  /// Indicates how many days ago
  ///
  /// In en, this message translates to:
  /// **'{count} days ago'**
  String daysAgo(int count);

  /// Indicates how many hours ago
  ///
  /// In en, this message translates to:
  /// **'{count} hrs ago'**
  String hoursAgo(int count);

  /// No description provided for @justNow.
  ///
  /// In en, this message translates to:
  /// **'Just now'**
  String get justNow;

  /// No description provided for @lastMonth.
  ///
  /// In en, this message translates to:
  /// **'Last month'**
  String get lastMonth;

  /// No description provided for @lastYear.
  ///
  /// In en, this message translates to:
  /// **'Last year'**
  String get lastYear;

  /// Indicates how many minutes ago
  ///
  /// In en, this message translates to:
  /// **'{count} min ago'**
  String minutesAgo(int count);

  /// Indicates how many months ago
  ///
  /// In en, this message translates to:
  /// **'{count} months ago'**
  String monthsAgo(int count);

  /// No description provided for @oneHourAgo.
  ///
  /// In en, this message translates to:
  /// **'1 hr ago'**
  String get oneHourAgo;

  /// No description provided for @oneMinuteAgo.
  ///
  /// In en, this message translates to:
  /// **'1 min ago'**
  String get oneMinuteAgo;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// Indicates how many years ago
  ///
  /// In en, this message translates to:
  /// **'{count} years ago'**
  String yearsAgo(int count);

  /// No description provided for @yesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterday;

  /// No description provided for @login_keys.
  ///
  /// In en, this message translates to:
  /// **'================ LOGIN KEYS ================'**
  String get login_keys;

  /// No description provided for @ask_forgot_password.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get ask_forgot_password;

  /// No description provided for @check_your_email.
  ///
  /// In en, this message translates to:
  /// **'Check Your Email'**
  String get check_your_email;

  /// No description provided for @resend.
  ///
  /// In en, this message translates to:
  /// **'Resend'**
  String get resend;

  /// No description provided for @login_continue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get login_continue;

  /// No description provided for @continue_with_apple.
  ///
  /// In en, this message translates to:
  /// **'Continue with Apple'**
  String get continue_with_apple;

  /// No description provided for @continue_with_email.
  ///
  /// In en, this message translates to:
  /// **'Continue with Email'**
  String get continue_with_email;

  /// No description provided for @continue_with_google.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get continue_with_google;

  /// No description provided for @continue_with_number.
  ///
  /// In en, this message translates to:
  /// **'Continue with Phone Number'**
  String get continue_with_number;

  /// No description provided for @enter_otp.
  ///
  /// In en, this message translates to:
  /// **'Enter OTP'**
  String get enter_otp;

  /// No description provided for @enter_phone_number.
  ///
  /// In en, this message translates to:
  /// **'Enter phone number'**
  String get enter_phone_number;

  /// No description provided for @enter_your_registered_phone_number.
  ///
  /// In en, this message translates to:
  /// **'Enter your registered phone number'**
  String get enter_your_registered_phone_number;

  /// No description provided for @forgot_password.
  ///
  /// In en, this message translates to:
  /// **'Forgot password'**
  String get forgot_password;

  /// No description provided for @invalid_mobile_number.
  ///
  /// In en, this message translates to:
  /// **'Invalid mobile number'**
  String get invalid_mobile_number;

  /// Email where reset link has been sent
  ///
  /// In en, this message translates to:
  /// **'A reset link has been sent to {email}. Please check your inbox and click the link to reset the password.'**
  String link_send_info(String email);

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @log_in.
  ///
  /// In en, this message translates to:
  /// **'Log in'**
  String get log_in;

  /// No description provided for @sign_in.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get sign_in;

  /// No description provided for @login_terms_notice.
  ///
  /// In en, this message translates to:
  /// **'By continuing, you agree to our'**
  String get login_terms_notice;

  /// No description provided for @sign_in_required_title.
  ///
  /// In en, this message translates to:
  /// **'Make iDeal work for you'**
  String get sign_in_required_title;

  /// No description provided for @sign_in_required_message.
  ///
  /// In en, this message translates to:
  /// **'Sign in to save homes, start secure conversations, and manage your bookings in one place.'**
  String get sign_in_required_message;

  /// No description provided for @guest_access_sign_in.
  ///
  /// In en, this message translates to:
  /// **'Sign in with phone'**
  String get guest_access_sign_in;

  /// No description provided for @guest_access_keep_browsing.
  ///
  /// In en, this message translates to:
  /// **'Keep browsing'**
  String get guest_access_keep_browsing;

  /// No description provided for @login_with_email.
  ///
  /// In en, this message translates to:
  /// **'Login with email'**
  String get login_with_email;

  /// No description provided for @send_otp.
  ///
  /// In en, this message translates to:
  /// **'Send OTP'**
  String get send_otp;

  /// No description provided for @otp_channel_confirmation.
  ///
  /// In en, this message translates to:
  /// **'Is the number correct?'**
  String get otp_channel_confirmation;

  /// No description provided for @otp_channel_telegram.
  ///
  /// In en, this message translates to:
  /// **'Via Telegram (recommended)'**
  String get otp_channel_telegram;

  /// No description provided for @otp_channel_sms.
  ///
  /// In en, this message translates to:
  /// **'Via SMS'**
  String get otp_channel_sms;

  /// No description provided for @otp_channel_edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get otp_channel_edit;

  /// No description provided for @send_reset_link.
  ///
  /// In en, this message translates to:
  /// **'Send Reset Link'**
  String get send_reset_link;

  /// No description provided for @sent_code_info.
  ///
  /// In en, this message translates to:
  /// **'We’ve sent a 6-digit code to'**
  String get sent_code_info;

  /// No description provided for @welcome_back.
  ///
  /// In en, this message translates to:
  /// **'Welcome back!'**
  String get welcome_back;

  /// No description provided for @signup_keys.
  ///
  /// In en, this message translates to:
  /// **'================ SIGNUP KEYS ================'**
  String get signup_keys;

  /// No description provided for @already_have_account.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? '**
  String get already_have_account;

  /// No description provided for @back_to_login.
  ///
  /// In en, this message translates to:
  /// **'Back to login'**
  String get back_to_login;

  /// No description provided for @confirm_password.
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get confirm_password;

  /// No description provided for @confirm_password_hint.
  ///
  /// In en, this message translates to:
  /// **'Enter confirm password'**
  String get confirm_password_hint;

  /// No description provided for @change_email.
  ///
  /// In en, this message translates to:
  /// **' Change Email'**
  String get change_email;

  /// No description provided for @create_your_password.
  ///
  /// In en, this message translates to:
  /// **'Create your password'**
  String get create_your_password;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @first_name.
  ///
  /// In en, this message translates to:
  /// **'First name'**
  String get first_name;

  /// No description provided for @last_name.
  ///
  /// In en, this message translates to:
  /// **'Last name'**
  String get last_name;

  /// No description provided for @patronymic.
  ///
  /// In en, this message translates to:
  /// **'Patronymic'**
  String get patronymic;

  /// No description provided for @nationality.
  ///
  /// In en, this message translates to:
  /// **'Nationality'**
  String get nationality;

  /// No description provided for @email_cant_be_empty.
  ///
  /// In en, this message translates to:
  /// **'Email can’t be empty'**
  String get email_cant_be_empty;

  /// No description provided for @email_hint.
  ///
  /// In en, this message translates to:
  /// **'Enter email'**
  String get email_hint;

  /// No description provided for @email_id.
  ///
  /// In en, this message translates to:
  /// **'Email Id'**
  String get email_id;

  /// No description provided for @enter_your_email_id.
  ///
  /// In en, this message translates to:
  /// **'Enter your email id'**
  String get enter_your_email_id;

  /// No description provided for @enter_your_name.
  ///
  /// In en, this message translates to:
  /// **'Enter your name'**
  String get enter_your_name;

  /// No description provided for @entered_wrong_email.
  ///
  /// In en, this message translates to:
  /// **'Entered the wrong email?'**
  String get entered_wrong_email;

  /// No description provided for @error_enter_confirm_password.
  ///
  /// In en, this message translates to:
  /// **'Please enter confirm password'**
  String get error_enter_confirm_password;

  /// No description provided for @error_retrieving_email.
  ///
  /// In en, this message translates to:
  /// **'Error retrieving your email'**
  String get error_retrieving_email;

  /// No description provided for @error_retrieving_phone_number.
  ///
  /// In en, this message translates to:
  /// **'Error retrieving your phone number'**
  String get error_retrieving_phone_number;

  /// No description provided for @invalid_email.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email address'**
  String get invalid_email;

  /// No description provided for @lets_get_started.
  ///
  /// In en, this message translates to:
  /// **'Let\'s get started'**
  String get lets_get_started;

  /// No description provided for @lets_get_started_info.
  ///
  /// In en, this message translates to:
  /// **'Enter your phone number, we will send you a verification code'**
  String get lets_get_started_info;

  /// Email where verification link has been sent
  ///
  /// In en, this message translates to:
  /// **'A verification link has been sent to {email}. Click the link to verify your account.'**
  String link_verify_info(String email);

  /// No description provided for @mobile_number.
  ///
  /// In en, this message translates to:
  /// **'Mobile number'**
  String get mobile_number;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @name_cannot_be_empty.
  ///
  /// In en, this message translates to:
  /// **'Name can\'t be empty'**
  String get name_cannot_be_empty;

  /// No description provided for @no_account.
  ///
  /// In en, this message translates to:
  /// **'Don’t have an account? '**
  String get no_account;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @password_cant_be_empty.
  ///
  /// In en, this message translates to:
  /// **'Password can\'t be empty'**
  String get password_cant_be_empty;

  /// No description provided for @password_hint.
  ///
  /// In en, this message translates to:
  /// **'Enter password'**
  String get password_hint;

  /// No description provided for @password_requirements.
  ///
  /// In en, this message translates to:
  /// **'Your password must have at least:'**
  String get password_requirements;

  /// No description provided for @password_requirements_length.
  ///
  /// In en, this message translates to:
  /// **'8 characters or more'**
  String get password_requirements_length;

  /// No description provided for @password_requirements_letter_number.
  ///
  /// In en, this message translates to:
  /// **'1 letter and number'**
  String get password_requirements_letter_number;

  /// No description provided for @password_requirements_special_char.
  ///
  /// In en, this message translates to:
  /// **'1 special character (Example: # ? ! \$ & @)'**
  String get password_requirements_special_char;

  /// No description provided for @password_strength.
  ///
  /// In en, this message translates to:
  /// **'Password strength:'**
  String get password_strength;

  /// No description provided for @passwords_do_not_match.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwords_do_not_match;

  /// No description provided for @phone_no_verified.
  ///
  /// In en, this message translates to:
  /// **'Phone number verified!'**
  String get phone_no_verified;

  /// No description provided for @phone_no_verified_info.
  ///
  /// In en, this message translates to:
  /// **'Your Phone number has been successfully verified. You can now complete your profile.'**
  String get phone_no_verified_info;

  /// No description provided for @poor.
  ///
  /// In en, this message translates to:
  /// **'Poor'**
  String get poor;

  /// No description provided for @sign_up.
  ///
  /// In en, this message translates to:
  /// **'Sign up'**
  String get sign_up;

  /// No description provided for @sign_up_with_apple.
  ///
  /// In en, this message translates to:
  /// **'Sign up with Apple'**
  String get sign_up_with_apple;

  /// No description provided for @sign_up_with_email.
  ///
  /// In en, this message translates to:
  /// **'Sign up with Email'**
  String get sign_up_with_email;

  /// No description provided for @sign_up_with_google.
  ///
  /// In en, this message translates to:
  /// **'Sign up with Google'**
  String get sign_up_with_google;

  /// No description provided for @strong.
  ///
  /// In en, this message translates to:
  /// **'Strong'**
  String get strong;

  /// No description provided for @terms_and_conditions.
  ///
  /// In en, this message translates to:
  /// **'Terms and Conditions'**
  String get terms_and_conditions;

  /// No description provided for @user_info_not_retrieved.
  ///
  /// In en, this message translates to:
  /// **'User information could not be retrieved.'**
  String get user_info_not_retrieved;

  /// No description provided for @weak.
  ///
  /// In en, this message translates to:
  /// **'Weak'**
  String get weak;

  /// No description provided for @verify.
  ///
  /// In en, this message translates to:
  /// **'Verify'**
  String get verify;

  /// No description provided for @verify_email_keys.
  ///
  /// In en, this message translates to:
  /// **'================ VERIFY EMAIL KEYS ================'**
  String get verify_email_keys;

  /// No description provided for @resend_verification_email.
  ///
  /// In en, this message translates to:
  /// **'Resend Verification Email'**
  String get resend_verification_email;

  /// No description provided for @verify_your_email.
  ///
  /// In en, this message translates to:
  /// **'Verify your email'**
  String get verify_your_email;

  /// No description provided for @profile_keys.
  ///
  /// In en, this message translates to:
  /// **'================ PROFILE KEYS ================'**
  String get profile_keys;

  /// No description provided for @account.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// No description provided for @add_a_profile_picture.
  ///
  /// In en, this message translates to:
  /// **'Add a profile picture'**
  String get add_a_profile_picture;

  /// No description provided for @personal_details.
  ///
  /// In en, this message translates to:
  /// **'Personal Details'**
  String get personal_details;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @help_and_support.
  ///
  /// In en, this message translates to:
  /// **'Help & Support'**
  String get help_and_support;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @rotate.
  ///
  /// In en, this message translates to:
  /// **'Rotate'**
  String get rotate;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @sign_out.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get sign_out;

  /// No description provided for @sign_out_confirmation_message.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to sign out?'**
  String get sign_out_confirmation_message;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @preferences.
  ///
  /// In en, this message translates to:
  /// **'Preferences'**
  String get preferences;

  /// No description provided for @appearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get version;

  /// No description provided for @activity.
  ///
  /// In en, this message translates to:
  /// **'Activity'**
  String get activity;

  /// No description provided for @my_orders.
  ///
  /// In en, this message translates to:
  /// **'My Orders'**
  String get my_orders;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @feedback_and_ratings.
  ///
  /// In en, this message translates to:
  /// **'Feedback & Ratings'**
  String get feedback_and_ratings;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @delete_account_keys.
  ///
  /// In en, this message translates to:
  /// **'================ DELETE ACCOUNT KEYS ================'**
  String get delete_account_keys;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @delete_account.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get delete_account;

  /// No description provided for @delete_account_alert_title.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to Delete Account?'**
  String get delete_account_alert_title;

  /// No description provided for @delete_account_confirmation_message.
  ///
  /// In en, this message translates to:
  /// **'This action is irreversible. Your account and reusable personal data will be deleted. Records retained for legal, service, or dispute purposes will be anonymized. Do you want to continue?'**
  String get delete_account_confirmation_message;

  /// No description provided for @delete_reason_dislike_app.
  ///
  /// In en, this message translates to:
  /// **'I don’t like to be on this app'**
  String get delete_reason_dislike_app;

  /// No description provided for @delete_reason_do_not_need_anymore.
  ///
  /// In en, this message translates to:
  /// **'I don\'t need it anymore'**
  String get delete_reason_do_not_need_anymore;

  /// No description provided for @delete_reason_other.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get delete_reason_other;

  /// No description provided for @delete_reason_product_no_more_relevant.
  ///
  /// In en, this message translates to:
  /// **'Products are no more relevant to me'**
  String get delete_reason_product_no_more_relevant;

  /// No description provided for @delete_reason_title.
  ///
  /// In en, this message translates to:
  /// **'Why are you deleting account?'**
  String get delete_reason_title;

  /// No description provided for @delete_warning_account_info.
  ///
  /// In en, this message translates to:
  /// **'Delete all of your account information'**
  String get delete_warning_account_info;

  /// No description provided for @delete_warning_products_chats.
  ///
  /// In en, this message translates to:
  /// **'Saved products, chats will be deleted'**
  String get delete_warning_products_chats;

  /// No description provided for @delete_warning_title.
  ///
  /// In en, this message translates to:
  /// **'Deleting account will do the following :'**
  String get delete_warning_title;

  /// No description provided for @please_select_at_least_one_reason.
  ///
  /// In en, this message translates to:
  /// **'Please select at least one reason'**
  String get please_select_at_least_one_reason;

  /// No description provided for @please_specify_your_reason.
  ///
  /// In en, this message translates to:
  /// **'Please specify your reason'**
  String get please_specify_your_reason;

  /// No description provided for @specify_reason.
  ///
  /// In en, this message translates to:
  /// **'Please specify your reason'**
  String get specify_reason;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @account_delete_success_keys.
  ///
  /// In en, this message translates to:
  /// **'================ ACCOUNT DELETE SUCCESS KEYS ================'**
  String get account_delete_success_keys;

  /// No description provided for @account_deleted.
  ///
  /// In en, this message translates to:
  /// **'Account Deleted!'**
  String get account_deleted;

  /// No description provided for @creating_new_account.
  ///
  /// In en, this message translates to:
  /// **'Creating new account?'**
  String get creating_new_account;

  /// No description provided for @coupons_keys.
  ///
  /// In en, this message translates to:
  /// **'================ COUPONS KEYS ================'**
  String get coupons_keys;

  /// No description provided for @apply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get apply;

  /// No description provided for @apply_coupon.
  ///
  /// In en, this message translates to:
  /// **'Apply Coupon'**
  String get apply_coupon;

  /// No description provided for @available_coupons.
  ///
  /// In en, this message translates to:
  /// **'Available Coupons'**
  String get available_coupons;

  /// Message based on the number of available coupons
  ///
  /// In en, this message translates to:
  /// **'{coupon_count, plural, =0 {No Coupon Available} =1 {{coupon_count} Coupon Available} other {{coupon_count} Coupons Available}}'**
  String coupon_message(int coupon_count);

  /// No description provided for @search_by_name_or_code.
  ///
  /// In en, this message translates to:
  /// **'Search by name or code'**
  String get search_by_name_or_code;

  /// No description provided for @home_keys.
  ///
  /// In en, this message translates to:
  /// **'================ HOME KEYS ================'**
  String get home_keys;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @selected.
  ///
  /// In en, this message translates to:
  /// **'Selected'**
  String get selected;

  /// No description provided for @rating.
  ///
  /// In en, this message translates to:
  /// **'Rating'**
  String get rating;

  /// No description provided for @reviews.
  ///
  /// In en, this message translates to:
  /// **'Reviews'**
  String get reviews;

  /// No description provided for @see_all.
  ///
  /// In en, this message translates to:
  /// **'See All'**
  String get see_all;

  /// No description provided for @star.
  ///
  /// In en, this message translates to:
  /// **'Star'**
  String get star;

  /// No description provided for @top_products.
  ///
  /// In en, this message translates to:
  /// **'Top Products'**
  String get top_products;

  /// No description provided for @no_result_for.
  ///
  /// In en, this message translates to:
  /// **'No results for \"{searchText}\"'**
  String no_result_for(Object searchText);

  /// No description provided for @no_search_result_message.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t found any result related to your search. Try searching for something else.'**
  String get no_search_result_message;

  /// No description provided for @microphone_permission_permanently_denied.
  ///
  /// In en, this message translates to:
  /// **'Microphone permission is permanently denied. Please go to settings and enable it.'**
  String get microphone_permission_permanently_denied;

  /// No description provided for @chat_keys.
  ///
  /// In en, this message translates to:
  /// **'================ CHAT KEYS ================'**
  String get chat_keys;

  /// No description provided for @chat.
  ///
  /// In en, this message translates to:
  /// **'Chat'**
  String get chat;

  /// No description provided for @you.
  ///
  /// In en, this message translates to:
  /// **'You'**
  String get you;

  /// No description provided for @message.
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get message;

  /// Error shown when user input exceeds maximum allowed length
  ///
  /// In en, this message translates to:
  /// **'Your message is too long (max {maxLength} characters)'**
  String messageTooLong(int maxLength);

  /// No description provided for @message_cannot_be_empty.
  ///
  /// In en, this message translates to:
  /// **'Message can\'t be empty'**
  String get message_cannot_be_empty;

  /// No description provided for @message_description.
  ///
  /// In en, this message translates to:
  /// **'Write description...'**
  String get message_description;

  /// No description provided for @no_messages_yet.
  ///
  /// In en, this message translates to:
  /// **'No messages yet'**
  String get no_messages_yet;

  /// No description provided for @failed_to_load_chats.
  ///
  /// In en, this message translates to:
  /// **'Failed to load chats'**
  String get failed_to_load_chats;

  /// No description provided for @send_a_new_message.
  ///
  /// In en, this message translates to:
  /// **'Send a new message'**
  String get send_a_new_message;

  /// No description provided for @chats_keys.
  ///
  /// In en, this message translates to:
  /// **'================ CHATS KEYS ================'**
  String get chats_keys;

  /// No description provided for @chats.
  ///
  /// In en, this message translates to:
  /// **'Chats'**
  String get chats;

  /// No description provided for @chats_empty_title.
  ///
  /// In en, this message translates to:
  /// **'No chats yet'**
  String get chats_empty_title;

  /// No description provided for @chats_empty_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Message us about a listing and your conversation will appear here'**
  String get chats_empty_subtitle;

  /// No description provided for @chats_active.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get chats_active;

  /// No description provided for @chats_archived.
  ///
  /// In en, this message translates to:
  /// **'Archived'**
  String get chats_archived;

  /// No description provided for @chats_archived_empty_title.
  ///
  /// In en, this message translates to:
  /// **'No archived chats'**
  String get chats_archived_empty_title;

  /// No description provided for @chats_archived_empty_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Chats you archive will appear here'**
  String get chats_archived_empty_subtitle;

  /// No description provided for @chats_loading_more.
  ///
  /// In en, this message translates to:
  /// **'Loading more chats'**
  String get chats_loading_more;

  /// No description provided for @chats_load_error.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load chats. Please try again.'**
  String get chats_load_error;

  /// No description provided for @chats_retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get chats_retry;

  /// No description provided for @chat_archive.
  ///
  /// In en, this message translates to:
  /// **'Archive'**
  String get chat_archive;

  /// No description provided for @chat_unarchive.
  ///
  /// In en, this message translates to:
  /// **'Unarchive'**
  String get chat_unarchive;

  /// No description provided for @chat_mute.
  ///
  /// In en, this message translates to:
  /// **'Mute notifications'**
  String get chat_mute;

  /// No description provided for @chat_unmute.
  ///
  /// In en, this message translates to:
  /// **'Unmute notifications'**
  String get chat_unmute;

  /// No description provided for @chat_delete.
  ///
  /// In en, this message translates to:
  /// **'Delete chat'**
  String get chat_delete;

  /// No description provided for @chat_report.
  ///
  /// In en, this message translates to:
  /// **'Report'**
  String get chat_report;

  /// No description provided for @chat_delete_title.
  ///
  /// In en, this message translates to:
  /// **'Delete this chat?'**
  String get chat_delete_title;

  /// No description provided for @chat_delete_message.
  ///
  /// In en, this message translates to:
  /// **'This chat will be removed from your list and you will not be able to reopen it.'**
  String get chat_delete_message;

  /// No description provided for @chat_delete_confirm.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get chat_delete_confirm;

  /// No description provided for @chat_cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get chat_cancel;

  /// No description provided for @chat_conversation_keys.
  ///
  /// In en, this message translates to:
  /// **'================ CHAT CONVERSATION KEYS ================'**
  String get chat_conversation_keys;

  /// No description provided for @chat_message_hint.
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get chat_message_hint;

  /// No description provided for @chat_message_too_long.
  ///
  /// In en, this message translates to:
  /// **'Messages can be up to 1024 characters'**
  String get chat_message_too_long;

  /// No description provided for @chat_send_failed.
  ///
  /// In en, this message translates to:
  /// **'Not sent. Tap to retry.'**
  String get chat_send_failed;

  /// No description provided for @chat_retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get chat_retry;

  /// No description provided for @chat_photo.
  ///
  /// In en, this message translates to:
  /// **'Photo'**
  String get chat_photo;

  /// No description provided for @chat_read_only_blocked.
  ///
  /// In en, this message translates to:
  /// **'You can no longer send messages in this chat.'**
  String get chat_read_only_blocked;

  /// No description provided for @chat_listing_unavailable.
  ///
  /// In en, this message translates to:
  /// **'This listing is no longer available.'**
  String get chat_listing_unavailable;

  /// No description provided for @chat_attach_photo.
  ///
  /// In en, this message translates to:
  /// **'Add photo'**
  String get chat_attach_photo;

  /// No description provided for @chat_attach_camera.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get chat_attach_camera;

  /// No description provided for @chat_attach_gallery.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get chat_attach_gallery;

  /// No description provided for @chat_image_too_large.
  ///
  /// In en, this message translates to:
  /// **'Images must be smaller than 5 MB'**
  String get chat_image_too_large;

  /// No description provided for @chat_image_unsupported_format.
  ///
  /// In en, this message translates to:
  /// **'Unsupported image format'**
  String get chat_image_unsupported_format;

  /// No description provided for @chat_today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get chat_today;

  /// No description provided for @chat_yesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get chat_yesterday;

  /// No description provided for @chat_report_keys.
  ///
  /// In en, this message translates to:
  /// **'================ CHAT REPORT KEYS ================'**
  String get chat_report_keys;

  /// No description provided for @chat_report_title.
  ///
  /// In en, this message translates to:
  /// **'Report this chat'**
  String get chat_report_title;

  /// No description provided for @chat_report_reason_spam.
  ///
  /// In en, this message translates to:
  /// **'Spam'**
  String get chat_report_reason_spam;

  /// No description provided for @chat_report_reason_abuse.
  ///
  /// In en, this message translates to:
  /// **'Abuse'**
  String get chat_report_reason_abuse;

  /// No description provided for @chat_report_reason_scam.
  ///
  /// In en, this message translates to:
  /// **'Scam'**
  String get chat_report_reason_scam;

  /// No description provided for @chat_report_reason_other.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get chat_report_reason_other;

  /// No description provided for @chat_report_note_hint.
  ///
  /// In en, this message translates to:
  /// **'Add details (optional)'**
  String get chat_report_note_hint;

  /// No description provided for @chat_report_submit.
  ///
  /// In en, this message translates to:
  /// **'Submit report'**
  String get chat_report_submit;

  /// No description provided for @chat_report_submitted.
  ///
  /// In en, this message translates to:
  /// **'Report submitted'**
  String get chat_report_submitted;

  /// No description provided for @contact_us_keys.
  ///
  /// In en, this message translates to:
  /// **'================ CONTACT US KEYS ================'**
  String get contact_us_keys;

  /// No description provided for @attachment.
  ///
  /// In en, this message translates to:
  /// **'Attachments (Up to 5)'**
  String get attachment;

  /// No description provided for @alright.
  ///
  /// In en, this message translates to:
  /// **'Alright !'**
  String get alright;

  /// No description provided for @choose_a_file.
  ///
  /// In en, this message translates to:
  /// **'Choose a file or drag and drop here'**
  String get choose_a_file;

  /// No description provided for @contact_us.
  ///
  /// In en, this message translates to:
  /// **'Contact Us'**
  String get contact_us;

  /// No description provided for @submit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get submit;

  /// No description provided for @contact_us_message.
  ///
  /// In en, this message translates to:
  /// **'Let’s get connect if you have any queries. We are happy to help you anytime.'**
  String get contact_us_message;

  /// No description provided for @file_cannot_be_empty.
  ///
  /// In en, this message translates to:
  /// **'Please select at least one file'**
  String get file_cannot_be_empty;

  /// No description provided for @file_empty_error.
  ///
  /// In en, this message translates to:
  /// **'The selected PDF file is empty. Please choose a valid file.'**
  String get file_empty_error;

  /// No description provided for @file_too_large_error.
  ///
  /// In en, this message translates to:
  /// **'One or more selected files exceed the 5MB limit.'**
  String get file_too_large_error;

  /// No description provided for @pick_file_error.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong while picking files. Please try again.'**
  String get pick_file_error;

  /// No description provided for @pick_image_error.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong while picking images. Please try again.'**
  String get pick_image_error;

  /// No description provided for @pick_pdf_error.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong while picking PDFs. Please try again.'**
  String get pick_pdf_error;

  /// No description provided for @response_received.
  ///
  /// In en, this message translates to:
  /// **'We have received your response and will revert back to you as soon as possible.'**
  String get response_received;

  /// No description provided for @support.
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get support;

  /// No description provided for @supported_format.
  ///
  /// In en, this message translates to:
  /// **'Supported JPG,PNG,PDF. Maximum file size 10mb'**
  String get supported_format;

  /// No description provided for @take_a_photo.
  ///
  /// In en, this message translates to:
  /// **'Take a photo'**
  String get take_a_photo;

  /// No description provided for @unsupported_file_format_error.
  ///
  /// In en, this message translates to:
  /// **'The selected file is not a valid PDF. Please choose a proper PDF file to continue.'**
  String get unsupported_file_format_error;

  /// No description provided for @upload_from_files.
  ///
  /// In en, this message translates to:
  /// **'Upload from files'**
  String get upload_from_files;

  /// No description provided for @upload_from_gallery.
  ///
  /// In en, this message translates to:
  /// **'Upload from gallery'**
  String get upload_from_gallery;

  /// No description provided for @notifications_keys.
  ///
  /// In en, this message translates to:
  /// **'================ NOTIFICATIONS KEYS ================'**
  String get notifications_keys;

  /// No description provided for @empty_notifications_title.
  ///
  /// In en, this message translates to:
  /// **'No Notifications Yet'**
  String get empty_notifications_title;

  /// No description provided for @notifications_mark_all_read.
  ///
  /// In en, this message translates to:
  /// **'Mark all read'**
  String get notifications_mark_all_read;

  /// No description provided for @notifications_push_enabled.
  ///
  /// In en, this message translates to:
  /// **'Push notifications'**
  String get notifications_push_enabled;

  /// No description provided for @notifications_push_description.
  ///
  /// In en, this message translates to:
  /// **'Receive alerts about your iDeal activity.'**
  String get notifications_push_description;

  /// No description provided for @notifications_messages.
  ///
  /// In en, this message translates to:
  /// **'Messages'**
  String get notifications_messages;

  /// No description provided for @notifications_payments.
  ///
  /// In en, this message translates to:
  /// **'Payments'**
  String get notifications_payments;

  /// No description provided for @notifications_bookings.
  ///
  /// In en, this message translates to:
  /// **'Bookings'**
  String get notifications_bookings;

  /// No description provided for @notifications_maintenance.
  ///
  /// In en, this message translates to:
  /// **'Maintenance'**
  String get notifications_maintenance;

  /// No description provided for @notifications_leases.
  ///
  /// In en, this message translates to:
  /// **'Leases'**
  String get notifications_leases;

  /// No description provided for @notifications_general.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get notifications_general;

  /// No description provided for @notifications_permission_denied.
  ///
  /// In en, this message translates to:
  /// **'Notifications are disabled in your device settings.'**
  String get notifications_permission_denied;

  /// No description provided for @notifications_open_settings.
  ///
  /// In en, this message translates to:
  /// **'Open settings'**
  String get notifications_open_settings;

  /// No description provided for @settings_keys.
  ///
  /// In en, this message translates to:
  /// **'================ SETTINGS KEYS ================'**
  String get settings_keys;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @notification_settings.
  ///
  /// In en, this message translates to:
  /// **'Notification Settings'**
  String get notification_settings;

  /// No description provided for @choose_app_theme.
  ///
  /// In en, this message translates to:
  /// **'Choose App Theme'**
  String get choose_app_theme;

  /// No description provided for @biometric_authentication.
  ///
  /// In en, this message translates to:
  /// **'Biometric Authentication'**
  String get biometric_authentication;

  /// No description provided for @privacy_policy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacy_policy;

  /// No description provided for @saved_cards_keys.
  ///
  /// In en, this message translates to:
  /// **'================ SAVED CARDS KEYS ================'**
  String get saved_cards_keys;

  /// No description provided for @empty_cards_list_message.
  ///
  /// In en, this message translates to:
  /// **'There is no card available at the moment.'**
  String get empty_cards_list_message;

  /// No description provided for @explore_products.
  ///
  /// In en, this message translates to:
  /// **'Explore Products'**
  String get explore_products;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @empty_screens_keys.
  ///
  /// In en, this message translates to:
  /// **'================ EMPTY SCREENS KEYS ================'**
  String get empty_screens_keys;

  /// No description provided for @force_update_keys.
  ///
  /// In en, this message translates to:
  /// **'================ FORCE UPDATE KEYS ================'**
  String get force_update_keys;

  /// No description provided for @could_not_launch_store_link.
  ///
  /// In en, this message translates to:
  /// **'Could not launch store link'**
  String get could_not_launch_store_link;

  /// No description provided for @its_time_to_update.
  ///
  /// In en, this message translates to:
  /// **'It’s time to Update!'**
  String get its_time_to_update;

  /// No description provided for @skip_update.
  ///
  /// In en, this message translates to:
  /// **'Skip Update'**
  String get skip_update;

  /// No description provided for @update_app.
  ///
  /// In en, this message translates to:
  /// **'Update App'**
  String get update_app;

  /// No description provided for @update_now.
  ///
  /// In en, this message translates to:
  /// **'Update Now'**
  String get update_now;

  /// No description provided for @update_required_description.
  ///
  /// In en, this message translates to:
  /// **'The version you are using is old, to continue using you need to update the latest version in order to experience new features.'**
  String get update_required_description;

  /// No description provided for @under_maintenance_keys.
  ///
  /// In en, this message translates to:
  /// **'================ UNDER MAINTENANCE KEYS ================'**
  String get under_maintenance_keys;

  /// No description provided for @under_maintenance.
  ///
  /// In en, this message translates to:
  /// **'App is Under Maintenance'**
  String get under_maintenance;

  /// No description provided for @under_maintenance_message.
  ///
  /// In en, this message translates to:
  /// **'App is currently under maintenance. We will notify you once we are done. Try again later.'**
  String get under_maintenance_message;

  /// No description provided for @no_internet_keys.
  ///
  /// In en, this message translates to:
  /// **'================ NO INTERNET KEYS ================'**
  String get no_internet_keys;

  /// No description provided for @lost_connection.
  ///
  /// In en, this message translates to:
  /// **'You Lost Connection'**
  String get lost_connection;

  /// No description provided for @lost_connection_message.
  ///
  /// In en, this message translates to:
  /// **'Seems like you have lost internet connection'**
  String get lost_connection_message;

  /// No description provided for @no_internet_connection.
  ///
  /// In en, this message translates to:
  /// **'Please check your internet connection'**
  String get no_internet_connection;

  /// No description provided for @server_error_keys.
  ///
  /// In en, this message translates to:
  /// **'================ SERVER ERROR KEYS ================'**
  String get server_error_keys;

  /// No description provided for @server_error.
  ///
  /// In en, this message translates to:
  /// **'Server Error'**
  String get server_error;

  /// No description provided for @server_error_description.
  ///
  /// In en, this message translates to:
  /// **'There is server error at the moment, please check back later'**
  String get server_error_description;

  /// No description provided for @server_error_title.
  ///
  /// In en, this message translates to:
  /// **'Server Error'**
  String get server_error_title;

  /// No description provided for @back_to_home.
  ///
  /// In en, this message translates to:
  /// **'Back to Home'**
  String get back_to_home;

  /// No description provided for @ssl_pinning_keys.
  ///
  /// In en, this message translates to:
  /// **'================ SSL PINNING KEYS ================'**
  String get ssl_pinning_keys;

  /// No description provided for @platform_not_supported.
  ///
  /// In en, this message translates to:
  /// **'Platform not supported'**
  String get platform_not_supported;

  /// No description provided for @secure_connection_failed_message.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t connect securely to our server. Please try again later, or check if app update available.'**
  String get secure_connection_failed_message;

  /// No description provided for @secure_connection_failed_title.
  ///
  /// In en, this message translates to:
  /// **'Secure Connection Failed!'**
  String get secure_connection_failed_title;

  /// No description provided for @try_again.
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get try_again;

  /// No description provided for @reminder_keys.
  ///
  /// In en, this message translates to:
  /// **'================ REMINDER KEYS ================'**
  String get reminder_keys;

  /// No description provided for @reminder.
  ///
  /// In en, this message translates to:
  /// **'Reminder'**
  String get reminder;

  /// No description provided for @reminder_title.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get reminder_title;

  /// No description provided for @reminder_description.
  ///
  /// In en, this message translates to:
  /// **'Description (Optional)'**
  String get reminder_description;

  /// No description provided for @reminder_title_hint.
  ///
  /// In en, this message translates to:
  /// **'Enter reminder title'**
  String get reminder_title_hint;

  /// No description provided for @reminder_description_hint.
  ///
  /// In en, this message translates to:
  /// **'Enter description'**
  String get reminder_description_hint;

  /// No description provided for @date_and_time.
  ///
  /// In en, this message translates to:
  /// **'Date & Time'**
  String get date_and_time;

  /// No description provided for @schedule_reminder.
  ///
  /// In en, this message translates to:
  /// **'Schedule Reminder'**
  String get schedule_reminder;

  /// No description provided for @reminder_title_required.
  ///
  /// In en, this message translates to:
  /// **'Please enter a title'**
  String get reminder_title_required;

  /// No description provided for @reminder_future_date_required.
  ///
  /// In en, this message translates to:
  /// **'Please select a future date and time'**
  String get reminder_future_date_required;

  /// No description provided for @reminder_scheduled_successfully.
  ///
  /// In en, this message translates to:
  /// **'Reminder scheduled successfully!'**
  String get reminder_scheduled_successfully;

  /// No description provided for @reminder_schedule_failed.
  ///
  /// In en, this message translates to:
  /// **'Failed to schedule reminder'**
  String get reminder_schedule_failed;

  /// Subject line used when sharing a product
  ///
  /// In en, this message translates to:
  /// **'Product on iDeal Mobile'**
  String get share_product_subject;

  /// Share body with product name and product URL
  ///
  /// In en, this message translates to:
  /// **'I found this product on iDeal Mobile and thought you might like it.\n\nCheck it out here:\n{url}'**
  String share_product_message(String url);

  /// No description provided for @app_tour_keys.
  ///
  /// In en, this message translates to:
  /// **'================ APP TOUR KEYS ================'**
  String get app_tour_keys;

  /// No description provided for @tour_search_title.
  ///
  /// In en, this message translates to:
  /// **'Search Products'**
  String get tour_search_title;

  /// No description provided for @tour_search_description.
  ///
  /// In en, this message translates to:
  /// **'Use the search bar to quickly find the products you\'re looking for. Just type what you need!'**
  String get tour_search_description;

  /// No description provided for @tour_nav_title.
  ///
  /// In en, this message translates to:
  /// **'Navigate the App'**
  String get tour_nav_title;

  /// No description provided for @tour_nav_description.
  ///
  /// In en, this message translates to:
  /// **'Use the bottom navigation to switch between Home, Search, Cart, and Profile sections.'**
  String get tour_nav_description;

  /// No description provided for @got_it.
  ///
  /// In en, this message translates to:
  /// **'Got it!'**
  String get got_it;

  /// No description provided for @search_bar_identify.
  ///
  /// In en, this message translates to:
  /// **'search_bar'**
  String get search_bar_identify;

  /// No description provided for @bottom_nav__bar_identify.
  ///
  /// In en, this message translates to:
  /// **'bottom_nav_bar'**
  String get bottom_nav__bar_identify;

  /// No description provided for @biometric_auth_keys.
  ///
  /// In en, this message translates to:
  /// **'================ BIOMETRIC AUTH KEYS ================'**
  String get biometric_auth_keys;

  /// No description provided for @biometric_auth_desc_for_enrollment.
  ///
  /// In en, this message translates to:
  /// **'Biometric authentication is not set up on your device. Please either enable Touch ID or Face ID on your phone.'**
  String get biometric_auth_desc_for_enrollment;

  /// No description provided for @go_to_settings.
  ///
  /// In en, this message translates to:
  /// **'Go to settings'**
  String get go_to_settings;

  /// No description provided for @biometric_auth_reason_access_app.
  ///
  /// In en, this message translates to:
  /// **'Please authenticate to access the app'**
  String get biometric_auth_reason_access_app;

  /// No description provided for @biometric_auth_not_setup.
  ///
  /// In en, this message translates to:
  /// **'Biometric authentication is not set up on your device.'**
  String get biometric_auth_not_setup;

  /// No description provided for @biometric_setup_enable_instruction.
  ///
  /// In en, this message translates to:
  /// **'Biometric authentication is not set up on your device. Please enable Touch ID or Face ID (iPhone) or Fingerprint/Face Unlock (Android) to continue.'**
  String get biometric_setup_enable_instruction;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @enable_or_disable.
  ///
  /// In en, this message translates to:
  /// **'Enable/ Disable'**
  String get enable_or_disable;

  /// No description provided for @biometric_auth_description.
  ///
  /// In en, this message translates to:
  /// **'Use the toggle to activate or deactivate biometric verification.'**
  String get biometric_auth_description;

  /// No description provided for @biometric_auth_enabled_success.
  ///
  /// In en, this message translates to:
  /// **'Biometric authentication enabled successfully'**
  String get biometric_auth_enabled_success;

  /// No description provided for @biometric_auth_disabled.
  ///
  /// In en, this message translates to:
  /// **'Biometric authentication disabled'**
  String get biometric_auth_disabled;

  /// No description provided for @auth_failed.
  ///
  /// In en, this message translates to:
  /// **'Authentication failed'**
  String get auth_failed;

  /// No description provided for @biometric_auth_not_available.
  ///
  /// In en, this message translates to:
  /// **'Biometric authentication is not available on this device'**
  String get biometric_auth_not_available;

  /// No description provided for @biometric_auth_too_many_attempts.
  ///
  /// In en, this message translates to:
  /// **'Too many attempts. Please try again later.'**
  String get biometric_auth_too_many_attempts;

  /// No description provided for @invoice_keys.
  ///
  /// In en, this message translates to:
  /// **'================ INVOICE KEYS ================'**
  String get invoice_keys;

  /// No description provided for @share_invoice.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share_invoice;

  /// No description provided for @download.
  ///
  /// In en, this message translates to:
  /// **'Download'**
  String get download;

  /// No description provided for @invoice_saved_success.
  ///
  /// In en, this message translates to:
  /// **'Invoice saved successfully'**
  String get invoice_saved_success;

  /// No description provided for @invoice_generation_failed.
  ///
  /// In en, this message translates to:
  /// **'Failed to generate invoice. Please try again.'**
  String get invoice_generation_failed;

  /// No description provided for @storage_permission_required.
  ///
  /// In en, this message translates to:
  /// **'Storage permission required to save invoice'**
  String get storage_permission_required;

  /// No description provided for @online_payment_method.
  ///
  /// In en, this message translates to:
  /// **'Online Payment'**
  String get online_payment_method;

  /// No description provided for @generate_invoice.
  ///
  /// In en, this message translates to:
  /// **'Generate Invoice'**
  String get generate_invoice;

  /// No description provided for @invoice.
  ///
  /// In en, this message translates to:
  /// **'INVOICE'**
  String get invoice;

  /// No description provided for @invoice_details.
  ///
  /// In en, this message translates to:
  /// **'Invoice Details:'**
  String get invoice_details;

  /// No description provided for @invoice_number.
  ///
  /// In en, this message translates to:
  /// **'Invoice Number'**
  String get invoice_number;

  /// No description provided for @invoice_date.
  ///
  /// In en, this message translates to:
  /// **'Invoice Date'**
  String get invoice_date;

  /// No description provided for @bill_to.
  ///
  /// In en, this message translates to:
  /// **'Bill To:'**
  String get bill_to;

  /// No description provided for @product.
  ///
  /// In en, this message translates to:
  /// **'Product'**
  String get product;

  /// No description provided for @quantity.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get quantity;

  /// No description provided for @total.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get total;

  /// No description provided for @subtotal.
  ///
  /// In en, this message translates to:
  /// **'Subtotal'**
  String get subtotal;

  /// No description provided for @payment_method.
  ///
  /// In en, this message translates to:
  /// **'Payment Method'**
  String get payment_method;

  /// No description provided for @download_invoice.
  ///
  /// In en, this message translates to:
  /// **'Download Invoice'**
  String get download_invoice;

  /// No description provided for @invoice_share_failed.
  ///
  /// In en, this message translates to:
  /// **'Failed to share invoice. Please try again'**
  String get invoice_share_failed;

  /// No description provided for @feedback_keys.
  ///
  /// In en, this message translates to:
  /// **'================ FEEDBACK KEYS ================'**
  String get feedback_keys;

  /// No description provided for @feedback.
  ///
  /// In en, this message translates to:
  /// **'Feedback'**
  String get feedback;

  /// No description provided for @please_share_your_thoughts.
  ///
  /// In en, this message translates to:
  /// **'Please share your thoughts before submitting.'**
  String get please_share_your_thoughts;

  /// No description provided for @rate_your_experience.
  ///
  /// In en, this message translates to:
  /// **'Rate your experience'**
  String get rate_your_experience;

  /// No description provided for @your_feedback.
  ///
  /// In en, this message translates to:
  /// **'Your feedback'**
  String get your_feedback;

  /// No description provided for @feedback_hint.
  ///
  /// In en, this message translates to:
  /// **'Tell us what you think...'**
  String get feedback_hint;

  /// No description provided for @submit_feedback.
  ///
  /// In en, this message translates to:
  /// **'Submit Feedback'**
  String get submit_feedback;

  /// No description provided for @feedback_submitted_success.
  ///
  /// In en, this message translates to:
  /// **'Thank you! Your feedback has been submitted.'**
  String get feedback_submitted_success;

  /// No description provided for @please_select_a_rating.
  ///
  /// In en, this message translates to:
  /// **'Please select a rating to continue.'**
  String get please_select_a_rating;

  /// No description provided for @feedback_category_label.
  ///
  /// In en, this message translates to:
  /// **'Pick a category'**
  String get feedback_category_label;

  /// No description provided for @feedback_category_required.
  ///
  /// In en, this message translates to:
  /// **'Please select a category to continue.'**
  String get feedback_category_required;

  /// No description provided for @feedback_category_bug.
  ///
  /// In en, this message translates to:
  /// **'Bug'**
  String get feedback_category_bug;

  /// No description provided for @feedback_category_suggestion.
  ///
  /// In en, this message translates to:
  /// **'Suggestion'**
  String get feedback_category_suggestion;

  /// No description provided for @feedback_category_content.
  ///
  /// In en, this message translates to:
  /// **'Content'**
  String get feedback_category_content;

  /// No description provided for @feedback_category_compliment.
  ///
  /// In en, this message translates to:
  /// **'Compliment'**
  String get feedback_category_compliment;

  /// No description provided for @feedback_category_other.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get feedback_category_other;

  /// No description provided for @feedback_description.
  ///
  /// In en, this message translates to:
  /// **'Share your experience and help us improve. We value every word you share with us.'**
  String get feedback_description;

  /// No description provided for @ai_chat_keys.
  ///
  /// In en, this message translates to:
  /// **'================ AI CHAT KEYS ================'**
  String get ai_chat_keys;

  /// No description provided for @ai_assistant.
  ///
  /// In en, this message translates to:
  /// **'AI Assistant'**
  String get ai_assistant;

  /// No description provided for @ai_chat_how_can_i_help.
  ///
  /// In en, this message translates to:
  /// **'How can I help you?'**
  String get ai_chat_how_can_i_help;

  /// No description provided for @ai_chat_ask_me_anything.
  ///
  /// In en, this message translates to:
  /// **'Ask me anything...'**
  String get ai_chat_ask_me_anything;

  /// No description provided for @ai_chat_description.
  ///
  /// In en, this message translates to:
  /// **'Ask me about listings, renting, or app navigation.'**
  String get ai_chat_description;

  /// No description provided for @ai_chat_error_no_response.
  ///
  /// In en, this message translates to:
  /// **'No response received. Please try again.'**
  String get ai_chat_error_no_response;

  /// No description provided for @ai_chat_error_quota.
  ///
  /// In en, this message translates to:
  /// **'AI assistant is temporarily unavailable due to high usage. Please try again in a minute.'**
  String get ai_chat_error_quota;

  /// No description provided for @ai_chat_error_timeout.
  ///
  /// In en, this message translates to:
  /// **'Response took too long. Please try again.'**
  String get ai_chat_error_timeout;

  /// No description provided for @ai_chat_error_network.
  ///
  /// In en, this message translates to:
  /// **'No internet connection. Please check your network and try again.'**
  String get ai_chat_error_network;

  /// No description provided for @ai_chat_error_generic.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get ai_chat_error_generic;

  /// No description provided for @listings_keys.
  ///
  /// In en, this message translates to:
  /// **'======== LISTINGS KEYS ========'**
  String get listings_keys;

  /// No description provided for @listings_per_month.
  ///
  /// In en, this message translates to:
  /// **'/mo'**
  String get listings_per_month;

  /// The number of rooms in a listing.
  ///
  /// In en, this message translates to:
  /// **'{count} rooms'**
  String listings_rooms_count(num count);

  /// The area of a listing in square metres.
  ///
  /// In en, this message translates to:
  /// **'{area} m²'**
  String listings_area_sqm(num area);

  /// The floor number of a listing when the building's total floors are unknown.
  ///
  /// In en, this message translates to:
  /// **'Floor {floor}'**
  String listings_floor_only(num floor);

  /// The floor number and total floors of a listing.
  ///
  /// In en, this message translates to:
  /// **'Floor {floor} of {total}'**
  String listings_floor_of(num floor, num total);

  /// No description provided for @listings_save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get listings_save;

  /// No description provided for @selected_empty_title.
  ///
  /// In en, this message translates to:
  /// **'No selected homes yet'**
  String get selected_empty_title;

  /// No description provided for @selected_empty_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Tap the heart on any home to keep it here for later.'**
  String get selected_empty_subtitle;

  /// No description provided for @selected_error_title.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load your selected homes'**
  String get selected_error_title;

  /// No description provided for @selected_load_error.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load your selected homes. Please try again.'**
  String get selected_load_error;

  /// No description provided for @selected_mutation_error.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t update your selected homes. Please try again.'**
  String get selected_mutation_error;

  /// No description provided for @selected_unknown_error.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong with your selected homes. Please try again.'**
  String get selected_unknown_error;

  /// No description provided for @selected_retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get selected_retry;

  /// No description provided for @selected_page_out_of_date.
  ///
  /// In en, this message translates to:
  /// **'The selected homes page changed. Please try again.'**
  String get selected_page_out_of_date;

  /// No description provided for @selected_loading_more.
  ///
  /// In en, this message translates to:
  /// **'Loading more selected homes'**
  String get selected_loading_more;

  /// The number of homes in the current selected list.
  ///
  /// In en, this message translates to:
  /// **'{count} selected homes'**
  String selected_result_count(num count);

  /// No description provided for @selected_sort.
  ///
  /// In en, this message translates to:
  /// **'Sort'**
  String get selected_sort;

  /// No description provided for @selected_sort_recent.
  ///
  /// In en, this message translates to:
  /// **'Recently selected'**
  String get selected_sort_recent;

  /// No description provided for @selected_sort_price_asc.
  ///
  /// In en, this message translates to:
  /// **'Price: low to high'**
  String get selected_sort_price_asc;

  /// No description provided for @selected_sort_price_desc.
  ///
  /// In en, this message translates to:
  /// **'Price: high to low'**
  String get selected_sort_price_desc;

  /// No description provided for @selected_no_matches_title.
  ///
  /// In en, this message translates to:
  /// **'No matching selected homes'**
  String get selected_no_matches_title;

  /// No description provided for @selected_no_matches_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Try widening your search or clearing some filters.'**
  String get selected_no_matches_subtitle;

  /// No description provided for @selected_clear_filters.
  ///
  /// In en, this message translates to:
  /// **'Clear filters'**
  String get selected_clear_filters;

  /// No description provided for @selected_removed.
  ///
  /// In en, this message translates to:
  /// **'Removed from selected homes'**
  String get selected_removed;

  /// No description provided for @selected_undo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get selected_undo;

  /// No description provided for @listings_verified.
  ///
  /// In en, this message translates to:
  /// **'Verified'**
  String get listings_verified;

  /// No description provided for @listings_tariff_standard.
  ///
  /// In en, this message translates to:
  /// **'Standard'**
  String get listings_tariff_standard;

  /// No description provided for @listings_tariff_comfort.
  ///
  /// In en, this message translates to:
  /// **'Comfort'**
  String get listings_tariff_comfort;

  /// No description provided for @listings_tariff_premium.
  ///
  /// In en, this message translates to:
  /// **'Premium'**
  String get listings_tariff_premium;

  /// No description provided for @listings_furnishing_furnished.
  ///
  /// In en, this message translates to:
  /// **'Furnished'**
  String get listings_furnishing_furnished;

  /// No description provided for @listings_furnishing_semi_furnished.
  ///
  /// In en, this message translates to:
  /// **'Semi-furnished'**
  String get listings_furnishing_semi_furnished;

  /// No description provided for @listings_furnishing_unfurnished.
  ///
  /// In en, this message translates to:
  /// **'Unfurnished'**
  String get listings_furnishing_unfurnished;

  /// No description provided for @listings_all_filters.
  ///
  /// In en, this message translates to:
  /// **'All filters'**
  String get listings_all_filters;

  /// No description provided for @listings_apply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get listings_apply;

  /// No description provided for @listings_clear_all.
  ///
  /// In en, this message translates to:
  /// **'Clear all'**
  String get listings_clear_all;

  /// No description provided for @listings_clear_filters.
  ///
  /// In en, this message translates to:
  /// **'Clear filters'**
  String get listings_clear_filters;

  /// No description provided for @listings_filter_district.
  ///
  /// In en, this message translates to:
  /// **'District'**
  String get listings_filter_district;

  /// No description provided for @listings_filter_property_type.
  ///
  /// In en, this message translates to:
  /// **'Property type'**
  String get listings_filter_property_type;

  /// No description provided for @listings_filter_price.
  ///
  /// In en, this message translates to:
  /// **'Price range'**
  String get listings_filter_price;

  /// No description provided for @listings_filter_rooms.
  ///
  /// In en, this message translates to:
  /// **'Rooms'**
  String get listings_filter_rooms;

  /// No description provided for @listings_filter_furnishing.
  ///
  /// In en, this message translates to:
  /// **'Furnishing'**
  String get listings_filter_furnishing;

  /// No description provided for @listings_filter_tariff.
  ///
  /// In en, this message translates to:
  /// **'Tariff'**
  String get listings_filter_tariff;

  /// No description provided for @listings_range_min.
  ///
  /// In en, this message translates to:
  /// **'Min'**
  String get listings_range_min;

  /// No description provided for @listings_range_max.
  ///
  /// In en, this message translates to:
  /// **'Max'**
  String get listings_range_max;

  /// No description provided for @listings_chip_verified.
  ///
  /// In en, this message translates to:
  /// **'Verified only'**
  String get listings_chip_verified;

  /// No description provided for @listings_chip_furnished.
  ///
  /// In en, this message translates to:
  /// **'Furnished'**
  String get listings_chip_furnished;

  /// No description provided for @listings_chip_comfort.
  ///
  /// In en, this message translates to:
  /// **'Comfort'**
  String get listings_chip_comfort;

  /// No description provided for @listings_chip_premium.
  ///
  /// In en, this message translates to:
  /// **'Premium'**
  String get listings_chip_premium;

  /// No description provided for @listings_search_placeholder.
  ///
  /// In en, this message translates to:
  /// **'Search rentals'**
  String get listings_search_placeholder;

  /// No description provided for @home_heading.
  ///
  /// In en, this message translates to:
  /// **'Find your next home'**
  String get home_heading;

  /// No description provided for @home_recommended_heading.
  ///
  /// In en, this message translates to:
  /// **'Recommended for you'**
  String get home_recommended_heading;

  /// No description provided for @home_recent_search_heading.
  ///
  /// In en, this message translates to:
  /// **'From your recent searches'**
  String get home_recent_search_heading;

  /// Subtitle showing recent search query and filter context.
  ///
  /// In en, this message translates to:
  /// **'Based on {query} and your last filters'**
  String home_recent_search_context(String query);

  /// No description provided for @home_selected_heading.
  ///
  /// In en, this message translates to:
  /// **'From selected'**
  String get home_selected_heading;

  /// No description provided for @home_selected_context.
  ///
  /// In en, this message translates to:
  /// **'More homes like the ones you saved'**
  String get home_selected_context;

  /// No description provided for @home_highly_rated_heading.
  ///
  /// In en, this message translates to:
  /// **'Highly rated homes'**
  String get home_highly_rated_heading;

  /// No description provided for @home_search_sheet_title.
  ///
  /// In en, this message translates to:
  /// **'Search homes'**
  String get home_search_sheet_title;

  /// No description provided for @home_search_sheet_placeholder.
  ///
  /// In en, this message translates to:
  /// **'Try Yunusobod'**
  String get home_search_sheet_placeholder;

  /// No description provided for @home_search_sheet_field_label.
  ///
  /// In en, this message translates to:
  /// **'District, address, or landmark'**
  String get home_search_sheet_field_label;

  /// No description provided for @home_search_sheet_example_recent.
  ///
  /// In en, this message translates to:
  /// **'Example recent searches'**
  String get home_search_sheet_example_recent;

  /// No description provided for @home_search_sheet_action.
  ///
  /// In en, this message translates to:
  /// **'Show matching homes'**
  String get home_search_sheet_action;

  /// No description provided for @home_tariff_sheet_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose the service level that fits your rental search.'**
  String get home_tariff_sheet_subtitle;

  /// No description provided for @home_tariff_sheet_clear_hint.
  ///
  /// In en, this message translates to:
  /// **'Tap the selected tariff again to clear it.'**
  String get home_tariff_sheet_clear_hint;

  /// No description provided for @home_feed_status_loading.
  ///
  /// In en, this message translates to:
  /// **'Loading more highly rated homes'**
  String get home_feed_status_loading;

  /// No description provided for @home_quick_filter_district.
  ///
  /// In en, this message translates to:
  /// **'District'**
  String get home_quick_filter_district;

  /// No description provided for @home_quick_filter_rooms.
  ///
  /// In en, this message translates to:
  /// **'Rooms'**
  String get home_quick_filter_rooms;

  /// No description provided for @home_quick_filter_price.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get home_quick_filter_price;

  /// No description provided for @home_quick_filter_tariff.
  ///
  /// In en, this message translates to:
  /// **'Tariff'**
  String get home_quick_filter_tariff;

  /// No description provided for @recent_searches.
  ///
  /// In en, this message translates to:
  /// **'Recent searches'**
  String get recent_searches;

  /// No description provided for @listings_view_map.
  ///
  /// In en, this message translates to:
  /// **'Map'**
  String get listings_view_map;

  /// No description provided for @listing_map_search_hint.
  ///
  /// In en, this message translates to:
  /// **'Search homes'**
  String get listing_map_search_hint;

  /// No description provided for @listing_map_full_filters.
  ///
  /// In en, this message translates to:
  /// **'Full filters'**
  String get listing_map_full_filters;

  /// No description provided for @listing_map_search_this_area.
  ///
  /// In en, this message translates to:
  /// **'Search this area'**
  String get listing_map_search_this_area;

  /// No description provided for @listing_map_list.
  ///
  /// In en, this message translates to:
  /// **'List'**
  String get listing_map_list;

  /// No description provided for @listing_map_zoom_in.
  ///
  /// In en, this message translates to:
  /// **'Zoom in to see all homes'**
  String get listing_map_zoom_in;

  /// No description provided for @listing_map_no_results.
  ///
  /// In en, this message translates to:
  /// **'No homes in this area'**
  String get listing_map_no_results;

  /// No description provided for @listing_map_loading.
  ///
  /// In en, this message translates to:
  /// **'Loading homes'**
  String get listing_map_loading;

  /// No description provided for @listing_map_full_info.
  ///
  /// In en, this message translates to:
  /// **'Full info'**
  String get listing_map_full_info;

  /// No description provided for @listing_map_call.
  ///
  /// In en, this message translates to:
  /// **'Call'**
  String get listing_map_call;

  /// No description provided for @listing_map_call_failed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t start the call. Check your phone settings and try again.'**
  String get listing_map_call_failed;

  /// No description provided for @listing_map_error_title.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load this area'**
  String get listing_map_error_title;

  /// No description provided for @listing_map_retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get listing_map_retry;

  /// No description provided for @listing_map_near_me.
  ///
  /// In en, this message translates to:
  /// **'Near me'**
  String get listing_map_near_me;

  /// No description provided for @listing_map_location_unavailable.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t determine your location'**
  String get listing_map_location_unavailable;

  /// The number of verified homes in the search results.
  ///
  /// In en, this message translates to:
  /// **'{count} verified homes'**
  String listings_result_count(num count);

  /// No description provided for @listings_empty_title.
  ///
  /// In en, this message translates to:
  /// **'No homes match these filters'**
  String get listings_empty_title;

  /// No description provided for @listings_empty_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Try widening your search or clearing some filters.'**
  String get listings_empty_subtitle;

  /// No description provided for @listings_error_title.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load homes'**
  String get listings_error_title;

  /// No description provided for @listings_error_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Check your connection and try again.'**
  String get listings_error_subtitle;

  /// No description provided for @listings_retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get listings_retry;

  /// No description provided for @listings_showing_saved.
  ///
  /// In en, this message translates to:
  /// **'Showing saved listings. Pull to retry.'**
  String get listings_showing_saved;

  /// No description provided for @listings_anywhere.
  ///
  /// In en, this message translates to:
  /// **'Anywhere'**
  String get listings_anywhere;

  /// No description provided for @listings_any.
  ///
  /// In en, this message translates to:
  /// **'Any'**
  String get listings_any;

  /// No description provided for @listing_detail_keys.
  ///
  /// In en, this message translates to:
  /// **'======== LISTING DETAIL KEYS ========'**
  String get listing_detail_keys;

  /// The number of reviews for a listing detail page.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0 {No reviews} =1 {1 review} other {{count} reviews}}'**
  String listing_detail_reviews_count(int count);

  /// No description provided for @listing_detail_verified.
  ///
  /// In en, this message translates to:
  /// **'Verified'**
  String get listing_detail_verified;

  /// No description provided for @listing_detail_trust_heading.
  ///
  /// In en, this message translates to:
  /// **'Verified & contract-backed by iDeal'**
  String get listing_detail_trust_heading;

  /// No description provided for @listing_detail_about.
  ///
  /// In en, this message translates to:
  /// **'About this home'**
  String get listing_detail_about;

  /// No description provided for @listing_detail_amenities.
  ///
  /// In en, this message translates to:
  /// **'What this place offers'**
  String get listing_detail_amenities;

  /// No description provided for @listing_detail_neighborhood.
  ///
  /// In en, this message translates to:
  /// **'Neighborhood'**
  String get listing_detail_neighborhood;

  /// No description provided for @listing_detail_location.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get listing_detail_location;

  /// No description provided for @listing_detail_map_open.
  ///
  /// In en, this message translates to:
  /// **'Open map'**
  String get listing_detail_map_open;

  /// No description provided for @listing_detail_map_unavailable.
  ///
  /// In en, this message translates to:
  /// **'Map unavailable'**
  String get listing_detail_map_unavailable;

  /// No description provided for @listing_detail_read_more.
  ///
  /// In en, this message translates to:
  /// **'Read more'**
  String get listing_detail_read_more;

  /// No description provided for @listing_detail_show_less.
  ///
  /// In en, this message translates to:
  /// **'Show less'**
  String get listing_detail_show_less;

  /// No description provided for @listing_detail_message.
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get listing_detail_message;

  /// No description provided for @listing_detail_message_unavailable.
  ///
  /// In en, this message translates to:
  /// **'Messaging is unavailable for this listing'**
  String get listing_detail_message_unavailable;

  /// No description provided for @listing_detail_call.
  ///
  /// In en, this message translates to:
  /// **'Call'**
  String get listing_detail_call;

  /// No description provided for @listing_detail_share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get listing_detail_share;

  /// The current photo number and total photo count.
  ///
  /// In en, this message translates to:
  /// **'{current} / {total}'**
  String listing_detail_photo_counter(int current, int total);

  /// The number of additional listing photos.
  ///
  /// In en, this message translates to:
  /// **'+{count}'**
  String listing_detail_more_photos(int count);

  /// No description provided for @listing_detail_no_obligation.
  ///
  /// In en, this message translates to:
  /// **'No obligation to rent'**
  String get listing_detail_no_obligation;

  /// The deposit amount for a listing.
  ///
  /// In en, this message translates to:
  /// **'Deposit: {amount}'**
  String listing_detail_deposit(String amount);

  /// The minimum rental duration for a listing.
  ///
  /// In en, this message translates to:
  /// **'Minimum stay: {count} months'**
  String listing_detail_minimum_stay(int count);

  /// No description provided for @listing_detail_error_title.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load this home'**
  String get listing_detail_error_title;

  /// No description provided for @listing_detail_error_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Check your connection and try again.'**
  String get listing_detail_error_subtitle;

  /// No description provided for @listing_detail_not_found.
  ///
  /// In en, this message translates to:
  /// **'This home is no longer available.'**
  String get listing_detail_not_found;

  /// No description provided for @listing_detail_retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get listing_detail_retry;

  /// No description provided for @empty_views_keys.
  ///
  /// In en, this message translates to:
  /// **'================ EMPTY VIEWS KEYS ================'**
  String get empty_views_keys;

  /// No description provided for @empty_views.
  ///
  /// In en, this message translates to:
  /// **'Empty Views'**
  String get empty_views;

  /// No description provided for @empty_states.
  ///
  /// In en, this message translates to:
  /// **'Empty States'**
  String get empty_states;

  /// No description provided for @error_states.
  ///
  /// In en, this message translates to:
  /// **'Error States'**
  String get error_states;

  /// No description provided for @utilities.
  ///
  /// In en, this message translates to:
  /// **'Utilities'**
  String get utilities;

  /// No description provided for @ai_chat_suggestion_listings.
  ///
  /// In en, this message translates to:
  /// **'Find an apartment'**
  String get ai_chat_suggestion_listings;

  /// No description provided for @ai_chat_suggestion_renting.
  ///
  /// In en, this message translates to:
  /// **'How does renting work?'**
  String get ai_chat_suggestion_renting;

  /// No description provided for @ai_chat_suggestion_support.
  ///
  /// In en, this message translates to:
  /// **'Contact support'**
  String get ai_chat_suggestion_support;

  /// No description provided for @booking_keys.
  ///
  /// In en, this message translates to:
  /// **'======== BOOKING KEYS ========'**
  String get booking_keys;

  /// No description provided for @booking_book_and_pay.
  ///
  /// In en, this message translates to:
  /// **'Book & pay'**
  String get booking_book_and_pay;

  /// No description provided for @booking_title.
  ///
  /// In en, this message translates to:
  /// **'Book this home'**
  String get booking_title;

  /// No description provided for @booking_status_title.
  ///
  /// In en, this message translates to:
  /// **'Booking status'**
  String get booking_status_title;

  /// No description provided for @booking_status_requested.
  ///
  /// In en, this message translates to:
  /// **'Requested'**
  String get booking_status_requested;

  /// No description provided for @booking_status_approved.
  ///
  /// In en, this message translates to:
  /// **'Approved'**
  String get booking_status_approved;

  /// No description provided for @booking_status_rejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get booking_status_rejected;

  /// No description provided for @booking_status_cancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get booking_status_cancelled;

  /// No description provided for @booking_status_payment_pending.
  ///
  /// In en, this message translates to:
  /// **'Payment pending'**
  String get booking_status_payment_pending;

  /// No description provided for @booking_status_confirmed.
  ///
  /// In en, this message translates to:
  /// **'Confirmed'**
  String get booking_status_confirmed;

  /// No description provided for @booking_status_payment_failed.
  ///
  /// In en, this message translates to:
  /// **'Payment failed'**
  String get booking_status_payment_failed;

  /// No description provided for @booking_status_payment_expired.
  ///
  /// In en, this message translates to:
  /// **'Payment expired'**
  String get booking_status_payment_expired;

  /// No description provided for @booking_status_reconciliation_required.
  ///
  /// In en, this message translates to:
  /// **'Under review'**
  String get booking_status_reconciliation_required;

  /// No description provided for @no_bookings_yet.
  ///
  /// In en, this message translates to:
  /// **'You have no bookings yet'**
  String get no_bookings_yet;

  /// No description provided for @booking_choose_dates.
  ///
  /// In en, this message translates to:
  /// **'Choose your stay'**
  String get booking_choose_dates;

  /// No description provided for @booking_dates_inclusive.
  ///
  /// In en, this message translates to:
  /// **'Your start and end dates are both included.'**
  String get booking_dates_inclusive;

  /// No description provided for @booking_select_dates.
  ///
  /// In en, this message translates to:
  /// **'Select dates'**
  String get booking_select_dates;

  /// No description provided for @booking_choose_start_date.
  ///
  /// In en, this message translates to:
  /// **'Choose a start date'**
  String get booking_choose_start_date;

  /// No description provided for @booking_choose_end_date.
  ///
  /// In en, this message translates to:
  /// **'Choose an end date'**
  String get booking_choose_end_date;

  /// No description provided for @booking_months.
  ///
  /// In en, this message translates to:
  /// **'{count} months'**
  String booking_months(int count);

  /// No description provided for @booking_range_unavailable.
  ///
  /// In en, this message translates to:
  /// **'That period is not available. Choose different dates.'**
  String get booking_range_unavailable;

  /// No description provided for @booking_get_quote.
  ///
  /// In en, this message translates to:
  /// **'Get price'**
  String get booking_get_quote;

  /// No description provided for @booking_price_summary.
  ///
  /// In en, this message translates to:
  /// **'Price summary'**
  String get booking_price_summary;

  /// No description provided for @booking_deposit.
  ///
  /// In en, this message translates to:
  /// **'Deposit'**
  String get booking_deposit;

  /// No description provided for @booking_rent.
  ///
  /// In en, this message translates to:
  /// **'Rent'**
  String get booking_rent;

  /// No description provided for @booking_total_due_now.
  ///
  /// In en, this message translates to:
  /// **'Total due now'**
  String get booking_total_due_now;

  /// No description provided for @booking_pay_full_stay.
  ///
  /// In en, this message translates to:
  /// **'Pay rent for the full stay'**
  String get booking_pay_full_stay;

  /// No description provided for @booking_pay_full_stay_note.
  ///
  /// In en, this message translates to:
  /// **'Off by default. Otherwise only the first rental period is charged now.'**
  String get booking_pay_full_stay_note;

  /// No description provided for @booking_payment_method.
  ///
  /// In en, this message translates to:
  /// **'Payment method'**
  String get booking_payment_method;

  /// No description provided for @booking_continue_to_payment.
  ///
  /// In en, this message translates to:
  /// **'Continue to secure payment'**
  String get booking_continue_to_payment;

  /// No description provided for @booking_preparing_checkout.
  ///
  /// In en, this message translates to:
  /// **'Preparing payment…'**
  String get booking_preparing_checkout;

  /// No description provided for @booking_hosted_payment_note.
  ///
  /// In en, this message translates to:
  /// **'Payment opens securely in your browser. Return here to check the verified result.'**
  String get booking_hosted_payment_note;

  /// No description provided for @booking_checkout_launch_failed.
  ///
  /// In en, this message translates to:
  /// **'Could not open the secure payment page.'**
  String get booking_checkout_launch_failed;

  /// No description provided for @booking_check_status.
  ///
  /// In en, this message translates to:
  /// **'Check payment status'**
  String get booking_check_status;

  /// No description provided for @booking_pending_title.
  ///
  /// In en, this message translates to:
  /// **'Checking your payment'**
  String get booking_pending_title;

  /// No description provided for @booking_pending_message.
  ///
  /// In en, this message translates to:
  /// **'The provider is still processing it. We will confirm only after the backend verifies the payment.'**
  String get booking_pending_message;

  /// No description provided for @booking_confirmed_title.
  ///
  /// In en, this message translates to:
  /// **'Booking confirmed'**
  String get booking_confirmed_title;

  /// No description provided for @booking_confirmed_message.
  ///
  /// In en, this message translates to:
  /// **'Your dates are secured. Your lease is ready for the next signing step.'**
  String get booking_confirmed_message;

  /// No description provided for @booking_failed_title.
  ///
  /// In en, this message translates to:
  /// **'Payment failed'**
  String get booking_failed_title;

  /// No description provided for @booking_failed_message.
  ///
  /// In en, this message translates to:
  /// **'The home was not booked. You can return and start a new payment.'**
  String get booking_failed_message;

  /// No description provided for @booking_expired_title.
  ///
  /// In en, this message translates to:
  /// **'Payment expired'**
  String get booking_expired_title;

  /// No description provided for @booking_expired_message.
  ///
  /// In en, this message translates to:
  /// **'The temporary hold was released. Choose the dates again to continue.'**
  String get booking_expired_message;

  /// No description provided for @booking_review_title.
  ///
  /// In en, this message translates to:
  /// **'Payment needs review'**
  String get booking_review_title;

  /// No description provided for @booking_review_message.
  ///
  /// In en, this message translates to:
  /// **'Our finance team must review this payment. Do not pay again until support contacts you.'**
  String get booking_review_message;

  /// No description provided for @booking_unavailable.
  ///
  /// In en, this message translates to:
  /// **'Direct booking is unavailable'**
  String get booking_unavailable;

  /// No description provided for @booking_return_unverified.
  ///
  /// In en, this message translates to:
  /// **'We could not match this return link to an active checkout. The link itself is not proof of payment.'**
  String get booking_return_unverified;

  /// No description provided for @booking_back_home.
  ///
  /// In en, this message translates to:
  /// **'Back to home'**
  String get booking_back_home;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ru', 'uz'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ru':
      return AppLocalizationsRu();
    case 'uz':
      return AppLocalizationsUz();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
