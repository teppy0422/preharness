// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'local_db_service.dart';

// ignore_for_file: type=lint
class $LocalProcessingConditionsTable extends LocalProcessingConditions
    with TableInfo<$LocalProcessingConditionsTable, LocalProcessingCondition> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalProcessingConditionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _wireTypeMeta =
      const VerificationMeta('wireType');
  @override
  late final GeneratedColumn<String> wireType = GeneratedColumn<String>(
      'wire_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _wireSizeMeta =
      const VerificationMeta('wireSize');
  @override
  late final GeneratedColumn<String> wireSize = GeneratedColumn<String>(
      'wire_size', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _termPartNoMeta =
      const VerificationMeta('termPartNo');
  @override
  late final GeneratedColumn<String> termPartNo = GeneratedColumn<String>(
      'term_part_no', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _addPartsMeta =
      const VerificationMeta('addParts');
  @override
  late final GeneratedColumn<String> addParts = GeneratedColumn<String>(
      'add_parts', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _topDialMeta =
      const VerificationMeta('topDial');
  @override
  late final GeneratedColumn<String> topDial = GeneratedColumn<String>(
      'top_dial', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _bottomDialMeta =
      const VerificationMeta('bottomDial');
  @override
  late final GeneratedColumn<String> bottomDial = GeneratedColumn<String>(
      'bottom_dial', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _hindDialMeta =
      const VerificationMeta('hindDial');
  @override
  late final GeneratedColumn<String> hindDial = GeneratedColumn<String>(
      'hind_dial', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        wireType,
        wireSize,
        termPartNo,
        addParts,
        topDial,
        bottomDial,
        hindDial
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_processing_conditions';
  @override
  VerificationContext validateIntegrity(
      Insertable<LocalProcessingCondition> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('wire_type')) {
      context.handle(_wireTypeMeta,
          wireType.isAcceptableOrUnknown(data['wire_type']!, _wireTypeMeta));
    } else if (isInserting) {
      context.missing(_wireTypeMeta);
    }
    if (data.containsKey('wire_size')) {
      context.handle(_wireSizeMeta,
          wireSize.isAcceptableOrUnknown(data['wire_size']!, _wireSizeMeta));
    } else if (isInserting) {
      context.missing(_wireSizeMeta);
    }
    if (data.containsKey('term_part_no')) {
      context.handle(
          _termPartNoMeta,
          termPartNo.isAcceptableOrUnknown(
              data['term_part_no']!, _termPartNoMeta));
    } else if (isInserting) {
      context.missing(_termPartNoMeta);
    }
    if (data.containsKey('add_parts')) {
      context.handle(_addPartsMeta,
          addParts.isAcceptableOrUnknown(data['add_parts']!, _addPartsMeta));
    } else if (isInserting) {
      context.missing(_addPartsMeta);
    }
    if (data.containsKey('top_dial')) {
      context.handle(_topDialMeta,
          topDial.isAcceptableOrUnknown(data['top_dial']!, _topDialMeta));
    }
    if (data.containsKey('bottom_dial')) {
      context.handle(
          _bottomDialMeta,
          bottomDial.isAcceptableOrUnknown(
              data['bottom_dial']!, _bottomDialMeta));
    }
    if (data.containsKey('hind_dial')) {
      context.handle(_hindDialMeta,
          hindDial.isAcceptableOrUnknown(data['hind_dial']!, _hindDialMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
        {wireType, wireSize, termPartNo, addParts},
      ];
  @override
  LocalProcessingCondition map(Map<String, dynamic> data,
      {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalProcessingCondition(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      wireType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}wire_type'])!,
      wireSize: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}wire_size'])!,
      termPartNo: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}term_part_no'])!,
      addParts: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}add_parts'])!,
      topDial: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}top_dial']),
      bottomDial: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}bottom_dial']),
      hindDial: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}hind_dial']),
    );
  }

  @override
  $LocalProcessingConditionsTable createAlias(String alias) {
    return $LocalProcessingConditionsTable(attachedDatabase, alias);
  }
}

class LocalProcessingCondition extends DataClass
    implements Insertable<LocalProcessingCondition> {
  final int id;
  final String wireType;
  final String wireSize;
  final String termPartNo;
  final String addParts;
  final String? topDial;
  final String? bottomDial;
  final String? hindDial;
  const LocalProcessingCondition(
      {required this.id,
      required this.wireType,
      required this.wireSize,
      required this.termPartNo,
      required this.addParts,
      this.topDial,
      this.bottomDial,
      this.hindDial});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['wire_type'] = Variable<String>(wireType);
    map['wire_size'] = Variable<String>(wireSize);
    map['term_part_no'] = Variable<String>(termPartNo);
    map['add_parts'] = Variable<String>(addParts);
    if (!nullToAbsent || topDial != null) {
      map['top_dial'] = Variable<String>(topDial);
    }
    if (!nullToAbsent || bottomDial != null) {
      map['bottom_dial'] = Variable<String>(bottomDial);
    }
    if (!nullToAbsent || hindDial != null) {
      map['hind_dial'] = Variable<String>(hindDial);
    }
    return map;
  }

  LocalProcessingConditionsCompanion toCompanion(bool nullToAbsent) {
    return LocalProcessingConditionsCompanion(
      id: Value(id),
      wireType: Value(wireType),
      wireSize: Value(wireSize),
      termPartNo: Value(termPartNo),
      addParts: Value(addParts),
      topDial: topDial == null && nullToAbsent
          ? const Value.absent()
          : Value(topDial),
      bottomDial: bottomDial == null && nullToAbsent
          ? const Value.absent()
          : Value(bottomDial),
      hindDial: hindDial == null && nullToAbsent
          ? const Value.absent()
          : Value(hindDial),
    );
  }

  factory LocalProcessingCondition.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalProcessingCondition(
      id: serializer.fromJson<int>(json['id']),
      wireType: serializer.fromJson<String>(json['wireType']),
      wireSize: serializer.fromJson<String>(json['wireSize']),
      termPartNo: serializer.fromJson<String>(json['termPartNo']),
      addParts: serializer.fromJson<String>(json['addParts']),
      topDial: serializer.fromJson<String?>(json['topDial']),
      bottomDial: serializer.fromJson<String?>(json['bottomDial']),
      hindDial: serializer.fromJson<String?>(json['hindDial']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'wireType': serializer.toJson<String>(wireType),
      'wireSize': serializer.toJson<String>(wireSize),
      'termPartNo': serializer.toJson<String>(termPartNo),
      'addParts': serializer.toJson<String>(addParts),
      'topDial': serializer.toJson<String?>(topDial),
      'bottomDial': serializer.toJson<String?>(bottomDial),
      'hindDial': serializer.toJson<String?>(hindDial),
    };
  }

  LocalProcessingCondition copyWith(
          {int? id,
          String? wireType,
          String? wireSize,
          String? termPartNo,
          String? addParts,
          Value<String?> topDial = const Value.absent(),
          Value<String?> bottomDial = const Value.absent(),
          Value<String?> hindDial = const Value.absent()}) =>
      LocalProcessingCondition(
        id: id ?? this.id,
        wireType: wireType ?? this.wireType,
        wireSize: wireSize ?? this.wireSize,
        termPartNo: termPartNo ?? this.termPartNo,
        addParts: addParts ?? this.addParts,
        topDial: topDial.present ? topDial.value : this.topDial,
        bottomDial: bottomDial.present ? bottomDial.value : this.bottomDial,
        hindDial: hindDial.present ? hindDial.value : this.hindDial,
      );
  LocalProcessingCondition copyWithCompanion(
      LocalProcessingConditionsCompanion data) {
    return LocalProcessingCondition(
      id: data.id.present ? data.id.value : this.id,
      wireType: data.wireType.present ? data.wireType.value : this.wireType,
      wireSize: data.wireSize.present ? data.wireSize.value : this.wireSize,
      termPartNo:
          data.termPartNo.present ? data.termPartNo.value : this.termPartNo,
      addParts: data.addParts.present ? data.addParts.value : this.addParts,
      topDial: data.topDial.present ? data.topDial.value : this.topDial,
      bottomDial:
          data.bottomDial.present ? data.bottomDial.value : this.bottomDial,
      hindDial: data.hindDial.present ? data.hindDial.value : this.hindDial,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalProcessingCondition(')
          ..write('id: $id, ')
          ..write('wireType: $wireType, ')
          ..write('wireSize: $wireSize, ')
          ..write('termPartNo: $termPartNo, ')
          ..write('addParts: $addParts, ')
          ..write('topDial: $topDial, ')
          ..write('bottomDial: $bottomDial, ')
          ..write('hindDial: $hindDial')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, wireType, wireSize, termPartNo, addParts,
      topDial, bottomDial, hindDial);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalProcessingCondition &&
          other.id == this.id &&
          other.wireType == this.wireType &&
          other.wireSize == this.wireSize &&
          other.termPartNo == this.termPartNo &&
          other.addParts == this.addParts &&
          other.topDial == this.topDial &&
          other.bottomDial == this.bottomDial &&
          other.hindDial == this.hindDial);
}

class LocalProcessingConditionsCompanion
    extends UpdateCompanion<LocalProcessingCondition> {
  final Value<int> id;
  final Value<String> wireType;
  final Value<String> wireSize;
  final Value<String> termPartNo;
  final Value<String> addParts;
  final Value<String?> topDial;
  final Value<String?> bottomDial;
  final Value<String?> hindDial;
  const LocalProcessingConditionsCompanion({
    this.id = const Value.absent(),
    this.wireType = const Value.absent(),
    this.wireSize = const Value.absent(),
    this.termPartNo = const Value.absent(),
    this.addParts = const Value.absent(),
    this.topDial = const Value.absent(),
    this.bottomDial = const Value.absent(),
    this.hindDial = const Value.absent(),
  });
  LocalProcessingConditionsCompanion.insert({
    this.id = const Value.absent(),
    required String wireType,
    required String wireSize,
    required String termPartNo,
    required String addParts,
    this.topDial = const Value.absent(),
    this.bottomDial = const Value.absent(),
    this.hindDial = const Value.absent(),
  })  : wireType = Value(wireType),
        wireSize = Value(wireSize),
        termPartNo = Value(termPartNo),
        addParts = Value(addParts);
  static Insertable<LocalProcessingCondition> custom({
    Expression<int>? id,
    Expression<String>? wireType,
    Expression<String>? wireSize,
    Expression<String>? termPartNo,
    Expression<String>? addParts,
    Expression<String>? topDial,
    Expression<String>? bottomDial,
    Expression<String>? hindDial,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (wireType != null) 'wire_type': wireType,
      if (wireSize != null) 'wire_size': wireSize,
      if (termPartNo != null) 'term_part_no': termPartNo,
      if (addParts != null) 'add_parts': addParts,
      if (topDial != null) 'top_dial': topDial,
      if (bottomDial != null) 'bottom_dial': bottomDial,
      if (hindDial != null) 'hind_dial': hindDial,
    });
  }

  LocalProcessingConditionsCompanion copyWith(
      {Value<int>? id,
      Value<String>? wireType,
      Value<String>? wireSize,
      Value<String>? termPartNo,
      Value<String>? addParts,
      Value<String?>? topDial,
      Value<String?>? bottomDial,
      Value<String?>? hindDial}) {
    return LocalProcessingConditionsCompanion(
      id: id ?? this.id,
      wireType: wireType ?? this.wireType,
      wireSize: wireSize ?? this.wireSize,
      termPartNo: termPartNo ?? this.termPartNo,
      addParts: addParts ?? this.addParts,
      topDial: topDial ?? this.topDial,
      bottomDial: bottomDial ?? this.bottomDial,
      hindDial: hindDial ?? this.hindDial,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (wireType.present) {
      map['wire_type'] = Variable<String>(wireType.value);
    }
    if (wireSize.present) {
      map['wire_size'] = Variable<String>(wireSize.value);
    }
    if (termPartNo.present) {
      map['term_part_no'] = Variable<String>(termPartNo.value);
    }
    if (addParts.present) {
      map['add_parts'] = Variable<String>(addParts.value);
    }
    if (topDial.present) {
      map['top_dial'] = Variable<String>(topDial.value);
    }
    if (bottomDial.present) {
      map['bottom_dial'] = Variable<String>(bottomDial.value);
    }
    if (hindDial.present) {
      map['hind_dial'] = Variable<String>(hindDial.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalProcessingConditionsCompanion(')
          ..write('id: $id, ')
          ..write('wireType: $wireType, ')
          ..write('wireSize: $wireSize, ')
          ..write('termPartNo: $termPartNo, ')
          ..write('addParts: $addParts, ')
          ..write('topDial: $topDial, ')
          ..write('bottomDial: $bottomDial, ')
          ..write('hindDial: $hindDial')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $LocalProcessingConditionsTable localProcessingConditions =
      $LocalProcessingConditionsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [localProcessingConditions];
}

typedef $$LocalProcessingConditionsTableCreateCompanionBuilder
    = LocalProcessingConditionsCompanion Function({
  Value<int> id,
  required String wireType,
  required String wireSize,
  required String termPartNo,
  required String addParts,
  Value<String?> topDial,
  Value<String?> bottomDial,
  Value<String?> hindDial,
});
typedef $$LocalProcessingConditionsTableUpdateCompanionBuilder
    = LocalProcessingConditionsCompanion Function({
  Value<int> id,
  Value<String> wireType,
  Value<String> wireSize,
  Value<String> termPartNo,
  Value<String> addParts,
  Value<String?> topDial,
  Value<String?> bottomDial,
  Value<String?> hindDial,
});

class $$LocalProcessingConditionsTableFilterComposer
    extends Composer<_$AppDatabase, $LocalProcessingConditionsTable> {
  $$LocalProcessingConditionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get wireType => $composableBuilder(
      column: $table.wireType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get wireSize => $composableBuilder(
      column: $table.wireSize, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get termPartNo => $composableBuilder(
      column: $table.termPartNo, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get addParts => $composableBuilder(
      column: $table.addParts, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get topDial => $composableBuilder(
      column: $table.topDial, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get bottomDial => $composableBuilder(
      column: $table.bottomDial, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get hindDial => $composableBuilder(
      column: $table.hindDial, builder: (column) => ColumnFilters(column));
}

class $$LocalProcessingConditionsTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalProcessingConditionsTable> {
  $$LocalProcessingConditionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get wireType => $composableBuilder(
      column: $table.wireType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get wireSize => $composableBuilder(
      column: $table.wireSize, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get termPartNo => $composableBuilder(
      column: $table.termPartNo, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get addParts => $composableBuilder(
      column: $table.addParts, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get topDial => $composableBuilder(
      column: $table.topDial, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get bottomDial => $composableBuilder(
      column: $table.bottomDial, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get hindDial => $composableBuilder(
      column: $table.hindDial, builder: (column) => ColumnOrderings(column));
}

class $$LocalProcessingConditionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalProcessingConditionsTable> {
  $$LocalProcessingConditionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get wireType =>
      $composableBuilder(column: $table.wireType, builder: (column) => column);

  GeneratedColumn<String> get wireSize =>
      $composableBuilder(column: $table.wireSize, builder: (column) => column);

  GeneratedColumn<String> get termPartNo => $composableBuilder(
      column: $table.termPartNo, builder: (column) => column);

  GeneratedColumn<String> get addParts =>
      $composableBuilder(column: $table.addParts, builder: (column) => column);

  GeneratedColumn<String> get topDial =>
      $composableBuilder(column: $table.topDial, builder: (column) => column);

  GeneratedColumn<String> get bottomDial => $composableBuilder(
      column: $table.bottomDial, builder: (column) => column);

  GeneratedColumn<String> get hindDial =>
      $composableBuilder(column: $table.hindDial, builder: (column) => column);
}

class $$LocalProcessingConditionsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $LocalProcessingConditionsTable,
    LocalProcessingCondition,
    $$LocalProcessingConditionsTableFilterComposer,
    $$LocalProcessingConditionsTableOrderingComposer,
    $$LocalProcessingConditionsTableAnnotationComposer,
    $$LocalProcessingConditionsTableCreateCompanionBuilder,
    $$LocalProcessingConditionsTableUpdateCompanionBuilder,
    (
      LocalProcessingCondition,
      BaseReferences<_$AppDatabase, $LocalProcessingConditionsTable,
          LocalProcessingCondition>
    ),
    LocalProcessingCondition,
    PrefetchHooks Function()> {
  $$LocalProcessingConditionsTableTableManager(
      _$AppDatabase db, $LocalProcessingConditionsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalProcessingConditionsTableFilterComposer(
                  $db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalProcessingConditionsTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalProcessingConditionsTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> wireType = const Value.absent(),
            Value<String> wireSize = const Value.absent(),
            Value<String> termPartNo = const Value.absent(),
            Value<String> addParts = const Value.absent(),
            Value<String?> topDial = const Value.absent(),
            Value<String?> bottomDial = const Value.absent(),
            Value<String?> hindDial = const Value.absent(),
          }) =>
              LocalProcessingConditionsCompanion(
            id: id,
            wireType: wireType,
            wireSize: wireSize,
            termPartNo: termPartNo,
            addParts: addParts,
            topDial: topDial,
            bottomDial: bottomDial,
            hindDial: hindDial,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String wireType,
            required String wireSize,
            required String termPartNo,
            required String addParts,
            Value<String?> topDial = const Value.absent(),
            Value<String?> bottomDial = const Value.absent(),
            Value<String?> hindDial = const Value.absent(),
          }) =>
              LocalProcessingConditionsCompanion.insert(
            id: id,
            wireType: wireType,
            wireSize: wireSize,
            termPartNo: termPartNo,
            addParts: addParts,
            topDial: topDial,
            bottomDial: bottomDial,
            hindDial: hindDial,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$LocalProcessingConditionsTableProcessedTableManager
    = ProcessedTableManager<
        _$AppDatabase,
        $LocalProcessingConditionsTable,
        LocalProcessingCondition,
        $$LocalProcessingConditionsTableFilterComposer,
        $$LocalProcessingConditionsTableOrderingComposer,
        $$LocalProcessingConditionsTableAnnotationComposer,
        $$LocalProcessingConditionsTableCreateCompanionBuilder,
        $$LocalProcessingConditionsTableUpdateCompanionBuilder,
        (
          LocalProcessingCondition,
          BaseReferences<_$AppDatabase, $LocalProcessingConditionsTable,
              LocalProcessingCondition>
        ),
        LocalProcessingCondition,
        PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$LocalProcessingConditionsTableTableManager get localProcessingConditions =>
      $$LocalProcessingConditionsTableTableManager(
          _db, _db.localProcessingConditions);
}
