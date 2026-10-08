// Renders AppLogo to 1024px PNGs in branding/. Run via tool/icon/make_icons.sh.
import 'dart:io';
import 'dart:ui' as ui;

import 'package:asmaul_husna/src/ui/app_logo.dart';
import 'package:asmaul_husna/src/ui/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

const _size = 1024.0;

/// Adaptive icons are 108dp, of which launchers show at least the middle
/// 66dp; keep the lettering well inside that.
const _adaptiveText = .33;

void main() {
  setUpAll(() async {
    final bytes = File('assets/fonts/PDMSSaleemQuran.ttf').readAsBytesSync();
    await (FontLoader(
      AppFonts.arabic,
    )..addFont(Future.value(ByteData.view(bytes.buffer)))).load();
  });

  for (final (layer, file, textScale) in const [
    (LogoLayer.full, 'icon_1024.png', .47),
    (LogoLayer.background, 'icon_background_1024.png', .47),
    (LogoLayer.foreground, 'icon_foreground_1024.png', _adaptiveText),
    (LogoLayer.monochrome, 'icon_monochrome_1024.png', _adaptiveText),
  ]) {
    testWidgets(file, (tester) async {
      tester.view.physicalSize = const Size(_size, _size);
      tester.view.devicePixelRatio = 1;
      final key = GlobalKey();
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Center(
            child: RepaintBoundary(
              key: key,
              child: AppLogo(size: _size, layer: layer, textScale: textScale),
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.runAsync(() async {
        final boundary =
            key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
        final image = await boundary.toImage();
        final png = await image.toByteData(format: ui.ImageByteFormat.png);
        File('branding/$file')
          ..createSync(recursive: true)
          ..writeAsBytesSync(png!.buffer.asUint8List());
      });
    });
  }
}
