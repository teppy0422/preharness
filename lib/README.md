# プロジェクト構造ガイド

## 🏗️ アーキテクチャ概要

このプロジェクトは **Feature-First Architecture** を採用しており、機能別にファイルを整理しています。

## 📂 ディレクトリ構造

```
lib/
├── core/                    # アプリケーション全体の基盤
│   ├── constants/           # 色定数など
│   ├── themes/              # アプリテーマ
│   ├── utils/               # 共通ユーティリティ
│   ├── models/              # 共通データモデル
│   ├── adapters/            # データアダプター
│   ├── services/            # 共通サービス
│   └── core.dart            # 👈 コア機能のエクスポート
├── features/                # 機能別フォルダ
│   ├── work40/              # Work40機能
│   │   ├── pages/           # Work40のページ
│   │   ├── widgets/         # Work40のウィジェット
│   │   ├── data/            # Work40のデータレイヤー
│   │   └── work40.dart      # 👈 Work40機能のエクスポート
│   ├── settings/            # 設定機能
│   ├── home/                # ホーム画面
│   └── import_export/       # インポート・エクスポート機能
├── shared/                  # 共通コンポーネント
│   ├── widgets/             # 再利用可能ウィジェット
│   ├── ui/                  # UIコンポーネント
│   ├── animations/          # アニメーション
│   └── shared.dart          # 👈 共通機能のエクスポート
├── routes/                  # ナビゲーション
└── main.dart                # アプリエントリーポイント
```

## 🎯 使用方法

### ✨ 簡潔なインポート

**Before（従来）:**
```dart
import 'package:preharness/widgets/work40/components/animated_counter.dart';
import 'package:preharness/widgets/work40/components/search_card.dart';
import 'package:preharness/pages/work40_page.dart';
```

**After（新構造）:**
```dart
import 'package:preharness/features/work40/work40.dart'; // 全部入り！
```

### 🔍 ファイルの見つけ方

1. **機能名**でディレクトリを探す
   - Work40関連 → `features/work40/`
   - 設定関連 → `features/settings/`

2. **役割**でサブディレクトリを選ぶ
   - 画面 → `pages/`
   - ウィジェット → `widgets/`
   - データ処理 → `data/`

3. **共通機能**は `shared/` または `core/` を確認

## 📋 ルール

### ✅ Good
- 機能に特化したファイルは `features/機能名/` に配置
- 複数機能で使う共通ウィジェットは `shared/` に配置
- アプリ全体の基盤は `core/` に配置
- エクスポートファイル（.dart）を経由してインポート

### ❌ Avoid
- 直接パスでのインポート（エクスポートファイルを使用）
- 機能を跨いだファイルの参照
- 型別ディレクトリ（pages/, widgets/など）の復活

## 🔄 移行ガイド

新しいファイルを追加する場合：

1. **どの機能に属するか**を判断
2. 適切な `features/機能名/` 配下に配置
3. 対応するエクスポートファイルに追加
4. インポート時はエクスポートファイル経由で使用