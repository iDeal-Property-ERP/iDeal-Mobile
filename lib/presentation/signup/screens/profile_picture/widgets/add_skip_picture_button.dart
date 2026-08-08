import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ideal_mobile/i18n/localization.dart';
import 'package:ideal_mobile/presentation/login/bloc/login_bloc.dart';
import 'package:ideal_mobile/presentation/login/bloc/login_events.dart';
import 'package:ideal_mobile/presentation/signup/screens/profile_picture/widgets/image_source_bottom_sheet_body.dart';
import 'package:ideal_mobile/utils/theme/extension/theme_extension.dart';
import 'package:ideal_mobile/widgets/app_button/app_button.dart';
import 'package:ideal_mobile/widgets/app_button/enums/app_button_size_enum.dart';
import 'package:ideal_mobile/widgets/app_button/enums/app_button_state_enum.dart';
import 'package:ideal_mobile/widgets/app_button/enums/app_button_style_enum.dart';
import 'package:ideal_mobile/widgets/styling/app_colors.dart';

class AddSkipPictureButton extends StatelessWidget {
  const AddSkipPictureButton({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isLoading = context.select<LoginBloc, bool>(
      (bloc) => bloc.state.isLoading,
    );
    return Column(
      children: [
        AppButton(
          label: context.localization.add,
          shouldSetFullWidth: true,
          size: AppButtonSize.large,
          state: isLoading ? AppButtonState.disabled : AppButtonState.normal,
          onPressed: () {
            if (!isLoading) {
              showImageSourceBottomSheet(
                context,
                onImageSelected: (File file) {
                  context.read<LoginBloc>().add(
                    SelectedProfilePictureEvent(image: file),
                  );
                  context.read<LoginBloc>().add(
                    ProfilePictureDoneToggleEvent(isDoneEditing: true),
                  );
                },
              );
            }
          },
        ),
        const SizedBox(height: 16),
        AppButton(
          label: context.localization.skip,
          shouldSetFullWidth: true,
          size: AppButtonSize.large,
          style: AppButtonStyle.outline,
          isLoading: isLoading,
          onPressed: () {
            context.read<LoginBloc>().add(FinishProfilePictureEvent());
          },
        ),
      ],
    );
  }

  static Future<void> showImageSourceBottomSheet(
    BuildContext context, {
    required Function(File file) onImageSelected,
    bool? showRemoveImageButton,
    Function()? onImageRemoved,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      barrierColor: AppColors.black.withOpacity(0.72),
      backgroundColor: context.currentTheme.bgSurfaceBase2,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      clipBehavior: Clip.antiAlias,
      builder: (_) => ImageSourceBottomSheetBody(
        onImageSelected: onImageSelected,
        showRemoveImageButton: showRemoveImageButton,
        onImageRemoved: onImageRemoved,
      ),
    );
  }
}
