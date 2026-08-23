import 'package:flutter_test/flutter_test.dart';
import 'package:ideal_mobile/presentation/profile/widgets/profile_avatar_file_size.dart';

void main() {
  test('allows profile avatars up to 5 MB', () {
    expect(isProfileAvatarFileSizeAllowed(profileAvatarMaxBytes), isTrue);
  });

  test('rejects profile avatars larger than 5 MB', () {
    expect(isProfileAvatarFileSizeAllowed(profileAvatarMaxBytes + 1), isFalse);
  });
}
