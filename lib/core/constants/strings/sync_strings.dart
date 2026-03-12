class SyncStrings {
  SyncStrings._();

  static const String titleSyncQueue = 'Sync Queue';
  static const String statusSynced = 'Synced';
  static const String statusPending = 'Pending';
  static const String statusFailed = 'Failed';
  static const String statusInProgress = 'In Progress';
  static const String operationCreate = 'Create';
  static const String operationUpdate = 'Update';
  static const String operationDelete = 'Delete';
  static const String noOperations = 'No pending operations';
  static const String syncNow = 'Sync Now';
  static const String clearCompleted = 'Clear Completed';
  static const String syncComplete = 'Sync complete';
  static const String syncFailed = 'Sync failed — will retry';

  static String retryCount(int count) => 'Retry $count/3';
  static String pendingCount(int count) =>
      '$count pending ${count == 1 ? 'operation' : 'operations'}';
}
