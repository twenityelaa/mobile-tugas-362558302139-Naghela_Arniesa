import 'package:flutter/material.dart';
import '../models/krs_course.dart';
import '../widgets/krs_course_tile.dart';
import 'add_krs_screen.dart';
import 'course_detail_screen.dart';

const int batasSksSemester = 24;
const int ambangPeringatanSks = 21;

class KrsListScreen extends StatefulWidget {
  const KrsListScreen({super.key});

  @override
  State<KrsListScreen> createState() => _KrsListScreenState();
}

class _KrsListScreenState extends State<KrsListScreen> {
  /// Perhatikan `List<KrsCourse>.of(...)`.
  /// `getInitialCourses()` mengembalikan list `const`, dan list `const`
  /// TIDAK DAPAT DIUBAH. Tanpa penyalinan ini, add() dan removeWhere()
  /// akan melempar UnsupportedError saat dijalankan.
  /// tahap 5
  final List<KrsCourse> _courses =
      List<KrsCourse>.of(KrsCourse.getInitialCourses());

  int get _totalSks =>
      _courses.fold(0, (jumlah, course) => jumlah + course.sks);

  /// langkah 6
  // Tidak ada nilai yang dikembalikan.
  void _bukaDetail(KrsCourse course) {
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => CourseDetailScreen(course: course),
      ),
    );
  }

  // Menerima hasil lewat Navigator.pop.
  Future<void> _bukaFormTambah() async {
    final KrsCourse? courseBaru = await Navigator.push<KrsCourse>(
      context,
      MaterialPageRoute<KrsCourse>(builder: (_) => const AddKrsScreen()),
    );

    // Tombol kembali ditekan tanpa menyimpan.
    if (!mounted || courseBaru == null) return;

    final bool duplikat = _courses.any(
      (course) => course.code.toUpperCase() == courseBaru.code.toUpperCase(),
    );
    if (duplikat) {
      _tampilkanPesan('Kode ${courseBaru.code} sudah ada di rencana studi.');
      return;
    }

    final int totalBaru = _totalSks + courseBaru.sks;
    if (totalBaru > batasSksSemester) {
      _tampilkanPesan(
        'Total SKS akan menjadi $totalBaru, melebihi batas '
        '$batasSksSemester SKS.',
      );
      return;
    }

    setState(() => _courses.add(courseBaru));
    _tampilkanPesan('${courseBaru.name} ditambahkan ke rencana studi.');
  }

  /// langkah 7
  Future<void> _konfirmasiHapus(KrsCourse course) async {
    // Ambil warna SEBELUM await, agar tidak memakai context
    // setelah jeda asynchronous.
    final Color errorColor = Theme.of(context).colorScheme.error;

    final bool? dikonfirmasi = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Hapus mata kuliah?'),
        content: Text(
          'Yakin ingin membatalkan pengambilan "${course.name}" '
          '(${course.sks} SKS)?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: errorColor),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (!mounted || dikonfirmasi != true) return;

    setState(() => _courses.removeWhere((item) => item.code == course.code));
    _tampilkanPesan('${course.name} dihapus dari rencana studi.');
  }

    void _tampilkanPesan(String pesan) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(pesan),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final bool mendekatiBatas = _totalSks >= ambangPeringatanSks;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Rencana Studi (KRS)'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Chip(
              avatar: Icon(
                mendekatiBatas
                    ? Icons.warning_amber_rounded
                    : Icons.check_circle_outline,
                size: 18,
                color: mendekatiBatas ? colors.error : colors.primary,
              ),
              label: Text('$_totalSks / $batasSksSemester SKS'),
            ),
          ),
        ],
      ),
      body: _courses.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.menu_book_outlined,
                        size: 64, color: colors.outline),
                    const SizedBox(height: 16),
                    Text(
                      'Belum ada mata kuliah',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tekan tombol Tambah untuk menyusun rencana studimu.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: colors.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
            )
          : ListView.builder(
              // padding bawah ekstra agar kartu terakhir tidak tertutup tombol
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 88),
              itemCount: _courses.length,
              itemBuilder: (context, index) {
                final KrsCourse course = _courses[index];
                return KrsCourseTile(
                  course: course,
                  onTap: () => _bukaDetail(course),
                  onDelete: () => _konfirmasiHapus(course),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _bukaFormTambah,
        icon: const Icon(Icons.add),
        label: const Text('Tambah'),
      ),
    );
  }
}