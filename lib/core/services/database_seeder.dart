import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:offline_first_app/core/services/database.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Seeds the local database with mock data on first launch.
/// Guarded by a SharedPreferences flag so it only runs once.
class DatabaseSeeder {
  DatabaseSeeder._();

  static const _seededKey = 'db_seeded_v1';

  static Future<void> seed(AppDatabase db) async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool(_seededKey) == true) return;

    await db.transaction(() async {
      await _seedStudents(db);
      await _seedLmsClasses(db);
      await _seedClassworkItems(db);
      await _seedTimetable(db);
      await _seedAttendance(db);
    });

    await prefs.setBool(_seededKey, true);
    debugPrint('[DatabaseSeeder] Mock data seeded successfully.');
  }

  static Future<void> _seedStudents(AppDatabase db) async {
    final rows = [
      StudentsCompanion.insert(
        name: 'Ahmed Khan',
        email: const Value('ahmed.khan@school.edu'),
        phone: const Value('+92 300 1234567'),
        grade: const Value('10'),
        section: const Value('A'),
        branch: const Value('Main Campus'),
      ),
      StudentsCompanion.insert(
        name: 'Fatima Ali',
        email: const Value('fatima.ali@school.edu'),
        phone: const Value('+92 301 2345678'),
        grade: const Value('10'),
        section: const Value('A'),
        branch: const Value('Main Campus'),
      ),
      StudentsCompanion.insert(
        name: 'Usman Tariq',
        email: const Value('usman.tariq@school.edu'),
        phone: const Value('+92 302 3456789'),
        grade: const Value('10'),
        section: const Value('B'),
        branch: const Value('Main Campus'),
      ),
      StudentsCompanion.insert(
        name: 'Ayesha Siddiqui',
        email: const Value('ayesha.s@school.edu'),
        phone: const Value('+92 303 4567890'),
        grade: const Value('11'),
        section: const Value('A'),
        branch: const Value('North Branch'),
      ),
      StudentsCompanion.insert(
        name: 'Bilal Hussain',
        email: const Value('bilal.h@school.edu'),
        phone: const Value('+92 304 5678901'),
        grade: const Value('11'),
        section: const Value('B'),
        branch: const Value('North Branch'),
      ),
    ];
    for (final row in rows) {
      await db.studentsDao.upsert(row);
    }
  }

  static Future<void> _seedLmsClasses(AppDatabase db) async {
    final rows = [
      LmsClassesCompanion.insert(
        name: 'Mathematics 10-A',
        campus: const Value('Main Campus'),
        grade: const Value('10'),
        section: const Value('A'),
        subject: const Value('Mathematics'),
        teacherName: const Value('Sir Ahmed'),
        studentCount: const Value(28),
      ),
      LmsClassesCompanion.insert(
        name: 'Physics 10-B',
        campus: const Value('Main Campus'),
        grade: const Value('10'),
        section: const Value('B'),
        subject: const Value('Physics'),
        teacherName: const Value('Sir Ahmed'),
        studentCount: const Value(25),
      ),
      LmsClassesCompanion.insert(
        name: 'Chemistry 11-A',
        campus: const Value('North Branch'),
        grade: const Value('11'),
        section: const Value('A'),
        subject: const Value('Chemistry'),
        teacherName: const Value('Sir Ahmed'),
        studentCount: const Value(30),
      ),
    ];
    for (final row in rows) {
      await db.lmsClassesDao.upsert(row);
    }
  }

  static Future<void> _seedClassworkItems(AppDatabase db) async {
    final rows = [
      LmsClassworkItemsCompanion.insert(
        classId: 1,
        title: 'Chapter 3 Exercises',
        type: 'assignment',
        topic: const Value('Algebra'),
        status: const Value('pending'),
        totalPoints: const Value(100),
        submittedCount: const Value(18),
        gradedCount: const Value(12),
        totalCount: const Value(28),
        dueDate: Value(DateTime.now().add(const Duration(days: 2)).toIso8601String()),
      ),
      LmsClassworkItemsCompanion.insert(
        classId: 1,
        title: 'Quadratic Equations Notes',
        type: 'material',
        topic: const Value('Algebra'),
        status: const Value('published'),
        totalCount: const Value(28),
      ),
      LmsClassworkItemsCompanion.insert(
        classId: 1,
        title: 'Mid-Term Practice Paper',
        type: 'assignment',
        topic: const Value('Revision'),
        status: const Value('pending'),
        totalPoints: const Value(50),
        submittedCount: const Value(5),
        totalCount: const Value(28),
        dueDate: Value(DateTime.now().add(const Duration(days: 7)).toIso8601String()),
      ),
      LmsClassworkItemsCompanion.insert(
        classId: 2,
        title: "Newton's Laws Lab Report",
        type: 'assignment',
        topic: const Value('Mechanics'),
        status: const Value('pending'),
        totalPoints: const Value(75),
        submittedCount: const Value(20),
        gradedCount: const Value(15),
        totalCount: const Value(25),
        dueDate: Value(DateTime.now().add(const Duration(days: 3)).toIso8601String()),
      ),
      LmsClassworkItemsCompanion.insert(
        classId: 2,
        title: 'Optics Lecture Slides',
        type: 'material',
        topic: const Value('Light'),
        status: const Value('published'),
        totalCount: const Value(25),
      ),
      LmsClassworkItemsCompanion.insert(
        classId: 3,
        title: 'Periodic Table Quiz',
        type: 'assignment',
        topic: const Value('Elements'),
        status: const Value('pending'),
        totalPoints: const Value(25),
        submittedCount: const Value(28),
        gradedCount: const Value(28),
        totalCount: const Value(30),
        dueDate: Value(DateTime.now().subtract(const Duration(days: 1)).toIso8601String()),
      ),
    ];
    for (final row in rows) {
      await db.lmsClassworkItemsDao.upsert(row);
    }
  }

  static Future<void> _seedTimetable(AppDatabase db) async {
    final rows = [
      TimetableEntriesCompanion.insert(
        className: 'Mathematics 10-A',
        subject: 'Mathematics',
        teacherName: 'Sir Ahmed',
        day: 'Mon',
        type: 'lesson',
        startTime: const Value('08:00'),
        endTime: const Value('09:00'),
        room: const Value('Room 101'),
        campus: const Value('Main Campus'),
      ),
      TimetableEntriesCompanion.insert(
        className: 'Physics 10-B',
        subject: 'Physics',
        teacherName: 'Sir Ahmed',
        day: 'Mon',
        type: 'lesson',
        startTime: const Value('09:30'),
        endTime: const Value('10:30'),
        room: const Value('Lab A'),
        campus: const Value('Main Campus'),
      ),
      TimetableEntriesCompanion.insert(
        className: 'Chemistry 11-A',
        subject: 'Chemistry',
        teacherName: 'Sir Ahmed',
        day: 'Tue',
        type: 'lesson',
        startTime: const Value('08:00'),
        endTime: const Value('09:00'),
        room: const Value('Lab B'),
        campus: const Value('North Branch'),
      ),
      TimetableEntriesCompanion.insert(
        className: 'Mathematics 10-A',
        subject: 'Mathematics',
        teacherName: 'Sir Ahmed',
        day: 'Tue',
        type: 'lesson',
        startTime: const Value('10:00'),
        endTime: const Value('11:00'),
        room: const Value('Room 101'),
        campus: const Value('Main Campus'),
      ),
      TimetableEntriesCompanion.insert(
        className: 'Physics 10-B',
        subject: 'Physics',
        teacherName: 'Sir Ahmed',
        day: 'Wed',
        type: 'lesson',
        startTime: const Value('08:30'),
        endTime: const Value('09:30'),
        room: const Value('Lab A'),
        campus: const Value('Main Campus'),
      ),
      TimetableEntriesCompanion.insert(
        className: 'Chemistry 11-A',
        subject: 'Chemistry',
        teacherName: 'Sir Ahmed',
        day: 'Thu',
        type: 'lesson',
        startTime: const Value('09:00'),
        endTime: const Value('10:00'),
        room: const Value('Lab B'),
        campus: const Value('North Branch'),
      ),
      TimetableEntriesCompanion.insert(
        className: 'Mathematics 10-A',
        subject: 'Mathematics',
        teacherName: 'Sir Ahmed',
        day: 'Fri',
        type: 'lesson',
        startTime: const Value('08:00'),
        endTime: const Value('09:00'),
        room: const Value('Room 101'),
        campus: const Value('Main Campus'),
      ),
    ];
    for (final row in rows) {
      await db.timetableEntriesDao.upsert(row);
    }
  }

  static Future<void> _seedAttendance(AppDatabase db) async {
    final today = DateTime.now();
    final dateStr =
        '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

    final rows = [
      AttendanceRecordsCompanion.insert(
        studentId: 1,
        classId: 1,
        date: dateStr,
        status: 'present',
      ),
      AttendanceRecordsCompanion.insert(
        studentId: 2,
        classId: 1,
        date: dateStr,
        status: 'present',
      ),
      AttendanceRecordsCompanion.insert(
        studentId: 3,
        classId: 1,
        date: dateStr,
        status: 'absent',
      ),
    ];
    for (final row in rows) {
      await db.attendanceRecordsDao.upsert(row);
    }
  }
}
