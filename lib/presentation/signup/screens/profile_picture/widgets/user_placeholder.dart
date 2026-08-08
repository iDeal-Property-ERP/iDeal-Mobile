import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:ideal_mobile/gen/assets.gen.dart';
import 'package:ideal_mobile/presentation/login/bloc/login_bloc.dart';
import 'package:ideal_mobile/presentation/login/bloc/login_events.dart';
import 'package:ideal_mobile/presentation/signup/screens/profile_picture/widgets/add_skip_picture_button.dart';
import 'package:ideal_mobile/utils/theme/extension/theme_extension.dart';
import 'package:ideal_mobile/widgets/styling/app_colors.dart';

class UserPlaceholder extends StatelessWidget {
  const UserPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => AddSkipPictureButton.showImageSourceBottomSheet(
        context,
        onImageSelected: (File file) {
          context.read<LoginBloc>().add(
            SelectedProfilePictureEvent(image: file),
          );
          context.read<LoginBloc>().add(
            ProfilePictureDoneToggleEvent(isDoneEditing: true),
          );
        },
      ),
      child: Container(
        padding: const EdgeInsets.all(4),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: .circle,
          color: context.currentTheme.bgShadesWhite,
          boxShadow: <BoxShadow>[
            const BoxShadow(
              color: AppColors.shadowColor,
              offset: Offset(0, 4),
              spreadRadius: -2,
              blurRadius: 2,
            ),
          ],
        ),
        child: Center(child: SvgPicture.asset(Assets.icons.userPlaceholder)),
      ),
    );
  }
}
