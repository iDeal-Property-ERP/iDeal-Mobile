import 'package:flutter/material.dart';
import 'package:ideal_mobile/common/theme/text_style/app_text_styles.dart';
import 'package:ideal_mobile/i18n/localization.dart';
import 'package:ideal_mobile/presentation/contact_us/widgets/attachment_error_display.dart';
import 'package:ideal_mobile/presentation/contact_us/widgets/image_preview_list.dart';
import 'package:ideal_mobile/presentation/contact_us/widgets/pdf_preview_list.dart';
import 'package:ideal_mobile/presentation/contact_us/widgets/upload_attachment.dart';
import 'package:ideal_mobile/utils/theme/extension/theme_extension.dart';

class ContactUsAttachmentSection extends StatelessWidget {
  const ContactUsAttachmentSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: .start,
      mainAxisSize: .min,
      children: [
        Text(
          context.localization.attachment,
          style: AppTextStyles.p3Medium.copyWith(
            color: context.currentTheme.textNeutralPrimary,
          ),
        ),
        const SizedBox(height: 6),
        const UploadAttachment(),
        const ImagePreviewList(),
        const SizedBox(height: 8),
        const PdfPreviewList(),
        const AttachmentErrorDisplay(),
      ],
    );
  }
}
