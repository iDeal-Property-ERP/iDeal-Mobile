import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:ideal_mobile/i18n/localization.dart';
import 'package:ideal_mobile/presentation/signup/screens/profile_picture/profile_photo_editor_screen.dart';
import 'package:ideal_mobile/utils/theme/extension/theme_extension.dart';
import 'package:ideal_mobile/widgets/app_button/app_button.dart';
import 'package:ideal_mobile/widgets/app_button/enums/app_button_size_enum.dart';
import 'package:ideal_mobile/widgets/app_button/enums/app_button_style_enum.dart';
import 'package:image_picker/image_picker.dart';

class ImageSourceBottomSheetBody extends StatelessWidget {
  const ImageSourceBottomSheetBody({
    super.key,
    required this.onImageSelected,
    this.showRemoveImageButton,
    this.onImageRemoved,
  });

  final void Function(File file) onImageSelected;
  final bool? showRemoveImageButton;
  final void Function()? onImageRemoved;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          12,
          20,
          max(20, MediaQuery.of(context).padding.bottom),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: context.currentTheme.strokeNeutralLight200,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 80,
              child: Row(
                mainAxisAlignment: .spaceEvenly,
                children: [
                  _Camera(
                    onCameraSelected: () async {
                      final XFile? xFile = await ImagePicker().pickImage(
                        source: ImageSource.camera,
                      );
                      if (xFile == null) {
                        debugPrint('xFile = null');
                        return;
                      }
                      await _cropImage(context, xFile.path);
                    },
                  ),
                  _Gallery(
                    onGallerySelected: () async {
                      final XFile? xFile = await pickImageXFile(
                        screenName: ModalRoute.of(context)?.settings.name,
                        source: ImageSource.gallery,
                      );
                      if (xFile == null) {
                        debugPrint('Photo = null');
                        return;
                      }
                      await _cropImage(context, xFile.path);
                    },
                  ),
                  if (showRemoveImageButton ?? false)
                    _RemoveImage(
                      onImageRemoved: () {
                        Navigator.of(context).pop();
                        onImageRemoved?.call();
                      },
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<XFile?> pickImageXFile({
    String? screenName,
    required ImageSource source,
    CameraDevice? cameraDevice,
  }) async {
    if (cameraDevice != null) {
      return await ImagePicker().pickImage(
        source: source,
        preferredCameraDevice: cameraDevice,
        requestFullMetadata: false,
      );
    }
    return await ImagePicker().pickImage(source: source);
  }

  Future<void> _cropImage(BuildContext context, String path) async {
    final croppedFile = await Navigator.of(context).push<File>(
      MaterialPageRoute(
        builder: (_) => ProfilePhotoEditorScreen(imageFile: File(path)),
      ),
    );
    if (croppedFile == null || !context.mounted) return;
    Navigator.of(context).pop();
    onImageSelected(croppedFile);
  }
}

class _RemoveImage extends StatelessWidget {
  const _RemoveImage({required this.onImageRemoved});

  final void Function() onImageRemoved;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        mainAxisSize: .min,
        children: [
          Expanded(
            child: AspectRatio(
              aspectRatio: 1,
              child: AppButton(
                style: AppButtonStyle.outline,
                size: AppButtonSize.extraSmall,
                isIconButton: true,
                iconData: TablerIcons.photo_x,
                onPressed: onImageRemoved,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(context.localization.remove),
        ],
      ),
    );
  }
}

class _Gallery extends StatelessWidget {
  const _Gallery({required this.onGallerySelected});

  final void Function() onGallerySelected;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        mainAxisSize: .min,
        children: [
          Expanded(
            child: AspectRatio(
              aspectRatio: 1,
              child: AppButton(
                style: AppButtonStyle.outline,
                size: AppButtonSize.extraSmall,
                isIconButton: true,
                iconData: TablerIcons.photo,
                onPressed: () => onGallerySelected(),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(context.localization.gallery),
        ],
      ),
    );
  }
}

class _Camera extends StatelessWidget {
  const _Camera({required this.onCameraSelected});

  final void Function() onCameraSelected;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        mainAxisSize: .min,
        children: [
          Expanded(
            child: AspectRatio(
              aspectRatio: 1,
              child: AppButton(
                style: AppButtonStyle.outline,
                size: AppButtonSize.extraSmall,
                isIconButton: true,
                iconData: TablerIcons.camera,
                onPressed: () => onCameraSelected(),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(context.localization.camera),
        ],
      ),
    );
  }
}
