// lib/pages/student_list_page.dart
// หน้าหลัก: แสดงรายชื่อนักศึกษาแบบเรียลไทม์ด้วย StreamBuilder

import 'package:flutter/material.dart';
import '../models/student.dart';
import '../services/student_service.dart';
import 'add_edit_page.dart';

class StudentListPage extends StatelessWidget {
  const StudentListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final StudentService service = StudentService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('รายชื่อนักศึกษา'),
        centerTitle: true,
      ),
      body: StreamBuilder<List<Student>>(
        stream: service.getStudents(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text('เกิดข้อผิดพลาด: ${snapshot.error}'),
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final students = snapshot.data ?? [];

          if (students.isEmpty) {
            return const Center(
              child: Text(
                'ยังไม่มีข้อมูลนักศึกษา\nกดปุ่ม + เพื่อเพิ่ม',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: students.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final student = students[index];
              return _StudentTile(
                student: student,
                onEdit: () => _goToEdit(context, student),
                onDelete: () => _confirmDelete(context, service, student),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AddEditPage()),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _goToEdit(BuildContext context, Student student) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => AddEditPage(student: student)),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    StudentService service,
    Student student,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('ยืนยันการลบ'),
        content: Text('ต้องการลบ "${student.name}" ใช่หรือไม่?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('ยกเลิก'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('ลบ'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await service.deleteStudent(student.id);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('ลบ "${student.name}" แล้ว')),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('ลบไม่สำเร็จ: $e')),
          );
        }
      }
    }
  }
}

class _StudentTile extends StatelessWidget {
  final Student student;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _StudentTile({
    required this.student,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        radius: 26,
        backgroundColor: Colors.grey.shade200,
        backgroundImage:
            student.imageUrl.isNotEmpty ? NetworkImage(student.imageUrl) : null,
        child: student.imageUrl.isEmpty
            ? const Icon(Icons.person, color: Colors.grey)
            : null,
      ),
      title: Text(
        student.name,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Text('${student.studentId} • ${student.major}'),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'GPA ${student.gpa.toStringAsFixed(2)}',
              style: TextStyle(
                color: Colors.blue.shade700,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            onPressed: onDelete,
            tooltip: 'ลบ',
          ),
        ],
      ),
      onTap: onEdit,
    );
  }
}
