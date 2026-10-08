import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../data/names.dart';
import '../detail/name_detail_screen.dart';
import '../settings/settings_screen.dart';
import '../settings/settings_store.dart';
import '../ui/theme.dart';
import '../ui/widgets.dart';
import 'name_cards.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _search = TextEditingController();
  String _query = '';
  bool _favouritesOnly = false;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  List<DivineName> _visible(SettingsStore s) {
    final q = normalizeForSearch(_query);
    return [
      for (final n in names)
        if ((!_favouritesOnly || s.isFavourite(n.number)) &&
            (q.isEmpty || _matches(n, q)))
          n,
    ];
  }

  static bool _matches(DivineName n, String q) =>
      '${n.number}' == q ||
      normalizeForSearch(n.transliteration).contains(q) ||
      normalizeForSearch(n.english).contains(q) ||
      normalizeForSearch(n.arabic).contains(q) ||
      normalizeForSearch(n.urdu).contains(q);

  void _open(List<DivineName> list, int index) {
    FocusScope.of(context).unfocus();
    Navigator.of(context).push(
      CupertinoPageRoute(
        builder: (_) => NameDetailScreen(names: list, initialIndex: index),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: SettingsStore.instance,
    builder: (context, _) => _build(context, SettingsStore.instance),
  );

  Widget _build(BuildContext context, SettingsStore s) {
    final list = _visible(s);
    final side = context.r(18);
    return Scaffold(
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: CustomScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          slivers: [
            SliverSafeArea(
              bottom: false,
              sliver: SliverPadding(
                padding: EdgeInsets.fromLTRB(side, context.r(12), side, 0),
                sliver: SliverList.list(
                  children: [
                    Row(
                      children: [
                        Expanded(child: Eyebrow('99 BEAUTIFUL NAMES')),
                        HeaderButton(
                          icon: s.gridLayout
                              ? Icons.view_agenda_outlined
                              : Icons.grid_view_rounded,
                          tooltip: s.gridLayout ? 'List view' : 'Grid view',
                          onTap: () => s.setGridLayout(!s.gridLayout),
                        ),
                        const SizedBox(width: 8),
                        HeaderButton(
                          icon: Icons.tune_rounded,
                          tooltip: 'Settings',
                          onTap: () => Navigator.of(context).push(
                            CupertinoPageRoute(
                              builder: (_) => const SettingsScreen(),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: context.r(10)),
                    const EditorialTitle('Asmaul\nHusna', size: 30),
                    SizedBox(height: context.r(18)),
                    const _VerseCard(),
                    SizedBox(height: context.r(18)),
                    _SearchField(
                      controller: _search,
                      onChanged: (v) => setState(() => _query = v),
                    ),
                    SizedBox(height: context.r(12)),
                    Row(
                      children: [
                        _FilterChip(
                          label: 'All 99',
                          selected: !_favouritesOnly,
                          onTap: () => setState(() => _favouritesOnly = false),
                        ),
                        const SizedBox(width: 8),
                        _FilterChip(
                          label: 'Favourites  ${s.favourites.length}',
                          icon: Icons.favorite_rounded,
                          selected: _favouritesOnly,
                          onTap: () => setState(() => _favouritesOnly = true),
                        ),
                      ],
                    ),
                    SizedBox(height: context.r(14)),
                  ],
                ),
              ),
            ),
            if (list.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: _EmptyState(
                  favourites: _favouritesOnly && _query.isEmpty,
                ),
              )
            else
              SliverPadding(
                padding: EdgeInsets.fromLTRB(
                  side,
                  0,
                  side,
                  context.r(24) + MediaQuery.paddingOf(context).bottom,
                ),
                sliver: s.gridLayout
                    ? SliverGrid.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 10,
                          crossAxisSpacing: 10,
                          mainAxisExtent: context.r(176),
                        ),
                        itemCount: list.length,
                        itemBuilder: (_, i) => NameGridCard(
                          name: list[i],
                          onTap: () => _open(list, i),
                        ),
                      )
                    : SliverList.separated(
                        itemCount: list.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 10),
                        itemBuilder: (_, i) => NameListCard(
                          name: list[i],
                          onTap: () => _open(list, i),
                        ),
                      ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Lowercases and strips punctuation, Arabic diacritics and alif variants so
/// "ar rahman", "Ar-Rahman" and "الرحمن" all match.
String normalizeForSearch(String s) => s
    .toLowerCase()
    .replaceAll(RegExp('[ً-ٰٟۖ-ۭـ]'), '')
    .replaceAll(RegExp('[ٱآأإ]'), 'ا')
    .replaceAll(RegExp(r"[\s\-'’ʿ،,.]"), '');

/// Al-A'raf 7:180, the verse naming the beautiful names.
class _VerseCard extends StatelessWidget {
  const _VerseCard();

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final s = SettingsStore.instance;
    return PatternCard(
      tint: p.gold,
      intensity: 1.4,
      radius: 22,
      padding: EdgeInsets.fromLTRB(18, context.r(14), 18, context.r(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'وَلِلَّهِ ٱلْأَسْمَآءُ ٱلْحُسْنَىٰ فَٱدْعُوهُ بِهَا',
            textAlign: TextAlign.center,
            textDirection: TextDirection.rtl,
            style: TextStyle(
              fontFamily: AppFonts.arabic,
              fontSize: context.r(31),
              height: 1.7,
              wordSpacing: 6,
              color: p.gold,
            ),
          ),
          if (s.showUrdu)
            Text(
              'اور اللہ کے سب نام اچھے ہی اچھے ہیں، تو اسے انہی ناموں سے پکارو',
              textAlign: TextAlign.center,
              textDirection: TextDirection.rtl,
              style: TextStyle(
                fontFamily: AppFonts.urdu,
                fontSize: context.r(19),
                height: 1.6,
                color: p.body,
              ),
            ),
          if (s.showEnglish) ...[
            const SizedBox(height: 4),
            Text(
              'To Allah belong the most beautiful names, so call upon Him by them.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: context.r(13), color: p.body),
            ),
          ],
          const SizedBox(height: 6),
          Text(
            "AL-A'RAF 7:180",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.4,
              color: p.muted,
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({required this.controller, required this.onChanged});
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) => Container(
        height: 48,
        decoration: BoxDecoration(
          color: p.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: p.border),
        ),
        child: Row(
          children: [
            const SizedBox(width: 14),
            Icon(Icons.search_rounded, size: 20, color: p.muted),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: controller,
                onChanged: onChanged,
                textInputAction: TextInputAction.search,
                style: TextStyle(fontSize: 15, color: p.title),
                decoration: InputDecoration(
                  isCollapsed: true,
                  border: InputBorder.none,
                  hintText: 'Search name, meaning or number',
                  hintStyle: TextStyle(fontSize: 15, color: p.faint),
                ),
              ),
            ),
            if (controller.text.isNotEmpty)
              IconButton(
                icon: Icon(Icons.close_rounded, size: 18, color: p.muted),
                onPressed: () {
                  controller.clear();
                  onChanged('');
                },
              )
            else
              const SizedBox(width: 14),
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.icon,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final fg = selected ? p.onAccent : p.body;
    return Material(
      color: selected ? p.accent : p.surface,
      shape: StadiumBorder(
        side: BorderSide(color: selected ? p.accent : p.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 14, color: selected ? p.onAccent : p.gold),
                const SizedBox(width: 6),
              ],
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: fg,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.favourites});
  final bool favourites;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Padding(
      padding: const EdgeInsets.fromLTRB(32, 24, 32, 48),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            favourites
                ? Icons.favorite_border_rounded
                : Icons.search_off_rounded,
            size: 36,
            color: p.faint,
          ),
          const SizedBox(height: 12),
          Text(
            favourites ? 'No favourites yet' : 'No matching names',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: p.title,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            favourites
                ? 'Open a name and tap the heart to keep it here.'
                : 'Try a transliteration, an English meaning or a number.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: p.muted),
          ),
        ],
      ),
    );
  }
}
