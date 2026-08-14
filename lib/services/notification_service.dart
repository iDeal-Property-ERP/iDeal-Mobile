import 'dart:async';
import 'dart:io';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:ideal_mobile/services/push/device_registration_api.dart';
import 'package:ideal_mobile/services/push/notification_permission_status.dart';
import 'package:ideal_mobile/services/push/push_device_info.dart';
import 'package:ideal_mobile/services/push/push_notification_event.dart';
import 'package:ideal_mobile/widgets/styling/app_colors.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('Background Message data: ${message.data}');
}

class NotificationService {
  NotificationService._();

  // Channel constants
  final basicChannel = 'basic_channel';
  final basicChannelName = 'Basic notifications';
  final basicChannelDescription =
      'Notification channel for basic notifications';
  final basicChannelSound = 'resource://raw/basic';
  final appIcon = 'resource://drawable/ic_notification';
  final defaultNotificationTitle = 'New Notification';
  final defaultNotificationBody = '';

  static final NotificationService instance = NotificationService._();
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final AwesomeNotifications _awesomeNotifications = AwesomeNotifications();
  final DeviceRegistrationApi _deviceRegistrationApi = DeviceRegistrationApi();
  final PushDeviceInfo _pushDeviceInfo = const PushDeviceInfo();

  final _onNotificationTapController = StreamController<Map<String, dynamic>>();
  final _onNotificationReceivedController =
      StreamController<PushNotificationEvent>.broadcast();

  StreamSubscription<RemoteMessage>? _onMessageSubscription;
  StreamSubscription<RemoteMessage>? _onMessageOpenedAppSubscription;
  StreamSubscription<String>? _onTokenRefreshSubscription;

  RemoteMessage? _initialMessage;
  Future<void>? _initializationFuture;
  bool _initialMessageDelivered = false;
  bool _isInitialized = false;
  bool _isDisposed = false;

  Stream<Map<String, dynamic>> get onNotificationTap =>
      _onNotificationTapController.stream;

  Stream<PushNotificationEvent> get onNotificationReceived =>
      _onNotificationReceivedController.stream;

  Map<String, dynamic>? get initialNotificationPayload => _initialMessage?.data;

  Future<void> initialize() async {
    if (_isDisposed) return;

    try {
      await _ensureInitialized();
    } catch (error) {
      debugPrint('[Push] Notification setup failed: $error');
      return;
    }

    if (_isDisposed) return;

    try {
      final permissionStatus = await requestPermission();
      if (permissionStatus != NotificationPermissionStatus.granted) {
        debugPrint(
          '[Push] Notification permission is not granted: '
          '$permissionStatus',
        );
        return;
      }

      if (_isDisposed) return;
      await _registerCurrentToken();
    } catch (error) {
      debugPrint('[Push] Notification initialization failed: $error');
    }
  }

  Future<void> _ensureInitialized() async {
    if (_isInitialized) return;

    final pendingInitialization = _initializationFuture;
    if (pendingInitialization != null) {
      await pendingInitialization;
      return;
    }

    final initialization = _initializeOnce();
    _initializationFuture = initialization;
    try {
      await initialization;
    } finally {
      if (identical(_initializationFuture, initialization)) {
        _initializationFuture = null;
      }
    }
  }

  Future<void> _initializeOnce() async {
    try {
      await _initializeAwesomeNotifications();
      await _setupFCMListeners();
      _isInitialized = true;
    } catch (error) {
      _isInitialized = false;
      debugPrint('[Push] Notification setup failed: $error');
    }
  }

  Future<void> _initializeAwesomeNotifications() async {
    await _awesomeNotifications.initialize(appIcon, [
      NotificationChannel(
        channelKey: basicChannel,
        channelName: basicChannelName,
        channelDescription: basicChannelDescription,
        ledColor: AppColors.white,
        defaultColor: AppColors.brand500,
        importance: NotificationImportance.High,
        channelShowBadge: true,
        playSound: true,
        soundSource: basicChannelSound,
        enableVibration: true,
      ),
    ], debug: kDebugMode);

    await _awesomeNotifications.setListeners(
      onActionReceivedMethod: _onActionReceivedMethod,
      onNotificationCreatedMethod: _onNotificationCreatedMethod,
      onNotificationDisplayedMethod: _onNotificationDisplayedMethod,
      onDismissActionReceivedMethod: _onDismissActionReceivedMethod,
    );
  }

