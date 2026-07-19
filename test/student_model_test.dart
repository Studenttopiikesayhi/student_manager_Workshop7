// test/student_model_test.dart
// ทดสอบ logic ของ Student model (toMap / fromMap) — รันได้โดยไม่ต้องต่อ Firebase

import 'package:flutter_test/flutter_test.dart';
import 'package:student_manager/models/student.dart';

void main() {
  group('Student.toMap()', () {
    test('แปลงเป็น Map ครบทุก field และไม่รวม id', () {
      final student = Student(
        id: 'doc123',
        studentId: '65011234',
        name: 'สมชาย รักเรียน',
        major: 'Software Engineering',
        gpa: 3.85,
        imageUrl: 'https://picsum.photos/seed/65011234/200',
      );

      final map = student.toMap();

      expect(map['studentId'], '65011234');
      expect(map['name'], 'สมชาย รักเรียน');
      expect(map['major'], 'Software Engineering');
      expect(map['gpa'], 3.85);
      expect(map['imageUrl'], 'https://picsum.photos/seed/65011234/200');
      expect(map.containsKey('id'), false);
    });
  });

  group('Student.fromMap()', () {
    test('สร้าง Student จาก Map ได้ครบถ้วน', () {
      final map = {
        'studentId': '65019999',
        'name': 'สมหญิง ตั้งใจ',
        'major': 'Computer Science',
        'gpa': 3.5,
        'imageUrl': 'https://picsum.photos/seed/65019999/200',
      };

      final student = Student.fromMap('docABC', map);

      expect(student.id, 'docABC');
      expect(student.studentId, '65019999');
      expect(student.name, 'สมหญิง ตั้งใจ');
      expect(student.major, 'Computer Science');
      expect(student.gpa, 3.5);
      expect(student.imageUrl, 'https://picsum.photos/seed/65019999/200');
    });

    test('ใส่ค่า default เมื่อ field หายไป (กัน null crash)', () {
      final student = Student.fromMap('docEmpty', {});

      expect(student.id, 'docEmpty');
      expect(student.studentId, '');
      expect(student.name, '');
      expect(student.major, '');
      expect(student.gpa, 0.0);
      expect(student.imageUrl, '');
    });

    test('แปลง gpa ที่เป็น int จาก Firestore ให้เป็น double', () {
      final map = {'gpa': 4};

      final student = Student.fromMap('docInt', map);

      expect(student.gpa, 4.0);
      expect(student.gpa, isA<double>());
    });
  });
}
