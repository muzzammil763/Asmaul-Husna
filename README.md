# Asmaul Husna

The 99 beautiful names of Allah — Arabic, transliteration, English and Urdu
meanings, with a short reflection for each. Fully offline: no account, no
network permission, no analytics.

- Package / bundle ID: `com.muzamil.asmaulhusna`
- Themes: System, Light, Dark (royal indigo + gold)
- Content: `lib/src/data/names.dart`

## Fonts

`assets/fonts/` holds fonts trimmed to the characters the app uses. After
changing any text in `lib/`, regenerate them from the full fonts in
`tool/fonts_src/`:

    pip install fonttools
    python3 tool/subset_fonts.py

Characters missing from a trimmed font fall back to the system font.

## Release

    flutter build apk --release --split-per-abi
    flutter build appbundle --release
    flutter build ipa --release

Android release builds are still signed with the debug key — add a signing
config in `android/app/build.gradle.kts` before publishing.
