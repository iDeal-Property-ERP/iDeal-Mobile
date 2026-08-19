import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:ideal_mobile/common/theme/text_style/app_text_styles.dart';
import 'package:ideal_mobile/i18n/localization.dart';
import 'package:ideal_mobile/presentation/booking/bloc/bookings_cubit.dart';
import 'package:ideal_mobile/presentation/booking/widgets/booking_card.dart';
import 'package:ideal_mobile/presentation/booking/widgets/bookings_loading_shimmer.dart';
import 'package:ideal_mobile/presentation/booking/widgets/empty_bookings_view.dart';
import 'package:ideal_mobile/utils/extensions/build_context_ext.dart';
import 'package:ideal_mobile/utils/theme/extension/theme_extension.dart';
import 'package:ideal_mobile/widgets/app_top_bar.dart';

@RoutePage()
class BookingsScreen extends StatelessWidget {
  const BookingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => BookingsCubit()..load(),
      child: const _BookingsScaffold(),
    );
  }
}

class _BookingsScaffold extends StatelessWidget {
  const _BookingsScaffold();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppTopBar.page(title: context.localization.my_orders),
      body: const BookingsScreenBody(),
    );
  }
}

class BookingsScreenBody extends StatelessWidget {
  const BookingsScreenBody({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<BookingsCubit, BookingsState>(
      listenWhen: (previous, current) =>
          previous.errorMessage != current.errorMessage,
      listener: (context, state) {
        final message = state.errorMessage;
        if (message != null) {
          context.showSnackBar(message, isDisplayingError: true);
        }
      },
      child: BlocBuilder<BookingsCubit, BookingsState>(
        builder: (context, state) {
          if (state.isLoading && state.bookings.isEmpty) {
            return const BookingsLoadingShimmer();
          }
          if (state.bookings.isEmpty) {
            if (state.errorMessage != null) {
              return BookingsErrorView(message: state.errorMessage!);
            }
            return const EmptyBookingsView();
          }
          return ListView.separated(
            itemCount: state.bookings.length,
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            separatorBuilder: (_, _) => const SizedBox(height: 12.0),
            itemBuilder: (context, index) =>
                BookingCard(booking: state.bookings[index]),
          );
        },
      ),
    );
  }
}

class BookingsErrorView extends StatelessWidget {
  const BookingsErrorView({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              TablerIcons.alert_circle,
              size: 56,
              color: context.currentTheme.iconNeutralDefault,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: AppTextStyles.p2Regular.copyWith(
                color: context.currentTheme.textNeutralSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () => context.read<BookingsCubit>().load(),
              icon: const Icon(TablerIcons.refresh),
              label: Text(context.localization.retry),
            ),
          ],
        ),
      ),
    );
  }
}
