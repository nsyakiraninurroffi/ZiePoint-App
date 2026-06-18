import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../core/theme.dart';
import 'glass_card.dart';

class AnalyticsChart extends StatelessWidget {
  final int totalPelanggaran;
  final int totalPrestasi;

  const AnalyticsChart({
    super.key,
    required this.totalPelanggaran,
    required this.totalPrestasi,
  });

  @override
  Widget build(BuildContext context) {
    final total = totalPelanggaran + totalPrestasi;
    if (total == 0) {
      return const SizedBox.shrink();
    }

    final pelanggaranPct = (totalPelanggaran / total) * 100;
    final prestasiPct = (totalPrestasi / total) * 100;

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.pie_chart_outline_rounded, color: AppTheme.accentIndigo, size: 20),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  'Statistik Kedisiplinan Sekolah',
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              // Pie Chart
              SizedBox(
                height: 160,
                width: 160,
                child: PieChart(
                  PieChartData(
                    sectionsSpace: 4,
                    centerSpaceRadius: 40,
                    sections: [
                      PieChartSectionData(
                        color: AppTheme.pelanggaran,
                        value: totalPelanggaran.toDouble(),
                        title: '${pelanggaranPct.toStringAsFixed(1)}%',
                        radius: 30,
                        titleStyle: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      PieChartSectionData(
                        color: AppTheme.prestasi,
                        value: totalPrestasi.toDouble(),
                        title: '${prestasiPct.toStringAsFixed(1)}%',
                        radius: 35,
                        titleStyle: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  duration: const Duration(milliseconds: 800),
                  curve: Curves.easeInOut,
                ),
              ),
              const SizedBox(width: 16),
              // Legend — Expanded so it takes remaining space without overflow
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _Indicator(
                      color: AppTheme.prestasi,
                      text: 'Prestasi',
                      value: totalPrestasi,
                    ),
                    const SizedBox(height: 16),
                    _Indicator(
                      color: AppTheme.pelanggaran,
                      text: 'Pelanggaran',
                      value: totalPelanggaran,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Indicator extends StatelessWidget {
  final Color color;
  final String text;
  final int value;

  const _Indicator({
    required this.color,
    required this.text,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
            boxShadow: [
              BoxShadow(color: color.withValues(alpha: 0.5), blurRadius: 4),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              text,
              style: TextStyle(
                fontSize: 12,
                color: Colors.white.withValues(alpha: 0.8),
              ),
            ),
            Text(
              value.toString(),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
