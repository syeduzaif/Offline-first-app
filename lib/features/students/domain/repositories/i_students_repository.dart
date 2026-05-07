import 'package:offline_first_app/features/students/domain/entities/student.dart';

abstract interface class IStudentsRepository {
  Stream<List<Student>> watchStudents();
  Stream<Student?> watchStudent(int id);
  Future<Student> createStudent(Student student);
  Future<Student> updateStudent(Student student);
  Future<void> deleteStudent(int id);
}
