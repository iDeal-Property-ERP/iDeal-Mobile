import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:ideal_mobile/common/theme/text_style/app_text_styles.dart';
import 'package:ideal_mobile/core/services/injection_container.dart';
import 'package:ideal_mobile/gen/assets.gen.dart';
import 'package:ideal_mobile/i18n/localization.dart';
import 'package:ideal_mobile/presentation/profile/bloc/profile_bloc.dart';
import 'package:ideal_mobile/presentation/profile/bloc/profile_event.dart';
import 'package:ideal_mobile/presentation/profile/bloc/profile_state.dart';
import 'package:ideal_mobile/presentation/profile/widgets/profile_avatar_cache_manager.dart';
import 'package:ideal_mobile/presentation/profile/widgets/profile_avatar_file_size.dart';
import 'package:ideal_mobile/routes.gr.dart';
import 'package:ideal_mobile/utils/extensions/build_context_ext.dart';
import 'package:ideal_mobile/utils/image_picker_util.dart';
import 'package:ideal_mobile/utils/theme/extension/theme_extension.dart';
import 'package:ideal_mobile/widgets/shimmer/shimmer_circular_image.dart';
import 'package:ideal_mobile/widgets/shimmer/shimmer_text.dart';
import 'package:ideal_mobile/widgets/styling/app_colors.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shimmer/shimmer.dart';

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({super.key});

  static const Color _navyLight = Color(0xFF0F2A5C);
  static const Color _navyDark = Color(0xFF0A1F45);
  static const Color _phoneColor = Color(0xFFAFC3EC);

  static Color backgroundColorFor(BuildContext context) =>
      context.isDark ? _navyDark : _navyLight;

  @override
  Widget build(BuildContext context) {
    final state = context.select<ProfileBloc, ProfileState>(
      (bloc) => bloc.state,
    );

    final fullName = state.name.isNotEmpty
        ? state.name
        : state.profile?.phone ?? '';
    final phone = state.profile?.phone ?? '';
    final showPhone = phone.isNotEmpty && phone != fullName;

    final headerBg = backgroundColorFor(context);

    return Container(
      width: double.infinity,
      color: headerBg,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20.0, 36.0, 20.0, 48.0),
          child: state.isProfileLoading && state.profile == null
              ? const _ProfileHeaderSkeleton()
              : Row(
                  children: [
                    _ProfileAvatarBadge(
                      avatarUrl: state.profile?.avatarUrl,
                      isUpdating: state.isAvatarUpdating,
                    ),
                    const SizedBox(width: 16.0),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            fullName,
                            style: AppTextStyles.h6Bold.copyWith(
                              color: Colors.white,
                              fontSize: 20.0,
                              fontWeight: FontWeight.w700,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (showPhone) ...[
                            const SizedBox(height: 4.0),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  TablerIcons.phone,
                                  size: 13.0,
                                  color: _phoneColor,
                                ),
                                const SizedBox(width: 6.0),
                                Flexible(
                                  child: Text(
                                    phone,
                                    style: AppTextStyles.p3Medium.copyWith(
                                      color: _phoneColor,
                                      fontSize: 13.0,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: 12.0),
                    GestureDetector(
                      onTap: () {
                        final profileBloc = context.read<ProfileBloc>();
                        if (profileBloc.state.profile == null) {
                          context.showSnackBar(
                            context.localization.user_info_not_retrieved,
                            isDisplayingError: true,
                          );
                          return;
                        }
                        context.router.push(
                          PersonalDetailsRoute(profileBloc: profileBloc),
                        );
                      },
                      child: Container(
                        width: 38.0,
                        height: 38.0,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(12.0),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.25),
                          ),
                        ),
                        child: const Center(
                          child: Icon(
                            TablerIcons.pencil,
                            size: 16.0,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

class _ProfileAvatarBadge extends StatelessWidget {
  const _ProfileAvatarBadge({
    required this.avatarUrl,
    required this.isUpdating,
  });

  final String? avatarUrl;
  final bool isUpdating;

  static const Color _navy = Color(0xFF0F2A5C);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isUpdating ? null : () => _showPicker(context),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 68.0,
            height: 68.0,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.14),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.5),
                width: 2.0,
              ),
            ),
            child: ClipOval(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (avatarUrl != null && avatarUrl!.isNotEmpty)
                    CachedNetworkImage(
                      imageUrl: avatarUrl!,
                      cacheKey: avatarUrl,
                      cacheManager: ProfileAvatarCacheManager.instance,
                      fit: BoxFit.cover,
                      errorWidget: (_, _, _) => _placeholder(context),
                    )
                  else
                    _placeholder(context),
                  if (isUpdating)
                    const ColoredBox(
                      color: Colors.black45,
                      child: Center(
                        child: SizedBox(
                          height: 24.0,
                          width: 24.0,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.0,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: -2.0,
            right: -2.0,
            child: Container(
              width: 24.0,
              height: 24.0,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Color(0x33000000),
                    blurRadius: 6.0,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: const Center(
                child: Icon(TablerIcons.camera, size: 12.0, color: _navy),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _placeholder(BuildContext context) => SvgPicture.asset(
    Assets.icons.userPlaceholder,
    fit: BoxFit.cover,
    colorMapper: context.isDark
        ? const _UserPlaceholderColorMapper(
            backgroundColor: AppColors.sapphirePrimaryDark,
            foregroundColor: AppColors.brand50,
          )
        : const _UserPlaceholderColorMapper(
            backgroundColor: AppColors.brand800,
            foregroundColor: AppColors.white,
          ),
  );

  Future<void> _showPicker(BuildContext context) async {
    final action = await showModalBottomSheet<_AvatarAction>(
      context: context,
      backgroundColor: context.currentTheme.bgSurfaceSheet,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.0)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12.0),
            Center(
              child: Container(
                width: 40.0,
                height: 4.0,
                decoration: BoxDecoration(
                  color: context.currentTheme.strokeNeutralLight200,
                  borderRadius: BorderRadius.circular(4.0),
                ),
              ),
            ),
            const SizedBox(height: 8.0),
            ListTile(
              leading: const Icon(TablerIcons.camera),
              title: Text(context.localization.camera),
              onTap: () => Navigator.pop(sheetContext, _AvatarAction.camera),
            ),
            ListTile(
              leading: const Icon(TablerIcons.photo),
              title: Text(context.localization.gallery),
              onTap: () => Navigator.pop(sheetContext, _AvatarAction.gallery),
            ),
            if (avatarUrl != null && avatarUrl!.isNotEmpty)
              ListTile(
                leading: const Icon(TablerIcons.trash),
                title: Text(context.localization.remove),
                onTap: () => Navigator.pop(sheetContext, _AvatarAction.remove),
              ),
            const SizedBox(height: 8.0),
          ],
        ),
      ),
    );

    if (action == null || !context.mounted) return;

    if (action == _AvatarAction.remove) {
      context.read<ProfileBloc>().add(const RemoveProfileAvatarEvent());
      return;
    }

    final images = await sl<ImagePickerUtil>().pickImages(
      source: action == _AvatarAction.camera
          ? ImageSource.camera
          : ImageSource.gallery,
      maxFileLimit: 1,
    );

    if (images.isEmpty) return;

    final image = File(images.first.path);
    final isAllowed = isProfileAvatarFileSizeAllowed(await image.length());
    if (!context.mounted) return;
    if (!isAllowed) {
      context.showSnackBar(
        context.localization.file_too_large_error,
        isDisplayingError: true,
      );
      return;
    }

    context.read<ProfileBloc>().add(UpdateProfileAvatarEvent(image: image));
  }
}

enum _AvatarAction { camera, gallery, remove }

class _UserPlaceholderColorMapper extends ColorMapper {
  const _UserPlaceholderColorMapper({
    required this.backgroundColor,
    required this.foregroundColor,
  });

  static const Color _sourceBackground = Color(0xFFCDCFCE);

  final Color backgroundColor;
  final Color foregroundColor;

  @override
  Color substitute(
    String? id,
    String elementName,
    String attributeName,
    Color color,
  ) {
    if (color == _sourceBackground) return backgroundColor;
    if (color == Colors.white) return foregroundColor;
    return color;
  }

  @override
  bool operator ==(Object other) =>
      other is _UserPlaceholderColorMapper &&
      other.backgroundColor == backgroundColor &&
      other.foregroundColor == foregroundColor;

  @override
  int get hashCode => Object.hash(backgroundColor, foregroundColor);
}

class _ProfileHeaderSkeleton extends StatelessWidget {
  const _ProfileHeaderSkeleton();

  @override
  Widget build(BuildContext context) {
    final double textWidth = MediaQuery.of(context).size.width;

    return Shimmer.fromColors(
      baseColor: Colors.white24,
      highlightColor: Colors.white38,
      child: Row(
        children: [
          const ShimmerCircularImage(size: 17),
          const SizedBox(width: 16.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: 24.0,
                  child: Center(child: ShimmerText(width: textWidth * 0.4)),
                ),
                const SizedBox(height: 6.0),
                SizedBox(
                  height: 18.0,
                  child: Center(child: ShimmerText(width: textWidth * 0.35)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
