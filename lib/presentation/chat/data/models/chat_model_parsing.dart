import 'package:ideal_mobile/utils/typedef.dart';

DataMap? mapValue(dynamic value) {
  if (value is! Map) return null;
  try {
    return Map<String, dynamic>.from(value);
  } catch (_) {
    return null;
  }
}

DataMap requiredMap(DataMap json, String key) {
  final value = mapValue(json[key]);
  if (value == null) throw FormatException('Missing $key.');
  return value;
}

String requiredString(DataMap json, String key) {
  final value = json[key];
  if (value is! String) throw FormatException('Invalid $key.');
  return value;
}

String? nullableString(dynamic value) {
  if (value == null) return null;
  if (value is String) return value;
  throw const FormatException('Invalid string.');
}

int requiredInt(DataMap json, String key) {
  final value = nullableInt(json[key]);
  if (value == null) throw FormatException('Invalid $key.');
  return value;
}

int? nullableInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) {
    return int.tryParse(value) ?? double.tryParse(value)?.toInt();
  }
  return null;
}

double? nullableDouble(dynamic value) {
  if (value == null) return null;
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value);
  return null;
}

double requiredDouble(DataMap json, String key) {
  final value = nullableDouble(json[key]);
  if (value == null) throw FormatException('Invalid $key.');
  return value;
}

bool boolValue(DataMap json, String key, {required bool fallback}) {
  final value = json[key];
  if (value == null) return fallback;
  if (value is bool) return value;
  if (value is num && (value == 0 || value == 1)) return value == 1;
  if (value is String) {
    if (value.toLowerCase() == 'true') return true;
    if (value.toLowerCase() == 'false') return false;
  }
  throw FormatException('Invalid $key.');
}

DateTime requiredDateTime(DataMap json, String key) {
  final value = json[key];
  if (value is! String) throw FormatException('Invalid $key.');
  try {
    return DateTime.parse(value);
  } on FormatException {
    throw FormatException('Invalid $key.');
  }
}

DateTime? nullableDateTime(dynamic value) {
  if (value == null) return null;
  if (value is! String) throw const FormatException('Invalid date time.');
  try {
    return DateTime.parse(value);
  } on FormatException {
    throw const FormatException('Invalid date time.');
  }
}

List<dynamic> requiredList(DataMap json, String key) {
  final value = json[key];
  if (value is! List) throw FormatException('Invalid $key.');
  return value;
}
