import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:ideal_mobile/common/theme/text_style/app_text_styles.dart';
import 'package:ideal_mobile/core/services/injection_container.dart';
import 'package:ideal_mobile/i18n/localization.dart';
import 'package:ideal_mobile/utils/extensions/build_context_ext.dart';
import 'package:ideal_mobile/utils/image_picker_util.dart';
import 'package:ideal_mobile/utils/theme/extension/theme_extension.dart';
import 'package:ideal_mobile/widgets/styling/app_radius.dart';
import 'package:image_picker/image_picker.dart';

class ChatAttachSheet {
  const ChatAttachSheet._();

  static Future<String?> show(
    BuildContext context, {
    ImagePickerUtil? picker,
  }) async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: context.currentTheme.bgSurfaceSheet,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppRadius.sheet),
        ),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 6),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  context.localization.chat_attach_photo,
                  style: AppTextStyles.p2SemiBold.copyWith(
                    color: context.currentTheme.textNeutralPrimary,
                  ),
                ),
              ),
            ),
            ListTile(
              leading: Icon(
                TablerIcons.camera,
                color: context.currentTheme.iconBrandHover,
              ),
              title: Text(context.localization.chat_attach_camera),
              onTap: () => Navigator.of(context).pop(ImageSource.camera),
            ),
            ListTile(
              leading: Icon(
                TablerIcons.photo,
                color: context.currentTheme.iconBrandHover,
              ),
              title: Text(context.localization.chat_attach_gallery),
              onTap: () => Navigator.of(context).pop(ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
    if (source == null || !context.mounted) return null;
    final imagePicker = picker ?? sl<ImagePickerUtil>();
    final images = await imagePicker.pickImages(
      source: source,
      maxFileLimit: 1,
      imageQuality: source == ImageSource.gallery ? 100 : 85,
    );
    if (!context.mounted || images.isEmpty) return null;
    final path = images.first.path;
    final file = File(path);
    final extension = _extension(path);
    if (!_supportedExtensions.contains(extension)) {
      context.showSnackBar(context.localization.chat_image_unsupported_format);
      return null;
    }
    try {
      if (await file.length() > _maxBytes) {
        context.showSnackBar(context.localization.chat_image_too_large);
        return null;
      }
    } on FileSystemException {
      context.showSnackBar(context.localization.chat_image_unsupported_format);
      return null;
    }
    return path;
  }

  static const _supportedExtensions = {'png', 'jpg', 'jpeg', 'webp', 'gif'};
  static const _maxBytes = 5 * 1024 * 1024;

  static String _extension(String path) {
    final dot = path.lastIndexOf('.');
    if (dot == -1) return '';
    return path.substring(dot + 1).toLowerCase();
  }
}
