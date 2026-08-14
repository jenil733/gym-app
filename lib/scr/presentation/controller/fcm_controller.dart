import 'dart:async';
import 'dart:math';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:gym/scr/core/services/local_storage.dart';
import 'package:gym/scr/core/services/local_notification_service.dart';
import 'package:gym/scr/domain/usecase/fcm_usecase.dart';

class FcmController extends GetxController with WidgetsBindingObserver {
  FcmController(this._useCase, this._storage, [FirebaseMessaging? messaging])
    : _messaging = messaging ?? FirebaseMessaging.instance;

  static const String storageKey = 'fcm_token';
  static const String accountPhoneStorageKey = 'fcm_account_phone';
  static const String installationIdStorageKey = 'device_installation_id';

  final FcmUseCase _useCase;
  final LocalStorageService _storage;
  final FirebaseMessaging _messaging;

  final RxnString token = RxnString();
  final RxBool isSyncing = false.obs;
  final RxBool isTokenSynced = false.obs;
  final RxnString syncError = RxnString();
  StreamSubscription<String>? _tokenRefreshSubscription;
  StreamSubscription<RemoteMessage>? _foregroundMessageSubscription;
  String? _phoneNumber;
  String? _installationId;
  bool _isInitializing = false;
  Timer? _syncRetryTimer;

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    unawaited(initialize());
  }

  Future<void> initialize() async {
    if (_isInitializing) {
      return;
    }
    _isInitializing = true;
    try {
      await _storage.init();
      token.value = _storage.getString(storageKey);
      _phoneNumber = _storage.getString(accountPhoneStorageKey)?.trim();
      _installationId = await _resolveInstallationId();

      await _messaging.setAutoInitEnabled(true);
      await _messaging.requestPermission(alert: true, badge: true, sound: true);
      await _messaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );
      final generatedToken = await _messaging.getToken();
      if (generatedToken != null && generatedToken.trim().isNotEmpty) {
        await _storeAndSync(generatedToken);
      }

      await _tokenRefreshSubscription?.cancel();
      _tokenRefreshSubscription = _messaging.onTokenRefresh.listen(
        (refreshedToken) => unawaited(_storeAndSync(refreshedToken)),
        onError: (Object error, StackTrace stackTrace) {
          debugPrint('Unable to refresh FCM token: $error');
        },
      );
      await _foregroundMessageSubscription?.cancel();
      _foregroundMessageSubscription = FirebaseMessaging.onMessage.listen(
        _showForegroundMessage,
      );
    } catch (error) {
      debugPrint('Unable to initialize FCM: $error');
    } finally {
      _isInitializing = false;
    }
  }

  Future<bool> syncToken({String? phoneNumber}) async {
    await _storage.init();
    final normalizedPhone = phoneNumber?.trim();
    if (normalizedPhone != null && normalizedPhone.isNotEmpty) {
      _phoneNumber = normalizedPhone;
      await _storage.saveString(accountPhoneStorageKey, normalizedPhone);
    }
    var currentToken =
        token.value?.trim() ?? _storage.getString(storageKey)?.trim();
    if (currentToken == null || currentToken.isEmpty) {
      currentToken = await _getTokenWithRetry();
      if (currentToken != null && currentToken.isNotEmpty) {
        token.value = currentToken;
        await _storage.saveString(storageKey, currentToken);
      }
    }
    final authToken = _storage.getString('auth_token')?.trim();
    if (currentToken == null ||
        currentToken.isEmpty ||
        authToken == null ||
        authToken.isEmpty) {
      if (authToken != null && authToken.isNotEmpty) {
        syncError.value = 'This device has not received an FCM token yet.';
        _scheduleSyncRetry();
      }
      return false;
    }
    if (isSyncing.value) {
      _scheduleSyncRetry();
      return false;
    }

    isSyncing.value = true;
    syncError.value = null;
    try {
      final response = await _useCase(
        token: currentToken,
        phoneNumber: _phoneNumber,
        deviceId: _installationId ?? await _resolveInstallationId(),
      );
      final succeeded =
          response.success == true ||
          response.code == 200 ||
          response.code == 201;
      isTokenSynced.value = succeeded;
      if (!succeeded) {
        syncError.value =
            response.message ?? 'The server did not accept this device token.';
        _scheduleSyncRetry();
      }
      return succeeded;
    } catch (error) {
      debugPrint('Unable to sync FCM token: $error');
      isTokenSynced.value = false;
      syncError.value = 'Unable to upload this device token.';
      _scheduleSyncRetry();
      return false;
    } finally {
      isSyncing.value = false;
    }
  }

  Future<String?> _getTokenWithRetry() async {
    for (var attempt = 0; attempt < 3; attempt += 1) {
      try {
        final generatedToken = await _messaging.getToken();
        if (generatedToken != null && generatedToken.trim().isNotEmpty) {
          return generatedToken.trim();
        }
      } catch (error) {
        debugPrint('FCM token attempt ${attempt + 1} failed: $error');
      }
      if (attempt < 2) {
        await Future<void>.delayed(Duration(seconds: attempt + 1));
      }
    }
    return null;
  }

  void _scheduleSyncRetry() {
    _syncRetryTimer?.cancel();
    _syncRetryTimer = Timer(const Duration(seconds: 10), () {
      unawaited(syncToken());
    });
  }

  Future<void> _storeAndSync(String value) async {
    final normalizedToken = value.trim();
    if (normalizedToken.isEmpty) {
      return;
    }

    try {
      token.value = normalizedToken;
      await _storage.saveString(storageKey, normalizedToken);
      await syncToken();
    } catch (error) {
      debugPrint('Unable to store FCM token: $error');
    }
  }

  Future<String> _resolveInstallationId() async {
    final saved = _storage.getString(installationIdStorageKey)?.trim();
    if (saved != null && saved.isNotEmpty) {
      return saved;
    }
    final random = Random.secure();
    final generated =
        '${DateTime.now().microsecondsSinceEpoch.toRadixString(36)}-'
        '${random.nextInt(1 << 32).toRadixString(36)}';
    await _storage.saveString(installationIdStorageKey, generated);
    return generated;
  }

  void _showForegroundMessage(RemoteMessage message) {
    unawaited(LocalNotificationService.showRemoteMessage(message));
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(initialize());
    }
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    _tokenRefreshSubscription?.cancel();
    _foregroundMessageSubscription?.cancel();
    _syncRetryTimer?.cancel();
    super.onClose();
  }
}
