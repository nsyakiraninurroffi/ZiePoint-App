import 'dart:ui';
import 'package:flutter/material.dart';
import '../core/theme.dart';

class GlassDropdown<T> extends StatelessWidget {
  final String label;
  final IconData icon;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?>? onChanged;
  final bool isLoading;

  const GlassDropdown({
    super.key,
    required this.label,
    required this.icon,
    required this.items,
    this.value,
    this.onChanged,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: AppTheme.radiusSm,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: AppTheme.radiusSm,
            border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
          ),
          child: isLoading
              ? _buildLoadingState()
              : DropdownButtonFormField<T>(
                  initialValue: value,
                  items: items,
                  onChanged: onChanged,
                  isExpanded: true,
                  style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                  dropdownColor: const Color(0xFF2D1B4E),
                  icon: Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: AppTheme.textSecondary,
                  ),
                  decoration: InputDecoration(
                    labelText: label,
                    prefixIcon: Icon(icon, color: AppTheme.textSecondary, size: 20),
                    filled: false,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                    labelStyle: TextStyle(
                      color: AppTheme.textLabel,
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                    floatingLabelStyle: TextStyle(
                      color: AppTheme.accentRose,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.textMuted, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: TextStyle(color: AppTheme.textMuted, fontSize: 14),
            ),
          ),
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 1.5,
              color: AppTheme.accentRose,
            ),
          ),
        ],
      ),
    );
  }
}
