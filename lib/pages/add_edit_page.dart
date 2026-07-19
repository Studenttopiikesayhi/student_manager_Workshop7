// lib/pages/add_edit_page.dart
// หน้าเพิ่ม/แก้ไขข้อมูลนักศึกษา (ใช้ฟอร์มเดียวกัน แยกด้วย widget.student == null)

import 'package:flutter/material.dart';
import '../models/student.dart';
import '../services/student_service.dart';

class AddEditPage extends StatefulWidget {
  final Student? student;

  const AddEditPage({super.key, this.student});

  @override
  State<AddEditPage> createState() => _AddEditPageState();
}

class _AddEditPageState extends State<AddEditPage> {
  final _formKey = GlobalKey<FormState>();
  final _service = StudentService();

  late final TextEditingController _studentIdController;
  late final TextEditingController _nameController;
  late final TextEditingController _majorController;
  late final TextEditingController _gpaController;

  bool _isSaving = false;

  bool get _isEditMode => widget.student != null;

  @override
  void initState() {
    super.initState();
    final s = widget.student;
    _studentIdController = TextEditingController(text: s?.studentId ?? '');
    _nameController = TextEditingController(text: s?.name ?? '');
    _majorController = TextEditingController(text: s?.major ?? '');
    _gpaController =
        TextEditingController(text: s != null ? s.gpa.toString() : '');
  }

  @override
  void dispose() {
    _studentIdController.dispose();
    _nameController.dispose();
    _majorController.dispose();
    _gpaController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final studentId = _studentIdController.text.trim();
    final gpa = double.parse(_gpaController.text.trim());

    final imageUrl = 'https://picsum.photos/seed/$studentId/200';

    final student = Student(
      id: widget.student?.id ?? '',
      studentId: studentId,
      name: _nameController.text.trim(),
      major: _majorController.text.trim(),
      gpa: gpa,
      imageUrl: imageUrl,
    );

    try {
      if (_isEditMode) {
        await _service.updateStudent(student);
      } else {
        await _service.addStudent(student);
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isEditMode ? 'แก้ไขข้อมูลแล้ว' : 'เพิ่มข้อมูลแล้ว'),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('บันทึกไม่สำเร็จ: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? 'แก้ไขข้อมูลนักศึกษา' : 'เพิ่มนักศึกษา'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _studentIdController,
                decoration: const InputDecoration(
                  labelText: 'รหัสนักศึกษา',
                  hintText: 'เช่น 65011234',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'กรุณากรอกรหัสนักศึกษา';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'ชื่อ-นามสกุล',
                  hintText: 'เช่น สมชาย รักเรียน',
                  border: OutlineInputBorder(),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'กรุณากรอกชื่อ-นามสกุล';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _majorController,
                decoration: const InputDecoration(
                  labelText: 'สาขาวิชา',
                  hintText: 'เช่น Software Engineering',
                  border: OutlineInputBorder(),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'กรุณากรอกสาขาวิชา';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _gpaController,
                decoration: const InputDecoration(
                  labelText: 'เกรดเฉลี่ย (GPA)',
                  hintText: 'เช่น 3.85',
                  border: OutlineInputBorder(),
                ),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'กรุณากรอกเกรดเฉลี่ย';
                  }
                  final gpa = double.tryParse(v.trim());
                  if (gpa == null) {
                    return 'กรุณากรอกเป็นตัวเลข เช่น 3.85';
                  }
                  if (gpa < 0 || gpa > 4) {
                    return 'GPA ต้องอยู่ระหว่าง 0.00 - 4.00';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: _isSaving ? null : _save,
                icon: _isSaving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.save),
                label: Text(_isSaving ? 'กำลังบันทึก...' : 'บันทึก'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
