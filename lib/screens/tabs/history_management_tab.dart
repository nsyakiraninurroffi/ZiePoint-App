import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../core/theme.dart';
import '../../viewmodels/teacher_input_viewmodel.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/confirm_dialog.dart';
import '../../widgets/glass_snackbar.dart';

class HistoryManagementTab extends StatefulWidget {
  const HistoryManagementTab({super.key});

  @override
  State<HistoryManagementTab> createState() => _HistoryManagementTabState();
}

class _HistoryManagementTabState extends State<HistoryManagementTab> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TeacherInputViewModel>().loadAllCatatan(refresh: true);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _handleDelete(BuildContext context, int idCatatan) async {
    final confirmed = await ConfirmDialog.show(
      context,
      title: 'Hapus Catatan?',
      message: 'Apakah Anda yakin ingin menghapus catatan ini? Tindakan ini tidak dapat dibatalkan.',
    );

    if (confirmed == true && mounted) {
      final success = await context.read<TeacherInputViewModel>().deleteCatatan(idCatatan);
      if (success) {
        GlassSnackBar.show(context, 'Catatan berhasil dihapus', GlassSnackBarType.success);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TeacherInputViewModel>(
      builder: (context, vm, _) {
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
              child: _buildSearchBar(vm),
            ),
            Expanded(
              child: vm.isLoadingCatatan && vm.allCatatan.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : vm.allCatatan.isEmpty
                      ? _buildEmptyState()
                      : RefreshIndicator(
                          onRefresh: () => vm.loadAllCatatan(refresh: true),
                          child: ListView.builder(
                            padding: const EdgeInsets.fromLTRB(24, 16, 24, 140),
                            physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                            itemCount: vm.allCatatan.length + (vm.catatanHasMore ? 1 : 0),
                            itemBuilder: (context, index) {
                              if (index == vm.allCatatan.length) {
                                if (!vm.isLoadingCatatan) {
                                  WidgetsBinding.instance.addPostFrameCallback((_) => vm.loadMoreCatatan());
                                }
                                return const Center(child: Padding(padding: EdgeInsets.all(16.0), child: CircularProgressIndicator()));
                              }
                              
                              final item = vm.allCatatan[index];
                              return _buildHistoryItem(item).animate().fadeIn(delay: (50 * (index % 10)).ms).slideX(begin: 0.1);
                            },
                          ),
                        ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSearchBar(TeacherInputViewModel vm) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          const Icon(Icons.search_rounded, color: AppTheme.textSecondary),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: _searchController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: 'Cari nama siswa atau NIS...',
                hintStyle: TextStyle(color: AppTheme.textMuted),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
              ),
              onSubmitted: (value) => vm.setCatatanSearch(value),
            ),
          ),
          if (_searchController.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear, color: AppTheme.textSecondary),
              onPressed: () {
                _searchController.clear();
                vm.setCatatanSearch(null);
              },
            ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list_rounded, color: AppTheme.accentRose),
            color: const Color(0xFF2D1B4E),
            onSelected: (value) => vm.setCatatanFilter(value == 'all' ? null : value),
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'all', child: Text('Semua Catatan', style: TextStyle(color: Colors.white))),
              const PopupMenuItem(value: 'pelanggaran', child: Text('Pelanggaran', style: TextStyle(color: Colors.white))),
              const PopupMenuItem(value: 'prestasi', child: Text('Prestasi', style: TextStyle(color: Colors.white))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history_rounded, size: 64, color: Colors.white.withOpacity(0.2)),
          const SizedBox(height: 16),
          Text(
            'Belum ada riwayat catatan.',
            style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryItem(Map<String, dynamic> item) {
    final isPelanggaran = item['tipe'] == 'pelanggaran';
    final color = isPelanggaran ? AppTheme.errorRed : AppTheme.successGreen;
    final icon = isPelanggaran ? Icons.warning_rounded : Icons.star_rounded;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: GlassCard(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          item['nama_siswa'] ?? 'Siswa',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        _formatDate(item['tanggal']),
                        style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.6)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item['nama_jenis'] ?? 'Catatan',
                    style: TextStyle(fontSize: 14, color: color, fontWeight: FontWeight.w500),
                  ),
                  if (item['keterangan'] != null && item['keterangan'].toString().isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      item['keterangan'],
                      style: TextStyle(fontSize: 13, color: Colors.white.withOpacity(0.8)),
                    ),
                  ],
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          'Guru: ${item['nama_guru']}',
                          style: TextStyle(fontSize: 11, color: Colors.white.withOpacity(0.5)),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Action buttons
                      Row(
                        children: [
                          /* Note: Implement Edit logic with BottomSheet if needed */
                          GestureDetector(
                            onTap: () => _handleDelete(context, item['id_catatan']),
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: AppTheme.errorRed.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Icon(Icons.delete_outline_rounded, color: AppTheme.errorRed, size: 16),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('dd MMM yyyy', 'id_ID').format(date);
    } catch (e) {
      return dateString;
    }
  }
}