  Future<NotificationPermissionStatus> requestPermission() async {
    var awesomeAllowed = false;
    try {
      awesomeAllowed = await _awesomeNotifications.isNotificationAllowed();
      if (!awesomeAllowed) {
        await _awesomeNotifications.requestPermissionToSendNotifications();
        awesomeAllowed = await _awesomeNotifications.isNotificationAllowed();
      }
    } catch (error) {
      debugPrint('[Push] Awesome Notifications permission failed: $error');
    }

    try {
      final settings = await _firebaseMessaging.requestPermission();
      debugPrint(
        '[Push] FCM permission status: ${settings.authorizationStatus}',
      );
      return _permissionStatus(
        authorizationStatus: settings.authorizationStatus,
        awesomeAllowed: awesomeAllowed,
        permissionWasRequested: true,
      );
    } catch (error) {
      debugPrint('[Push] FCM permission request failed: $error');
      return NotificationPermissionStatus.denied;
    }
  }

  Future<bool> requestNotificationPermission() async {
    return await requestPermission() == NotificationPermissionStatus.granted;
  }

  Future<NotificationPermissionStatus> checkPermission() async {
    try {
      final settings = await _firebaseMessaging.getNotificationSettings();
      final awesomeAllowed = await _awesomeNotifications
          .isNotificationAllowed();
      return _permissionStatus(
        authorizationStatus: settings.authorizationStatus,
        awesomeAllowed: awesomeAllowed,
        permissionWasRequested: false,
      );
    } catch (error) {
      debugPrint('[Push] Notification permission check failed: $error');
      return NotificationPermissionStatus.denied;
    }
  }

  NotificationPermissionStatus _permissionStatus({
    required AuthorizationStatus authorizationStatus,
    required bool awesomeAllowed,
    required bool permissionWasRequested,
  }) {
    final fcmAllowed =
        authorizationStatus == AuthorizationStatus.authorized ||
        authorizationStatus == AuthorizationStatus.provisional;
    if (fcmAllowed && awesomeAllowed) {
      return NotificationPermissionStatus.granted;
    }

    if (authorizationStatus == AuthorizationStatus.notDetermined) {
      return NotificationPermissionStatus.notDetermined;
    }

    if (!permissionWasRequested &&
        authorizationStatus == AuthorizationStatus.denied) {
      return NotificationPermissionStatus.permanentlyDenied;
    }

    return NotificationPermissionStatus.denied;
  }

  Future<void> _setupFCMListeners() async {
    _onMessageSubscription ??= FirebaseMessaging.onMessage.listen(
      (message) => unawaited(_handleForegroundMessage(message)),
    );
    _onMessageOpenedAppSubscription ??= FirebaseMessaging.onMessageOpenedApp
        .listen(_handleMessageOpenedApp);

    _initialMessage ??= await _firebaseMessaging.getInitialMessage();
    final initialMessage = _initialMessage;
    if (initialMessage != null && !_initialMessageDelivered) {
      _initialMessageDelivered = true;
      _handleMessageOpenedApp(initialMessage);
    }
  }

  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    final notification = message.notification;
    final data = message.data;

    _emitNotificationReceived(
      PushNotificationEvent.fromData(
        data,
        title: notification?.title,
        body: notification?.body,
      ),
    );

    debugPrint('[Push] Foreground message data: $data');

    if (Platform.isIOS) return;

