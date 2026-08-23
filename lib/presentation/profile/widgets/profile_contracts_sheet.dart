import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:ideal_mobile/common/theme/text_style/app_text_styles.dart';
import 'package:ideal_mobile/i18n/localization.dart';
import 'package:ideal_mobile/utils/extensions/build_context_ext.dart';
import 'package:ideal_mobile/utils/theme/extension/theme_extension.dart';

class ProfileContractsSheet extends StatelessWidget {
  const ProfileContractsSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.currentTheme.bgSurfaceSheet,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.0)),
      ),
      builder: (_) => const ProfileContractsSheet(),
    );
  }

  static const Color _greenColor = Color(0xFF16A34A);

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final cardBg = isDark ? context.currentTheme.bgSurfaceBase2 : Colors.white;

    final contracts = [
      _ContractMockItem(
        contractNumber: 'ID-2025/0842',
        propertyTitle: '3 xonali zamonaviy kvartira',
        propertyAddress: 'Toshkent sh., Mirzo Ulug‘bek tumani',
        period: '01.02.2025 - 01.02.2026',
        monthlyRent: '850 \$ / oy',
        status: 'Faol',
        statusColor: _greenColor,
        statusBg: _greenColor.withValues(alpha: 0.12),
      ),
      _ContractMockItem(
        contractNumber: 'ID-2024/0319',
        propertyTitle: '1 xonali shinam kvartira',
        propertyAddress: 'Toshkent sh., Chilonzor tumani',
        period: '15.01.2024 - 15.01.2025',
        monthlyRent: '450 \$ / oy',
        status: 'Tugallangan',
        statusColor: context.currentTheme.textNeutralSecondary,
        statusBg: context.currentTheme.bgNeutralLight200.withValues(alpha: 0.5),
      ),
    ];

    return DraggableScrollableSheet(
      initialChildSize: 0.75,
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
                    context.localization.my_contracts,
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
                itemCount: contracts.length,
                itemBuilder: (context, index) {
                  final item = contracts[index];
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  TablerIcons.file_certificate,
                                  size: 18.0,
                                  color: Color(0xFF0F2A5C),
                                ),
                                const SizedBox(width: 6.0),
                                Text(
                                  item.contractNumber,
                                  style: AppTextStyles.p3SemiBold.copyWith(
                                    color:
                                        context.currentTheme.textNeutralPrimary,
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10.0,
                                vertical: 4.0,
                              ),
                              decoration: BoxDecoration(
                                color: item.statusBg,
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              child: Text(
                                item.status,
                                style: AppTextStyles.c1SemiBold.copyWith(
                                  color: item.statusColor,
                                  fontSize: 11.0,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10.0),
                        Text(
                          item.propertyTitle,
                          style: AppTextStyles.p2SemiBold.copyWith(
                            color: context.currentTheme.textNeutralPrimary,
                          ),
                        ),
                        const SizedBox(height: 4.0),
                        Text(
                          item.propertyAddress,
                          style: AppTextStyles.p4Regular.copyWith(
                            color: context.currentTheme.textNeutralSecondary,
                          ),
                        ),
                        const SizedBox(height: 12.0),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Muddati:',
                                  style: AppTextStyles.c2Regular.copyWith(
                                    color: context
                                        .currentTheme
                                        .textNeutralSecondary,
                                  ),
                                ),
                                const SizedBox(height: 2.0),
                                Text(
                                  item.period,
                                  style: AppTextStyles.p4Medium.copyWith(
                                    color:
                                        context.currentTheme.textNeutralPrimary,
                                  ),
                                ),
                              ],
                            ),
                            OutlinedButton.icon(
                              onPressed: () {
                                context.showSnackBar(
                                  'Shartnoma yuklab olinmoqda...',
                                );
                              },
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(
                                  color: context
                                      .currentTheme
                                      .strokeNeutralLight200,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12.0,
                                  vertical: 8.0,
                                ),
                              ),
                              icon: const Icon(
                                TablerIcons.download,
                                size: 16.0,
                              ),
                              label: const Text('PDF'),
                            ),
                          ],
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

class _ContractMockItem {
  const _ContractMockItem({
    required this.contractNumber,
    required this.propertyTitle,
    required this.propertyAddress,
    required this.period,
    required this.monthlyRent,
    required this.status,
    required this.statusColor,
    required this.statusBg,
  });

  final String contractNumber;
  final String propertyTitle;
  final String propertyAddress;
  final String period;
  final String monthlyRent;
  final String status;
  final Color statusColor;
  final Color statusBg;
}
