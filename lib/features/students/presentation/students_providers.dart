import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:offline_first_app/core/providers/providers.dart';
import 'package:offline_first_app/core/services/database.dart';
import 'package:offline_first_app/features/students/data/repositories/students_repository.dart';
import 'package:offline_first_app/features/students/domain/entities/student.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'students_providers.g.dart';

@Riverpod(keepAlive: true)
StudentsDao studentsDao(Ref ref) => ref.watch(appDatabaseProvider).studentsDao;

@Riverpod(keepAlive: true)
StudentsRepository studentsRepository(Ref ref) => StudentsRepository(
      studentsDao: ref.watch(studentsDaoProvider),
      syncQueueDao: ref.watch(appDatabaseProvider).syncQueueDao,
    );

@riverpod
Stream<List<Student>> studentsStream(Ref ref) =>
    ref.watch(studentsRepositoryProvider).watchStudents();

@riverpod
Stream<Student?> studentDetail(Ref ref, int studentId) =>
    ref.watch(studentsRepositoryProvider).watchStudent(studentId);
