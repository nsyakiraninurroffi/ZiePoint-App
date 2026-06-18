import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/theme.dart';
import '../../models/catatan_model.dart';
import '../../viewmodels/student_dashboard_viewmodel.dart';
import '../../widgets/skeleton_card.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/error_state.dart';

class StudentDashboardTab extends StatefulWidget {
  const StudentDashboardTab({super.key});

  @override
  State<StudentDashboardTab> createState() => _StudentDashboardTabState();
}

class _StudentDashboardTabState extends State<StudentDashboardTab> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      context.read<StudentDashboardViewModel>().fetchNextPage();
    }
  }

  String _formatTanggal(String? raw) {
    if (raw == null || raw.isEmpty) return '-';
    try {
      final dt = DateTime.parse(raw).toLocal();
      return DateFormat('d MMM yyyy', 'id_ID').format(dt);
    } catch (_) {
      return raw;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<StudentDashboardViewModel>(
      builder: (context, vm, _) {
        switch (vm.state) {
          case DashboardState.idle:
          case DashboardState.loading:
            return _buildLoadingState();
          case DashboardState.error:
            return ErrorState(
              message: vm.errorMessage ?? 'Gagal memuat data.',
              onRetry: vm.loadDashboard,
            );
          case DashboardState.empty:
          case DashboardState.loaded:
          case DashboardState.loadingMore:
            return _buildContent(vm);
        }
      },
    );
  }

  Widget _buildLoadingState() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: const SkeletonListLoader().animate().fadeIn(duration: 400.ms),
    );
  }

  Widget _buildContent(StudentDashboardViewModel vm) {
    return RefreshIndicator(
      onRefresh: vm.refresh,
      color: AppTheme.accentIndigo,
      child: ListView(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 140), // Bottom padding for Nav
        children: [
          if (vm.summary != null) _buildSummaryCard(vm.summary!),
          const SizedBox(height: 24),
          _buildLeaderboard(vm),
          const SizedBox(height: 24),
          Row(
            children: [
              Container(
                width: 4,
                height: 20,
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(2)),
              ),
              const SizedBox(width: 10),
              const Text(
                'Riwayat Catatan',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white),
              ),
            ],
          ).animate().fadeIn(delay: 400.ms),
          const SizedBox(height: 12),
          if (vm.state == DashboardState.empty)
            const EmptyState(
              title: 'Belum Ada Riwayat',
              subtitle: 'Catatan pelanggaran dan prestasi Anda akan muncul di sini.',
              icon: Icons.history_rounded,
            )
          else
            ...vm.riwayat.asMap().entries.map((entry) {
              return _buildHistoryItem(entry.value, entry.key, vm.riwayat.length)
                  .animate()
                  .fadeIn(delay: (500 + entry.key * 80).ms, duration: 400.ms)
                  .slideX(begin: 0.05);
            }),
          if (vm.isLoadingMore)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: SizedBox(height: 28, width: 28, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white)),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(RiwayatSummary summary) {
    return ClipRRect(
      borderRadius: AppTheme.radiusMd,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.12),
            borderRadius: AppTheme.radiusMd,
            border: Border.all(color: Colors.white.withOpacity(0.2)),
          ),
          child: Row(
            children: [
              _summaryTile('Pelanggaran', summary.totalPelanggaran, AppTheme.pelanggaran, Icons.warning_amber_rounded),
              _verticalDivider(),
              _summaryTile('Prestasi', summary.totalPrestasi, AppTheme.prestasi, Icons.emoji_events_rounded),
              _verticalDivider(),
              _summaryTile(
                'Poin Bersih',
                summary.totalPoin,
                summary.totalPoin > 20 ? AppTheme.errorRed : summary.totalPoin > 10 ? Colors.orange : AppTheme.successGreen,
                summary.totalPoin > 20 ? Icons.trending_up_rounded : summary.totalPoin > 10 ? Icons.remove_rounded : Icons.trending_down_rounded,
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(delay: 200.ms, duration: 500.ms).slideY(begin: 0.1);
  }

  Widget _summaryTile(String label, int value, Color color, IconData icon) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(height: 4),
          Text(value.toString(), style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: color)),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 10, color: Colors.white.withOpacity(0.7), fontWeight: FontWeight.w600, letterSpacing: 0.5),
          ),
        ],
      ),
    );
  }

  Widget _verticalDivider() {
    return Container(width: 1, height: 40, color: Colors.white.withOpacity(0.15));
  }

  Widget _buildLeaderboard(StudentDashboardViewModel vm) {
    if (vm.leaderboard.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(width: 4, height: 20, decoration: BoxDecoration(color: AppTheme.prestasi, borderRadius: BorderRadius.circular(2))),
            const SizedBox(width: 10),
            const Text(
              'Top Siswa Berprestasi',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.stars_rounded, color: AppTheme.prestasi, size: 20),
          ],
        ).animate().fadeIn(delay: 300.ms),
        const SizedBox(height: 12),
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: vm.leaderboard.length,
            itemBuilder: (context, index) {
              final student = vm.leaderboard[index];
              return Container(
                width: 140,
                margin: const EdgeInsets.only(right: 12),
                child: ClipRRect(
                  borderRadius: AppTheme.radiusMd,
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: index == 0 ? AppTheme.prestasi.withOpacity(0.15) : Colors.white.withOpacity(0.08),
                        borderRadius: AppTheme.radiusMd,
                        border: Border.all(color: index == 0 ? AppTheme.prestasi.withOpacity(0.4) : Colors.white.withOpacity(0.12)),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(shape: BoxShape.circle, color: index == 0 ? AppTheme.prestasi : Colors.white24),
                            alignment: Alignment.center,
                            child: Text('#${index + 1}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 14)),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            student['nama'] ?? '-',
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${student['total_prestasi'] ?? 0} Poin',
                            style: TextStyle(color: index == 0 ? AppTheme.prestasi : Colors.white70, fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ).animate().fadeIn(delay: (350 + index * 100).ms).slideX(begin: 0.1);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildHistoryItem(Catatan catatan, int index, int totalLength) {
    final isPelanggaran = catatan.tipe == 'pelanggaran';
    final color = isPelanggaran ? AppTheme.pelanggaran : AppTheme.prestasi;
    final icon = isPelanggaran ? Icons.warning_amber_rounded : Icons.emoji_events_rounded;
    final isLast = index == totalLength - 1;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 32,
            child: Column(
              children: [
                const SizedBox(height: 16),
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(color: color, shape: BoxShape.circle, boxShadow: [BoxShadow(color: color.withOpacity(0.5), blurRadius: 6)]),
                ),
                if (!isLast) Expanded(child: Container(width: 2, margin: const EdgeInsets.only(top: 8), color: Colors.white.withOpacity(0.15))),
                if (isLast) const SizedBox(height: 16),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(bottom: 16),
              child: ClipRRect(
                borderRadius: AppTheme.radiusSm,
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.06),
                      borderRadius: AppTheme.radiusSm,
                      border: Border.all(color: Colors.white.withOpacity(0.12)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(12)),
                          child: Icon(icon, color: color, size: 22),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(catatan.namaJenis, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Colors.white)),
                              const SizedBox(height: 3),
                              Text('${_formatTanggal(catatan.tanggal)}  •  ${catatan.namaGuru}', style: TextStyle(fontSize: 11, color: Colors.white.withOpacity(0.6))),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: color.withOpacity(0.3)),
                          ),
                          child: Text('${isPelanggaran ? '+' : '-'}${catatan.poin}', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: color)),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
