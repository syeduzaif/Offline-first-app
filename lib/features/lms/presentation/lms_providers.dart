import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:offline_first_app/core/providers/providers.dart';
import 'package:offline_first_app/core/services/database.dart';
import 'package:offline_first_app/features/lms/data/repositories/lms_repository.dart';
import 'package:offline_first_app/features/lms/domain/entities/lms_class.dart';
import 'package:offline_first_app/features/lms/domain/entities/lms_classwork_item.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'lms_providers.g.dart';

@Riverpod(keepAlive: true)
LmsClassesDao lmsClassesDao(Ref ref) =>
    ref.watch(appDatabaseProvider).lmsClassesDao;

@Riverpod(keepAlive: true)
LmsClassworkItemsDao lmsClassworkItemsDao(Ref ref) =>
    ref.watch(appDatabaseProvider).lmsClassworkItemsDao;

@Riverpod(keepAlive: true)
LmsRepository lmsRepository(Ref ref) => LmsRepository(
      lmsClassesDao: ref.watch(lmsClassesDaoProvider),
      lmsClassworkItemsDao: ref.watch(lmsClassworkItemsDaoProvider),
      syncQueueDao: ref.watch(appDatabaseProvider).syncQueueDao,
    );

@riverpod
Stream<List<LmsClass>> lmsClassesStream(Ref ref) =>
    ref.watch(lmsRepositoryProvider).watchClasses();

@riverpod
Stream<LmsClass?> lmsClassDetail(Ref ref, int classId) =>
    ref.watch(lmsRepositoryProvider).watchClass(classId);

@riverpod
Stream<List<LmsClassworkItem>> lmsClassworkForClass(Ref ref, int classId) =>
    ref.watch(lmsRepositoryProvider).watchClassworkForClass(classId);

@riverpod
Stream<LmsClassworkItem?> lmsClassworkItemDetail(Ref ref, int itemId) =>
    ref.watch(lmsRepositoryProvider).watchClassworkItem(itemId);
