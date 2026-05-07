import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:offline_first_app/core/services/connectivity_service.dart';
import 'package:offline_first_app/core/services/database.dart';

class SyncEngine extends ChangeNotifier {
  SyncEngine({
    required this.database,
    required this.connectivityService,
  });

  final AppDatabase database;
  final ConnectivityService connectivityService;

  bool _isSyncing = false;
  bool get isSyncing => _isSyncing;

  StreamSubscription<bool>? _connectivitySub;

  void initialize() {
    _connectivitySub = connectivityService.onConnectivityChanged.listen((online) {
      if (online) syncAll();
    });
  }

  Future<void> syncAll() async {
    if (_isSyncing || !connectivityService.isOnline) return;
    _isSyncing = true;
    notifyListeners();

    try {
      // Recover any ops stuck in inProgress from a previous crash
      await database.syncQueueDao.resetInProgressToPending();

      final operations = await database.syncQueueDao.getPendingOperations();
      for (final op in operations) {
        await _processOperation(op);
      }

      // Clean up completed ops to keep the queue lean
      await database.syncQueueDao.clearCompleted();
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
  }

  Future<void> _processOperation(SyncQueueEntry op) async {
    await database.syncQueueDao.markInProgress(op.id);

    try {
      final payload = (jsonDecode(op.payload) as Map?)?.cast<String, dynamic>() ?? {};

      switch (op.entityType) {
        case 'student':
          await _syncStudent(op, payload);
        case 'attendance':
          await _syncAttendance(op, payload);
        case 'timetable':
          await _syncTimetable(op, payload);
        case 'lmsClass':
          await _syncLmsClass(op, payload);
        case 'classwork':
          await _syncClassworkItem(op, payload);
        default:
          debugPrint('[SyncEngine] Unknown entityType: ${op.entityType}');
      }

      await database.syncQueueDao.markCompleted(op.id);
    } catch (e) {
      final backoffDelay =
          Duration(seconds: pow(2, op.retryCount).toInt().clamp(1, 64));
      debugPrint('[SyncEngine] Operation ${op.id} failed (retry ${op.retryCount}): $e');
      debugPrint('[SyncEngine] Back-off: ${backoffDelay.inSeconds}s');

      await database.syncQueueDao.markFailed(op.id, e.toString());
    }
  }

  // ─── Placeholder sync handlers (Phase 3: replace with real API calls) ────────

  Future<void> _syncStudent(SyncQueueEntry op, Map<String, dynamic> payload) async {
    debugPrint('[SyncEngine] student ${op.operation}: ${payload['name']}');
    // TODO(Phase 3): await apiClient.students.${op.operation}(payload);
  }

  Future<void> _syncAttendance(SyncQueueEntry op, Map<String, dynamic> payload) async {
    debugPrint('[SyncEngine] attendance ${op.operation}: studentId=${payload['studentId']}');
    // TODO(Phase 3): await apiClient.attendance.${op.operation}(payload);
  }

  Future<void> _syncTimetable(SyncQueueEntry op, Map<String, dynamic> payload) async {
    debugPrint('[SyncEngine] timetable ${op.operation}: ${payload['subject']}');
    // TODO(Phase 3): await apiClient.timetable.${op.operation}(payload);
  }

  Future<void> _syncLmsClass(SyncQueueEntry op, Map<String, dynamic> payload) async {
    debugPrint('[SyncEngine] lmsClass ${op.operation}: ${payload['name']}');
    // TODO(Phase 3): await apiClient.lmsClasses.${op.operation}(payload);
  }

  Future<void> _syncClassworkItem(SyncQueueEntry op, Map<String, dynamic> payload) async {
    debugPrint('[SyncEngine] classwork ${op.operation}: ${payload['title']}');
    // TODO(Phase 3): await apiClient.classwork.${op.operation}(payload);
  }

  @override
  void dispose() {
    _connectivitySub?.cancel();
    super.dispose();
  }
}
