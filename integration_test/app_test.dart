import 'package:flutter_test/flutter_test.dart';

import 'presentation/login/login_screen_test.dart' as login;
import 'presentation/profile/profile_screen_test.dart' as profile;
import 'presentation/signup/signup_with_email_test.dart' as signup_with_email;

void main() {
  group('Signup With Email Tests', signup_with_email.main);
  group('Login Tests', login.main);
  group('Profile Tests', profile.main);
}
