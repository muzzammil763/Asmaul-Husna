import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'theme.dart';

/// Boldonse title whose last word is picked out in the accent colour.
class EditorialTitle extends StatelessWidget {
  const EditorialTitle(this.text, {super.key, this.size = 27, this.textAlign});
  final String text;
  final double size;
  final TextAlign? textAlign;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final split = text.lastIndexOf(RegExp(r'[ \n]'));
    final lead = split < 0 ? '' : text.substring(0, split + 1);
    final accent = split < 0 ? text : text.substring(split + 1);
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(text: lead),
          TextSpan(
            text: accent,
            style: TextStyle(color: p.accent),
          ),
        ],
      ),
      textAlign: textAlign,
      style: TextStyle(
        fontFamily: AppFonts.display,
        fontSize: context.r(size),
        height: 1.5,
        letterSpacing: -.8,
        color: p.title,
      ),
    );
  }
}

class Eyebrow extends StatelessWidget {
  const Eyebrow(this.text, {super.key, this.color});
  final String text;
  final Color? color;

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: TextStyle(
      color: color ?? context.palette.accent,
      fontSize: context.r(12),
      height: 1.3,
      fontWeight: FontWeight.w800,
      letterSpacing: 1.6,
    ),
  );
}

/// Eight-pointed star (Rub el Hizb) holding a number.
class StarBadge extends StatelessWidget {
  const StarBadge({
    super.key,
    required this.label,
    this.size = 32,
    this.color,
    this.textColor,
    this.outline,
  });

  final String label;
  final double size;
  final Color? color;
  final Color? textColor;
  final Color? outline;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return SizedBox.square(
      dimension: size,
      child: CustomPaint(
        painter: _StarPainter(color ?? p.accentDeep, outline),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: size * (label.length > 2 ? .26 : .3),
              fontWeight: FontWeight.w700,
              color: textColor ?? (context.isDark ? p.title : p.accent),
            ),
          ),
        ),
      ),
    );
  }
}

class _StarPainter extends CustomPainter {
  const _StarPainter(this.color, this.outline);
  final Color color;
  final Color? outline;

