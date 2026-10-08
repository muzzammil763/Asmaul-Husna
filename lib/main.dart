import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'src/home/home_screen.dart';
import 'src/settings/settings_store.dart';
import 'src/splash/splash_screen.dart';
import 'src/ui/theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SettingsStore.instance.load();
  _registerFontLicenses();
  runApp(const AsmaulHusnaApp());
}

/// The Open Font License travels with Google Sans and Boldonse; Flutter's
/// licence page (Settings → Open-source licences) lists them.
void _registerFontLicenses() {
  for (final (font, file) in const [
    ('Google Sans', 'GoogleSans-OFL.txt'),
    ('Boldonse', 'Boldonse-OFL.txt'),
  ]) {
    LicenseRegistry.addLicense(() async* {
      final text = await rootBundle.loadString('assets/licenses/$file');
      yield LicenseEntryWithLineBreaks([font], text);
    });
  }
}

class AsmaulHusnaApp extends StatelessWidget {
  const AsmaulHusnaApp({super.key});

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: SettingsStore.instance,
    builder: (context, _) => MaterialApp(
      title: 'Asmaul Husna',
      debugShowCheckedModeBanner: false,
      themeMode: SettingsStore.instance.themeMode,
      theme: buildTheme(Brightness.light),
      darkTheme: buildTheme(Brightness.dark),
      // Status and navigation bars follow whichever theme is showing.
      builder: (context, child) {
        final base = context.isDark
            ? SystemUiOverlayStyle.light
            : SystemUiOverlayStyle.dark;
        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: base.copyWith(
            statusBarColor: Colors.transparent,
            systemNavigationBarColor: context.palette.background,
          ),
          child: child!,
        );
      },
      home: const SplashScreen(next: HomeScreen()),
    ),
  );
}
