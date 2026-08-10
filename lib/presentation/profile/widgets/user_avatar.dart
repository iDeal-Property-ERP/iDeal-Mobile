import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ideal_mobile/gen/assets.gen.dart';
import 'package:ideal_mobile/presentation/profile/bloc/profile_bloc.dart';
import 'package:ideal_mobile/presentation/profile/bloc/profile_event.dart';
import 'package:ideal_mobile/presentation/profile/bloc/profile_state.dart';
import 'package:ideal_mobile/presentation/profile/widgets/profile_avatar_cache_manager.dart';
import 'package:ideal_mobile/presentation/signup/screens/profile_picture/widgets/add_skip_picture_button.dart';
import 'package:sizer/sizer.dart';

class UserAvatar extends StatelessWidget {
  const UserAvatar({super.key});

  static const double _profileImageSize = 18.0;

  @override
  Widget build(BuildContext context) {
    final state = context.select<ProfileBloc, ProfileState>(
      (bloc) => bloc.state,
    );
    final avatarUrl = state.profile?.avatarUrl;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        GestureDetector(
          onTap: state.isAvatarUpdating
              ? null
              : () => AddSkipPictureButton.showImageSourceBottomSheet(
                  context,
                  showRemoveImageButton: avatarUrl != null,
                  onImageSelected: (image) => context.read<ProfileBloc>().add(
                    UpdateProfileAvatarEvent(image: image),
                  ),
                  onImageRemoved: () => context.read<ProfileBloc>().add(
                    const RemoveProfileAvatarEvent(),
                  ),
                ),
          child: SizedBox(
            height: _profileImageSize.w,
            width: _profileImageSize.w,
            child: ClipOval(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  _AvatarImage(url: avatarUrl),
                  if (state.isAvatarUpdating)
                    const ColoredBox(
                      color: Colors.black45,
                      child: Center(
                        child: SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _AvatarImage extends StatelessWidget {
  const _AvatarImage({required this.url});

  final String? url;

  @override
  Widget build(BuildContext context) {
    if (url == null) return _placeholder();

    return CachedNetworkImage(
      imageUrl: url!,
      cacheKey: url,
      cacheManager: ProfileAvatarCacheManager.instance,
      fit: BoxFit.cover,
      errorWidget: (_, _, _) => _placeholder(),
    );
  }

  Widget _placeholder() => ColoredBox(
    color: Colors.white,
    child: Padding(
      padding: const EdgeInsets.all(12),
      child: SvgPicture.asset(Assets.icons.userPlaceholder),
    ),
  );
}
