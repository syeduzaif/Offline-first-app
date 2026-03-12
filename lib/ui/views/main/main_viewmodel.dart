import 'dart:async';

import 'package:offline_first_app/app/app.locator.dart';
import 'package:offline_first_app/data/local/database.dart';
import 'package:offline_first_app/services/sync_service.dart';
import 'package:stacked/stacked.dart';

class MainViewModel extends ReactiveViewModel {
  final _syncService = locator<SyncService>();
  final _db = locator<AppDatabase>();

  int _currentIndex = 0;
  int get currentIndex => _currentIndex;

  int _pendingSyncCount = 0;
  int get pendingSyncCount => _pendingSyncCount;

  StreamSubscription<int>? _pendingCountSub;

  void initialize() {
    _pendingCountSub =
        _db.syncQueueDao.watchPendingCount().listen((c) {
      _pendingSyncCount = c;
      notifyListeners();
    });
  }

  void onTabChanged(int index) {
    _currentIndex = index;
    notifyListeners();
  }

  @override
  List<ListenableServiceMixin> get listenableServices =>
      [_syncService];

  @override
  void dispose() {
    _pendingCountSub?.cancel();
    super.dispose();
  }
}
