import 'package:flutter/material.dart';
import '../models/krs_course.dart';

class AddKrsScreen extends StatefulWidget {
  const AddKrsScreen({super.key});

  @override
  State<AddKrsScreen> createState() => _AddKrsScreenState();
}

class _AddKrsScreenState extends State<AddKrsScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _lecturerController = TextEditingController();
  final TextEditingController _sksController =
      TextEditingController(text: '3');

  @override
  void dispose() {
    // Wajib: setiap controller harus dibebaskan agar tidak bocor memori.
    _codeController.dispose();
    _nameController.dispose();
    _lecturerController.dispose();
    _sksController.dispose();
    super.dispose();
  }

  void _simpan() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final KrsCourse courseBaru = KrsCourse(
      code: _codeController.text.trim().toUpperCase(),
      name: _nameController.text.trim(),
      lecturer: _lecturerController.text.trim(),
      sks: int.tryParse(_sksController.text.trim()) ?? 3,
    );

    Navigator.pop(context, courseBaru);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tambah Mata Kuliah')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey, // tanpa key ini validate() tidak akan berfungsi
          child: Column(
            children: [
              TextFormField(
                controller: _codeController,
                textInputAction: TextInputAction.next,
                textCapitalization: TextCapitalization.characters,
                decoration: const InputDecoration(
                  labelText: 'Kode mata kuliah',
                  hintText: 'Contoh: TRPL505',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  final String teks = value?.trim() ?? '';
                  if (teks.isEmpty) return 'Kode mata kuliah wajib diisi';
                  if (teks.length < 4) {
                    return 'Kode minimal terdiri dari 4 karakter';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Nama mata kuliah',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  final String teks = value?.trim() ?? '';
                  if (teks.isEmpty) return 'Nama mata kuliah wajib diisi';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _lecturerController,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Dosen pengampu',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  final String teks = value?.trim() ?? '';
                  if (teks.isEmpty) return 'Nama dosen wajib diisi';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _sksController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Bobot SKS',
                  helperText: 'Isi dengan angka 1 sampai 6',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  final int? sks = int.tryParse(value?.trim() ?? '');
                  if (sks == null) return 'SKS harus berupa angka';
                  if (sks < 1 || sks > 6) return 'SKS harus antara 1 dan 6';
                  return null;
                },
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _simpan,
                  icon: const Icon(Icons.save_outlined),
                  label: const Text('Simpan'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}