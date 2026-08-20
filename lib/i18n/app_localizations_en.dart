// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get common_keys => '================ COMMON KEYS ================';

  @override
  String get add => 'Add';

  @override
  String get camera => 'Camera';

  @override
  String get gallery => 'Gallery';

  @override
  String get next => 'Next';

  @override
  String get or => 'Or';

  @override
  String get remove => 'Remove';

  @override
  String get search => 'Search';

  @override
  String get opps_something_went_wrong => 'Opps Something Went Wrong';

  @override
  String get time_date_keys =>
      '================ TIME & DATE KEYS ================';

  @override
  String daysAgo(int count) {
    return '$count days ago';
  }

  @override
  String hoursAgo(int count) {
    return '$count hrs ago';
  }

  @override
  String get justNow => 'Just now';

  @override
  String get lastMonth => 'Last month';

  @override
  String get lastYear => 'Last year';

  @override
  String minutesAgo(int count) {
    return '$count min ago';
  }

  @override
  String monthsAgo(int count) {
    return '$count months ago';
  }

  @override
  String get oneHourAgo => '1 hr ago';

  @override
  String get oneMinuteAgo => '1 min ago';

  @override
  String get today => 'Today';

  @override
  String yearsAgo(int count) {
    return '$count years ago';
  }

  @override
  String get yesterday => 'Yesterday';

  @override
  String get login_keys => '================ LOGIN KEYS ================';

  @override
  String get ask_forgot_password => 'Forgot password?';

  @override
  String get check_your_email => 'Check Your Email';

  @override
  String get resend => 'Resend';

  @override
  String get login_continue => 'Continue';

  @override
  String get continue_with_apple => 'Continue with Apple';

  @override
  String get continue_with_email => 'Continue with Email';

  @override
  String get continue_with_google => 'Continue with Google';

  @override
  String get continue_with_number => 'Continue with Phone Number';

  @override
  String get enter_otp => 'Enter OTP';

  @override
  String get enter_phone_number => 'Enter phone number';

  @override
  String get enter_your_registered_phone_number =>
      'Enter your registered phone number';

  @override
  String get forgot_password => 'Forgot password';

  @override
  String get invalid_mobile_number => 'Invalid mobile number';

  @override
  String link_send_info(String email) {
    return 'A reset link has been sent to $email. Please check your inbox and click the link to reset the password.';
  }

  @override
  String get login => 'Login';

  @override
  String get log_in => 'Log in';

  @override
  String get sign_in => 'Sign in';

  @override
  String get login_terms_notice => 'By continuing, you agree to our';

  @override
  String get sign_in_required_title => 'Make iDeal work for you';

  @override
  String get sign_in_required_message =>
      'Sign in to save homes, start secure conversations, and manage your bookings in one place.';

  @override
  String get guest_access_sign_in => 'Sign in with phone';

  @override
  String get guest_access_keep_browsing => 'Keep browsing';

  @override
  String get login_with_email => 'Login with email';

  @override
  String get send_otp => 'Send OTP';

  @override
  String get otp_channel_confirmation => 'Is the number correct?';

  @override
  String get otp_channel_telegram => 'Via Telegram (recommended)';

  @override
  String get otp_channel_sms => 'Via SMS';

  @override
  String get otp_channel_edit => 'Edit';

  @override
  String get send_reset_link => 'Send Reset Link';

  @override
  String get sent_code_info => 'We’ve sent a 6-digit code to';

  @override
  String get welcome_back => 'Welcome back!';

  @override
  String get signup_keys => '================ SIGNUP KEYS ================';

  @override
  String get already_have_account => 'Already have an account? ';

  @override
  String get back_to_login => 'Back to login';

  @override
  String get confirm_password => 'Confirm password';

  @override
  String get confirm_password_hint => 'Enter confirm password';

  @override
  String get change_email => ' Change Email';

  @override
  String get create_your_password => 'Create your password';

  @override
  String get email => 'Email';

  @override
  String get first_name => 'First name';

  @override
  String get last_name => 'Last name';

  @override
  String get patronymic => 'Patronymic';

  @override
  String get nationality => 'Nationality';

  @override
  String get email_cant_be_empty => 'Email can’t be empty';

  @override
  String get email_hint => 'Enter email';

  @override
  String get email_id => 'Email Id';

  @override
  String get enter_your_email_id => 'Enter your email id';

  @override
  String get enter_your_name => 'Enter your name';

  @override
  String get entered_wrong_email => 'Entered the wrong email?';

  @override
  String get error_enter_confirm_password => 'Please enter confirm password';

  @override
  String get error_retrieving_email => 'Error retrieving your email';

  @override
  String get error_retrieving_phone_number =>
      'Error retrieving your phone number';

  @override
  String get invalid_email => 'Please enter a valid email address';

  @override
  String get lets_get_started => 'Let\'s get started';

  @override
  String get lets_get_started_info =>
      'Enter your phone number, we will send you a verification code';

  @override
  String link_verify_info(String email) {
    return 'A verification link has been sent to $email. Click the link to verify your account.';
  }

  @override
  String get mobile_number => 'Mobile number';

  @override
  String get name => 'Name';

  @override
  String get name_cannot_be_empty => 'Name can\'t be empty';

  @override
  String get no_account => 'Don’t have an account? ';

  @override
  String get password => 'Password';

  @override
  String get password_cant_be_empty => 'Password can\'t be empty';

  @override
  String get password_hint => 'Enter password';

  @override
  String get password_requirements => 'Your password must have at least:';

  @override
  String get password_requirements_length => '8 characters or more';

  @override
  String get password_requirements_letter_number => '1 letter and number';

  @override
  String get password_requirements_special_char =>
      '1 special character (Example: # ? ! \$ & @)';

  @override
  String get password_strength => 'Password strength:';

  @override
  String get passwords_do_not_match => 'Passwords do not match';

  @override
  String get phone_no_verified => 'Phone number verified!';

  @override
  String get phone_no_verified_info =>
      'Your Phone number has been successfully verified. You can now complete your profile.';

  @override
  String get poor => 'Poor';

  @override
  String get sign_up => 'Sign up';

  @override
  String get sign_up_with_apple => 'Sign up with Apple';

  @override
  String get sign_up_with_email => 'Sign up with Email';

  @override
  String get sign_up_with_google => 'Sign up with Google';

  @override
  String get strong => 'Strong';

  @override
  String get terms_and_conditions => 'Terms and Conditions';

  @override
  String get user_info_not_retrieved =>
      'User information could not be retrieved.';

  @override
  String get weak => 'Weak';

  @override
  String get verify => 'Verify';

  @override
  String get verify_email_keys =>
      '================ VERIFY EMAIL KEYS ================';

  @override
  String get resend_verification_email => 'Resend Verification Email';

  @override
  String get verify_your_email => 'Verify your email';

  @override
  String get profile_keys => '================ PROFILE KEYS ================';

  @override
  String get account => 'Account';

  @override
  String get add_a_profile_picture => 'Add a profile picture';

  @override
  String get personal_details => 'Personal Details';

  @override
  String get profile => 'Profile';

  @override
  String get help_and_support => 'Help & Support';

  @override
  String get edit => 'Edit';

  @override
  String get rotate => 'Rotate';

  @override
  String get retry => 'Retry';

  @override
  String get sign_out => 'Sign out';

  @override
  String get sign_out_confirmation_message =>
      'Are you sure you want to sign out?';

  @override
  String get skip => 'Skip';

  @override
  String get preferences => 'Preferences';

  @override
  String get appearance => 'Appearance';

  @override
  String get version => 'Version';

  @override
  String get activity => 'Activity';

  @override
  String get my_orders => 'My Orders';

  @override
  String get done => 'Done';

  @override
  String get feedback_and_ratings => 'Feedback & Ratings';

  @override
  String get notifications => 'Notifications';

  @override
  String get delete_account_keys =>
      '================ DELETE ACCOUNT KEYS ================';

  @override
  String get delete => 'Delete';

  @override
  String get delete_account => 'Delete Account';

  @override
  String get delete_account_alert_title =>
      'Are you sure you want to Delete Account?';

  @override
  String get delete_account_confirmation_message =>
      'This action is irreversible. Your account and reusable personal data will be deleted. Records retained for legal, service, or dispute purposes will be anonymized. Do you want to continue?';

  @override
  String get delete_reason_dislike_app => 'I don’t like to be on this app';

  @override
  String get delete_reason_do_not_need_anymore => 'I don\'t need it anymore';

  @override
  String get delete_reason_other => 'Other';

  @override
  String get delete_reason_product_no_more_relevant =>
      'Products are no more relevant to me';

  @override
  String get delete_reason_title => 'Why are you deleting account?';

  @override
  String get delete_warning_account_info =>
      'Delete all of your account information';

  @override
  String get delete_warning_products_chats =>
      'Saved products, chats will be deleted';

  @override
  String get delete_warning_title => 'Deleting account will do the following :';

  @override
  String get please_select_at_least_one_reason =>
      'Please select at least one reason';

  @override
  String get please_specify_your_reason => 'Please specify your reason';

  @override
  String get specify_reason => 'Please specify your reason';

  @override
  String get cancel => 'Cancel';

  @override
  String get account_delete_success_keys =>
      '================ ACCOUNT DELETE SUCCESS KEYS ================';

  @override
  String get account_deleted => 'Account Deleted!';

  @override
  String get creating_new_account => 'Creating new account?';

  @override
  String get coupons_keys => '================ COUPONS KEYS ================';

  @override
  String get apply => 'Apply';

  @override
  String get apply_coupon => 'Apply Coupon';

  @override
  String get available_coupons => 'Available Coupons';

  @override
  String coupon_message(int coupon_count) {
    String _temp0 = intl.Intl.pluralLogic(
      coupon_count,
      locale: localeName,
      other: '$coupon_count Coupons Available',
      one: '$coupon_count Coupon Available',
      zero: 'No Coupon Available',
    );
    return '$_temp0';
  }

  @override
  String get search_by_name_or_code => 'Search by name or code';

  @override
  String get home_keys => '================ HOME KEYS ================';

  @override
  String get home => 'Home';

  @override
  String get selected => 'Selected';

  @override
  String get rating => 'Rating';

  @override
  String get reviews => 'Reviews';

  @override
  String get see_all => 'See All';

  @override
  String get star => 'Star';

  @override
  String get top_products => 'Top Products';

  @override
  String no_result_for(Object searchText) {
    return 'No results for \"$searchText\"';
  }

  @override
  String get no_search_result_message =>
      'We couldn\'t found any result related to your search. Try searching for something else.';

  @override
  String get microphone_permission_permanently_denied =>
      'Microphone permission is permanently denied. Please go to settings and enable it.';

  @override
  String get chat_keys => '================ CHAT KEYS ================';

  @override
  String get chat => 'Chat';

  @override
  String get you => 'You';

  @override
  String get message => 'Message';

  @override
  String messageTooLong(int maxLength) {
    return 'Your message is too long (max $maxLength characters)';
  }

  @override
  String get message_cannot_be_empty => 'Message can\'t be empty';

  @override
  String get message_description => 'Write description...';

  @override
  String get no_messages_yet => 'No messages yet';

  @override
  String get failed_to_load_chats => 'Failed to load chats';

  @override
  String get send_a_new_message => 'Send a new message';

  @override
  String get chats_keys => '================ CHATS KEYS ================';

  @override
  String get chats => 'Chats';

  @override
  String get chats_empty_title => 'No chats yet';

  @override
  String get chats_empty_subtitle =>
      'Message us about a listing and your conversation will appear here';

  @override
  String get chats_active => 'Active';

  @override
  String get chats_archived => 'Archived';

  @override
  String get chats_archived_empty_title => 'No archived chats';

  @override
  String get chats_archived_empty_subtitle =>
      'Chats you archive will appear here';

  @override
  String get chats_loading_more => 'Loading more chats';

  @override
  String get chats_load_error => 'Couldn\'t load chats. Please try again.';

  @override
  String get chats_retry => 'Retry';

  @override
  String get chat_archive => 'Archive';

  @override
  String get chat_unarchive => 'Unarchive';

  @override
  String get chat_mute => 'Mute notifications';

  @override
  String get chat_unmute => 'Unmute notifications';

  @override
  String get chat_delete => 'Delete chat';

  @override
  String get chat_report => 'Report';

  @override
  String get chat_delete_title => 'Delete this chat?';

  @override
  String get chat_delete_message =>
      'This chat will be removed from your list and you will not be able to reopen it.';

  @override
  String get chat_delete_confirm => 'Delete';

  @override
  String get chat_cancel => 'Cancel';

  @override
  String get chat_conversation_keys =>
      '================ CHAT CONVERSATION KEYS ================';

  @override
  String get chat_message_hint => 'Message';

  @override
  String get chat_message_too_long => 'Messages can be up to 1024 characters';

  @override
  String get chat_send_failed => 'Not sent. Tap to retry.';

  @override
  String get chat_retry => 'Retry';

  @override
  String get chat_photo => 'Photo';

  @override
  String get chat_read_only_blocked =>
      'You can no longer send messages in this chat.';

  @override
  String get chat_listing_unavailable => 'This listing is no longer available.';

  @override
  String get chat_attach_photo => 'Add photo';

  @override
  String get chat_attach_camera => 'Camera';

  @override
  String get chat_attach_gallery => 'Gallery';

  @override
  String get chat_image_too_large => 'Images must be smaller than 5 MB';

  @override
  String get chat_image_unsupported_format => 'Unsupported image format';

  @override
  String get chat_today => 'Today';

  @override
  String get chat_yesterday => 'Yesterday';

  @override
  String get chat_report_keys =>
      '================ CHAT REPORT KEYS ================';

  @override
  String get chat_report_title => 'Report this chat';

  @override
  String get chat_report_reason_spam => 'Spam';

  @override
  String get chat_report_reason_abuse => 'Abuse';

  @override
  String get chat_report_reason_scam => 'Scam';

  @override
  String get chat_report_reason_other => 'Other';

  @override
  String get chat_report_note_hint => 'Add details (optional)';

  @override
  String get chat_report_submit => 'Submit report';

  @override
  String get chat_report_submitted => 'Report submitted';

  @override
  String get contact_us_keys =>
      '================ CONTACT US KEYS ================';

  @override
  String get attachment => 'Attachments (Up to 5)';

  @override
  String get alright => 'Alright !';

  @override
  String get choose_a_file => 'Choose a file or drag and drop here';

  @override
  String get contact_us => 'Contact Us';

  @override
  String get submit => 'Submit';

  @override
  String get contact_us_message =>
      'Let’s get connect if you have any queries. We are happy to help you anytime.';

  @override
  String get file_cannot_be_empty => 'Please select at least one file';

  @override
  String get file_empty_error =>
      'The selected PDF file is empty. Please choose a valid file.';

  @override
  String get file_too_large_error =>
      'One or more selected files exceed the 5MB limit.';

  @override
  String get pick_file_error =>
      'Something went wrong while picking files. Please try again.';

  @override
  String get pick_image_error =>
      'Something went wrong while picking images. Please try again.';

  @override
  String get pick_pdf_error =>
      'Something went wrong while picking PDFs. Please try again.';

  @override
  String get response_received =>
      'We have received your response and will revert back to you as soon as possible.';

  @override
  String get support => 'Support';

  @override
  String get supported_format =>
      'Supported JPG,PNG,PDF. Maximum file size 10mb';

  @override
  String get take_a_photo => 'Take a photo';

  @override
  String get unsupported_file_format_error =>
      'The selected file is not a valid PDF. Please choose a proper PDF file to continue.';

  @override
  String get upload_from_files => 'Upload from files';

  @override
  String get upload_from_gallery => 'Upload from gallery';

  @override
  String get notifications_keys =>
      '================ NOTIFICATIONS KEYS ================';

  @override
  String get empty_notifications_title => 'No Notifications Yet';

  @override
  String get notifications_mark_all_read => 'Mark all read';

  @override
  String get notifications_push_enabled => 'Push notifications';

  @override
  String get notifications_push_description =>
      'Receive alerts about your iDeal activity.';

  @override
  String get notifications_messages => 'Messages';

  @override
  String get notifications_payments => 'Payments';

  @override
  String get notifications_bookings => 'Bookings';

  @override
  String get notifications_maintenance => 'Maintenance';

  @override
  String get notifications_leases => 'Leases';

  @override
  String get notifications_general => 'General';

  @override
  String get notifications_permission_denied =>
      'Notifications are disabled in your device settings.';

  @override
  String get notifications_open_settings => 'Open settings';

  @override
  String get settings_keys => '================ SETTINGS KEYS ================';

  @override
  String get settings => 'Settings';

  @override
  String get notification_settings => 'Notification Settings';

  @override
  String get choose_app_theme => 'Choose App Theme';

  @override
  String get biometric_authentication => 'Biometric Authentication';

  @override
  String get privacy_policy => 'Privacy Policy';

  @override
  String get saved_cards_keys =>
      '================ SAVED CARDS KEYS ================';

  @override
  String get empty_cards_list_message =>
      'There is no card available at the moment.';

  @override
  String get explore_products => 'Explore Products';

  @override
  String get save => 'Save';

  @override
  String get empty_screens_keys =>
      '================ EMPTY SCREENS KEYS ================';

  @override
  String get force_update_keys =>
      '================ FORCE UPDATE KEYS ================';

  @override
  String get could_not_launch_store_link => 'Could not launch store link';

  @override
  String get its_time_to_update => 'It’s time to Update!';

  @override
  String get skip_update => 'Skip Update';

  @override
  String get update_app => 'Update App';

  @override
  String get update_now => 'Update Now';

  @override
  String get update_required_description =>
      'The version you are using is old, to continue using you need to update the latest version in order to experience new features.';

  @override
  String get under_maintenance_keys =>
      '================ UNDER MAINTENANCE KEYS ================';

  @override
  String get under_maintenance => 'App is Under Maintenance';

  @override
  String get under_maintenance_message =>
      'App is currently under maintenance. We will notify you once we are done. Try again later.';

  @override
  String get no_internet_keys =>
      '================ NO INTERNET KEYS ================';

  @override
  String get lost_connection => 'You Lost Connection';

  @override
  String get lost_connection_message =>
      'Seems like you have lost internet connection';

  @override
  String get no_internet_connection => 'Please check your internet connection';

  @override
  String get server_error_keys =>
      '================ SERVER ERROR KEYS ================';

  @override
  String get server_error => 'Server Error';

  @override
  String get server_error_description =>
      'There is server error at the moment, please check back later';

  @override
  String get server_error_title => 'Server Error';

  @override
  String get back_to_home => 'Back to Home';

  @override
  String get ssl_pinning_keys =>
      '================ SSL PINNING KEYS ================';

  @override
  String get platform_not_supported => 'Platform not supported';

  @override
  String get secure_connection_failed_message =>
      'We couldn\'t connect securely to our server. Please try again later, or check if app update available.';

  @override
  String get secure_connection_failed_title => 'Secure Connection Failed!';

  @override
  String get try_again => 'Try Again';

  @override
  String get reminder_keys => '================ REMINDER KEYS ================';

  @override
  String get reminder => 'Reminder';

  @override
  String get reminder_title => 'Title';

  @override
  String get reminder_description => 'Description (Optional)';

  @override
  String get reminder_title_hint => 'Enter reminder title';

  @override
  String get reminder_description_hint => 'Enter description';

  @override
  String get date_and_time => 'Date & Time';

  @override
  String get schedule_reminder => 'Schedule Reminder';

  @override
  String get reminder_title_required => 'Please enter a title';

  @override
  String get reminder_future_date_required =>
      'Please select a future date and time';

  @override
  String get reminder_scheduled_successfully =>
      'Reminder scheduled successfully!';

  @override
  String get reminder_schedule_failed => 'Failed to schedule reminder';

  @override
  String get share_product_subject => 'Product on iDeal Mobile';

  @override
  String share_product_message(String url) {
    return 'I found this product on iDeal Mobile and thought you might like it.\n\nCheck it out here:\n$url';
  }

  @override
  String get app_tour_keys => '================ APP TOUR KEYS ================';

  @override
  String get tour_search_title => 'Search Products';

  @override
  String get tour_search_description =>
      'Use the search bar to quickly find the products you\'re looking for. Just type what you need!';

  @override
  String get tour_nav_title => 'Navigate the App';

  @override
  String get tour_nav_description =>
      'Use the bottom navigation to switch between Home, Search, Cart, and Profile sections.';

  @override
  String get got_it => 'Got it!';

  @override
  String get search_bar_identify => 'search_bar';

  @override
  String get bottom_nav__bar_identify => 'bottom_nav_bar';

  @override
  String get biometric_auth_keys =>
      '================ BIOMETRIC AUTH KEYS ================';

  @override
  String get biometric_auth_desc_for_enrollment =>
      'Biometric authentication is not set up on your device. Please either enable Touch ID or Face ID on your phone.';

  @override
  String get go_to_settings => 'Go to settings';

  @override
  String get biometric_auth_reason_access_app =>
      'Please authenticate to access the app';

  @override
  String get biometric_auth_not_setup =>
      'Biometric authentication is not set up on your device.';

  @override
  String get biometric_setup_enable_instruction =>
      'Biometric authentication is not set up on your device. Please enable Touch ID or Face ID (iPhone) or Fingerprint/Face Unlock (Android) to continue.';

  @override
  String get ok => 'OK';

  @override
  String get enable_or_disable => 'Enable/ Disable';

  @override
  String get biometric_auth_description =>
      'Use the toggle to activate or deactivate biometric verification.';

  @override
  String get biometric_auth_enabled_success =>
      'Biometric authentication enabled successfully';

  @override
  String get biometric_auth_disabled => 'Biometric authentication disabled';

  @override
  String get auth_failed => 'Authentication failed';

  @override
  String get biometric_auth_not_available =>
      'Biometric authentication is not available on this device';

  @override
  String get biometric_auth_too_many_attempts =>
      'Too many attempts. Please try again later.';

  @override
  String get invoice_keys => '================ INVOICE KEYS ================';

  @override
  String get share_invoice => 'Share';

  @override
  String get download => 'Download';

  @override
  String get invoice_saved_success => 'Invoice saved successfully';

  @override
  String get invoice_generation_failed =>
      'Failed to generate invoice. Please try again.';

  @override
  String get storage_permission_required =>
      'Storage permission required to save invoice';

  @override
  String get online_payment_method => 'Online Payment';

  @override
  String get generate_invoice => 'Generate Invoice';

  @override
  String get invoice => 'INVOICE';

  @override
  String get invoice_details => 'Invoice Details:';

  @override
  String get invoice_number => 'Invoice Number';

  @override
  String get invoice_date => 'Invoice Date';

  @override
  String get bill_to => 'Bill To:';

  @override
  String get product => 'Product';

  @override
  String get quantity => 'Quantity';

  @override
  String get total => 'Total';

  @override
  String get subtotal => 'Subtotal';

  @override
  String get payment_method => 'Payment Method';

  @override
  String get download_invoice => 'Download Invoice';

  @override
  String get invoice_share_failed =>
      'Failed to share invoice. Please try again';

  @override
  String get feedback_keys => '================ FEEDBACK KEYS ================';

  @override
  String get feedback => 'Feedback';

  @override
  String get please_share_your_thoughts =>
      'Please share your thoughts before submitting.';

  @override
  String get rate_your_experience => 'Rate your experience';

  @override
  String get your_feedback => 'Your feedback';

  @override
  String get feedback_hint => 'Tell us what you think...';

  @override
  String get submit_feedback => 'Submit Feedback';

  @override
  String get feedback_submitted_success =>
      'Thank you! Your feedback has been submitted.';

  @override
  String get please_select_a_rating => 'Please select a rating to continue.';

  @override
  String get feedback_category_label => 'Pick a category';

  @override
  String get feedback_category_required =>
      'Please select a category to continue.';

  @override
  String get feedback_category_bug => 'Bug';

  @override
  String get feedback_category_suggestion => 'Suggestion';

  @override
  String get feedback_category_content => 'Content';

  @override
  String get feedback_category_compliment => 'Compliment';

  @override
  String get feedback_category_other => 'Other';

  @override
  String get feedback_description =>
      'Share your experience and help us improve. We value every word you share with us.';

  @override
  String get ai_chat_keys => '================ AI CHAT KEYS ================';

  @override
  String get ai_assistant => 'AI Assistant';

  @override
  String get ai_chat_how_can_i_help => 'How can I help you?';

  @override
  String get ai_chat_ask_me_anything => 'Ask me anything...';

  @override
  String get ai_chat_description =>
      'Ask me about listings, renting, or app navigation.';

  @override
  String get ai_chat_error_no_response =>
      'No response received. Please try again.';

  @override
  String get ai_chat_error_quota =>
      'AI assistant is temporarily unavailable due to high usage. Please try again in a minute.';

  @override
  String get ai_chat_error_timeout =>
      'Response took too long. Please try again.';

  @override
  String get ai_chat_error_network =>
      'No internet connection. Please check your network and try again.';

  @override
  String get ai_chat_error_generic => 'Something went wrong. Please try again.';

  @override
  String get listings_keys => '======== LISTINGS KEYS ========';

  @override
  String get listings_per_month => '/mo';

  @override
  String listings_rooms_count(num count) {
    return '$count rooms';
  }

  @override
  String listings_area_sqm(num area) {
    return '$area m²';
  }

  @override
  String listings_floor_only(num floor) {
    return 'Floor $floor';
  }

  @override
  String listings_floor_of(num floor, num total) {
    return 'Floor $floor of $total';
  }

  @override
  String get listings_save => 'Save';

  @override
  String get selected_empty_title => 'No selected homes yet';

  @override
  String get selected_empty_subtitle =>
      'Tap the heart on any home to keep it here for later.';

  @override
  String get selected_error_title => 'Couldn\'t load your selected homes';

  @override
  String get selected_load_error =>
      'Couldn\'t load your selected homes. Please try again.';

  @override
  String get selected_mutation_error =>
      'Couldn\'t update your selected homes. Please try again.';

  @override
  String get selected_unknown_error =>
      'Something went wrong with your selected homes. Please try again.';

  @override
  String get selected_retry => 'Retry';

  @override
  String get selected_page_out_of_date =>
      'The selected homes page changed. Please try again.';

  @override
  String get selected_loading_more => 'Loading more selected homes';

  @override
  String selected_result_count(num count) {
    return '$count selected homes';
  }

  @override
  String get selected_sort => 'Sort';

  @override
  String get selected_sort_recent => 'Recently selected';

  @override
  String get selected_sort_price_asc => 'Price: low to high';

  @override
  String get selected_sort_price_desc => 'Price: high to low';

  @override
  String get selected_no_matches_title => 'No matching selected homes';

  @override
  String get selected_no_matches_subtitle =>
      'Try widening your search or clearing some filters.';

  @override
  String get selected_clear_filters => 'Clear filters';

  @override
  String get selected_removed => 'Removed from selected homes';

  @override
  String get selected_undo => 'Undo';

  @override
  String get listings_verified => 'Verified';

  @override
  String get listings_tariff_standard => 'Standard';

  @override
  String get listings_tariff_comfort => 'Comfort';

  @override
  String get listings_tariff_premium => 'Premium';

  @override
  String get listings_furnishing_furnished => 'Furnished';

  @override
  String get listings_furnishing_semi_furnished => 'Semi-furnished';

  @override
  String get listings_furnishing_unfurnished => 'Unfurnished';

  @override
  String get listings_all_filters => 'All filters';

  @override
  String get listings_apply => 'Apply';

  @override
  String get listings_clear_all => 'Clear all';

  @override
  String get listings_clear_filters => 'Clear filters';

  @override
  String get listings_filter_district => 'District';

  @override
  String get listings_filter_property_type => 'Property type';

  @override
  String get listings_filter_price => 'Price range';

  @override
  String get listings_filter_rooms => 'Rooms';

  @override
  String get listings_filter_furnishing => 'Furnishing';

  @override
  String get listings_filter_tariff => 'Tariff';

  @override
  String get listings_range_min => 'Min';

  @override
  String get listings_range_max => 'Max';

  @override
  String get listings_chip_verified => 'Verified only';

  @override
  String get listings_chip_furnished => 'Furnished';

  @override
  String get listings_chip_comfort => 'Comfort';

  @override
  String get listings_chip_premium => 'Premium';

  @override
  String get listings_search_placeholder => 'Search rentals';

  @override
  String get recent_searches => 'Recent searches';

  @override
  String get listings_view_map => 'Map';

  @override
  String get listing_map_search_hint => 'Search homes';

  @override
  String get listing_map_full_filters => 'Full filters';

  @override
  String get listing_map_search_this_area => 'Search this area';

  @override
  String get listing_map_list => 'List';

  @override
  String get listing_map_zoom_in => 'Zoom in to see all homes';

  @override
  String get listing_map_no_results => 'No homes in this area';

  @override
  String get listing_map_loading => 'Loading homes';

  @override
  String get listing_map_full_info => 'Full info';

  @override
  String get listing_map_call => 'Call';

  @override
  String get listing_map_call_failed =>
      'Couldn\'t start the call. Check your phone settings and try again.';

  @override
  String get listing_map_error_title => 'Couldn\'t load this area';

  @override
  String get listing_map_retry => 'Retry';

  @override
  String get listing_map_near_me => 'Near me';

  @override
  String get listing_map_location_unavailable =>
      'Couldn\'t determine your location';

  @override
  String listings_result_count(num count) {
    return '$count verified homes';
  }

  @override
  String get listings_empty_title => 'No homes match these filters';

  @override
  String get listings_empty_subtitle =>
      'Try widening your search or clearing some filters.';

  @override
  String get listings_error_title => 'Couldn\'t load homes';

  @override
  String get listings_error_subtitle => 'Check your connection and try again.';

  @override
  String get listings_retry => 'Retry';

  @override
  String get listings_showing_saved => 'Showing saved listings. Pull to retry.';

  @override
  String get listings_anywhere => 'Anywhere';

  @override
  String get listings_any => 'Any';

  @override
  String get listing_detail_keys => '======== LISTING DETAIL KEYS ========';

  @override
  String listing_detail_reviews_count(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count reviews',
      one: '1 review',
      zero: 'No reviews',
    );
    return '$_temp0';
  }

  @override
  String get listing_detail_verified => 'Verified';

  @override
  String get listing_detail_trust_heading =>
      'Verified & contract-backed by iDeal';

  @override
  String get listing_detail_about => 'About this home';

  @override
  String get listing_detail_amenities => 'What this place offers';

  @override
  String get listing_detail_neighborhood => 'Neighborhood';

  @override
  String get listing_detail_location => 'Location';

  @override
  String get listing_detail_map_open => 'Open map';

  @override
  String get listing_detail_map_unavailable => 'Map unavailable';

  @override
  String get listing_detail_read_more => 'Read more';

  @override
  String get listing_detail_show_less => 'Show less';

  @override
  String get listing_detail_message => 'Message';

  @override
  String get listing_detail_message_unavailable =>
      'Messaging is unavailable for this listing';

  @override
  String get listing_detail_call => 'Call';

  @override
  String get listing_detail_share => 'Share';

  @override
  String listing_detail_photo_counter(int current, int total) {
    return '$current / $total';
  }

  @override
  String listing_detail_more_photos(int count) {
    return '+$count';
  }

  @override
  String get listing_detail_no_obligation => 'No obligation to rent';

  @override
  String listing_detail_deposit(String amount) {
    return 'Deposit: $amount';
  }

  @override
  String listing_detail_minimum_stay(int count) {
    return 'Minimum stay: $count months';
  }

  @override
  String get listing_detail_error_title => 'Couldn\'t load this home';

  @override
  String get listing_detail_error_subtitle =>
      'Check your connection and try again.';

  @override
  String get listing_detail_not_found => 'This home is no longer available.';

  @override
  String get listing_detail_retry => 'Retry';

  @override
  String get empty_views_keys =>
      '================ EMPTY VIEWS KEYS ================';

  @override
  String get empty_views => 'Empty Views';

  @override
  String get empty_states => 'Empty States';

  @override
  String get error_states => 'Error States';

  @override
  String get utilities => 'Utilities';

  @override
  String get ai_chat_suggestion_listings => 'Find an apartment';

  @override
  String get ai_chat_suggestion_renting => 'How does renting work?';

  @override
  String get ai_chat_suggestion_support => 'Contact support';

  @override
  String get booking_keys => '======== BOOKING KEYS ========';

  @override
  String get booking_book_and_pay => 'Book & pay';

  @override
  String get booking_title => 'Book this home';

  @override
  String get booking_status_title => 'Booking status';

  @override
  String get booking_status_requested => 'Requested';

  @override
  String get booking_status_approved => 'Approved';

  @override
  String get booking_status_rejected => 'Rejected';

  @override
  String get booking_status_cancelled => 'Cancelled';

  @override
  String get booking_status_payment_pending => 'Payment pending';

  @override
  String get booking_status_confirmed => 'Confirmed';

  @override
  String get booking_status_payment_failed => 'Payment failed';

  @override
  String get booking_status_payment_expired => 'Payment expired';

  @override
  String get booking_status_reconciliation_required => 'Under review';

  @override
  String get no_bookings_yet => 'You have no bookings yet';

  @override
  String get booking_choose_dates => 'Choose your stay';

  @override
  String get booking_dates_inclusive =>
      'Your start and end dates are both included.';

  @override
  String get booking_select_dates => 'Select dates';

  @override
  String get booking_choose_start_date => 'Choose a start date';

  @override
  String get booking_choose_end_date => 'Choose an end date';

  @override
  String booking_months(int count) {
    return '$count months';
  }

  @override
  String get booking_range_unavailable =>
      'That period is not available. Choose different dates.';

  @override
  String get booking_get_quote => 'Get price';

  @override
  String get booking_price_summary => 'Price summary';

  @override
  String get booking_deposit => 'Deposit';

  @override
  String get booking_rent => 'Rent';

  @override
  String get booking_total_due_now => 'Total due now';

  @override
  String get booking_pay_full_stay => 'Pay rent for the full stay';

  @override
  String get booking_pay_full_stay_note =>
      'Off by default. Otherwise only the first rental period is charged now.';

  @override
  String get booking_payment_method => 'Payment method';

  @override
  String get booking_continue_to_payment => 'Continue to secure payment';

  @override
  String get booking_preparing_checkout => 'Preparing payment…';

  @override
  String get booking_hosted_payment_note =>
      'Payment opens securely in your browser. Return here to check the verified result.';

  @override
  String get booking_checkout_launch_failed =>
      'Could not open the secure payment page.';

  @override
  String get booking_check_status => 'Check payment status';

  @override
  String get booking_pending_title => 'Checking your payment';

  @override
  String get booking_pending_message =>
      'The provider is still processing it. We will confirm only after the backend verifies the payment.';

  @override
  String get booking_confirmed_title => 'Booking confirmed';

  @override
  String get booking_confirmed_message =>
      'Your dates are secured. Your lease is ready for the next signing step.';

  @override
  String get booking_failed_title => 'Payment failed';

  @override
  String get booking_failed_message =>
      'The home was not booked. You can return and start a new payment.';

  @override
  String get booking_expired_title => 'Payment expired';

  @override
  String get booking_expired_message =>
      'The temporary hold was released. Choose the dates again to continue.';

  @override
  String get booking_review_title => 'Payment needs review';

  @override
  String get booking_review_message =>
      'Our finance team must review this payment. Do not pay again until support contacts you.';

  @override
  String get booking_unavailable => 'Direct booking is unavailable';

  @override
  String get booking_return_unverified =>
      'We could not match this return link to an active checkout. The link itself is not proof of payment.';

  @override
  String get booking_back_home => 'Back to home';
}
