// lib/models/student.dart
// คลาสข้อมูลนักศึกษา แยกออกจาก UI เพื่อให้จัดการข้อมูลง่ายและเชื่อม Firestore ได้

class Student {
  final String id;         // document id จาก Firestore (ใช้ตอน update/delete)
  final String studentId;  // รหัสนักศึกษา เช่น "65011234"
  final String name;       // ชื่อ-นามสกุล
  final String major;      // สาขาวิชา
  final double gpa;        // เกรดเฉลี่ยสะสม (GPAX)
  final String imageUrl;   // URL รูปโปรไฟล์ (Mockup)

  Student({
    required this.id,
    required this.studentId,
    required this.name,
    required this.major,
    required this.gpa,
    required this.imageUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'studentId': studentId,
      'name': name,
      'major': major,
      'gpa': gpa,
      'imageUrl': imageUrl,
    };
  }

  factory Student.fromMap(String documentId, Map<String, dynamic> map) {
    return Student(
      id: documentId,
      studentId: map['studentId'] ?? '',
      name: map['name'] ?? '',
      major: map['major'] ?? '',
      gpa: (map['gpa'] ?? 0).toDouble(),
      imageUrl: map['imageUrl'] ?? '',
    );
  }
}
