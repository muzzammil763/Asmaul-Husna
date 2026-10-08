import 'package:flutter/material.dart';

import '../ui/theme.dart';
import '../ui/widgets.dart';

/// Brief opening: the name of Allah, then fades to [next].
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key, required this.next});
  final Widget next;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..forward();

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 1600), () {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 450),
          pageBuilder: (_, _, _) => widget.next,
          transitionsBuilder: (_, animation, _, child) =>
              FadeTransition(opacity: animation, child: child),
        ),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    return Scaffold(
      body: Stack(
        children: [
          const Positioned.fill(
            child: IslamicPattern(style: PatternStyle.rosettes, cell: 72),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [
                    p.accent.withValues(alpha: .18),
                    p.background.withValues(alpha: 0),
                  ],
                ),
              ),
            ),
          ),
          Center(
            child: FadeTransition(
              opacity: fade,
              child: ScaleTransition(
                scale: Tween(begin: .92, end: 1.0).animate(fade),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'ٱللَّٰهُ',
                      textDirection: TextDirection.rtl,
                      style: TextStyle(
                        fontFamily: AppFonts.arabic,
                        fontSize: context.r(110),
                        height: 1.4,
                        color: p.gold,
                      ),
                    ),
                    SizedBox(height: context.r(20)),
                    const EditorialTitle('Asmaul Husna', size: 26),
                    SizedBox(height: context.r(10)),
                    Eyebrow('THE 99 BEAUTIFUL NAMES', color: p.muted),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
