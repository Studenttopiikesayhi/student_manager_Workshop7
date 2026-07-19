// lib/services/student_service.dart
// ชั้นบริการ (Service Layer) แยก logic การคุย Firestore ออกจาก UI

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/student.dart';

class StudentService {
  final CollectionReference<Map<String, dynamic>> _collection =
      FirebaseFirestore.instance.collection('students');

  Stream<List<Student>> getStudents() {
    return _collection
        .orderBy('studentId')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Student.fromMap(doc.id, doc.data()))
            .toList());
  }

  Future<void> addStudent(Student student) {
    return _collection.add(student.toMap());
  }

  Future<void> updateStudent(Student student) {
    return _collection.doc(student.id).update(student.toMap());
  }

  Future<void> deleteStudent(String id) {
    return _collection.doc(id).delete();
  }
}
