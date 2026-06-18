import 'dart:ui';
import 'package:flutter/material.dart';
import '../core/theme.dart';

class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final bool accentTop; // rose shimmer top border
  final bool accentBorder; // full rose‑glow border
  final double blurSigma;
  final BorderRadius? borderRadius;
  final VoidCallback? onTap;

  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.accentTop = false,
    this.accentBorder = false,
    this.blurSigma = 20,
    this.borderRadius,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final br = borderRadius ?? AppTheme.radiusMd;
    Widget content = ClipRRect(
      borderRadius: br,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: br,
            gradient: const LinearGradient(
              colors: [
                Color.fromRGBO(255, 255, 255, 0.09),
                Color.fromRGBO(255, 255, 255, 0.04),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: accentBorder
                ? Border.all(color: AppTheme.accentRose.withValues(alpha: 0.40), width: 1.2)
                : Border.all(color: AppTheme.glassBorder),
          ),
          child: Stack(
            children: [
              if (accentTop)
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 1.5,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.vertical(top: br.topLeft),
                      gradient: AppTheme.shimmerGradient,
                    ),
                  ),
                ),
              Padding(
                padding: padding ?? const EdgeInsets.all(20),
                child: child,
              ),
            ],
          ),
        ),
      ),
    );

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        borderRadius: br,
        child: InkWell(
          borderRadius: br,
          onTap: onTap,
          splashColor: AppTheme.accentRose.withValues(alpha: 0.08),
          highlightColor: AppTheme.accentRose.withValues(alpha: 0.04),
          child: content,
        ),
      );
    }
    return content;
  }
}
