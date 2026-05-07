import 'package:offline_first_app/features/lms/domain/entities/lms_class.dart';
import 'package:offline_first_app/features/lms/domain/entities/lms_classwork_item.dart';

abstract interface class ILmsRepository {
  Stream<List<LmsClass>> watchClasses();
  Stream<LmsClass?> watchClass(int id);
  Stream<List<LmsClassworkItem>> watchClassworkForClass(int classId);
  Stream<LmsClassworkItem?> watchClassworkItem(int id);
  Future<LmsClass> createClass(LmsClass lmsClass);
  Future<LmsClassworkItem> updateClassworkItem(LmsClassworkItem item);
}
