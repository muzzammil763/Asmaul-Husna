import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../ui/theme.dart';
import '../ui/widgets.dart';
import 'settings_store.dart';

const appVersion = '1.0.0';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = SettingsStore.instance;
    return ListenableBuilder(
      listenable: s,
      builder: (context, _) {
        final p = context.palette;
        return Scaffold(
          body: SafeArea(
            bottom: false,
            child: ListView(
              padding: EdgeInsets.fromLTRB(
                context.r(18),
                context.r(8),
                context.r(18),
                24 + MediaQuery.paddingOf(context).bottom,
              ),
              children: [
                Row(
                  children: [
                    HeaderButton(
                      icon: Icons.arrow_back_rounded,
                      tooltip: 'Back',
                      onTap: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                SizedBox(height: context.r(16)),
                const EditorialTitle('Your Settings', size: 26),
                SizedBox(height: context.r(22)),
                const Eyebrow('APPEARANCE'),
                const SizedBox(height: 10),
                Row(
                  children: [
                    for (final (mode, icon, label) in const [
                      (
                        ThemeMode.system,
                        Icons.brightness_auto_rounded,
                        'System',
                      ),
                      (ThemeMode.light, Icons.light_mode_rounded, 'Light'),
                      (ThemeMode.dark, Icons.dark_mode_rounded, 'Dark'),
                    ]) ...[
                      if (mode != ThemeMode.system) const SizedBox(width: 10),
                      Expanded(
                        child: _ThemeOption(
                          icon: icon,
                          label: label,
                          selected: s.themeMode == mode,
                          onTap: () => s.setThemeMode(mode),
                        ),
                      ),
                    ],
                  ],
                ),
                SizedBox(height: context.r(24)),
                const Eyebrow('SHOW ON CARDS'),
                const SizedBox(height: 10),
                PatternCard(
                  intensity: .4,
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Column(
                    children: [
                      _SwitchRow(
                        title: 'Transliteration',
                        subtitle: 'Ar-Rahman',
                        value: s.showTransliteration,
                        onChanged: s.setShowTransliteration,
                      ),
                      Divider(
                        height: 1,
                        indent: 16,
                        endIndent: 16,
                        color: p.border,
                      ),
                      _SwitchRow(
                        title: 'English meaning',
                        subtitle: 'The Most Gracious',
                        value: s.showEnglish,
                        onChanged: s.setShowEnglish,
                      ),
                      Divider(
                        height: 1,
                        indent: 16,
                        endIndent: 16,
                        color: p.border,
                      ),
                      _SwitchRow(
                        title: 'Urdu meaning',
                        subtitle: 'بے حد مہربان',
                        urduSubtitle: true,
                        value: s.showUrdu,
                        onChanged: s.setShowUrdu,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: context.r(24)),
                const Eyebrow('ARABIC TEXT SIZE'),
                const SizedBox(height: 10),
                PatternCard(
                  intensity: .4,
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  child: Column(
                    children: [
                      SizedBox(
                        height: 90,
                        child: Center(
                          child: Text(
                            'ٱلرَّحْمَٰنُ',
                            textDirection: TextDirection.rtl,
                            style: TextStyle(
                              fontFamily: AppFonts.arabic,
                              fontSize: 42 * s.arabicScale,
                              height: 1.5,
                              color: p.title,
                            ),
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          Text(
                            'A',
                            style: TextStyle(fontSize: 13, color: p.muted),
                          ),
                          Expanded(
                            child: Slider.adaptive(
                              value: s.arabicScale,
                              min: .8,
                              max: 1.4,
                              divisions: 6,
                              onChanged: s.setArabicScale,
                            ),
                          ),
                          Text(
                            'A',
                            style: TextStyle(fontSize: 20, color: p.muted),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: context.r(24)),
                const Eyebrow('ABOUT'),
                const SizedBox(height: 10),
                PatternCard(
                  tint: p.gold,
                  intensity: .8,
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Asmaul Husna',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: p.title,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'The 99 beautiful names of Allah with transliteration '
                        'and English and Urdu meanings. Works fully offline: '
                        'no account, no internet, no tracking.',
                        style: TextStyle(
                          fontSize: 13.5,
                          height: 1.5,
                          color: p.body,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Version $appVersion',
                        style: TextStyle(fontSize: 12, color: p.muted),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: context.r(24)),
                const Eyebrow('FONTS & CREDITS'),
                const SizedBox(height: 10),
                PatternCard(
                  intensity: .4,
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Column(
                    children: [
                      for (final (i, credit) in _fontCredits.indexed) ...[
                        if (i > 0)
                          Divider(
                            height: 1,
                            indent: 16,
                            endIndent: 16,
                            color: p.border,
                          ),
                        _CreditRow(credit),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Center(
                  child: TextButton(
                    onPressed: () => showLicensePage(
                      context: context,
                      applicationName: 'Asmaul Husna',
                      applicationVersion: appVersion,
                    ),
                    child: const Text('Open-source licences'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

typedef _FontCredit = ({
  String font,
  String usedFor,
  String note,
  String source,
  String url,
});

const List<_FontCredit> _fontCredits = [
  (
    font: 'Jameel Noori Nastaleeq',
    usedFor: 'Urdu',
    note: 'Free of charge for Urdu lovers',
    source: 'urdufonts.net',
    url: 'https://urdufonts.net/fonts/jameel-noori-nastaleeq-regular',
  ),
  (
    font: 'PDMS Saleem Quran',
    usedFor: 'Arabic',
    note: '© 2001 Pakistan Data Management Services',
    source: 'urdunigaar.com',
    url:
        'https://urdunigaar.com/download/pdms-saleem-quran-font-ttf-file-download/',
  ),
  (
    font: 'Google Sans',
    usedFor: 'Text',
    note: 'SIL Open Font License 1.1',
    source: 'Google Fonts',
    url: 'https://fonts.google.com/specimen/Google+Sans',
  ),
  (
    font: 'Boldonse',
    usedFor: 'Titles',
    note: 'SIL Open Font License 1.1',
    source: 'Google Fonts',
    url: 'https://fonts.google.com/specimen/Boldonse',
  ),
];

/// One font with its source. The app is offline, so tapping copies the link
/// instead of opening it.
class _CreditRow extends StatelessWidget {
  const _CreditRow(this.credit);
  final _FontCredit credit;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return InkWell(
      onTap: () {
        Clipboard.setData(ClipboardData(text: credit.url));
        showToast(context, 'Link to ${credit.source} copied');
      },
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 14, 12),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${credit.font} · ${credit.usedFor}',
                    style: TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w600,
                      color: p.title,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    credit.note,
                    style: TextStyle(fontSize: 12.5, color: p.muted),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Source: ${credit.source}',
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: p.accent,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.link_rounded, size: 18, color: p.faint),
          ],
        ),
      ),
    );
  }
}

class _ThemeOption extends StatelessWidget {
  const _ThemeOption({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return PatternCard(
      highlight: selected,
      intensity: selected ? 1.6 : .3,
      onTap: onTap,
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        children: [
          Icon(icon, color: selected ? p.accent : p.muted),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: selected ? p.title : p.body,
            ),
          ),
        ],
      ),
    );
  }
}

class _SwitchRow extends StatelessWidget {
  const _SwitchRow({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
    this.urduSubtitle = false,
  });

  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool urduSubtitle;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return InkWell(
      onTap: () => onChanged(!value),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 10, 8),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: p.title,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: urduSubtitle
                        ? TextStyle(
                            fontFamily: AppFonts.urdu,
                            fontSize: 18,
                            height: 1.5,
                            color: p.muted,
                          )
                        : TextStyle(fontSize: 12.5, color: p.muted),
                  ),
                ],
              ),
            ),
            Switch.adaptive(
              value: value,
              activeTrackColor: p.accent,
              onChanged: onChanged,
            ),
          ],
        ),
      ),
    );
  }
}
