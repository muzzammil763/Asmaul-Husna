import 'package:flutter/material.dart';

import '../data/names.dart';
import '../settings/settings_store.dart';
import '../ui/theme.dart';
import '../ui/widgets.dart';

/// Compact card for the two-column grid: number, Arabic, transliteration and
/// one line of meaning.
class NameGridCard extends StatelessWidget {
  const NameGridCard({super.key, required this.name, required this.onTap});
  final DivineName name;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final s = SettingsStore.instance;
    final favourite = s.isFavourite(name.number);
    return PatternCard(
      onTap: onTap,
      intensity: favourite ? 1.4 : .7,
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              StarBadge(label: '${name.number}', size: 30),
              const Spacer(),
              if (favourite)
                Icon(Icons.favorite_rounded, size: 16, color: p.gold),
            ],
          ),
          Expanded(
            child: Center(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  name.arabic,
                  maxLines: 1,
                  textDirection: TextDirection.rtl,
                  style: TextStyle(
                    fontFamily: AppFonts.arabic,
                    fontSize: context.r(30) * s.arabicScale,
                    height: 1.9,
                    color: p.title,
                  ),
                ),
              ),
            ),
          ),
          if (s.showTransliteration)
            Text(
              name.transliteration,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: context.r(14),
                fontWeight: FontWeight.w700,
                color: p.accent,
              ),
            ),
          if (s.showEnglish) ...[
            const SizedBox(height: 3),
            Text(
              name.english,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: context.r(12), color: p.muted),
            ),
          ] else if (s.showUrdu)
            Text(
              name.urdu,
              textAlign: TextAlign.center,
              textDirection: TextDirection.rtl,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: AppFonts.urdu,
                fontSize: context.r(12),
                height: 1.9,
                color: p.muted,
              ),
            ),
        ],
      ),
    );
  }
}

/// Full-width card: number and meanings on the left, Arabic on the right.
class NameListCard extends StatelessWidget {
  const NameListCard({super.key, required this.name, required this.onTap});
  final DivineName name;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final s = SettingsStore.instance;
    final favourite = s.isFavourite(name.number);
    return PatternCard(
      onTap: onTap,
      intensity: favourite ? 1.4 : .7,
      padding: const EdgeInsets.fromLTRB(12, 12, 16, 12),
      child: Row(
        children: [
          StarBadge(label: '${name.number}', size: 36),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (s.showTransliteration)
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          name.transliteration,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: p.accent,
                          ),
                        ),
                      ),
                      if (favourite) ...[
                        const SizedBox(width: 6),
                        Icon(Icons.favorite_rounded, size: 14, color: p.gold),
                      ],
                    ],
                  ),
                if (s.showEnglish)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      name.english,
                      style: TextStyle(fontSize: 13, color: p.body),
                    ),
                  ),
                if (s.showUrdu)
                  Text(
                    name.urdu,
                    textDirection: TextDirection.rtl,
                    style: TextStyle(
                      fontFamily: AppFonts.urdu,
                      fontSize: 12.5,
                      height: 2,
                      color: p.muted,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: context.r(130)),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerRight,
              child: Text(
                name.arabic,
                maxLines: 1,
                textDirection: TextDirection.rtl,
                style: TextStyle(
                  fontFamily: AppFonts.arabic,
                  fontSize: 26 * s.arabicScale,
                  height: 1.9,
                  color: p.title,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
