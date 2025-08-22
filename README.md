# preharness

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

### 2025-07-23

- Download flutter
- Move to c:/dev/flutter
- Add System path c:/dev/flutter/bin

- Installed vs sdk & android sdk

- jdk17 をインストールしたあとにターミナルで r 押したらリロードされたけど、jdk17 のインストールが関係あったかは不明

### 2025-07-24

- Add settings_page.

### 2025-07-25

- Add save/load setting_Path to setting_page.
- Add NotoSansJp font.
- copy 001 636MB
- Add filepider 10.2.0
- Added server path field.
- Added display of directory dialog from server path
- copy 002 688MB

- copy 003 692MB

- Hot reloads don't work.
- Added message when file is missing on import.
- copy 004 692MB

- Added efu to work40_page.
- copy 005 689MB

<pre>flutter pub add flutter_svg </pre>

- Added feltPen at efu.
- Added darkmode to efu.
- copy 006 773MB

- Added key Input to standard_info_card.
- fixed notice.
- copy 007 775MB

- Intentions for mac environment
- copy 008 1420MB

- Added UserResiter.
- copy 009 1420MB

- Cange static NotoSansJPfont.
- Added UserList, PrintUserCard, Delete User.
- copy 010 1670MB

### 2025-08-05

- Added EditUser.
- Added Login modal.
- deploy 0001
- copy 011 1660MB

### 2025-08-06

- Added Icon picker.
- Fixed that used Icon cannot be selected.
- deploy 0002
- copy 012 1710MB

### 2025-08-07

- Modified to allow some browsing when server connection is not available.
- Iconic display of connection status to Nas.
- Add icon animation with littie
- deploy 013
- copy 013 1720MB

### 2025-08-17

- Response is displayed below the network status icon.
- Start using Gemini_cli.
- deploy 014
- copy 014 1710MB
- Create new page efu_detail.dart.

#### commit 015

- copy 015

- Added Dial value local storage.

#### commit 016

- copy 016 1810MB

- Change position on dial_selector.

#### commit 017

- Fixed layout of work40_page.dart.

#### commit 018

- Changed to show empty ef if before search.

#### commit 019

- Fixed button cannot be pressed again during import.

#### commit 020

- Display progress counts during import.

#### commit 021

### 2025-08-18

- Standards data search added.
- Add accessory parts to search criteria.

#### commit 022

- Change machining condition details.

#### commit 023

### 2025-08-19

- Changed so that if there is no dialing history, it will be known.
- Added API tests to debug_page.

##### commit 024

- Added process to receive colorList as json.
- Convert int 30 to Color.(0xFF000000) and save in hive.
- Support for calling from hive with 30.

#### commit 025

- Add get colors from hive to api_test_page.dart.
- Added color acquisition to efu_detail.dart.

#### commit 026

### 2025-08-20

- Fix ColorList in api_test_page.dart.
- Added WireColorBox to global.dart.

#### commit 027

- Fixing local ip.
- Change development connection to wifi.
- Static change of ip address in development environment. Target tablet is 192.168.11.14 Server is 192.168.11.11.

#### commit 028

- Support for tapping without searching for ef conditions.
- Once efu.dart is active, make it active with all data retrieval text selected.
- Add button to activate data search.

#### commit 029

- Add code to make keystrokes half-width.
- Addition of QR reader input mode.
- Layout correction for work40_page.dart.

#### commit 030

- Add animation for successful searches to settings.

#### commit 031

- Optimizing flip animations.

#### commit 032

- Added slide animation.

#### commit 033

- キーボード切り替えボタンの削除 ← 手入力モードに一度したらキーボードが常時表示されるようになる

#### commit 034

---

### now

ダイヤル値の保存条件にマジックを排除

### next

- インデックス検索

- 起動時に ch_list をローカル更新する
- ファイルインポートの速度向上
- ファイルインポートのプログレスバーを追加

#### memo

---

### prompt

あなたは、Flutter/Dart の専門家として、以下のプロジェクト概要を
理解し、今後の開発に関する質問に答えられるように準備してくださ
い。

---

プロジェクト概要

