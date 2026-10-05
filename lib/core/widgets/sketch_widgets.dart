import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/sketch_theme.dart';

/// Seeded pseudo-random jitter generator so sketched borders stay identical
/// across widget rebuilds without recalculating or flickering.
class SketchBorderPainter extends CustomPainter {
  final Color borderColor;
  final double borderWidth;
  final double cornerRadius;
  final int seed;
  final Color? fillColor;
  final bool hasTornEdge;

  // Path cache
  static final Map<String, Path> _pathCache = {};

  SketchBorderPainter({
    required this.borderColor,
    this.borderWidth = 1.6,
    this.cornerRadius = 8.0,
    required this.seed,
    this.fillColor,
    this.hasTornEdge = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;

    final cacheKey =
        '${seed}_${size.width.toInt()}x${size.height.toInt()}_${cornerRadius}_$hasTornEdge';
    var path = _pathCache[cacheKey];

    if (path == null) {
      path = _generateSketchPath(size);
      if (_pathCache.length > 500) {
        _pathCache.clear();
      }
      _pathCache[cacheKey] = path;
    }

    if (fillColor != null && fillColor != Colors.transparent) {
      final fillPaint = Paint()
        ..color = fillColor!
        ..style = PaintingStyle.fill;
      canvas.drawPath(path, fillPaint);
    }

    final strokePaint = Paint()
      ..color = borderColor
      ..strokeWidth = borderWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(path, strokePaint);
  }

  Path _generateSketchPath(Size size) {
    final rand = math.Random(seed);
    final path = Path();
    final w = size.width;
    final h = size.height;
    final r = cornerRadius;

    // Small jitter helper
    double j([double max = 1.2]) => (rand.nextDouble() * 2 - 1) * max;

    // Start at top-left corner
    path.moveTo(r + j(), 0 + j());

    // Top edge with subtle wave
    final topMidX = w / 2;
    path.quadraticBezierTo(topMidX, j(1.0), w - r + j(), 0 + j());

    // Top-right corner
    path.quadraticBezierTo(w + j(1.2), 0 + j(1.2), w + j(), r + j());

    // Right edge
    final rightMidY = h / 2;
    path.quadraticBezierTo(w + j(1.0), rightMidY, w + j(), h - r + j());

    // Bottom-right corner
    path.quadraticBezierTo(w + j(1.2), h + j(1.2), w - r + j(), h + j());

    // Bottom edge
    if (hasTornEdge) {
      // Wavy / torn bottom notebook edge
      const segments = 6;
      final segW = (w - 2 * r) / segments;
      for (int i = 0; i < segments; i++) {
        final x1 = (w - r) - (i + 0.5) * segW;
        final x2 = (w - r) - (i + 1) * segW;
        final dip = (i % 2 == 0) ? -2.5 : 2.5;
        path.quadraticBezierTo(x1, h + dip + j(0.5), x2 + j(), h + j());
      }
    } else {
      final botMidX = w / 2;
      path.quadraticBezierTo(botMidX, h + j(1.0), r + j(), h + j());
    }

    // Bottom-left corner
    path.quadraticBezierTo(0 + j(1.2), h + j(1.2), 0 + j(), h - r + j());

    // Left edge
    final leftMidY = h / 2;
    path.quadraticBezierTo(0 + j(1.0), leftMidY, 0 + j(), r + j());

    // Top-left corner close
    path.quadraticBezierTo(0 + j(1.2), 0 + j(1.2), r + j(), 0 + j());
    path.close();

    return path;
  }

  @override
  bool shouldRepaint(covariant SketchBorderPainter oldDelegate) {
    return oldDelegate.borderColor != borderColor ||
        oldDelegate.borderWidth != borderWidth ||
        oldDelegate.seed != seed ||
        oldDelegate.fillColor != fillColor ||
        oldDelegate.hasTornEdge != hasTornEdge;
  }
}

/// A card with a hand-drawn jittery border and warm paper background
class SketchCard extends StatelessWidget {
  final Widget child;
  final String? id;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final Color? backgroundColor;
  final Color? borderColor;
  final double borderWidth;
  final double cornerRadius;
  final VoidCallback? onTap;
  final bool hasTornEdge;
  final double? width;
  final double? height;