  @override
  void paint(Canvas canvas, Size size) {
    final path = starPath(size.center(Offset.zero), size.width / 2);
    canvas.drawPath(path, Paint()..color = color);
    if (outline != null) {
      canvas.drawPath(
        path,
        Paint()
          ..color = outline!
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _StarPainter old) =>
      old.color != color || old.outline != outline;
}

/// Two overlapping squares, rotated 45° apart.
Path starPath(Offset center, double radius) {
  final side = radius * 1.5;
  Path square(double angle) {
    final p = Path();
    for (var i = 0; i < 4; i++) {
      final a = angle + i * math.pi / 2 + math.pi / 4;
      final pt = center + Offset(math.cos(a), math.sin(a)) * side / math.sqrt2;
      i == 0 ? p.moveTo(pt.dx, pt.dy) : p.lineTo(pt.dx, pt.dy);
    }
    return p..close();
  }

  return Path.combine(PathOperation.union, square(0), square(math.pi / 4));
}

/// Geometric motifs for backgrounds; each surface uses its own.
enum PatternStyle { stars, hexagons, rosettes }

/// Faint repeating Islamic geometric pattern.
class IslamicPattern extends StatelessWidget {
  const IslamicPattern({
    super.key,
    this.opacity = .07,
    this.cell = 64,
    this.style = PatternStyle.stars,
    this.color,
  });

  final double opacity;
  final double cell;
  final PatternStyle style;
  final Color? color;

  @override
  Widget build(BuildContext context) => RepaintBoundary(
    child: CustomPaint(
      painter: _PatternPainter(
        (color ?? context.palette.patternInk).withValues(alpha: opacity),
        cell,
        style,
      ),
      size: Size.infinite,
    ),
  );
}

class _PatternPainter extends CustomPainter {
  const _PatternPainter(this.color, this.cell, this.style);
  final Color color;
  final double cell;
  final PatternStyle style;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    var row = 0;
    for (var y = -cell; y < size.height + cell; y += cell, row++) {
      // Hexagons and rosettes tile on offset rows.
      final shift = style != PatternStyle.stars && row.isOdd ? cell / 2 : 0.0;
      for (var x = -cell + shift; x < size.width + cell; x += cell) {
        _motif(canvas, Offset(x, y), paint);
      }
    }
  }

  void _motif(Canvas canvas, Offset c, Paint paint) {
    switch (style) {
      case PatternStyle.stars:
        canvas.drawPath(starPath(c, cell * .34), paint);
        canvas.drawCircle(c, cell * .12, paint);
        canvas.drawLine(
          c + Offset(cell * .36, 0),
          c + Offset(cell * .64, 0),
          paint,
        );
        canvas.drawLine(
          c + Offset(0, cell * .36),
          c + Offset(0, cell * .64),
          paint,
        );
      case PatternStyle.hexagons:
        canvas.drawPath(_polygon(c, cell * .5, 6, math.pi / 6), paint);
        canvas.drawPath(_polygon(c, cell * .22, 6, 0), paint);
      case PatternStyle.rosettes:
        for (var i = 0; i < 6; i++) {
          final a = i * math.pi / 3;
          canvas.drawCircle(
            c + Offset(math.cos(a), math.sin(a)) * cell * .25,
            cell * .25,
            paint,
          );
        }
    }
  }

  static Path _polygon(Offset c, double r, int sides, double rotation) {
    final p = Path();
    for (var i = 0; i < sides; i++) {
      final a = rotation + i * 2 * math.pi / sides;
      final pt = c + Offset(math.cos(a), math.sin(a)) * r;
      i == 0 ? p.moveTo(pt.dx, pt.dy) : p.lineTo(pt.dx, pt.dy);
    }
    return p..close();
  }

  @override
  bool shouldRepaint(covariant _PatternPainter old) =>
      old.color != color || old.style != style || old.cell != cell;
}

/// Card with the star-lattice pattern behind its content, tinted by [tint].
class PatternCard extends StatelessWidget {
  const PatternCard({
    super.key,
    required this.child,
    this.tint,
    this.padding = const EdgeInsets.all(12),
    this.radius = 18,
    this.intensity = 1,
    this.highlight = false,
    this.onTap,
  });

  final Widget child;

  /// Defaults to the accent colour.
  final Color? tint;
  final EdgeInsetsGeometry padding;
  final double radius;

  /// Scales how strongly the tint shows (0 = neutral card).
  final double intensity;

  /// Stronger border and glow, e.g. for the hero card.
  final bool highlight;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final tint = this.tint ?? p.accent;
    final shape = BorderRadius.circular(radius);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      decoration: BoxDecoration(
        borderRadius: shape,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color.lerp(p.surface, tint, .08 * intensity)!, p.surface],
        ),
        border: Border.all(
          color: highlight ? tint : Color.lerp(p.border, tint, .3 * intensity)!,
          width: highlight ? 1.6 : 1,
        ),
        boxShadow: [
          if (highlight)
            BoxShadow(color: tint.withValues(alpha: .14), blurRadius: 24)
          else if (!context.isDark)
            BoxShadow(
              color: p.shadow,
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      child: ClipRRect(
        borderRadius: shape,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            child: Stack(
              fit: StackFit.passthrough,
              children: [
                Positioned.fill(
                  child: IslamicPattern(
                    color: Color.lerp(p.patternInk, tint, .5),
                    opacity: (context.isDark ? .03 : .04) + .02 * intensity,
                    cell: 48,
                  ),
                ),
                Padding(padding: padding, child: child),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Small rounded icon button used in screen headers.
class HeaderButton extends StatelessWidget {
  const HeaderButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.active = false,
    this.tooltip,
  });

  final IconData icon;
  final VoidCallback onTap;
  final bool active;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final button = Material(
      color: active ? p.accent.withValues(alpha: .16) : p.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(32),
        side: BorderSide(color: active ? p.accent : p.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox.square(
          dimension: 42,
          child: Icon(icon, size: 20, color: active ? p.accent : p.title),
        ),
      ),
    );
    return tooltip == null ? button : Tooltip(message: tooltip, child: button);
  }
}
