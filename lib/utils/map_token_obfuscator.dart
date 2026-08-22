import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:ideal_mobile/utils/app_flavor_env.dart';

class MapTokenObfuscator {
  const MapTokenObfuscator._();

  static const String customAlphabet =
      '9876543210zyxwvutsrqponmlkjihgfedcbaZYXWVUTSRQPONMLKJIHGFEDCBA-_';

  static final Map<String, int> _reverseAlphabet = {
    for (var i = 0; i < customAlphabet.length; i++) customAlphabet[i]: i,
  };

  static const int magicByte = 0x5B;
  static const int nonceSize = 8;

  static String customBaseEncode(List<int> data) {
    final result = StringBuffer();
    final length = data.length;
    var i = 0;
    while (i < length) {
      final b0 = data[i];
      final b1 = i + 1 < length ? data[i + 1] : 0;
      final b2 = i + 2 < length ? data[i + 2] : 0;

      final chunk = (b0 << 16) | (b1 << 8) | b2;

      result.write(customAlphabet[(chunk >> 18) & 0x3F]);
      result.write(customAlphabet[(chunk >> 12) & 0x3F]);

      if (i + 1 < length) {
        result.write(customAlphabet[(chunk >> 6) & 0x3F]);
      }
      if (i + 2 < length) {
        result.write(customAlphabet[chunk & 0x3F]);
      }

      i += 3;
    }
    return result.toString();
  }

  static Uint8List customBaseDecode(String text) {
    final cleanText = text.trim();
    if (cleanText.isEmpty) {
      return Uint8List(0);
    }

    for (var i = 0; i < cleanText.length; i++) {
      final char = cleanText[i];
      if (!_reverseAlphabet.containsKey(char)) {
        throw FormatException('Invalid character in encoded payload: $char');
      }
    }

    final result = <int>[];
    final length = cleanText.length;
    var i = 0;
    while (i < length) {
      final rem = length - i;
      if (rem == 1) {
        throw const FormatException('Truncated base encoding');
      }

      final c0 = _reverseAlphabet[cleanText[i]]!;
      final c1 = _reverseAlphabet[cleanText[i + 1]]!;
      final c2 = rem > 2 ? _reverseAlphabet[cleanText[i + 2]]! : 0;
      final c3 = rem > 3 ? _reverseAlphabet[cleanText[i + 3]]! : 0;

      final chunk = (c0 << 18) | (c1 << 12) | (c2 << 6) | c3;

      result.add((chunk >> 16) & 0xFF);
      if (rem > 2) {
        result.add((chunk >> 8) & 0xFF);
      }
      if (rem > 3) {
        result.add(chunk & 0xFF);
      }

      i += 4;
    }
    return Uint8List.fromList(result);
  }

  static int _seedState(String secret, List<int> nonce) {
    var h = 0x811C9DC5;
    final bytes = [...utf8.encode(secret), ...nonce];
    for (final b in bytes) {
      h = ((h ^ b) * 0x01000193) & 0xFFFFFFFF;
    }
    return h;
  }

  static List<int> _generateKeystream(int state, int length) {
    final stream = <int>[];
    var current = state;
    for (var i = 0; i < length; i++) {
      current = (current * 1103515245 + 12345) & 0xFFFFFFFF;
      stream.add((current >> 16) & 0xFF);
    }
    return stream;
  }

  static String obfuscate(String token, {String? secret, List<int>? nonce}) {
    if (token.isEmpty) return '';

    final effectiveSecret = secret ?? AppConfig.mapObfuscationSecret;
    if (effectiveSecret.isEmpty) return '';
    final effectiveNonce = nonce ?? _randomNonce();
    if (effectiveNonce.length != nonceSize) {
      throw ArgumentError('Nonce must be exactly $nonceSize bytes');
    }

    final tokenBytes = utf8.encode(token);
    final length = tokenBytes.length;
    if (length > 0xFFFF) {
      throw ArgumentError('Token exceeds maximum supported size (65535 bytes)');
    }

    final lenHigh = (length >> 8) & 0xFF;
    final lenLow = length & 0xFF;

    var checksum = magicByte ^ lenHigh ^ lenLow;
    for (final b in tokenBytes) {
      checksum ^= b;
    }

    final payload = <int>[magicByte, lenHigh, lenLow, ...tokenBytes, checksum];
    final payloadLen = payload.length;

    final state = _seedState(effectiveSecret, effectiveNonce);
    final keystream = _generateKeystream(state, payloadLen);

    final scrambled = Uint8List(payloadLen);
    for (var i = 0; i < payloadLen; i++) {
      final p = payload[i];
      final k = keystream[i];
      // 1. Rolling XOR
      final x = p ^ k ^ ((i * 37 + 13) & 0xFF);
      // 2. Nibble swap
      final n = ((x << 4) & 0xF0) | ((x >> 4) & 0x0F);
      // 3. Dynamic rotation left
      final shift = (effectiveNonce[i % nonceSize] & 0x03) + 1;
      final r = ((n << shift) & 0xFF) | (n >> (8 - shift));
      // 4. Modulo addition
      scrambled[i] = (r + 0x2A) & 0xFF;
    }

    final rawData = [...effectiveNonce, ...scrambled];
    return customBaseEncode(rawData);
  }

  static String deobfuscate(String payload, {String? secret}) {
    if (payload.trim().isEmpty) return '';

    final effectiveSecret = secret ?? AppConfig.mapObfuscationSecret;
    if (effectiveSecret.isEmpty) return '';
    final rawData = customBaseDecode(payload);
    if (rawData.length < nonceSize + 4) {
      throw const FormatException('Payload is too short to be valid');
    }

    final nonce = rawData.sublist(0, nonceSize);
    final scrambled = rawData.sublist(nonceSize);
    final payloadLen = scrambled.length;

    final state = _seedState(effectiveSecret, nonce);
    final keystream = _generateKeystream(state, payloadLen);

    final unscrambled = Uint8List(payloadLen);
    for (var i = 0; i < payloadLen; i++) {
      final s = scrambled[i];
      // Reverse 4. Modulo subtraction
      final r = (s - 0x2A) & 0xFF;
      // Reverse 3. Dynamic rotation right
      final shift = (nonce[i % nonceSize] & 0x03) + 1;
      final n = (r >> shift) | ((r << (8 - shift)) & 0xFF);
      // Reverse 2. Nibble swap
      final x = ((n << 4) & 0xF0) | ((n >> 4) & 0x0F);
      // Reverse 1. Rolling XOR
      final k = keystream[i];
      unscrambled[i] = x ^ k ^ ((i * 37 + 13) & 0xFF);
    }

    if (unscrambled[0] != magicByte) {
      throw const FormatException('Invalid magic byte in decrypted payload');
    }

    final length = (unscrambled[1] << 8) | unscrambled[2];
    if (unscrambled.length != 3 + length + 1) {
      throw const FormatException('Payload length mismatch');
    }

    final tokenBytes = unscrambled.sublist(3, 3 + length);
    final expectedChecksum = unscrambled[3 + length];

    var calcChecksum = magicByte ^ unscrambled[1] ^ unscrambled[2];
    for (final b in tokenBytes) {
      calcChecksum ^= b;
    }

    if (calcChecksum != expectedChecksum) {
      throw const FormatException('Checksum verification failed');
    }

    return utf8.decode(tokenBytes);
  }

  static List<int> _randomNonce() {
    final random = Random.secure();
    return List<int>.generate(nonceSize, (_) => random.nextInt(256));
  }
}
