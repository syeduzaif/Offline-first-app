import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:offline_first_app/core/providers/providers.dart';
import 'package:offline_first_app/core/services/database.dart';
import 'package:offline_first_app/features/timetable/data/repositories/timetable_repository.dart';
import 'package:offline_first_app/features/timetable/domain/entities/timetable_entry.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'timetable_providers.g.dart';

@Riverpod(keepAlive: true)
TimetableEntriesDao timetableEntriesDao(Ref ref) =>
    ref.watch(appDatabaseProvider).timetableEntriesDao;

@Riverpod(keepAlive: true)
TimetableRepository timetableRepository(Ref ref) => TimetableRepository(
      timetableEntriesDao: ref.watch(timetableEntriesDaoProvider),
      syncQueueDao: ref.watch(appDatabaseProvider).syncQueueDao,
    );

@riverpod
Stream<List<TimetableEntry>> timetableForDay(Ref ref, String day) =>
    ref.watch(timetableRepositoryProvider).watchEntriesForDay(day);

// Currently selected day tab
final timetableSelectedDayProvider = StateProvider<String>((ref) {
  // Default to today's day abbreviation
  const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri'];
  final weekday = DateTime.now().weekday; // 1=Mon, 5=Fri, 6/7=weekend
  if (weekday >= 1 && weekday <= 5) return days[weekday - 1];
  return 'Mon';
});
