import 'package:drift/drift.dart';
import 'dart:io';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

// 生成されるファイル名を指定
part 'local_db_service.g.dart';

// グローバルなデータベースインスタンスを作成
final AppDatabase db = AppDatabase();

// テーブルの定義
class LocalProcessingConditions extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get wireType => text().named('wire_type')();
  TextColumn get wireSize => text().named('wire_size')();
  TextColumn get termPartNo => text().named('term_part_no')();
  TextColumn get addParts => text().named('add_parts')();
  TextColumn get topDial => text().named('top_dial').nullable()();
  TextColumn get bottomDial => text().named('bottom_dial').nullable()();
  TextColumn get hindDial => text().named('hind_dial').nullable()();

  @override
  List<Set<Column>> get uniqueKeys => [
    {wireType, wireSize, termPartNo, addParts},
  ];
}

// データベースクラスの定義
@DriftDatabase(tables: [LocalProcessingConditions])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  // データの取得
  Future<LocalProcessingCondition?> getCondition({
    required String wireType,
    required String wireSize,
    required String termPartNo,
    required String addParts,
  }) {
    return (select(localProcessingConditions)..where(
          (tbl) =>
              tbl.wireType.equals(wireType) &
              tbl.wireSize.equals(wireSize) &
              tbl.termPartNo.equals(termPartNo) &
              tbl.addParts.equals(addParts),
        ))
        .getSingleOrNull();
  }

  // データの追加または更新
  Future<void> createOrUpdateCondition(
    LocalProcessingConditionsCompanion entry,
  ) {
    return into(localProcessingConditions).insert(
      entry,
      onConflict: DoUpdate(
        (row) => LocalProcessingConditionsCompanion(
          topDial: entry.topDial,
          bottomDial: entry.bottomDial,
          hindDial: entry.hindDial,
        ),
        target: [
          localProcessingConditions.wireType,
          localProcessingConditions.wireSize,
          localProcessingConditions.termPartNo,
          localProcessingConditions.addParts,
        ],
      ),
    );
  }
}

// データベース接続を開く
LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'db.sqlite'));
    return NativeDatabase(file);
  });
}
