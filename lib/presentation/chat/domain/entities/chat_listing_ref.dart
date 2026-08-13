import 'package:equatable/equatable.dart';

class ChatListingRef extends Equatable {
  const ChatListingRef({
    required this.id,
    required this.title,
    required this.coverImageUrl,
    this.coverPreviewUrl,
    this.coverDisplayUrl,
    required this.price,
    required this.currency,
    required this.isAvailable,
  });

  final int id;
  final String title;
  final String? coverImageUrl;
  final String? coverPreviewUrl;
  final String? coverDisplayUrl;
  final double? price;
  final String currency;
  final bool isAvailable;

  @override
  List<Object?> get props => [
    id,
    title,
    coverImageUrl,
    coverPreviewUrl,
    coverDisplayUrl,
    price,
    currency,
    isAvailable,
  ];
}
