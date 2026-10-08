# Asmaul Husna — agent notes

- Flutter app `com.muzamil.asmaulhusna`, Android + iOS. Fully offline: no network, no analytics; `shared_preferences` is the only package. Don't add dependencies without asking.
- Colours only via `context.palette` (`AppPalette` in `lib/src/ui/theme.dart`); every screen must look right in light and dark.
- Fonts via `AppFonts`: Google Sans (UI), Boldonse (titles), PDMS Saleem Quran (Arabic), Jameel Noori Nastaleeq (Urdu). Arabic/Urdu fonts draw small, so their sizes are large on purpose.
- Content: `lib/src/data/names.dart` — exactly 99 names in order (tested).

## tool/
- `tool/subset_fonts.py` — `assets/fonts/` are trimmed to the text in `lib/`. **After changing any text, run it** (`pip install fonttools uharfbuzz`; full fonts go in `tool/fonts_src/`, not committed — see its README). Skipping it shows missing glyphs.
- `tool/icon/make_icons.sh` — icon = `AppLogo` widget (`lib/src/ui/app_logo.dart`). After changing it, run this to regenerate all iOS/Android icons (needs ImageMagick).

## Rules
- New font → also credit it in Settings (`_fontCredits`) and README.
- Before committing: `dart format lib`, `flutter analyze`, `flutter test`.
- Small conventional commits (`feat:`, `style:`, `build:`…); push to `muzzammil763/Asmaul-Husna` (`main`).
