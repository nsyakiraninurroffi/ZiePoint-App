import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import '../core/app_logger.dart';

class ConnectivityService {
  static final ConnectivityService _instance = ConnectivityService._internal();
  factory ConnectivityService() => _instance;
  
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<List<ConnectivityResult>> _subscription;
  
  // ValueNotifier so widgets can easily listen to it
  final ValueNotifier<bool> isConnected = ValueNotifier<bool>(true);

  ConnectivityService._internal() {
    _initConnectivity();
    _subscription = _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
  }

  Future<void> _initConnectivity() async {
    try {
      final results = await _connectivity.checkConnectivity();
      _updateConnectionStatus(results);
    } catch (e) {
      AppLogger.e('Could not check connectivity status', e);
      isConnected.value = true; // Fallback to true
    }
  }

  void _updateConnectionStatus(List<ConnectivityResult> results) {
    bool hasConnection = !results.contains(ConnectivityResult.none);
    // If results is empty, assume no connection
    if (results.isEmpty) {
      hasConnection = false;
    }
    
    // Only update and notify if there's an actual change
    if (isConnected.value != hasConnection) {
      isConnected.value = hasConnection;
      AppLogger.d('Network connectivity changed: ${hasConnection ? "Connected" : "Disconnected"}');
    }
  }

  void dispose() {
    _subscription.cancel();
    isConnected.dispose();
  }
}
