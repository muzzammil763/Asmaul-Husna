import 'package:flutter/material.dart';

import 'theme.dart';
import 'widgets.dart';

/// Which part of the logo to draw. The launcher icons are rendered from
/// these (see tool/icon/), so the app and its icon always match.
enum LogoLayer {
  /// Background and lettering together: the iOS and legacy Android icon.
  full,

  /// Indigo night and gold pattern only (Android adaptive background).
  background,

  /// Gold lettering on transparent (Android adaptive foreground).
  foreground,

  /// White lettering on transparent (Android 13 themed icon).
  monochrome,
}

/// "ٱللَّٰهُ" in the app's Arabic font, gold on a deep indigo night.
class AppLogo extends StatelessWidget {
  const AppLogo({
    super.key,
    this.size = 64,
    this.layer = LogoLayer.full,
    this.radius,
    this.textScale = .47,
  });

  final double size;
  final LogoLayer layer;

  /// Corner radius; null keeps square corners for the icon renders.
  final double? radius;

  /// Width of the lettering as a share of [size]; its ink is about 1.2×
  /// as tall. Adaptive icons pass less, since launchers crop to the middle.
  final double textScale;

  static const _night = Color(0xFF0B0B12);
  static const _indigo = Color(0xFF2B2E6E);
  static const _gold = Color(0xFFFFC66D);

  @override
  Widget build(BuildContext context) {
    final background = layer == LogoLayer.full || layer == LogoLayer.background;
    final lettering = layer != LogoLayer.background;
    Widget logo = SizedBox.square(
      dimension: size,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (background) ...[
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment(0, -.15),
                  radius: .85,
                  colors: [_indigo, _night],
                ),
              ),
            ),
            IslamicPattern(
              style: PatternStyle.rosettes,
              color: _gold,
              opacity: .09,
              cell: size / 4,
            ),
            // Soft halo behind the lettering.
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment(0, -.05),
                  radius: .45,
                  colors: [Color(0x33FFC66D), Color(0x00FFC66D)],
                ),
              ),
            ),
          ],
          if (lettering)
            Center(
              // The font's line box sits the ink high; nudge it to centre.
              child: Transform.translate(
                offset: Offset(0, size * textScale * .57),
                child: SizedBox(
                  width: size * textScale,
                  child: FittedBox(
                    child: Text(
                      'ٱللَّٰهُ',
                      textDirection: TextDirection.rtl,
                      style: TextStyle(
                        fontFamily: AppFonts.arabic,
                        fontSize: 100,
                        color: layer == LogoLayer.monochrome
                            ? Colors.white
                            : _gold,
                        shadows: layer == LogoLayer.monochrome
                            ? null
                            : const [
                                Shadow(color: Color(0x66000000), blurRadius: 6),
                              ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
    if (radius != null) {
      logo = ClipRRect(
        borderRadius: BorderRadius.circular(radius!),
        child: logo,
      );
    }
    return logo;
  }
}
