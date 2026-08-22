import 'package:flutter_test/flutter_test.dart';
import 'package:ideal_mobile/utils/map_token_obfuscator.dart';

void main() {
  const secret = 'iDeal-Test-Map-Secret-2025!';
  const knownNonce = [1, 2, 3, 4, 5, 6, 7, 8];

  group('MapTokenObfuscator', () {
    test('cross-platform vector matching Backend Python implementation', () {
      const knownPythonOutput =
          '9t1689p38NdKBqYQoPFRt3kt_Pmf40YiRMoM9vOwlWsk2W9H3XUs3_0Srul';
      const expectedToken = 'test-yandex-mapkit-api-key-12345';

      final deobfuscated = MapTokenObfuscator.deobfuscate(
        knownPythonOutput,
        secret: secret,
      );
      expect(deobfuscated, expectedToken);

      final obfuscated = MapTokenObfuscator.obfuscate(
        expectedToken,
        secret: secret,
        nonce: knownNonce,
      );
      expect(obfuscated, knownPythonOutput);
    });

    test('round-trip tokens across various formats', () {
      final tokens = [
        'a1b2c3d4-e5f6-7890-abcd-ef1234567890',
        'AIzaSyD-1234567890abcdefghijklmnopqrst',
        'simple_key',
        'X',
        'A' * 200,
        'token_with_utf8_🔥_test',
      ];

      for (final token in tokens) {
        final obfuscated = MapTokenObfuscator.obfuscate(token, secret: secret);
        expect(obfuscated, isNot(equals(token)));
        final recovered = MapTokenObfuscator.deobfuscate(
          obfuscated,
          secret: secret,
        );
        expect(recovered, token);
      }
    });

    test('custom base encode and decode consistency', () {
      final bytes = [0, 1, 2, 3, 4, 5, 250, 255, 128, 64];
      final encoded = MapTokenObfuscator.customBaseEncode(bytes);
      final decoded = MapTokenObfuscator.customBaseDecode(encoded);
      expect(decoded, bytes);
    });

    test('different nonces produce distinct ciphertexts', () {
      const token = 'test-google-maps-api-key';
      final obf1 = MapTokenObfuscator.obfuscate(token, secret: secret);
      final obf2 = MapTokenObfuscator.obfuscate(token, secret: secret);

      expect(obf1, isNot(equals(obf2)));
      expect(
        MapTokenObfuscator.deobfuscate(obf1, secret: secret),
        equals(token),
      );
      expect(
        MapTokenObfuscator.deobfuscate(obf2, secret: secret),
        equals(token),
      );
    });

    test('throws FormatException on invalid characters in payload', () {
      expect(
        () => MapTokenObfuscator.deobfuscate('invalid+char=', secret: secret),
        throwsFormatException,
      );
    });

    test('throws FormatException on corrupted payload', () {
      final obfuscated = MapTokenObfuscator.obfuscate(
        'test-token',
        secret: secret,
      );
      final corrupted =
          obfuscated.substring(0, 10) +
          (obfuscated[10] != 'z' ? 'z' : 'y') +
          obfuscated.substring(11);

      expect(
        () => MapTokenObfuscator.deobfuscate(corrupted, secret: secret),
        throwsFormatException,
      );
    });

    test('throws FormatException when deobfuscating with wrong secret', () {
      final obfuscated = MapTokenObfuscator.obfuscate(
        'test-token',
        secret: secret,
      );
      expect(
        () => MapTokenObfuscator.deobfuscate(obfuscated, secret: 'wrong-key'),
        throwsFormatException,
      );
    });

    test('handles empty input gracefully', () {
      expect(MapTokenObfuscator.obfuscate('', secret: secret), '');
      expect(MapTokenObfuscator.deobfuscate('', secret: secret), '');
    });

    test('deobfuscates correctly with 128-char dollar-containing secret', () {
      const dummySecret =
          r'TestSecret123$var*Foo!Bar1234567890abcdefghijklmnopqrstuvwxyz'
          r'$Special$chars$test$dollar$string$here$1234567890abcdefghijklm';
      const dummyToken = 'mock-api-key-value-12345-abcdef';
      final obfuscated = MapTokenObfuscator.obfuscate(
        dummyToken,
        secret: dummySecret,
      );
      final deobfuscated = MapTokenObfuscator.deobfuscate(
        obfuscated,
        secret: dummySecret,
      );
      expect(deobfuscated, dummyToken);
    });
  });
}
