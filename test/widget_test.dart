import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:guideline_app/models.dart';

void main() {
  test('マニフェストの全PDFがassetsに存在する', () {
    final raw = File('assets/data/guidelines.json').readAsStringSync();
    final json = jsonDecode(raw) as Map<String, dynamic>;
    final items = (json['items'] as List)
        .map((e) => Guideline.fromJson(e as Map<String, dynamic>))
        .toList();

    expect(items, isNotEmpty);
    for (final g in items) {
      if (g.external) {
        expect(g.url, startsWith('http'));
      } else {
        final f = File('assets/pdfs/${g.file}');
        expect(f.existsSync(), isTrue, reason: '${g.title}: ${g.file} がない');
        expect(f.lengthSync(), greaterThan(1000));
      }
    }
  });

  test('検索正規化', () {
    expect(normalizeForSearch('ＭＥＰモニタリング'), 'mepもにたりんぐ');
    expect(normalizeForSearch('Awake Craniotomy'), 'awake craniotomy');
    expect(normalizeForSearch('アナフィラキシー'), 'あなふぃらきしー');
  });
}
