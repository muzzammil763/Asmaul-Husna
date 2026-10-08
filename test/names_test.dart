import 'package:asmaul_husna/src/data/names.dart';
import 'package:asmaul_husna/src/home/home_screen.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('all 99 names are present, numbered in order and filled in', () {
    expect(names, hasLength(99));
    for (final (i, n) in names.indexed) {
      expect(n.number, i + 1);
      for (final field in [
        n.arabic,
        n.transliteration,
        n.english,
        n.urdu,
        n.explanation,
      ]) {
        expect(field.trim(), isNotEmpty, reason: 'name ${n.number}');
      }
    }
  });

  test('search ignores case, punctuation and Arabic diacritics', () {
    expect(normalizeForSearch('Ar-Rahman'), 'arrahman');
    expect(normalizeForSearch("Al-Mu'min"), 'almumin');
    expect(normalizeForSearch('ٱلرَّحْمَٰنُ'), normalizeForSearch('الرحمن'));
  });
}
