import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:stacked/stacked.dart';

class ConnectivityService with ListenableServiceMixin {
  ConnectivityService() {
    listenToReactiveValues([_isOnline]);
  }

  final _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  final ReactiveValue<bool> _isOnline = ReactiveValue<bool>(true);
  bool get isOnline => _isOnline.value;

  final _controller = StreamController<bool>.broadcast();
  Stream<bool> get onConnectivityChanged => _controller.stream;

  Future<void> initialize() async {
    final result = await _connectivity.checkConnectivity();
    _updateStatus(result);
    _subscription =
        _connectivity.onConnectivityChanged.listen(_updateStatus);
  }

  void _updateStatus(List<ConnectivityResult> results) {
    final online =
        results.any((r) => r != ConnectivityResult.none);
    if (_isOnline.value != online) {
      _isOnline.value = online;
      _controller.add(online);
      notifyListeners();
    }
  }

  void dispose() {
    _subscription?.cancel();
    _controller.close();
  }
}
