import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/names.dart';
import '../settings/settings_store.dart';
import '../ui/theme.dart';
import '../ui/widgets.dart';

/// One name per page; swipe between the names shown on the home screen.
class NameDetailScreen extends StatefulWidget {
  const NameDetailScreen({
    super.key,
    required this.names,
    required this.initialIndex,
  });

  final List<DivineName> names;
  final int initialIndex;

  @override
  State<NameDetailScreen> createState() => _NameDetailScreenState();
}

class _NameDetailScreenState extends State<NameDetailScreen> {
  late final _pages = PageController(initialPage: widget.initialIndex);
  late int _index = widget.initialIndex;

  DivineName get _name => widget.names[_index];

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  void _go(int delta) => _pages.animateToPage(
    _index + delta,
    duration: const Duration(milliseconds: 320),
    curve: Curves.easeOutCubic,
  );

  void _copy() {
    final n = _name;
    Clipboard.setData(
      ClipboardData(
        text:
            '${n.number}. ${n.arabic}\n'
            '${n.transliteration} — ${n.english}\n'
            '${n.urdu}\n\n'
            '${n.explanation}',
      ),
    );
    showToast(context, 'Copied ${n.transliteration}');
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final s = SettingsStore.instance;
    return ListenableBuilder(
      listenable: s,
      builder: (context, _) => Scaffold(
        body: Stack(
          children: [
            const Positioned.fill(
              child: IslamicPattern(
                style: PatternStyle.hexagons,
                cell: 70,
                opacity: .035,
              ),
            ),
            SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
                    child: Row(
                      children: [
                        HeaderButton(
                          icon: Icons.arrow_back_rounded,
                          tooltip: 'Back',
                          onTap: () => Navigator.of(context).pop(),
                        ),
                        Expanded(
                          child: Text(
                            '${_name.number} of 99',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: p.muted,
                            ),
                          ),
                        ),
                        HeaderButton(
                          icon: Icons.copy_rounded,
                          tooltip: 'Copy',
                          onTap: _copy,
                        ),
                        const SizedBox(width: 8),
                        HeaderButton(
                          icon: s.isFavourite(_name.number)
                              ? Icons.favorite_rounded
                              : Icons.favorite_border_rounded,
                          tooltip: 'Favourite',
                          active: s.isFavourite(_name.number),
                          onTap: () {
                            HapticFeedback.selectionClick();
                            s.toggleFavourite(_name.number);
                          },
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: PageView.builder(
                      controller: _pages,
                      itemCount: widget.names.length,
                      onPageChanged: (i) => setState(() => _index = i),
                      itemBuilder: (_, i) => _NamePage(name: widget.names[i]),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 6, 12, 12),
                    child: Row(
                      children: [
                        _NavButton(
                          icon: Icons.chevron_left_rounded,
                          label: _index > 0
                              ? widget.names[_index - 1].transliteration
                              : null,
                          onTap: _index > 0 ? () => _go(-1) : null,
                        ),
                        const SizedBox(width: 8),
                        _NavButton(
                          icon: Icons.chevron_right_rounded,
                          trailingIcon: true,
                          label: _index < widget.names.length - 1
                              ? widget.names[_index + 1].transliteration
                              : null,
                          onTap: _index < widget.names.length - 1
                              ? () => _go(1)
                              : null,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NamePage extends StatelessWidget {
  const _NamePage({required this.name});
  final DivineName name;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final s = SettingsStore.instance;
    return ListView(
      padding: EdgeInsets.fromLTRB(context.r(12), 8, context.r(12), 16),
      children: [
        PatternCard(
          highlight: true,
          intensity: 2,
          radius: 16,
          padding: EdgeInsets.symmetric(
            horizontal: 12,
            vertical: context.r(24),
          ),
          child: Column(
            children: [
              Eyebrow('NAME ${name.number}', color: p.accent),
              SizedBox(height: context.r(10)),
              Padding(
                padding: EdgeInsets.symmetric(vertical: context.r(18)),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    name.arabic,
                    maxLines: 1,
                    textDirection: TextDirection.rtl,
                    style: TextStyle(
                      fontFamily: AppFonts.arabic,
                      fontSize: context.r(92) * s.arabicScale,
                      color: p.title,
                    ),
                  ),
                ),
              ),
              SizedBox(height: context.r(12)),
              if (s.showTransliteration)
                EditorialTitle(
                  name.transliteration,
                  size: 22,
                  textAlign: TextAlign.center,
                ),
              if (s.showEnglish) ...[
                const SizedBox(height: 6),
                Text(
                  name.english,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: context.r(16),
                    fontWeight: FontWeight.w600,
                    color: p.body,
                  ),
                ),
              ],
            ],
          ),
        ),
        if (s.showUrdu) ...[
          const SizedBox(height: 12),
          _InfoCard(
            eyebrow: 'URDU MEANING',
            child: Text(
              name.urdu,
              textAlign: TextAlign.right,
              textDirection: TextDirection.rtl,
              style: TextStyle(
                fontFamily: AppFonts.urdu,
                fontSize: context.r(32),
                height: 1.7,
                color: p.title,
              ),
            ),
          ),
        ],
        const SizedBox(height: 12),
        _InfoCard(
          eyebrow: 'REFLECTION',
          tint: p.gold,
          child: Text(
            name.explanation,
            style: TextStyle(fontSize: 16, height: 1.55, color: p.body),
          ),
        ),
      ],
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.eyebrow, required this.child, this.tint});
  final String eyebrow;
  final Widget child;
  final Color? tint;

  @override
  Widget build(BuildContext context) => PatternCard(
    tint: tint,
    intensity: .6,
    padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Eyebrow(eyebrow, color: tint),
        const SizedBox(height: 6),
        child,
      ],
    ),
  );
}

class _NavButton extends StatelessWidget {
  const _NavButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.trailingIcon = false,
  });

  final IconData icon;
  final String? label;
  final VoidCallback? onTap;
  final bool trailingIcon;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final enabled = onTap != null;
    final text = Flexible(
      child: Text(
        label ?? '',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: p.title,
        ),
      ),
    );
    final arrow = Icon(icon, size: 22, color: p.accent);
    return Expanded(
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: enabled ? 1 : .35,
        child: Material(
          color: p.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: BorderSide(color: p.border),
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: SizedBox(
              height: 48,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: trailingIcon
                    ? [
                        const SizedBox(width: 12),
                        text,
                        arrow,
                        const SizedBox(width: 8),
                      ]
                    : [
                        const SizedBox(width: 8),
                        arrow,
                        text,
                        const SizedBox(width: 12),
                      ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
