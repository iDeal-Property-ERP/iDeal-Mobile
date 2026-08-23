import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:ideal_mobile/common/theme/text_style/app_text_styles.dart';
import 'package:ideal_mobile/presentation/list_property/bloc/list_property_wizard_bloc.dart';
import 'package:ideal_mobile/presentation/list_property/bloc/list_property_wizard_event.dart';
import 'package:ideal_mobile/presentation/list_property/bloc/list_property_wizard_state.dart';
import 'package:ideal_mobile/utils/image_picker_util.dart';
import 'package:ideal_mobile/utils/theme/extension/theme_extension.dart';
import 'package:image_picker/image_picker.dart';

class PhotosStepView extends StatelessWidget {
  const PhotosStepView({super.key});

  Future<void> _pickFromGallery(BuildContext context) async {
    final picker = ImagePickerUtil();
    try {
      final images = await picker.pickImages(
        source: ImageSource.gallery,
        maxFileLimit: 20,
        imageQuality: 85,
      );
      if (images.isNotEmpty && context.mounted) {
        context.read<ListPropertyWizardBloc>().add(
          ListPropertyPhotosAdded(images.map((img) => img.path).toList()),
        );
      }
    } catch (e) {
      debugPrint('Error picking images: $e');
    }
  }

  Future<void> _pickFromCamera(BuildContext context) async {
    final picker = ImagePickerUtil();
    try {
      final images = await picker.pickImages(
        source: ImageSource.camera,
        maxFileLimit: 1,
        imageQuality: 85,
      );
      if (images.isNotEmpty && context.mounted) {
        context.read<ListPropertyWizardBloc>().add(
          ListPropertyPhotosAdded(images.map((img) => img.path).toList()),
        );
      }
    } catch (e) {
      debugPrint('Error taking photo: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ListPropertyWizardBloc, ListPropertyWizardState>(
      builder: (context, state) {
        final theme = context.currentTheme;
        final photoCount = state.imagePaths.length;
        final hasMinimumPhotos = photoCount >= 5;
        final showError = state.showValidationErrors && !hasMinimumPhotos;
        final banner = _BannerColors.resolve(
          isDark: context.isDark,
          hasMinPhotos: hasMinimumPhotos,
          showError: showError,
        );

        return ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          children: [
            // Status Banner
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: banner.bg,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: banner.border,
                  width: showError ? 1.5 : 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    hasMinimumPhotos
                        ? TablerIcons.check
                        : (showError
                              ? TablerIcons.alert_triangle
                              : TablerIcons.alert_circle),
                    color: banner.icon,
                    size: 22,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$photoCount of 5 photos added',
                          style: AppTextStyles.p3SemiBold.copyWith(
                            color: banner.title,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          hasMinimumPhotos
                              ? 'Great job! You can add more or continue.'
                              : 'Add at least 5 bright photos to proceed.',
                          style: AppTextStyles.p4Regular.copyWith(
                            color: banner.subtitle,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Pick Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _pickFromGallery(context),
                    icon: const Icon(TablerIcons.photo),
                    label: const Text('Gallery'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      foregroundColor: theme.textBrandPrimary,
                      side: BorderSide(color: theme.bgBrandDefault),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _pickFromCamera(context),
                    icon: const Icon(TablerIcons.camera),
                    label: const Text('Camera'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      foregroundColor: theme.textBrandPrimary,
                      side: BorderSide(color: theme.bgBrandDefault),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Photo Grid
            if (state.imagePaths.isEmpty)
              Container(
                height: 180,
                decoration: BoxDecoration(
                  color: theme.bgSurfaceBase2,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: theme.strokeNeutralLight200),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        TablerIcons.photo_plus,
                        size: 44,
                        color: theme.textNeutralSecondary,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'No photos added yet',
                        style: AppTextStyles.p3Medium.copyWith(
                          color: theme.textNeutralSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: state.imagePaths.length,
                itemBuilder: (context, index) {
                  final path = state.imagePaths[index];
                  final isCover = index == 0;

                  return Stack(
                    fit: StackFit.expand,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.file(File(path), fit: BoxFit.cover),
                      ),

                      // Gradient Overlay for readability
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        height: 40,
                        child: Container(
                          decoration: const BoxDecoration(
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(10),
                            ),
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [Colors.black54, Colors.transparent],
                            ),
                          ),
                        ),
                      ),

                      // Cover Badge / Set Cover Button
                      Positioned(
                        top: 6,
                        left: 6,
                        child: isCover
                            ? Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: theme.bgBrandDefault,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  'Cover Photo',
                                  style: AppTextStyles.p4Medium.copyWith(
                                    color: Colors.white,
                                  ),
                                ),
                              )
                            : GestureDetector(
                                onTap: () => context
                                    .read<ListPropertyWizardBloc>()
                                    .add(ListPropertyPhotoSetPrimary(index)),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.black54,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    'Make Cover',
                                    style: AppTextStyles.p4Medium.copyWith(
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                      ),

                      // Delete Button
                      Positioned(
                        top: 6,
                        right: 6,
                        child: GestureDetector(
                          onTap: () => context
                              .read<ListPropertyWizardBloc>()
                              .add(ListPropertyPhotoRemoved(index)),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.black54,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            const SizedBox(height: 24),
          ],
        );
      },
    );
  }
}

class _BannerColors {
  const _BannerColors({
    required this.bg,
    required this.border,
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final Color bg;
  final Color border;
  final Color title;
  final Color subtitle;
  final Color icon;

  static _BannerColors resolve({
    required bool isDark,
    required bool hasMinPhotos,
    required bool showError,
  }) {
    if (hasMinPhotos) {
      return _BannerColors(
        bg: isDark ? const Color(0xFF132A1C) : const Color(0xFFEAF7EE),
        border: isDark ? const Color(0xFF1E5131) : const Color(0xFFA6E3B8),
        title: isDark ? const Color(0xFF4ADE80) : const Color(0xFF15803D),
        subtitle: isDark ? const Color(0xFF86EFAC) : const Color(0xFF166534),
        icon: isDark ? const Color(0xFF4ADE80) : const Color(0xFF15803D),
      );
    }
    if (showError) {
      return _BannerColors(
        bg: isDark ? const Color(0xFF2D1214) : const Color(0xFFFEECEE),
        border: isDark ? const Color(0xFF6B2026) : const Color(0xFFFCA5A5),
        title: isDark ? const Color(0xFFF87171) : const Color(0xFFB91C1C),
        subtitle: isDark ? const Color(0xFFFCA5A5) : const Color(0xFF991B1B),
        icon: isDark ? const Color(0xFFF87171) : const Color(0xFFB91C1C),
      );
    }
    return _BannerColors(
      bg: isDark ? const Color(0xFF2B220A) : const Color(0xFFFEFBE8),
      border: isDark ? const Color(0xFF5A4412) : const Color(0xFFFDE047),
      title: isDark ? const Color(0xFFFACC15) : const Color(0xFFA16207),
      subtitle: isDark ? const Color(0xFFFDE68A) : const Color(0xFF854D0E),
      icon: isDark ? const Color(0xFFFACC15) : const Color(0xFFA16207),
    );
  }
}
