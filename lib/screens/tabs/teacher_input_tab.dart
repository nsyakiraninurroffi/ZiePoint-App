import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

import '../../core/theme.dart';
import '../../models/guru_model.dart';
import '../../models/siswa_model.dart';
import '../../viewmodels/teacher_input_viewmodel.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/glass_dropdown.dart';
import '../../widgets/glass_snackbar.dart';
import '../../widgets/stat_card.dart';

class TeacherInputTab extends StatefulWidget {
  final Guru guru;
  const TeacherInputTab({super.key, required this.guru});

  @override
  State<TeacherInputTab> createState() => _TeacherInputTabState();
}

class _TeacherInputTabState extends State<TeacherInputTab> {
  final TextEditingController _ketController = TextEditingController();
  
  late Timer _clockTimer;
  String _currentTime = '';
  String _currentDate = '';

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('id_ID', null).then((_) {
      _updateTime();
      _clockTimer = Timer.periodic(const Duration(seconds: 1), (_) => _updateTime());
    });
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TeacherInputViewModel>().loadFormData();
    });

    _ketController.addListener(() {
      setState(() {});
    });
  }

  void _updateTime() {
    final now = DateTime.now();
    if (!mounted) return;
    setState(() {
      _currentTime = DateFormat('HH:mm:ss').format(now);
      _currentDate = DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(now);
    });
  }

  @override
  void dispose() {
    _clockTimer.cancel();
    _ketController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final vm = context.read<TeacherInputViewModel>();
    final success = await vm.saveCatatan(
      idGuru: widget.guru.idGuru,
      keterangan: _ketController.text,
    );

    if (!mounted) return;
    
    if (success) {
      GlassSnackBar.show(context, 'Catatan berhasil disimpan!', GlassSnackBarType.success);
      _ketController.clear();
      vm.loadTeacherStats(); // Refresh stats after saving
    } else {
      if (vm.errorMessage != null) {
        GlassSnackBar.show(context, vm.errorMessage!, GlassSnackBarType.error);
      }
    }
  }

  Future<void> _selectDate(BuildContext context, TeacherInputViewModel vm) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: vm.selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppTheme.accentRose,
              onPrimary: Colors.white,
              surface: Color(0xFF1E1E2C),
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != vm.selectedDate) {
      vm.setSelectedDate(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TeacherInputViewModel>(
      builder: (context, vm, _) {
        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 140), // Bottom padding for Nav
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildProfileCard().animate().fadeIn(delay: 100.ms).slideY(begin: 0.1),
              const SizedBox(height: 24),
              
              // Header Dashboard & Export Button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Statistik Bulan Ini',
                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  GestureDetector(
                    onTap: () async {
                      // Simulated Export Functionality
                      GlassSnackBar.show(context, 'Mempersiapkan data laporan...', GlassSnackBarType.success);
                      await Future.delayed(const Duration(seconds: 2));
                      if (context.mounted) {
                        GlassSnackBar.show(context, 'Laporan berhasil diekspor ke format PDF/Excel!', GlassSnackBarType.success);
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppTheme.accentRose.withValues(alpha: 0.15),
                        border: Border.all(color: AppTheme.accentRose.withValues(alpha: 0.4)),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.download_rounded, color: AppTheme.accentRose, size: 16),
                          const SizedBox(width: 6),
                          const Text(
                            'Ekspor Laporan',
                            style: TextStyle(color: AppTheme.accentRose, fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Stats
              Row(
                children: [
                  Expanded(
                    child: StatCard(
                      title: 'Total Pelanggaran',
                      value: vm.isLoadingStats ? '-' : '${vm.stats?['total_pelanggaran'] ?? 0}',
                      icon: Icons.warning_rounded,
                      color: AppTheme.errorRed,
                      delayMs: 200,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: StatCard(
                      title: 'Total Prestasi',
                      value: vm.isLoadingStats ? '-' : '${vm.stats?['total_prestasi'] ?? 0}',
                      icon: Icons.star_rounded,
                      color: AppTheme.successGreen,
                      delayMs: 300,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              
              const Text(
                'Input Catatan Baru',
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              _buildTabSwitcher(vm).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1),
              const SizedBox(height: 16),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 350),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeInCubic,
                child: _buildFormCard(vm, key: ValueKey<bool>(vm.isPelanggaran)),
              ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.1),
              const SizedBox(height: 24),
              _buildSaveButton(vm).animate().fadeIn(delay: 600.ms).slideY(begin: 0.1),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProfileCard() {
    return GlassCard(
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppTheme.accentIndigo.withOpacity(0.25),
              shape: BoxShape.circle,
              border: Border.all(color: AppTheme.accentIndigo.withOpacity(0.4)),
            ),
            alignment: Alignment.center,
            child: Text(
              widget.guru.nama.isNotEmpty ? widget.guru.nama[0].toUpperCase() : 'G',
              style: const TextStyle(
                color: AppTheme.accentHover,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'GURU PETUGAS',
                  style: Theme.of(context).textTheme.labelMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  widget.guru.nama,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 16),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _currentTime,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontFamily: 'monospace',
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.accentRose,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _currentDate,
                maxLines: 2,
                textAlign: TextAlign.right,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTabSwitcher(TeacherInputViewModel vm) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => vm.switchTipe(true),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOutCubic,
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: vm.isPelanggaran ? AppTheme.glassActiveTabBg : Colors.transparent,
                  border: vm.isPelanggaran ? Border.all(color: AppTheme.glassActiveTabBorder) : Border.all(color: Colors.transparent),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      size: 18,
                      color: vm.isPelanggaran ? AppTheme.errorRed : AppTheme.textMuted,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Pelanggaran',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: vm.isPelanggaran ? FontWeight.w600 : FontWeight.w400,
                        color: vm.isPelanggaran ? Colors.white : AppTheme.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => vm.switchTipe(false),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOutCubic,
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: !vm.isPelanggaran ? AppTheme.glassActiveTabBg : Colors.transparent,
                  border: !vm.isPelanggaran ? Border.all(color: AppTheme.glassActiveTabBorder) : Border.all(color: Colors.transparent),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.emoji_events_outlined,
                      size: 18,
                      color: !vm.isPelanggaran ? AppTheme.successGreen : AppTheme.textMuted,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Prestasi',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: !vm.isPelanggaran ? FontWeight.w600 : FontWeight.w400,
                        color: !vm.isPelanggaran ? Colors.white : AppTheme.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormCard(TeacherInputViewModel vm, {Key? key}) {
    return GlassCard(
      key: key,
      accentTop: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 16,
                decoration: BoxDecoration(
                  color: vm.isPelanggaran ? AppTheme.errorRed : AppTheme.successGreen,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Form ${vm.isPelanggaran ? "Pelanggaran" : "Prestasi"}',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: vm.isPelanggaran ? AppTheme.errorRed : AppTheme.successGreen,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // Tanggal Selector
          GestureDetector(
            onTap: () => _selectDate(context, vm),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: AppTheme.radiusSm,
                border: Border.all(color: Colors.white.withOpacity(0.12)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today_rounded, color: AppTheme.textSecondary, size: 20),
                  const SizedBox(width: 12),
                  Text(
                    DateFormat('dd MMMM yyyy', 'id_ID').format(vm.selectedDate),
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                  ),
                  const Spacer(),
                  const Icon(Icons.edit_calendar_rounded, color: AppTheme.accentRose, size: 18),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // Smart Autocomplete for Siswa
          ClipRRect(
            borderRadius: AppTheme.radiusSm,
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: AppTheme.radiusSm,
                  border: Border.all(color: Colors.white.withOpacity(0.12)),
                ),
                child: vm.isLoadingData
                    ? Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        child: Row(
                          children: [
                            const Icon(Icons.person_outline, color: AppTheme.textMuted, size: 20),
                            const SizedBox(width: 12),
                            const Text('Memuat Siswa...', style: TextStyle(color: AppTheme.textMuted, fontSize: 14)),
                            const Spacer(),
                            const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 1.5, color: AppTheme.accentRose)),
                          ],
                        ),
                      )
                    : Autocomplete<Siswa>(
                        displayStringForOption: (Siswa option) => option.nama,
                        optionsBuilder: (TextEditingValue textEditingValue) {
                          if (textEditingValue.text.isEmpty) {
                            return vm.siswaList;
                          }
                          return vm.siswaList.where((Siswa siswa) {
                            return siswa.nama.toLowerCase().contains(textEditingValue.text.toLowerCase()) ||
                                (siswa.nis != null && siswa.nis!.contains(textEditingValue.text));
                          });
                        },
                        onSelected: (Siswa selection) {
                          vm.setSelectedSiswa(selection.idSiswa.toString());
                        },
                        fieldViewBuilder: (context, textEditingController, focusNode, onFieldSubmitted) {
                          if (vm.selectedSiswa != null && textEditingController.text.isEmpty) {
                            final initialSiswa = vm.siswaList.where((s) => s.idSiswa.toString() == vm.selectedSiswa).firstOrNull;
                            if (initialSiswa != null) {
                              textEditingController.text = initialSiswa.nama;
                            }
                          }
                          return TextFormField(
                            controller: textEditingController,
                            focusNode: focusNode,
                            style: const TextStyle(color: Colors.white, fontSize: 14),
                            decoration: InputDecoration(
                              labelText: 'CARI SISWA (Nama / NIS)',
                              prefixIcon: const Icon(Icons.search_rounded, color: AppTheme.textSecondary, size: 20),
                              suffixIcon: IconButton(
                                icon: const Icon(Icons.clear_rounded, color: AppTheme.textSecondary, size: 18),
                                onPressed: () {
                                  textEditingController.clear();
                                  vm.setSelectedSiswa(null);
                                  focusNode.requestFocus();
                                },
                              ),
                              filled: false,
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                              labelStyle: const TextStyle(color: AppTheme.textLabel, fontSize: 14, fontWeight: FontWeight.w400),
                              floatingLabelStyle: const TextStyle(color: AppTheme.accentRose, fontSize: 12, fontWeight: FontWeight.w500),
                            ),
                          );
                        },
                        optionsViewBuilder: (context, onSelected, options) {
                          return Align(
                            alignment: Alignment.topLeft,
                            child: Material(
                              color: Colors.transparent,
                              child: Container(
                                width: 350,
                                margin: const EdgeInsets.only(top: 8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF2D1B4E),
                                  borderRadius: AppTheme.radiusSm,
                                  border: Border.all(color: Colors.white.withOpacity(0.15)),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.3),
                                      blurRadius: 10,
                                      offset: const Offset(0, 5),
                                    )
                                  ],
                                ),
                                child: ListView.builder(
                                  padding: EdgeInsets.zero,
                                  shrinkWrap: true,
                                  itemCount: options.length,
                                  itemBuilder: (BuildContext context, int index) {
                                    final Siswa option = options.elementAt(index);
                                    return ListTile(
                                      title: Text(option.nama, style: const TextStyle(color: Colors.white, fontSize: 14)),
                                      subtitle: Text('${option.nis ?? "-"} • ${option.kelas ?? "-"}', style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12)),
                                      onTap: () {
                                        onSelected(option);
                                      },
                                    );
                                  },
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          GlassDropdown<String>(
            label: vm.isPelanggaran ? 'JENIS PELANGGARAN' : 'JENIS PRESTASI',
            icon: vm.isPelanggaran ? Icons.warning_amber_rounded : Icons.star_border_rounded,
            value: vm.selectedJenis,
            isLoading: vm.isLoadingData,
            items: vm.jenisList.map((j) {
              final poin = j['poin'] ?? 0;
              return DropdownMenuItem(
                value: j['id_jenis'].toString(),
                child: Text('${j['nama']} ($poin poin)'),
              );
            }).toList(),
            onChanged: vm.setSelectedJenis,
          ),
          const SizedBox(height: 16),
          
          Stack(
            children: [
              TextFormField(
                controller: _ketController,
                maxLines: 4,
                minLines: 3,
                style: Theme.of(context).textTheme.bodyLarge,
                decoration: const InputDecoration(
                  labelText: 'KETERANGAN TAMBAHAN',
                  hintText: 'Masukkan detail keterangan di sini...',
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                ),
              ),
              Positioned(
                bottom: 12,
                right: 16,
                child: Text(
                  '${_ketController.text.length} / 200',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.textMuted,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton(TeacherInputViewModel vm) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: 54,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: AppTheme.buttonGradient,
        boxShadow: [
          if (!vm.isSaving)
            BoxShadow(
              color: AppTheme.accentIndigo.withOpacity(0.35),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: vm.isSaving ? null : _save,
          child: Center(
            child: vm.isSaving
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(
                        width: 18, 
                        height: 18, 
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Menyimpan...',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(color: Colors.white),
                      ),
                    ],
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.save_outlined, color: Colors.white, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        'Simpan Catatan',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(color: Colors.white),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
