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

Download flutter
Move to c:/dev/flutter
Add System path c:/dev/flutter/bin

Installed vs sdk & android sdk

jdk17 をインストールしたあとにターミナルで r 押したらリロードされたけど、jdk17 のインストールが関係あったかは不明

### 2025-07-24

Add settings_page.

### 2025-07-25

Add save/load setting_Path to setting_page.
Add NotoSansJp font.
copy 001 636MB
Add filepider 10.2.0
Added server path field.
Added display of directory dialog from server path
copy 002 688MB

copy 003 692MB

Hot reloads don't work.
Added message when file is missing on import.
copy 004 692MB

Added efu to work40_page.
copy 005 689MB

flutter pub add flutter_svg
Added feltPen at efu.
Added darkmode to efu.
copy 006 773MB

Added key Input to standard_info_card.
fixed notice.
copy 007 775MB

Intentions for mac environment
copy 008 1420MB

Added UserResiter.
copy 009 1420MB

Cange static NotoSansJPfont.
Added UserList, PrintUserCard, Delete User.
copy 010 1670MB

### 2025-08-05

Added EditUser.
Added Login modal.
deploy 0001
copy 011 1660MB

### 2025-08-06

Added Icon picker.
Fixed that used Icon cannot be selected.
deploy 0002
copy 012 1710MB

### 2025-08-07

Modified to allow some browsing when server connection is not available.
Iconic display of connection status to Nas.
Add icon animation with littie

#### base

目的:
作業実績をペーパーレスにして生産性の工場

手段:
flutter でアプリ開発

テスト環境:← いまここ
editor=VsCode
アプリデバイス=andoroid タブレット
Nas(DB)=windows11

本番環境:
アプリデバイス=android タブレット or windows10 以上
Nas(DB)=synology DS423+(メモリ 6GB)

機能:
タッチパネルによるタッチ操作メイン
DB からデータを取得して作業完了したら作業実績データを DB に保存

DB:
PostgreSQL + Node.js API サーバーをバックエンドに利用
同時接続数は 20 台程度
ネットワーク環境は社内ローカル
Nas に PostgreSQL の DB

設定ファイルは端末に保存
設定データは下記
mainPath: \\192.168.11.8,
path01: \\192.168.11.8\g\projects\PreHarnessPro\data,
machineType: CM20,
machineSerial: 0000,
workName: 手圧着,
呼び出す時は下記
final prefs = await SharedPreferences.getInstance();
setState(() {
mainPath = prefs.getString('main_path') ?? '未設定';
path01 = prefs.getString('path_01') ?? '未設定';
});

ログインについて:
ユーザーは QR コードでログイン
QR コードは id と同じ
users テーブルには id, username, iconname を保持
ログイン状態は SharedPreferences で管理
iconname はログインユーザーごとに一意で、重複不可

チャットルール:
提案するコードの先頭にはファイルパスを記載して

####

インデックス検索

#### Nas セットアップ

DS423+(6GB)
Synology で運用する場合は永続サービス機能で API サーバー起動するようにしておく
node.js と postregSQL をセットアップ
