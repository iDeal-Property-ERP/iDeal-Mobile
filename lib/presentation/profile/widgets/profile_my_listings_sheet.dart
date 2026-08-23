import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:ideal_mobile/common/theme/text_style/app_text_styles.dart';
import 'package:ideal_mobile/i18n/localization.dart';
import 'package:ideal_mobile/utils/theme/extension/theme_extension.dart';

class ProfileMyListingsSheet extends StatefulWidget {
  const ProfileMyListingsSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.currentTheme.bgSurfaceSheet,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.0)),
      ),
      builder: (_) => const ProfileMyListingsSheet(),
    );
  }

  @override
  State<ProfileMyListingsSheet> createState() => _ProfileMyListingsSheetState();
}

class _ProfileMyListingsSheetState extends State<ProfileMyListingsSheet> {
  int _selectedFilterIndex = 0;

  static const Color _accentColor = Color(0xFF3B82F6);
  static const Color _pendingColor = Color(0xFFD97706);
  static const Color _rentedColor = Color(0xFF16A34A);

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final cardBg = isDark ? context.currentTheme.bgSurfaceBase2 : Colors.white;

    final listings = [
      _ListingMockItem(
        title: '3 xonali zamonaviy kvartira',
        address: 'Toshkent sh., Mirzo Ulug‘bek tumani',
        price: '850 \$ / oy',
        status: context.localization.status_approved,
        statusColor: _accentColor,
        statusBg: _accentColor.withValues(alpha: 0.12),
        views: 142,
      ),
      _ListingMockItem(
        title: '2 xonali shinam xonadon',
        address: 'Toshkent sh., Yakkasaroy tumani',
        price: '600 \$ / oy',
        status: context.localization.status_approved,
        statusColor: _accentColor,
        statusBg: _accentColor.withValues(alpha: 0.12),
        views: 98,
      ),
      _ListingMockItem(
        title: 'Yangi ta’mirlangan hovli uy',
        address: 'Toshkent sh., Yunusobod tumani',
        price: '1,200 \$ / oy',
        status: context.localization.status_pending,
        statusColor: _pendingColor,
        statusBg: _pendingColor.withValues(alpha: 0.12),
        views: 24,
      ),
      _ListingMockItem(
        title: '1 xonali studiya',
        address: 'Toshkent sh., Chilonzor tumani',
        price: '450 \$ / oy',
        status: context.localization.status_rented,
        statusColor: _rentedColor,
        statusBg: _rentedColor.withValues(alpha: 0.12),
        views: 310,
      ),
    ];

    final filteredListings = switch (_selectedFilterIndex) {
      1 =>
        listings
            .where((l) => l.status == context.localization.status_approved)
            .toList(),
      2 =>
        listings
            .where((l) => l.status == context.localization.status_pending)
            .toList(),
      3 =>
        listings
            .where((l) => l.status == context.localization.status_rented)
            .toList(),
      _ => listings,
    };

    return DraggableScrollableSheet(
      initialChildSize: 0.82,
      minChildSize: 0.5,
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
                    context.localization.my_listings,
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
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: Row(
                children: [
                  _FilterChip(
                    label: context.localization.view_all,
                    count: listings.length,
                    isSelected: _selectedFilterIndex == 0,
                    onTap: () => setState(() => _selectedFilterIndex = 0),
                  ),
                  const SizedBox(width: 8.0),
                  _FilterChip(
                    label: context.localization.status_approved,
                    count: 2,
                    isSelected: _selectedFilterIndex == 1,
                    onTap: () => setState(() => _selectedFilterIndex = 1),
                  ),
                  const SizedBox(width: 8.0),
                  _FilterChip(
                    label: context.localization.status_pending,
                    count: 1,
                    isSelected: _selectedFilterIndex == 2,
                    onTap: () => setState(() => _selectedFilterIndex = 2),
                  ),
                  const SizedBox(width: 8.0),
                  _FilterChip(
                    label: context.localization.status_rented,
                    count: 1,
                    isSelected: _selectedFilterIndex == 3,
                    onTap: () => setState(() => _selectedFilterIndex = 3),
                  ),
                ],
              ),
            ),
            const Divider(height: 1.0),
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                padding: const EdgeInsets.all(16.0),
                itemCount: filteredListings.length,
                itemBuilder: (context, index) {
                  final item = filteredListings[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12.0),
                    padding: const EdgeInsets.all(14.0),
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
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 50.0,
                              height: 50.0,
                              decoration: BoxDecoration(
                                color: _accentColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              child: const Center(
                                child: Icon(
                                  TablerIcons.building,
                                  color: _accentColor,
                                  size: 24.0,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12.0),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.title,
                                    style: AppTextStyles.p2SemiBold.copyWith(
                                      color: context
                                          .currentTheme
                                          .textNeutralPrimary,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4.0),
                                  Text(
                                    item.address,
                                    style: AppTextStyles.p4Regular.copyWith(
                                      color: context
                                          .currentTheme
                                          .textNeutralSecondary,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12.0),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              item.price,
                              style: AppTextStyles.p2Bold.copyWith(
                                color: _accentColor,
                              ),
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

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.count,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final int count;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 7.0),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF0F2A5C)
              : (context.isDark
                    ? context.currentTheme.bgSurfaceBase2
                    : const Color(0xFFF0F2F6)),
          borderRadius: BorderRadius.circular(20.0),
        ),
        child: Text(
          '$label · $count',
          style: AppTextStyles.p4SemiBold.copyWith(
            color: isSelected
                ? Colors.white
                : context.currentTheme.textNeutralPrimary,
            fontSize: 12.0,
          ),
        ),
      ),
    );
  }
}

class _ListingMockItem {
  const _ListingMockItem({
    required this.title,
    required this.address,
    required this.price,
    required this.status,
    required this.statusColor,
    required this.statusBg,
    required this.views,
  });

  final String title;
  final String address;
  final String price;
  final String status;
  final Color statusColor;
  final Color statusBg;
  final int views;
}
