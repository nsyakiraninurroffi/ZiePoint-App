import 'package:flutter/material.dart';
import '../services/connectivity_service.dart';
import '../core/theme.dart';

class ConnectionIndicator extends StatelessWidget {
  const ConnectionIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: ConnectivityService().isConnected,
      builder: (context, isConnected, child) {
        return Tooltip(
          message: isConnected ? "Terhubung ke server" : "Tidak ada koneksi",
          child: Container(
            width: 8,
            height: 8,
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isConnected ? AppTheme.successGreen : AppTheme.errorRed,
              boxShadow: [
                BoxShadow(
                  color: (isConnected ? AppTheme.successGreen : AppTheme.errorRed).withValues(alpha: 0.5),
                  blurRadius: 6,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
