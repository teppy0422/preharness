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

:2025-07-23:
Download flutter
Move to c:/dev/flutter
Add System path c:/dev/flutter/bin

Installed vs sdk & android sdk

jdk17 をインストールしたあとにターミナルで r 押したらリロードされたけど、jdk17 のインストールが関係あったかは不明

:2025-07-24:
Add settings_page.

:2025-07-25:
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

####

flutter でアプリケーション開発
vscode をメインにする
対象デバイスは Windows10 以上の PC と Android タブレット
同時接続数は 20 台程度
ネットワーク環境は社内ローカル
Nas に PostgreSQL の DB

設定ファイルは端末に保存

動作内容：
DB からデータを取得して作業完了したら完了データを DB に保存

現在は圧着作業のページを作成中

####

keyPath01 のディレクトリ階層にある全ての.txt を同じ Nas にある postregsql の DB にインポートしたい。
サブディレクトリは含まない。
Windows と android で動作するようにしたい。
Nas の Node.js の API サーバーを経由する。
インポートしたら同じディレクトリの bak に保存。bak が無い場合は作成。
.txt は固定長、Nas はとりあえず localhost で、設定は以下
user: "postgres",
host: "localhost",
database: "postgres",
password: "sakurajaiko",
port: 5432,

テーブル名は parts で、カラムは以下
part_no, serial, code, flag
全て string

####

設定ページを作りたい。
保存方法は shared_preferences

#### Nas

postgreSQL のインストールとテーブル作成

postgreSQL と通信する為に Node.js の API を準備
Node.js は通常と同じようにプロジェクトを作成する
変更都度の再起動が面倒なので変更したら再起動を設定しておくと便利

Synology で運用する場合は永続サービス機能で API サーバー起動するようにしておく
