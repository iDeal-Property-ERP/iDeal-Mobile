import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:ideal_mobile/common/theme/text_style/app_text_styles.dart';
import 'package:ideal_mobile/i18n/localization.dart';
import 'package:ideal_mobile/utils/theme/extension/theme_extension.dart';

class ProfileTermsSheet extends StatelessWidget {
  const ProfileTermsSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.currentTheme.bgSurfaceSheet,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.0)),
      ),
      builder: (_) => const ProfileTermsSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final cardBg = isDark ? context.currentTheme.bgSurfaceBase2 : Colors.white;

    final sections = [
      const _TermSection(
        title: '1. Umumiy qoidalar',
        content:
            'iDeal ilovasi ko‘chmas mulk ijarasi va oldi-sotdisi bo‘yicha '
            'xizmatlarni taqdim etuvchi platformadir. Ilovadan foydalanish '
            'orqali siz ushbu shartlarga to‘liq rozilik bildirasiz.',
      ),
      const _TermSection(
        title: '2. Mulkdorlar majburiyatlari',
        content:
            'Platformada e’lon joylashtiruvchi shaxslar ko‘chmas mulk haqidagi '
            'ma’lumotlarning to‘g‘riligi, dolzarbligi va mulkka bo‘lgan '
            'qonuniy egalik huquqi uchun shaxsan javobgardir.',
      ),
      const _TermSection(
        title: '3. Bron qilish va to‘lovlar',
        content:
            'Ilova orqali amalga oshirilgan har bir bron qilish va to‘lov '
            'operatsiyasi xavfsiz to‘lov shlyuzlari orqali himoyalanadi va '
            'rasmiy shartnoma bilan mustahkamlanadi.',
      ),
      const _TermSection(
        title: '4. Maxfiylik va ma’lumotlar xavfsizligi',
        content:
            'Foydalanuvchilarning shaxsiy ma’lumotlari O‘zbekiston '
            'Respublikasi qonunchiligiga muvofiq qat’iy himoyalanadi va '
            'uchinchi shaxslarga berilmaydi.',
      ),
    ];

    return DraggableScrollableSheet(
      initialChildSize: 0.8,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Column(
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
            Padding(
              padding: const EdgeInsets.fromLTRB(20.0, 16.0, 16.0, 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    context.localization.terms_and_conditions,
                    style: AppTextStyles.h6Bold.copyWith(
                      color: context.currentTheme.textNeutralPrimary,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(TablerIcons.x),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            const Divider(height: 1.0),
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                padding: const EdgeInsets.all(16.0),
                itemCount: sections.length,
                itemBuilder: (context, index) {
                  final sec = sections[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12.0),
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(16.0),
                      border: Border.all(
                        color: context.currentTheme.strokeNeutralLight200,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          sec.title,
                          style: AppTextStyles.p2SemiBold.copyWith(
                            color: context.currentTheme.textNeutralPrimary,
                          ),
                        ),
                        const SizedBox(height: 8.0),
                        Text(
                          sec.content,
                          style: AppTextStyles.p3Regular.copyWith(
                            color: context.currentTheme.textNeutralSecondary,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

class _TermSection {
  const _TermSection({required this.title, required this.content});

  final String title;
  final String content;
}
