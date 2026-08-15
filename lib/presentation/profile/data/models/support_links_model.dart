import 'package:equatable/equatable.dart';

class SupportLinksModel extends Equatable {
  const SupportLinksModel({this.telegramUrl, this.whatsappUrl});

  factory SupportLinksModel.fromJson(Map<String, dynamic> json) {
    return SupportLinksModel(
      telegramUrl: _nullableString(json, 'telegram_url'),
      whatsappUrl: _nullableString(json, 'whatsapp_url'),
    );
  }

  final String? telegramUrl;
  final String? whatsappUrl;

  bool get hasTelegram => telegramUrl != null && telegramUrl!.trim().isNotEmpty;

  bool get hasWhatsApp => whatsappUrl != null && whatsappUrl!.trim().isNotEmpty;

  Map<String, dynamic> toJson() => {
    'telegram_url': telegramUrl,
    'whatsapp_url': whatsappUrl,
  };

  static String? _nullableString(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value is String) {
      final trimmed = value.trim();
      return trimmed.isNotEmpty ? trimmed : null;
    }
    return null;
  }

  @override
  List<Object?> get props => [telegramUrl, whatsappUrl];
}
