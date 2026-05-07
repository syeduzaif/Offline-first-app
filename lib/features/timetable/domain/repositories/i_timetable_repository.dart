import 'package:offline_first_app/features/timetable/domain/entities/timetable_entry.dart';

abstract interface class ITimetableRepository {
  Stream<List<TimetableEntry>> watchAll();
  Stream<List<TimetableEntry>> watchEntriesForDay(String day);
  Future<TimetableEntry> createEntry(TimetableEntry entry);
  Future<void> deleteEntry(int id);
}
