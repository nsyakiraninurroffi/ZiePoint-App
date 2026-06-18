import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../../core/theme.dart';
import '../../viewmodels/student_dashboard_viewmodel.dart';
import '../../widgets/glass_card.dart';

class StudentProfileTab extends StatelessWidget {
  const StudentProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<StudentDashboardViewModel>(
      builder: (context, vm, _) {
        if (vm.profile == null) {
          return const Center(child: CircularProgressIndicator());
        }

        final profile = vm.profile!;
        
        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 140),
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  shape: BoxShape.circle,
                  border: Border.all(color: AppTheme.accentIndigo.withOpacity(0.5), width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.accentIndigo.withOpacity(0.3),
                      blurRadius: 30,
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: Text(
                  profile.nama.isNotEmpty ? profile.nama[0].toUpperCase() : 'S',
                  style: const TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ).animate().fadeIn().scale(delay: 100.ms, curve: Curves.easeOutBack),
              const SizedBox(height: 24),
              Text(
                profile.nama,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.accentRose.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppTheme.accentRose.withOpacity(0.5)),
                ),
                child: Text(
                  'Siswa Aktif',
                  style: const TextStyle(
                    color: AppTheme.accentHover,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2),
              const SizedBox(height: 40),
              _buildProfileDetailCard(
                icon: Icons.badge_rounded,
                label: 'Nomor Induk Siswa (NIS)',
                value: profile.nis ?? '-',
                delay: 400,
              ),
              const SizedBox(height: 16),
              _buildProfileDetailCard(
                icon: Icons.class_rounded,
                label: 'Kelas',
                value: profile.kelas ?? '-',
                delay: 500,
              ),
              const SizedBox(height: 16),
              _buildProfileDetailCard(
                icon: Icons.star_border_rounded,
                label: 'Total Prestasi',
                value: '${vm.summary?.totalPrestasi ?? 0} Poin',
                color: AppTheme.successGreen,
                delay: 600,
              ),
              const SizedBox(height: 16),
              _buildProfileDetailCard(
                icon: Icons.warning_amber_rounded,
                label: 'Total Pelanggaran',
                value: '${vm.summary?.totalPelanggaran ?? 0} Poin',
                color: AppTheme.errorRed,
                delay: 700,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProfileDetailCard({
    required IconData icon,
    required String label,
    required String value,
    Color color = AppTheme.accentIndigo,
    required int delay,
  }) {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: color.withOpacity(0.3)),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.6),
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: delay.ms).slideX(begin: 0.1);
  }
}