    if (notification != null) {
      try {
        await showNotification(
          data: data,
          imageUrl:
              notification.android?.imageUrl ?? notification.apple?.imageUrl,
          notification: notification,
        );
      } catch (error) {
        debugPrint('[Push] Foreground notification failed: $error');
      }
    }
  }

  void _handleMessageOpenedApp(RemoteMessage message) {
    _emitNotificationTap(message.data);
  }

  void _emitNotificationTap(Map<String, dynamic> payload) {
    if (_onNotificationTapController.isClosed) return;
    _onNotificationTapController.add(Map<String, dynamic>.from(payload));
  }

  void _emitNotificationReceived(PushNotificationEvent event) {
    if (_onNotificationReceivedController.isClosed) return;
    _onNotificationReceivedController.add(event);
  }

  Future<void> _registerCurrentToken() async {
    _listenForTokenRefresh();
    try {
      final token = await _firebaseMessaging.getToken();
      if (token == null || token.trim().isEmpty) {
        debugPrint('[Push] FCM did not return a device token.');
        return;
      }

      await _registerToken(token);
    } catch (error) {
      debugPrint('[Push] FCM token registration failed: $error');
    }
  }

  void _listenForTokenRefresh() {
    if (_onTokenRefreshSubscription != null || _isDisposed) return;

    _onTokenRefreshSubscription = _firebaseMessaging.onTokenRefresh.listen(
      (token) => unawaited(_handleTokenRefresh(token)),
      onError: (Object error) {
        debugPrint('[Push] FCM token refresh stream failed: $error');
      },
    );
  }

  Future<void> _handleTokenRefresh(String token) async {
    if (_isDisposed || token.trim().isEmpty) return;

    try {
      final permissionStatus = await checkPermission();
      if (permissionStatus != NotificationPermissionStatus.granted) {
        debugPrint(
          '[Push] Ignoring token refresh without notification permission.',
        );
        return;
      }

      await _registerToken(token);
    } catch (error) {
      debugPrint('[Push] Refreshed FCM token registration failed: $error');
    }
  }

  Future<void> _registerToken(String token) async {
    final payload = await _pushDeviceInfo.buildPayload(token: token);
    await _deviceRegistrationApi.register(payload);
  }

  Future<void> unregisterDevice() async {
    final tokenRefreshSubscription = _onTokenRefreshSubscription;
    _onTokenRefreshSubscription = null;
    if (tokenRefreshSubscription != null) {
      unawaited(tokenRefreshSubscription.cancel());
    }

    String? token;
    try {
      token = await _firebaseMessaging.getToken();
    } catch (error) {
      debugPrint('[Push] Could not read the FCM token for cleanup: $error');
      return;
    }

    if (token != null && token.trim().isNotEmpty) {
      try {
        await _deviceRegistrationApi.unregister(token);
      } catch (error) {
        debugPrint('[Push] Device unregister failed: $error');
      }
    }

    try {
      await _firebaseMessaging.deleteToken();
      debugPrint('[Push] FCM token deleted after device cleanup.');
    } catch (error) {
      debugPrint('[Push] Failed to delete the FCM token: $error');
    }
  }

  Future<void> showNotification({
    Map<String, dynamic>? data,
    String? imageUrl,
    RemoteNotification? notification,
  }) async {
    // Create a unique ID for each notification
    int notificationId;
    if (data?['notification_id'] != null) {
      // Convert UUID to a valid 32-bit integer by hashing
      final notificationIdStr = data!['notification_id'].toString();
      // Simple hash function that produces a 31-bit positive integer
      // (avoiding sign issues)
      notificationId = notificationIdStr.hashCode & 0x7FFFFFFF;
    } else {
      // Fallback to timestamp but ensure it's within 32-bit range
      notificationId = DateTime.now().millisecondsSinceEpoch & 0x7FFFFFFF;
    }

    await _awesomeNotifications.createNotification(
      content: NotificationContent(
        id: notificationId,
        channelKey: basicChannel,
        title: notification?.title ?? defaultNotificationTitle,
        body: notification?.body ?? defaultNotificationBody,
        payload: data?.cast(),
        bigPicture: imageUrl,
        notificationLayout: imageUrl != null
            ? NotificationLayout.BigPicture
            : NotificationLayout.Default,
        wakeUpScreen: true,
        category: NotificationCategory.Message,
      ),
    );
  }

  @pragma('vm:entry-point')
  static Future<void> _onNotificationCreatedMethod(
    ReceivedNotification receivedNotification,
  ) async {
    // Notification created callback
  }

  @pragma('vm:entry-point')
  static Future<void> _onNotificationDisplayedMethod(
    ReceivedNotification receivedNotification,
  ) async {
    // Notification displayed callback
  }

  @pragma('vm:entry-point')
  static Future<void> _onActionReceivedMethod(
    ReceivedAction receivedAction,
  ) async {
    final payloadMap = Map<String, dynamic>.from(receivedAction.payload ?? {});
    instance._emitNotificationTap(payloadMap);
  }

  @pragma('vm:entry-point')
  static Future<void> _onDismissActionReceivedMethod(
    ReceivedAction receivedAction,
  ) async {
    // Notification dismissed callback
  }

  void dispose() {
    if (_isDisposed) return;
    _isDisposed = true;

    final onMessageSubscription = _onMessageSubscription;
    if (onMessageSubscription != null) {
      unawaited(onMessageSubscription.cancel());
    }

    final onMessageOpenedAppSubscription = _onMessageOpenedAppSubscription;
    if (onMessageOpenedAppSubscription != null) {
      unawaited(onMessageOpenedAppSubscription.cancel());
    }

    final onTokenRefreshSubscription = _onTokenRefreshSubscription;
    if (onTokenRefreshSubscription != null) {
      unawaited(onTokenRefreshSubscription.cancel());
    }

    unawaited(_onNotificationTapController.close());
    unawaited(_onNotificationReceivedController.close());
  }
}
