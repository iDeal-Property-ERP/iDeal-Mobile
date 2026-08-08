import 'dart:io';
import 'dart:typed_data';

import 'package:crop_your_image/crop_your_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:ideal_mobile/common/theme/text_style/app_text_styles.dart';
import 'package:ideal_mobile/i18n/localization.dart';
import 'package:ideal_mobile/utils/extensions/build_context_ext.dart';
import 'package:ideal_mobile/utils/theme/extension/theme_extension.dart';
import 'package:image/image.dart' as image;
import 'package:path_provider/path_provider.dart';

class ProfilePhotoEditorScreen extends StatefulWidget {
  const ProfilePhotoEditorScreen({super.key, required this.imageFile});

  final File imageFile;

  @override
  State<ProfilePhotoEditorScreen> createState() =>
      _ProfilePhotoEditorScreenState();
}

class _ProfilePhotoEditorScreenState extends State<ProfilePhotoEditorScreen> {
  final CropController _cropController = CropController();
  Uint8List? _imageBytes;
  bool _isCropping = false;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  Future<void> _loadImage() async {
    final bytes = await widget.imageFile.readAsBytes();
    if (!mounted) return;
    setState(() => _imageBytes = bytes);
  }

  void _rotate() {
    final bytes = _imageBytes;
    if (bytes == null) return;

    final decoded = image.decodeImage(bytes);
    if (decoded == null) {
      context.showSnackBar(
        context.localization.opps_something_went_wrong,
        isDisplayingError: true,
      );
      return;
    }

    final rotated = image.copyRotate(image.bakeOrientation(decoded), angle: 90);
    setState(
      () => _imageBytes = Uint8List.fromList(
        image.encodeJpg(rotated, quality: 92),
      ),
    );
  }

  Future<void> _onCropped(CropResult result) async {
    setState(() => _isCropping = false);
    if (result is! CropSuccess) {
      if (mounted) {
        context.showSnackBar(
          context.localization.opps_something_went_wrong,
          isDisplayingError: true,
        );
      }
      return;
    }

    final decoded = image.decodeImage(result.croppedImage);
    if (decoded == null) {
      if (mounted) {
        context.showSnackBar(
          context.localization.opps_something_went_wrong,
          isDisplayingError: true,
        );
      }
      return;
    }

    final directory = await getTemporaryDirectory();
    final croppedFile = File(
      '${directory.path}/profile-photo-${DateTime.now().microsecondsSinceEpoch}.jpg',
    );
    await croppedFile.writeAsBytes(
      image.encodeJpg(decoded, quality: 92),
      flush: true,
    );

    if (mounted) Navigator.of(context).pop(croppedFile);
  }

  @override
  Widget build(BuildContext context) {
    final imageBytes = _imageBytes;
    return Scaffold(
      backgroundColor: context.currentTheme.bgSurfaceBase,
      appBar: AppBar(
        title: Text(
          context.localization.edit,
          style: AppTextStyles.h6Bold.copyWith(
            color: context.currentTheme.textNeutralPrimary,
          ),
        ),
        leading: TextButton(
          onPressed: _isCropping ? null : () => Navigator.of(context).pop(),
          child: Text(context.localization.cancel),
        ),
        leadingWidth: 88,
        actions: [
          IconButton(
            tooltip: context.localization.rotate,
            onPressed: imageBytes == null || _isCropping ? null : _rotate,
            icon: const Icon(TablerIcons.rotate_clockwise),
          ),
          TextButton(
            onPressed: imageBytes == null || _isCropping
                ? null
                : () {
                    setState(() => _isCropping = true);
                    _cropController.cropCircle();
                  },
            child: _isCropping
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(context.localization.save),
          ),
        ],
      ),
      body: imageBytes == null
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Crop(
                image: imageBytes,
                controller: _cropController,
                withCircleUi: true,
                interactive: true,
                fixCropRect: true,
                baseColor: context.currentTheme.bgSurfaceBase,
                maskColor: Colors.black54,
                onCropped: _onCropped,
              ),
            ),
    );
  }
}
