import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:ideal_mobile/i18n/localization.dart';
import 'package:ideal_mobile/utils/app_flavor_env.dart';
import 'package:ideal_mobile/widgets/app_top_bar.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

class LegalWebPageScreen extends StatefulWidget {
  const LegalWebPageScreen({
    super.key,
    required this.title,
    required this.path,
  });

  final String title;
  final String path;

  @override
  State<LegalWebPageScreen> createState() => _LegalWebPageScreenState();
}

class _LegalWebPageScreenState extends State<LegalWebPageScreen> {
  late final WebViewController _controller;
  Uri? _documentUri;
  var _initialized = false;
  var _loading = true;
  var _failed = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    _initialized = true;
    final frontendBaseUrl = _frontendBaseUrl;
    if (frontendBaseUrl.isEmpty) return;
    _documentUri = _buildDocumentUri(frontendBaseUrl);
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
            if (destination == null || destination.host != _documentUri!.host) {
              if (destination != null) {
                launchUrl(destination, mode: LaunchMode.externalApplication);
              }
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(_documentUri!);
  }

  String get _frontendBaseUrl =>
      dotenv.isInitialized ? AppConfig.frontendBaseUrl : '';

  Uri _buildDocumentUri(String frontendBaseUrl) {
    final base = Uri.parse(frontendBaseUrl);
    final locale = Localizations.localeOf(context).languageCode;
    final localePath = locale == 'en' ? '' : '/$locale';
    return base.replace(path: '$localePath${widget.path}');
  }

  @override
  Widget build(BuildContext context) {
    final unavailable = _documentUri == null;
    return Scaffold(
      appBar: AppTopBar.page(title: widget.title),
      body: unavailable || _failed
          ? Center(
              child: TextButton(
                onPressed: unavailable
                    ? null
                    : () => _controller.loadRequest(_documentUri!),
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
