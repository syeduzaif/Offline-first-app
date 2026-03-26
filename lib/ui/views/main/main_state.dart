import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:offline_first_app/core/di/providers.dart';
import 'package:offline_first_app/data/local/database.dart';

@immutable
class MainState {
  const MainState({
    this.currentIndex = 0,
    this.pendingSyncCount = 0,
  });

  final int currentIndex;
  final int pendingSyncCount;

  MainState copyWith({
    int? currentIndex,
    int? pendingSyncCount,
  }) {
    return MainState(
      currentIndex: currentIndex ?? this.currentIndex,
      pendingSyncCount: pendingSyncCount ?? this.pendingSyncCount,
    );
  }
}

final mainControllerProvider =
    NotifierProvider<MainController, MainState>(
  MainController.new,
);

class MainController extends Notifier<MainState> {
  late final AppDatabase _db;
  StreamSubscription<int>? _pendingCountSub;

  @override
  MainState build() {
    _db = ref.read(appDatabaseProvider);

    _pendingCountSub =
        _db.syncQueueDao.watchPendingCount().listen((c) {
      state = state.copyWith(pendingSyncCount: c);
    });

    ref.onDispose(() {
      _pendingCountSub?.cancel();
    });

    return const MainState();
  }

  void onTabChanged(int index) {
    state = state.copyWith(currentIndex: index);
  }
}
