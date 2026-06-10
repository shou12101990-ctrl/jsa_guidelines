import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

/// ガイドライン1件分のメタデータ
class Guideline {
  final String id;
  final String title;
  final String category;
  final String url; // 原典URL(外部リンク項目はこれを開く)
  final String? file; // assets/pdfs/ 内のファイル名(PDF同梱項目のみ)
  final bool external;
  final int? size; // バイト数

  const Guideline({
    required this.id,
    required this.title,
    required this.category,
    required this.url,
    required this.external,
    this.file,
    this.size,
  });

  factory Guideline.fromJson(Map<String, dynamic> json) => Guideline(
        id: json['id'] as String,
        title: json['title'] as String,
        category: json['category'] as String,
        url: json['url'] as String,
        external: json['external'] as bool,
        file: json['file'] as String?,
        size: json['size'] as int?,
      );

  String get assetPath => 'assets/pdfs/$file';

  String get sizeLabel {
    final s = size;
    if (s == null) return '';
    if (s >= 1024 * 1024) return '${(s / 1024 / 1024).toStringAsFixed(1)} MB';
    return '${(s / 1024).round()} KB';
  }
}

class GuidelineRepository {
  final List<Guideline> items;
  final List<String> categories;
  final String source;
  final String fetched;

  const GuidelineRepository({
    required this.items,
    required this.categories,
    required this.source,
    required this.fetched,
  });

  static Future<GuidelineRepository> load() async {
    final raw = await rootBundle.loadString('assets/data/guidelines.json');
    final json = jsonDecode(raw) as Map<String, dynamic>;
    return GuidelineRepository(
      items: (json['items'] as List)
          .map((e) => Guideline.fromJson(e as Map<String, dynamic>))
          .toList(),
      categories: (json['categories'] as List).cast<String>(),
      source: json['source'] as String,
      fetched: json['fetched'] as String,
    );
  }
}

/// 検索用正規化: 小文字化 + 全角英数→半角 + カタカナ→ひらがな
String normalizeForSearch(String s) {
  final buf = StringBuffer();
  for (final code in s.toLowerCase().runes) {
    var c = code;
    if (c >= 0xFF01 && c <= 0xFF5E) {
      c -= 0xFEE0; // 全角英数記号 → 半角
    } else if (c >= 0x30A1 && c <= 0x30F6) {
      c -= 0x60; // カタカナ → ひらがな
    } else if (c == 0x3000) {
      c = 0x20; // 全角スペース
    }
    buf.writeCharCode(c);
  }
  return buf.toString();
}
