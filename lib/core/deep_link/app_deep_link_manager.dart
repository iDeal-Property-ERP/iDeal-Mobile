import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:ideal_mobile/main.dart';
import 'package:ideal_mobile/presentation/product_detail/constant/product_detail_constants.dart';
import 'package:ideal_mobile/routes.gr.dart';

class AppDeepLinkManager {
  AppDeepLinkManager();

  final AppLinks _appLinks = AppLinks();
  StreamSubscription<Uri?>? _linkSubscription;
  Uri? _pendingDeepLink;
  bool _isProcessingDeepLink = false;

  bool get hasPendingDeepLink => _pendingDeepLink != null;

  Future<void> initializeDeepLink() async {
    try {
      final initialUri = await _appLinks.getInitialLink();
      if (initialUri != null) _pendingDeepLink = initialUri;

      _linkSubscription = _appLinks.uriLinkStream.listen(
        _onRuntimeDeepLinkReceived,
        onError: (err) => debugPrint('[DeepLink] Error: $err'),
        onDone: disposeDeepLinkListener,
      );
    } on PlatformException catch (e) {
      debugPrint('[DeepLink] PlatformException: $e');
    }
  }

  Future<void> _onRuntimeDeepLinkReceived(Uri? uri) async {
    if (uri == null) return;

    final context = rootNavigatorKey.currentContext;
    if (context == null) {
      _pendingDeepLink = uri;
      return;
    }

    await _handleDeepLink(uri, context);
  }

  Future<bool> handlePendingDeepLink(BuildContext context) async {
    if (_pendingDeepLink == null || _isProcessingDeepLink) return false;

    _isProcessingDeepLink = true;
    try {
      return await _handleDeepLink(_pendingDeepLink!, context);
    } finally {
      _pendingDeepLink = null;
      _isProcessingDeepLink = false;
    }
  }

  Future<bool> _handleDeepLink(Uri uri, BuildContext context) async {
    if (!_isValidDeepLink(uri)) return false;

    final segments = uri.pathSegments;
    if (segments.length < 2) return false;

    final routeKey = segments[0].toLowerCase();
    final routeArg = segments[1];

    final router = context.router;
    final routeName = _deepLinkRoutes[routeKey];

    if (routeName == null) return false;

    if (_isOnProductDetail(router, routeArg)) return true;

    await _navigateToProductDetail(router, routeArg);
    return true;
  }

  final Map<String, String> _deepLinkRoutes = {
    'product-detail': ProductDetailRoute.name,
    'home': HomeRoute.name,
  };

  bool _isOnProductDetail(StackRouter router, String productId) {
    final current = router.current;
    return current.name == ProductDetailRoute.name &&
        current.args is ProductDetailRouteArgs &&
        (current.args! as ProductDetailRouteArgs).productId == productId;
  }

  Future<void> _navigateToProductDetail(
    StackRouter router,
    String productId,
  ) async {
    final isHomeAlreadyInStack = router.stack.any(
      (route) => route.name == HomeRoute.name,
    );

    if (!isHomeAlreadyInStack) {
      await router.replaceAll([
        const HomeRoute(),
        ProductDetailRoute(productId: productId),
      ]);
    } else {
      router.popUntilRouteWithName(HomeRoute.name);
      await router.push(ProductDetailRoute(productId: productId));
    }
  }

  void disposeDeepLinkListener() => _linkSubscription?.cancel();

  bool _isValidDeepLink(Uri uri) {
    return uri.scheme == kDeepLinkScheme &&
        uri.host == kHost &&
        uri.pathSegments.length >= 2 &&
        uri.pathSegments[0] == kProductDetail;
  }
}