このプロジェクトは、製造現場の作業実績を記録・管理するための Fl
utter 製クロスプラットフォームアプリケーション「PreHarnessPro」
です。ペーパーレス化による生産性向上を目的としています。

主な仕様:

- ターゲットプラットフォーム: Android タブレット、Windows 10 以上
- UI/UX: タッチパネル操作がメイン。レスポンシブ UI を採用し、サイ
  ドバー形式のナビゲーションを持つ。ライト/ダークテーマ切り替え
  機能あり。
- バックエンド: 社内 LAN 上の NAS に構築された Node.js の API サーバー
  と PostgreSQL データベース。
  - NAS (本番): Synology DS423+ (メモリ 6GB)
  - NAS (開発): Windows 11
- 同時接続数: 20 台程度を想定

主要機能:

1.  ユーザー認証:

    - QR コード（ユーザー ID と同じ）をスキャンしてログイン。
    - ログイン状態は shared_preferences で端末に保持。
    - ユーザー情報は (id, username, iconname)
      を持ち、API 経由で DB から取得。

2.  設定:

    - API サーバーのパス (mainPath) やデータ読み込みパス
      (path01) などを端末に保存。
    - SettingsService クラス (shared_preferences のラッパー)
      が設定の読み書きを管理。
    - FilePicker を利用したディレクトリ選択機能。

3.  メイン画面 (HomePage):

    - アプリケーションの入り口。
    - 「圧着作業」「出荷作業」「設定」など、主要機能へのナビゲ
      ーションカードを表示。

4.  作業実績入力 (Work40Page):

    - 「圧着作業」の実績を入力する画面。
    - 設備情報、作業者情報、ダイヤル調整値などを記録。

5.  データ連携:
    - ApiService クラスが Node.js サーバーとの HTTP 通信を担当。
    - 製造指示データをサーバーに送信する機能などを持つ。

コード構成:

- エントリーポイント (`lib/main.dart`):

  - アプリの起動、テーマ (ThemeNotifier)
    の設定、初期ルートとルーティングの定義。
  - 起動時に UserLoginManager でログイン状態を復元。
  - 起動時に colorList を hive でローカル保存

- ルーティング (`lib/routes/app_routes.dart`):

  - MaterialApp の routes で利用する名前付きルートを定義。
  - (home, settings, import, work40, temp)

- ページ (`lib/pages/`):

  - HomePage, SettingsPage,
    Work40Page など、各画面に対応するウィジェット。
  - 各ページは共通の ResponsiveScaffold ウィジェットを利用して
    構築。

- 共通ウィジェット (`lib/widgets/`):

  - ResponsiveScaffold: サイドバーとメインコンテンツ領域を持
    つ、アプリの基本骨格となるレスポンシブな Scaffold。テーマ
    切り替えスイッチもここに実装。
  - UserIconButton: ユーザーアイコンと名前を表示し、タップで
    ログインモーダルを開く。
  - NasStatusIcon: API サーバーへの接続状態を定期的に確認し、L
    ottie アニメーションで結果を表示。

- サービス (`lib/services/`):

  - SettingsService:
    shared_preferences を使い、アプリ設定の永続化を担う。
  - ApiService:
    バックエンド API との通信ロジックをまとめたクラス。

- ユーティリティ (`lib/utils/`):

  - UserLoginManager: ユーザーのログイン、ログアウト、ログイ
    ン状態の確認処理を管理。

- 依存パッケージ (`pubspec.yaml`):
  - shared_preferences: データ永続化
  - file_picker: ファイル/ディレクトリ選択
  - http: HTTP 通信
  - lottie: Lottie アニメーション
  - qr_flutter: QR コード生成
  - その他 UI 関連パッケージ

あなたの役割:

このプロジェクトのアーキテクチャとコードベースを理解した上で、
機能追加、バグ修正、リファクタリングなどの開発タスクに関する具
体的なコードの提案や、実装に関する質問への回答を行ってください
。提案するコードには、必ず先頭に対象のファイルパスをコメントで
記載してください。

チャットルール:
提案するコードの先頭にはファイルパスを記載して

#### Nas セットアップ

DS423+(6GB)
Synology で運用する場合は永続サービス機能で API サーバー起動するようにしておく
node.js と postregSQL をセットアップ