  const SketchCard({
    super.key,
    required this.child,
    this.id,
    this.padding = const EdgeInsets.all(14.0),
    this.margin = const EdgeInsets.symmetric(vertical: 6.0, horizontal: 2.0),
    this.backgroundColor,
    this.borderColor,
    this.borderWidth = 1.4,
    this.cornerRadius = 8.0,
    this.onTap,
    this.hasTornEdge = false,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final seed = (id ?? hashCode.toString()).hashCode.abs();
    final defaultBorder =
        isDark ? SketchPalette.borderDark : SketchPalette.borderLight;
    final defaultFill =
        isDark ? SketchPalette.paperCardDark : SketchPalette.paperCardLight;

    Widget content = Container(
      width: width,
      height: height,
      margin: margin,
      child: CustomPaint(
        painter: SketchBorderPainter(
          borderColor: borderColor ?? defaultBorder,
          borderWidth: borderWidth,
          cornerRadius: cornerRadius,
          seed: seed,
          fillColor: backgroundColor ?? defaultFill,
          hasTornEdge: hasTornEdge,
        ),
        child: Padding(
          padding: padding,
          child: child,
        ),
      ),
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: content,
      );
    }
    return content;
  }
}

/// A hand-drawn styled button with tactile feel and minimum 48dp touch target
class SketchButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? borderColor;
  final IconData? icon;
  final bool isSecondary;
  final bool isSmall;

  const SketchButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.backgroundColor,
    this.textColor,
    this.borderColor,
    this.icon,
    this.isSecondary = false,
    this.isSmall = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Color bg;
    Color fg;
    Color border;

    if (isSecondary) {
      bg = Colors.transparent;
      fg = isDark ? SketchPalette.inkCream : SketchPalette.inkDark;
      border = isDark ? SketchPalette.borderDark : SketchPalette.borderLight;
    } else {
      bg = backgroundColor ??
          (isDark ? SketchPalette.markerYellowDark : SketchPalette.markerYellow);
      fg = textColor ?? SketchPalette.inkDark;
      border = borderColor ??
          (isDark ? SketchPalette.inkCream : SketchPalette.borderLight);
    }

    final height = isSmall ? 38.0 : 48.0;
    final seed = (key?.hashCode ?? hashCode).abs();

