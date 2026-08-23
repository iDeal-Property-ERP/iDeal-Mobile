import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:ideal_mobile/common/theme/text_style/app_text_styles.dart';
import 'package:ideal_mobile/core/services/injection_container.dart';
import 'package:ideal_mobile/i18n/localization.dart';
import 'package:ideal_mobile/presentation/contracts/bloc/contracts_bloc.dart';
import 'package:ideal_mobile/presentation/contracts/bloc/contracts_event.dart';
import 'package:ideal_mobile/presentation/contracts/bloc/contracts_state.dart';
import 'package:ideal_mobile/presentation/contracts/domain/entities/mobile_contract.dart';
import 'package:ideal_mobile/utils/theme/extension/theme_extension.dart';
import 'package:shimmer/shimmer.dart';

class ProfileContractsSheet extends StatelessWidget {
  const ProfileContractsSheet({super.key});

  static Future<void> show(BuildContext context, {ContractsBloc? bloc}) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.currentTheme.bgSurfaceSheet,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.0)),
      ),
      builder: (_) => BlocProvider<ContractsBloc>(
        create: (_) =>
            (bloc ?? sl<ContractsBloc>())..add(const LoadContractsEvent()),
        child: const ProfileContractsSheet(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
              child: BlocBuilder<ContractsBloc, ContractsState>(
                builder: (context, state) {
                  if (state.isLoading) {
                    return _LoadingContracts(
                      scrollController: scrollController,
                    );
                  }
                  if (state.errorMessage != null) {
                    return _ContractsLoadError(
                      message: state.errorMessage!,
                      onRetry: () => context.read<ContractsBloc>().add(
                        const LoadContractsEvent(),
                      ),
                    );
                  }
                  if (state.contracts.isEmpty) {
                    return _EmptyContracts(scrollController: scrollController);
                  }
                  return RefreshIndicator(
                    onRefresh: () async => context.read<ContractsBloc>().add(
                      const LoadContractsEvent(),
                    ),
                    child: ListView.builder(
                      controller: scrollController,
                      padding: const EdgeInsets.all(16.0),
                      itemCount: state.contracts.length,
                      itemBuilder: (_, index) =>
                          _ContractCard(item: state.contracts[index]),
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

class _ContractCard extends StatelessWidget {
  const _ContractCard({required this.item});

  final MobileContract item;

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final statusColor = switch (item.status) {
      'active' || 'scheduled' => const Color(0xFF16A34A),
      'pending_signature' => const Color(0xFFD97706),
      _ => context.currentTheme.textNeutralSecondary,
    };
    final statusBackground = statusColor.withValues(alpha: 0.12);
    final cardBackground = isDark
        ? context.currentTheme.bgSurfaceBase2
        : Colors.white;

    return Container(
      margin: const EdgeInsets.only(bottom: 12.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: cardBackground,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: context.currentTheme.strokeNeutralLight200),
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
                    item.reference,
                    style: AppTextStyles.p3SemiBold.copyWith(
                      color: context.currentTheme.textNeutralPrimary,
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
                  color: statusBackground,
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Text(
                  item.statusDisplay,
                  style: AppTextStyles.c1SemiBold.copyWith(
                    color: statusColor,
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
            children: [
              Expanded(
                child: _ContractValue(
                  label: context.localization.contracts_period,
                  value: '${item.startDate} – ${item.endDate}',
                ),
              ),
              const SizedBox(width: 16.0),
              Expanded(
                child: _ContractValue(
                  label: context.localization.contracts_monthly_rent,
                  value: _formatRent(item.monthlyRent, item.currency),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatRent(double amount, String currency) {
    final value = amount == amount.roundToDouble()
        ? amount.toInt().toString()
        : amount.toStringAsFixed(2);
    return currency == 'USD' ? '\$$value' : '$value $currency';
  }
}

class _ContractValue extends StatelessWidget {
  const _ContractValue({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.c2Regular.copyWith(
            color: context.currentTheme.textNeutralSecondary,
          ),
        ),
        const SizedBox(height: 2.0),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.p4Medium.copyWith(
            color: context.currentTheme.textNeutralPrimary,
          ),
        ),
      ],
    );
  }
}

class _EmptyContracts extends StatelessWidget {
  const _EmptyContracts({required this.scrollController});

  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    return ListView(
      controller: scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 32.0),
      children: [
        const SizedBox(height: 96.0),
        Icon(
          TablerIcons.file_off,
          size: 44.0,
          color: context.currentTheme.textNeutralSecondary,
        ),
        const SizedBox(height: 16.0),
        Text(
          context.localization.contracts_empty_title,
          textAlign: TextAlign.center,
          style: AppTextStyles.h6Bold.copyWith(
            color: context.currentTheme.textNeutralPrimary,
          ),
        ),
        const SizedBox(height: 8.0),
        Text(
          context.localization.contracts_empty_subtitle,
          textAlign: TextAlign.center,
          style: AppTextStyles.p4Regular.copyWith(
            color: context.currentTheme.textNeutralSecondary,
          ),
        ),
      ],
    );
  }
}

class _ContractsLoadError extends StatelessWidget {
  const _ContractsLoadError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              context.localization.contracts_load_error,
              textAlign: TextAlign.center,
              style: AppTextStyles.p2SemiBold.copyWith(
                color: context.currentTheme.textNeutralPrimary,
              ),
            ),
            const SizedBox(height: 8.0),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTextStyles.p4Regular.copyWith(
                color: context.currentTheme.textNeutralSecondary,
              ),
            ),
            const SizedBox(height: 20.0),
            OutlinedButton(
              onPressed: onRetry,
              child: Text(context.localization.retry),
            ),
          ],
        ),
      ),
    );
  }
}

class _LoadingContracts extends StatelessWidget {
  const _LoadingContracts({required this.scrollController});

  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    final baseColor = context.isDark
        ? Colors.grey.shade800
        : Colors.grey.shade300;
    final highlightColor = context.isDark
        ? Colors.grey.shade700
        : Colors.grey.shade100;
    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: ListView.builder(
        controller: scrollController,
        padding: const EdgeInsets.all(16.0),
        itemCount: 3,
        itemBuilder: (_, _) => Container(
          height: 166.0,
          margin: const EdgeInsets.only(bottom: 12.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.0),
          ),
        ),
      ),
    );
  }
}
