import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ideal_mobile/services/push/device_registration_api.dart';
import 'package:mocktail/mocktail.dart';

class MockDio extends Mock implements Dio {}

void main() {
  late MockDio dio;
  late DeviceRegistrationApi api;

  Response<dynamic> response(String path) {
    return Response<dynamic>(
      requestOptions: RequestOptions(path: path),
      statusCode: 200,
      data: {
        'success': true,
        'message': 'OK',
        'data': {'id': 3},
      },
    );
  }

  setUp(() {
    dio = MockDio();
    api = DeviceRegistrationApi(dio: dio);
  });

  test('payload omits optional null values', () {
    const payload = DeviceRegistrationPayload(
      token: 'fcm-token',
      platform: 'android',
    );

    expect(payload.toJson(), {'token': 'fcm-token', 'platform': 'android'});
  });

  test('register posts the complete payload', () async {
    when(
      () => dio.post(
        '/mobile/devices/',
        data: any(named: 'data'),
        options: any(named: 'options'),
      ),
    ).thenAnswer((_) async => response('/mobile/devices/'));

    const payload = DeviceRegistrationPayload(
      token: 'fcm-token',
      platform: 'ios',
      deviceId: 'device-id',
      appVersion: '1.2.3+45',
      locale: 'uz',
    );

    await api.register(payload);

    final captured =
        verify(
              () => dio.post(
                '/mobile/devices/',
                data: {
                  'token': 'fcm-token',
                  'platform': 'ios',
                  'device_id': 'device-id',
                  'app_version': '1.2.3+45',
                  'locale': 'uz',
                },
                options: captureAny(named: 'options'),
              ),
            ).captured.single
            as Options;
    expect(captured.extra!['skip_forced_logout'], isTrue);
  });

  test('unregister posts the token', () async {
    when(
      () => dio.post(
        '/mobile/devices/unregister/',
        data: any(named: 'data'),
        options: any(named: 'options'),
      ),
    ).thenAnswer((_) async => response('/mobile/devices/unregister/'));

    await api.unregister('fcm-token');

    final captured =
        verify(
              () => dio.post(
                '/mobile/devices/unregister/',
                data: {'token': 'fcm-token'},
                options: captureAny(named: 'options'),
              ),
            ).captured.single
            as Options;
    expect(captured.extra!['skip_forced_logout'], isTrue);
  });
}
