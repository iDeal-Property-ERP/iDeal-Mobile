import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ideal_mobile/presentation/login/domain/repositories/auth_repository.dart';
import 'package:ideal_mobile/presentation/login/domain/usecases/get_otp_methods.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockAuthRepository repository;
  late GetOtpMethods useCase;

  setUp(() {
    repository = MockAuthRepository();
    useCase = GetOtpMethods(repository);
  });

  test(
    'calls repository.getOtpMethods and returns available channels',
    () async {
      const channels = ['telegram', 'sms'];
      when(
        () => repository.getOtpMethods(),
      ).thenAnswer((_) async => const Right(channels));

      final result = await useCase();

      expect(result, const Right(channels));
      verify(() => repository.getOtpMethods()).called(1);
      verifyNoMoreInteractions(repository);
    },
  );
}
