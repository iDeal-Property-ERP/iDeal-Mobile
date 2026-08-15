import 'package:flutter/material.dart';
import 'package:ideal_mobile/i18n/localization.dart';
import 'package:ideal_mobile/utils/app_flavor_env.dart';
import 'package:ideal_mobile/widgets/app_top_bar.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PrivacyPolicyScreen extends StatefulWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  State<PrivacyPolicyScreen> createState() => _PrivacyPolicyScreenState();
}

class _PrivacyPolicyScreenState extends State<PrivacyPolicyScreen> {
  late final WebViewController _controller;
  Uri? _policyUri;
  var _initialized = false;
  var _loading = true;
  var _failed = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    _initialized = true;
    if (AppConfig.frontendBaseUrl.isEmpty) return;
    _policyUri = _buildPolicyUri();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.disabled)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) => setState(() {
            _loading = true;
            _failed = false;
          }),
          onPageFinished: (_) => setState(() => _loading = false),
          onWebResourceError: (_) => setState(() {
            _loading = false;
            _failed = true;
          }),
          onNavigationRequest: (request) {
            final destination = Uri.tryParse(request.url);
            if (destination == null || destination.host != _policyUri!.host) {
              if (destination != null) {
                launchUrl(destination, mode: LaunchMode.externalApplication);
              }
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(_policyUri!);
  }

  Uri _buildPolicyUri() {
    final base = Uri.parse(AppConfig.frontendBaseUrl);
    final locale = Localizations.localeOf(context).languageCode;
    final localePath = locale == 'en' ? '' : '/$locale';
    return base.replace(path: '$localePath/privacy-policy');
  }

  @override
  Widget build(BuildContext context) {
    final unavailable = _policyUri == null;
    return Scaffold(
      appBar: AppTopBar.page(title: context.localization.privacy_policy),
      body: unavailable || _failed
          ? Center(
              child: TextButton(
                onPressed: unavailable
                    ? null
                    : () => _controller.loadRequest(_policyUri!),
                child: Text(context.localization.retry),
              ),
            )
          : Stack(
              children: [
                WebViewWidget(controller: _controller),
                if (_loading) const Center(child: CircularProgressIndicator()),
              ],
            ),
    );
  }
}
