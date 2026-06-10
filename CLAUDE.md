# 麻酔科ガイドラインアプリ (guideline_app)

日本麻酔科学会の指針・ガイドラインPDF(68本同梱+外部リンク3件)を
オフライン閲覧するFlutterアプリ。iOS/Android/Web対応。
英語版リンクはユーザーの指示で収載対象外(2026-06-10)。

## 構成

- `lib/main.dart` — エントリ + テーマ + 起動時ロード
- `lib/models.dart` — Guidelineモデル / マニフェスト読込 / 検索正規化
- `lib/store.dart` — お気に入り・閲覧履歴 (shared_preferences)
- `lib/home_screen.dart` — 検索・カテゴリチップ・セクションリスト
- `lib/viewer_screen.dart` — PDFビューア (pdfrx)
- `assets/data/guidelines.json` — マニフェスト(tools/build_manifest.pyが生成)
- `assets/pdfs/` — ダウンロード済みPDF (約157MB)
- `tools/build_manifest.py` — 学会サイトからのPDF一括DL + マニフェスト生成

## コマンド

- `flutter test` — マニフェスト整合性 + 検索正規化テスト
- `dart analyze lib test` — 解析(この環境では `flutter analyze` はクラッシュすることがある)
- `flutter build web` — Webビルド

## この環境の注意点

- Android SDK / Xcode / CocoaPods 未導入。動作確認はWeb(Chrome)で行う。
- Claude Codeのpreviewサーバ(launch.json経由)はTCC制限でDesktop配下に
  アクセスできない。`build/web` を `/tmp/guideline_web` にコピーしてから
  `.claude/launch.json` の guideline-web を起動すること。
- Flutter Webはcanvas描画のため合成DOMイベントが効かない。preview経由の
  クリック検証は `pointer-events:none` の固定位置divを注入して
  `preview_click('#clickproxy')` で行う(CDPの信頼済みクリックが透過する)。

## ガイドライン更新手順

1. https://anesth.or.jp/users/person/guide_line (+ /medicine) の変更を確認
2. `tools/build_manifest.py` の ITEMS を更新
3. `python3 tools/build_manifest.py` 実行(差分PDFのみDL)
4. `flutter test` で整合性確認

## デプロイ

- GitHub Pages: https://shou12101990-ctrl.github.io/jsa_guidelines/
- リポジトリ: https://github.com/shou12101990-ctrl/jsa_guidelines
- mainへのpushで `.github/workflows/deploy.yml` が自動ビルド・デプロイ(nutricalcと同方式)
- ローカルからのgh-pagesブランチ直接push(約155MB)はHTTP 408で失敗するため使わない。
  mainのpush自体も大きいので `git -c http.postBuffer=524288000 -c http.version=HTTP/1.1 push` が必要なことがある

## 配布上の注意

PDFの著作権は日本麻酔科学会等に帰属。個人利用前提。
ストア公開・再配布には学会許諾が必要。
