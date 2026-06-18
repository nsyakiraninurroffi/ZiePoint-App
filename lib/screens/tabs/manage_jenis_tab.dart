import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../../core/theme.dart';
import '../../viewmodels/manage_jenis_viewmodel.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/crud_bottom_sheet.dart';
import '../../widgets/confirm_dialog.dart';
import '../../widgets/glass_snackbar.dart';

class ManageJenisTab extends StatefulWidget {
  const ManageJenisTab({super.key});

  @override
  State<ManageJenisTab> createState() => _ManageJenisTabState();
}

class _ManageJenisTabState extends State<ManageJenisTab> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _poinController = TextEditingController();
  String _selectedTipe = 'pelanggaran';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ManageJenisViewModel>().loadJenisCatatan();
    });
  }

  @override
  void dispose() {
    _namaController.dispose();
    _poinController.dispose();
    super.dispose();
  }

  void _showForm({Map<String, dynamic>? jenis}) {
    final isEdit = jenis != null;
    if (isEdit) {
      _namaController.text = jenis['nama'] ?? '';
      _poinController.text = (jenis['poin'] ?? 0).toString();
      _selectedTipe = jenis['tipe'] ?? 'pelanggaran';
    } else {
      _namaController.clear();
      _poinController.clear();
      _selectedTipe = 'pelanggaran';
    }

    CrudBottomSheet.show(
      context,
      title: isEdit ? 'Edit Jenis Catatan' : 'Tambah Jenis Catatan',
      child: StatefulBuilder(
        builder: (context, setStateSB) {
          return Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTextField(
                  controller: _namaController,
                  label: 'Nama Jenis (Misal: Terlambat, Juara Kelas)',
                  icon: Icons.title_rounded,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _poinController,
                  label: 'Poin',
                  icon: Icons.score_rounded,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 24),
                const Text('Tipe Catatan', style: TextStyle(color: AppTheme.textMuted, fontSize: 14)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setStateSB(() => _selectedTipe = 'pelanggaran'),
                        child: _buildTipeOption('Pelanggaran', Icons.warning_rounded, AppTheme.errorRed, _selectedTipe == 'pelanggaran'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setStateSB(() => _selectedTipe = 'prestasi'),
                        child: _buildTipeOption('Prestasi', Icons.star_rounded, AppTheme.successGreen, _selectedTipe == 'prestasi'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        final vm = context.read<ManageJenisViewModel>();
                        bool success;
                        final poin = int.tryParse(_poinController.text) ?? 0;
                        if (isEdit) {
                          success = await vm.updateJenisCatatan(
                            jenis['id_jenis'],
                            nama: _namaController.text.trim(),
                            poin: poin,
                            tipe: _selectedTipe,
                          );
                        } else {
                          success = await vm.createJenisCatatan(
                            nama: _namaController.text.trim(),
                            poin: poin,
                            tipe: _selectedTipe,
                          );
                        }

                        if (!mounted) return;
                        if (success) {
                          Navigator.pop(context);
                          GlassSnackBar.show(context, isEdit ? 'Berhasil diperbarui' : 'Berhasil ditambahkan', GlassSnackBarType.success);
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
                    child: Text(isEdit ? 'Simpan Perubahan' : 'Tambah Jenis', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                ),
              ],
            ),
          );
        }
      ),
    );
  }

  Widget _buildTipeOption(String label, IconData icon, Color color, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: isSelected ? color.withValues(alpha: 0.2) : Colors.transparent,
        border: Border.all(color: isSelected ? color : Colors.white.withValues(alpha: 0.1)),
        borderRadius: AppTheme.radiusSm,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: isSelected ? color : AppTheme.textMuted, size: 18),
          const SizedBox(width: 8),
          Text(label, style: TextStyle(color: isSelected ? Colors.white : AppTheme.textMuted, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
        ],
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

  Future<void> _handleDelete(int idJenis) async {
    final confirm = await ConfirmDialog.show(
      context,
      title: 'Hapus Jenis Catatan',
      message: 'Yakin ingin menghapus jenis catatan ini? Jika masih digunakan pada catatan siswa, maka tidak bisa dihapus.',
    );

    if (confirm == true && mounted) {
      final success = await context.read<ManageJenisViewModel>().deleteJenisCatatan(idJenis);
      if (success) {
        GlassSnackBar.show(context, 'Jenis catatan berhasil dihapus', GlassSnackBarType.success);
      } else {
        final err = context.read<ManageJenisViewModel>().errorMessage;
        GlassSnackBar.show(context, err ?? 'Gagal menghapus', GlassSnackBarType.error);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ManageJenisViewModel>(
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
                        'Kelola Jenis Catatan',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: vm.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : RefreshIndicator(
                          onRefresh: () => vm.loadJenisCatatan(),
                          child: ListView.builder(
                            padding: const EdgeInsets.fromLTRB(24, 0, 24, 140),
                            physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                            itemCount: vm.jenisList.length,
                            itemBuilder: (context, index) {
                              final jenis = vm.jenisList[index];
                              return _buildJenisCard(jenis).animate().fadeIn(delay: (30 * (index % 15)).ms).slideX(begin: 0.1);
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

  Widget _buildJenisCard(Map<String, dynamic> jenis) {
    final isPelanggaran = jenis['tipe'] == 'pelanggaran';
    final color = isPelanggaran ? AppTheme.errorRed : AppTheme.successGreen;
    final icon = isPelanggaran ? Icons.warning_rounded : Icons.star_rounded;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: GlassCard(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                shape: BoxShape.circle,
                border: Border.all(color: color.withOpacity(0.3)),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    jenis['nama'] ?? 'Unknown',
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
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          (jenis['tipe'] ?? '').toUpperCase(),
                          style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Text('${jenis['poin']} Poin', style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 13)),
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
                  onPressed: () => _showForm(jenis: jenis),
                  constraints: const BoxConstraints(),
                  padding: const EdgeInsets.all(8),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded, color: AppTheme.errorRed, size: 18),
                  onPressed: () => _handleDelete(jenis['id_jenis']),
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
