import 'dart:ui';
import 'package:flutter/material.dart';
import '../core/theme.dart';

enum GlassSnackBarType { success, error, info }

class GlassSnackBar {
  static void show(BuildContext context, String message, GlassSnackBarType type) {
    Color accentColor;
    IconData icon;
    
    switch (type) {
      case GlassSnackBarType.success:
        accentColor = AppTheme.successGreen;
        icon = Icons.check_circle_outline;
        break;
      case GlassSnackBarType.error:
        accentColor = AppTheme.errorRed;
        icon = Icons.error_outline;
        break;
      case GlassSnackBarType.info:
        accentColor = AppTheme.accentIndigo;
        icon = Icons.info_outline;
        break;
    }

    final snackBar = SnackBar(
      elevation: 0,
      backgroundColor: Colors.transparent,
      behavior: SnackBarBehavior.floating,
      duration: const Duration(seconds: 3),
      content: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: accentColor.withValues(alpha: 0.5), width: 1),
            ),
            child: Row(
              children: [
                Icon(icon, color: accentColor, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    message,
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 14),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  },
                  child: Icon(Icons.close, color: Colors.white.withValues(alpha: 0.5), size: 20),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(snackBar);
  }
}
