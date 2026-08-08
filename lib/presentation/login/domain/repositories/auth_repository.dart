import 'package:ideal_mobile/presentation/login/data/models/auth_tokens.dart';
import 'package:ideal_mobile/utils/typedef.dart';

abstract class AuthRepository {
  ResultVoid requestOtp({required String phone, required String channel});

  ResultFuture<AuthTokens> verifyOtp({
    required String phone,
    required String code,
  });
}
