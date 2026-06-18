import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../core/theme.dart';
import '../models/guru_model.dart';
import '../viewmodels/login_viewmodel.dart';
import '../viewmodels/teacher_input_viewmodel.dart';
import '../widgets/ziepoint_bottom_nav.dart';

import 'tabs/teacher_input_tab.dart';
import 'tabs/history_management_tab.dart';
import 'tabs/manage_siswa_tab.dart';
import 'tabs/manage_jenis_tab.dart';

class TeacherInputPage extends StatefulWidget {
  final Guru guru;
  const TeacherInputPage({super.key, required this.guru});

  @override
  State<TeacherInputPage> createState() => _TeacherInputPageState();
}

class _TeacherInputPageState extends State<TeacherInputPage> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TeacherInputViewModel>().loadTeacherStats();
    });
  }

  void _onTabChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  Future<void> _logout() async {
    await context.read<LoginViewModel>().logout();
    if (!mounted) return;
    context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundTop,
      extendBody: true,
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.navyBackgroundGradient),
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              _buildAppBar(),
              Expanded(
                child: IndexedStack(
                  index: _currentIndex,
                  children: [
                    TeacherInputTab(guru: widget.guru),
                    const HistoryManagementTab(),
                    const ManageSiswaTab(),
                    const ManageJenisTab(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: ZiePointBottomNav(
        currentIndex: _currentIndex,
        onTap: _onTabChanged,
        items: [
          BottomNavItem(icon: Icons.edit_document, activeIcon: Icons.edit_document, label: 'Input'),
          BottomNavItem(icon: Icons.history_rounded, activeIcon: Icons.history_rounded, label: 'Riwayat'),
          BottomNavItem(icon: Icons.people_outline_rounded, activeIcon: Icons.people_rounded, label: 'Siswa'),
          BottomNavItem(icon: Icons.category_outlined, activeIcon: Icons.category_rounded, label: 'Jenis'),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          height: 64,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          decoration: BoxDecoration(
            color: const Color(0xFF0F1729).withOpacity(0.85),
            border: Border(
              bottom: BorderSide(color: Colors.white.withOpacity(0.08), width: 1),
            ),
          ),
          child: Row(
            children: [
              const Icon(Icons.shield_rounded, color: AppTheme.accentRose, size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'ZiePoint',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                    Text(
                      'Teacher Portal',
                      style: TextStyle(
                        color: AppTheme.accentRose.withOpacity(0.8),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: _logout,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.logout_rounded, color: AppTheme.textSecondary, size: 20),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
