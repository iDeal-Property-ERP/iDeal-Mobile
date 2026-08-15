import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:ideal_mobile/core/services/injection_container.dart';
import 'package:ideal_mobile/i18n/localization.dart';
import 'package:ideal_mobile/presentation/booking/data/active_checkout_store.dart';
import 'package:ideal_mobile/routes.gr.dart';
import 'package:ideal_mobile/widgets/app_top_bar.dart';

@RoutePage()
class PaymentReturnScreen extends StatefulWidget {
  const PaymentReturnScreen({
    super.key,
    @QueryParam('checkout') this.checkoutToken,
  });

  final String? checkoutToken;

  @override
  State<PaymentReturnScreen> createState() => _PaymentReturnScreenState();
}

class _PaymentReturnScreenState extends State<PaymentReturnScreen> {
  bool _invalid = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _resolve());
  }

  Future<void> _resolve() async {
    final active = await sl<ActiveCheckoutStore>().read();
    if (!mounted) return;
    if (active != null &&
        widget.checkoutToken != null &&
        active.publicToken == widget.checkoutToken) {
      await context.router.replace(
        BookingStatusRoute(
          bookingId: active.bookingId,
          initialCheckout: active.checkout,
        ),
      );
      return;
    }
    setState(() => _invalid = true);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppTopBar.page(title: context.localization.booking_status_title),
    body: Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: _invalid
            ? Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    context.localization.booking_return_unverified,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: () => context.router.replace(const HomeRoute()),
                    child: Text(context.localization.booking_back_home),
                  ),
                ],
              )
            : const CircularProgressIndicator(),
      ),
    ),
  );
}
