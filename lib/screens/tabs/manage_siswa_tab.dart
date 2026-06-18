import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../../core/theme.dart';
import '../../viewmodels/manage_siswa_viewmodel.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/crud_bottom_sheet.dart';
import '../../widgets/confirm_dialog.dart';
import '../../widgets/glass_snackbar.dart';

class ManageSiswaTab extends StatefulWidget {
  const ManageSiswaTab({super.key});

  @override
  State<ManageSiswaTab> createState() => _ManageSiswaTabState();
}

class _ManageSiswaTabState extends State<ManageSiswaTab> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _nisController = TextEditingController();
  final _kelasController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ManageSiswaViewModel>().loadSiswa();
    });
  }

  @override
  void dispose() {
    _namaController.dispose();
    _nisController.dispose();
    _kelasController.dispose();
    super.dispose();
  }

  void _showForm({Map<String, dynamic>? siswa}) {
    final isEdit = siswa != null;
    if (isEdit) {
      _namaController.text = siswa['nama'] ?? '';
      _nisController.text = siswa['nis'] ?? '';
      _kelasController.text = siswa['kelas'] ?? '';
    } else {
      _namaController.clear();
      _nisController.clear();
      _kelasController.clear();
    }

    CrudBottomSheet.show(
      context,
      title: isEdit ? 'Edit Data Siswa' : 'Tambah Siswa Baru',
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildTextField(
              controller: _namaController,
              label: 'Nama Lengkap',
              icon: Icons.person_outline,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _nisController,
              label: 'NIS',
              icon: Icons.badge_outlined,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _kelasController,
              label: 'Kelas',
              icon: Icons.class_outlined,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    final vm = context.read<ManageSiswaViewModel>();
                    bool success;
                    if (isEdit) {
                      success = await vm.updateSiswa(
                        siswa['id'] ?? siswa['id_siswa'],
                        nama: _namaController.text.trim(),
                        nis: _nisController.text.trim(),
                        kelas: _kelasController.text.trim(),
                      );
                    } else {
                      success = await vm.createSiswa(
                        nama: _namaController.text.trim(),
                        nis: _nisController.text.trim(),
                        kelas: _kelasController.text.trim(),
                      );
                    }

                    if (!mounted) return;
                    if (success) {
                      Navigator.pop(context);
                      GlassSnackBar.show(context, isEdit ? 'Siswa berhasil diperbarui' : 'Siswa berhasil ditambahkan', GlassSnackBarType.success);
                    } else if (vm.errorMessage != null) {
                      GlassSnackBar.show(context, vm.errorMessage!, GlassSnackBarType.error);
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accentIndigo,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: AppTheme.radiusMd),
                ),
                child: Text(isEdit ? 'Simpan Perubahan' : 'Tambah Siswa', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({required TextEditingController controller, required String label, required IconData icon, TextInputType? keyboardType}) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: AppTheme.textMuted),
        prefixIcon: Icon(icon, color: AppTheme.textSecondary),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.05),
        border: OutlineInputBorder(borderRadius: AppTheme.radiusSm, borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1))),
        enabledBorder: OutlineInputBorder(borderRadius: AppTheme.radiusSm, borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1))),
        focusedBorder: OutlineInputBorder(borderRadius: AppTheme.radiusSm, borderSide: const BorderSide(color: AppTheme.accentRose, width: 2)),
      ),
      validator: (v) => v == null || v.isEmpty ? 'Wajib diisi' : null,
    );
  }

  Future<void> _handleDelete(int idSiswa) async {
    final confirm = await ConfirmDialog.show(
      context,
      title: 'Hapus Siswa',
      message: 'Yakin ingin menghapus siswa ini? Jika siswa ini sudah memiliki catatan pelanggaran/prestasi, Anda harus menghapus catatannya terlebih dahulu.',
    );

    if (confirm == true && mounted) {
      final success = await context.read<ManageSiswaViewModel>().deleteSiswa(idSiswa);
      if (success) {
        GlassSnackBar.show(context, 'Siswa berhasil dihapus', GlassSnackBarType.success);
      } else {
        final err = context.read<ManageSiswaViewModel>().errorMessage;
        GlassSnackBar.show(context, err ?? 'Gagal menghapus', GlassSnackBarType.error);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ManageSiswaViewModel>(
      builder: (context, vm, _) {
        return Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Kelola Data Siswa',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppTheme.accentIndigo.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppTheme.accentIndigo.withOpacity(0.5)),
                        ),
                        child: Text(
                          '${vm.siswaList.length} Siswa',
                          style: const TextStyle(color: AppTheme.accentHover, fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: vm.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : RefreshIndicator(
                          onRefresh: () => vm.loadSiswa(),
                          child: ListView.builder(
                            padding: const EdgeInsets.fromLTRB(24, 0, 24, 140),
                            physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                            itemCount: vm.siswaList.length,
                            itemBuilder: (context, index) {
                              final siswa = vm.siswaList[index];
                              return _buildSiswaCard(siswa).animate().fadeIn(delay: (30 * (index % 15)).ms).slideX(begin: -0.1);
                            },
                          ),
                        ),
                ),
              ],
            ),
            Positioned(
              right: 24,
              bottom: 110, // Above bottom nav
              child: FloatingActionButton(
                onPressed: () => _showForm(),
                backgroundColor: AppTheme.accentRose,
                child: const Icon(Icons.add, color: Colors.white),
              ).animate().scale(delay: 500.ms, curve: Curves.easeOutBack),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSiswaCard(Map<String, dynamic> siswa) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: GlassCard(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                (siswa['nama'] ?? 'S')[0].toUpperCase(),
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    siswa['nama'] ?? 'Unknown',
                    style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.badge_rounded, size: 13, color: Colors.white.withOpacity(0.5)),
                          const SizedBox(width: 4),
                          Text(siswa['nis'] ?? '-', style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 11)),
                        ],
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.class_rounded, size: 13, color: Colors.white.withOpacity(0.5)),
                          const SizedBox(width: 4),
                          Text(siswa['kelas'] ?? '-', style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 11)),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit_rounded, color: AppTheme.accentHover, size: 18),
                  onPressed: () => _showForm(siswa: siswa),
                  constraints: const BoxConstraints(),
                  padding: const EdgeInsets.all(8),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded, color: AppTheme.errorRed, size: 18),
                  onPressed: () => _handleDelete(siswa['id'] ?? siswa['id_siswa']),
                  constraints: const BoxConstraints(),
                  padding: const EdgeInsets.all(8),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