    return ConstrainedBox(
      constraints: BoxConstraints(
        minHeight: height,
        minWidth: isSmall ? 64.0 : 80.0,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(8),
          child: CustomPaint(
            painter: SketchBorderPainter(
              borderColor: border,
              borderWidth: 1.5,
              cornerRadius: 6.0,
              seed: seed,
              fillColor: bg,
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isSmall ? 12.0 : 18.0,
                vertical: isSmall ? 6.0 : 12.0,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: isSmall ? 16 : 18, color: fg),
                    const SizedBox(width: 6),
                  ],
                  DefaultTextStyle(
                    style: TextStyle(
                      fontFamily: 'Caveat',
                      fontSize: isSmall ? 16 : 18,
                      fontWeight: FontWeight.bold,
                      color: fg,
                    ),
                    child: child,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A chip styled like a hand-drawn sticky label or tag
class SketchChip extends StatelessWidget {
  final String label;
  final Color? color;
  final Color? textColor;
  final IconData? icon;
  final VoidCallback? onTap;
  final bool isSelected;

  const SketchChip({
    super.key,
    required this.label,
    this.color,
    this.textColor,
    this.icon,
    this.onTap,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final chipColor = color ??
        (isSelected
            ? (isDark ? SketchPalette.markerYellowDark : SketchPalette.markerYellow)
            : (isDark ? SketchPalette.paperSurfaceDark : SketchPalette.paperSurfaceLight));
    final fgColor = textColor ?? (isDark ? SketchPalette.inkCream : SketchPalette.inkDark);
    final borderColor = isSelected
        ? (isDark ? SketchPalette.inkCream : SketchPalette.borderLight)
        : (isDark ? SketchPalette.borderDark : SketchPalette.borderSubtleLight);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: chipColor,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: borderColor, width: 1.1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 13, color: fgColor),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Caveat',
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                color: fgColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Highlighting text like a real marker pen
class MarkerHighlight extends StatelessWidget {
  final String text;
  final Color? markerColor;
  final TextStyle? style;

  const MarkerHighlight({
    super.key,
    required this.text,
    this.markerColor,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final highlight = markerColor ??
        (isDark
            ? SketchPalette.markerYellowDark.withValues(alpha: 0.4)
            : SketchPalette.markerYellow.withValues(alpha: 0.55));

    return Stack(
      children: [
        Positioned(
          left: 0,
          right: 0,
          bottom: 2,
          height: 10,
          child: Container(
            decoration: BoxDecoration(
              color: highlight,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
        Text(
          text,
          style: style ??
              Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
        ),
      ],
    );
  }
}

/// Hand-drawn doodle divider with subtle wavy sketch line
class DoodleDivider extends StatelessWidget {
  final Color? color;
  final double height;

  const DoodleDivider({super.key, this.color, this.height = 20});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final strokeColor = color ??
        (isDark ? SketchPalette.borderSubtleDark : SketchPalette.borderSubtleLight);

    return SizedBox(
      height: height,
      child: CustomPaint(
        painter: _DoodleDividerPainter(strokeColor),
        size: Size.infinite,
      ),
    );
  }
}

class _DoodleDividerPainter extends CustomPainter {
  final Color color;
  _DoodleDividerPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    final y = size.height / 2;
    path.moveTo(0, y);

    const segments = 12;
    final segW = size.width / segments;
    for (int i = 0; i < segments; i++) {
      final x1 = (i + 0.5) * segW;
      final x2 = (i + 1) * segW;
      final dy = (i % 2 == 0) ? -1.5 : 1.5;
      path.quadraticBezierTo(x1, y + dy, x2, y);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Hand-drawn progress bar with sketchbook hatch/fill
class HandDrawnProgressBar extends StatelessWidget {
  final double progress; // 0.0 to 1.0
  final Color? color;
  final double height;

  const HandDrawnProgressBar({
    super.key,
    required this.progress,
    this.color,
    this.height = 10,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fill = color ?? (isDark ? SketchPalette.sageGreen : SketchPalette.sageGreen);
    final border = isDark ? SketchPalette.borderDark : SketchPalette.borderLight;
    final clamped = progress.clamp(0.0, 1.0);

    return SizedBox(
      height: height,
      child: CustomPaint(
        painter: _HandDrawnProgressBarPainter(
          progress: clamped,
          fillColor: fill,
          borderColor: border,
        ),
        size: Size.infinite,
      ),
    );
  }
}

class _HandDrawnProgressBarPainter extends CustomPainter {
  final double progress;
  final Color fillColor;
  final Color borderColor;

  _HandDrawnProgressBarPainter({
    required this.progress,
    required this.fillColor,
    required this.borderColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final r = Rect.fromLTWH(0, 0, size.width, size.height);
    final borderPaint = Paint()
      ..color = borderColor
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    // Draw rough outline
    canvas.drawRRect(RRect.fromRectAndRadius(r, const Radius.circular(4)), borderPaint);

    if (progress > 0) {
      final fillR = Rect.fromLTWH(1, 1, (size.width - 2) * progress, size.height - 2);
      final fillPaint = Paint()
        ..color = fillColor
        ..style = PaintingStyle.fill;
      canvas.drawRRect(RRect.fromRectAndRadius(fillR, const Radius.circular(3)), fillPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _HandDrawnProgressBarPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.fillColor != fillColor ||
        oldDelegate.borderColor != borderColor;
  }
}
