const int profileAvatarMaxBytes = 5 * 1024 * 1024;

bool isProfileAvatarFileSizeAllowed(int bytes) =>
    bytes <= profileAvatarMaxBytes;
