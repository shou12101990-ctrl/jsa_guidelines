# 麻酔科ガイドライン

日本麻酔科学会が公開している指針・ガイドライン・プラクティカルガイドを
オフラインで一覧・検索・閲覧できる個人用Flutterアプリ。

公開URL: https://shou12101990-ctrl.github.io/jsa_guidelines/
(mainへのpushでGitHub Actionsが自動ビルド・デプロイ)

- 収載: 71項目(PDF同梱68本 + 外部リンク3件)/ 2026-06-10時点(英語版は除外)
- 出典: https://anesth.or.jp/users/person/guide_line (医薬品ガイドラインのサブページ含む)

## 機能

- カテゴリ別一覧(教育 / 本学会制定 / プラクティカルガイド / 救急救命士 / 他学会合同 / 医薬品 / その他)
- タイトル検索(全角半角・カタカナひらがなを同一視)
- お気に入り(★)と閲覧履歴(最近見た項目)
- アプリ内PDFビューア(pdfrx / オフライン動作)
- 外部リンク(禁煙啓発動画・他学会ページ)はブラウザで開く

## 開発

```sh
flutter pub get
flutter test          # マニフェスト整合性 + 検索正規化のテスト
flutter build web     # Web版ビルド
flutter run -d chrome
```

## ガイドラインの更新

学会サイトの更新を取り込むには `tools/build_manifest.py` のITEMSを
最新のページ内容に合わせて編集し、再実行する:

```sh
python3 tools/build_manifest.py
```

PDFの再ダウンロードと `assets/data/guidelines.json` の再生成が行われる。

## 注意

各文書の著作権は日本麻酔科学会および各学会に帰属します。
本アプリは個人利用を想定しており、PDFを同梱したままの再配布や
ストア公開には学会の許諾が必要です。臨床使用時は必ず原典の最新版を確認してください。
