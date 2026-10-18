// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $WorkoutEntriesTable extends WorkoutEntries
    with TableInfo<$WorkoutEntriesTable, WorkoutEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WorkoutEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _detailMeta = const VerificationMeta('detail');
  @override
  late final GeneratedColumn<String> detail = GeneratedColumn<String>(
    'detail',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _benefitMeta = const VerificationMeta(
    'benefit',
  );
  @override
  late final GeneratedColumn<String> benefit = GeneratedColumn<String>(
    'benefit',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isDoneMeta = const VerificationMeta('isDone');
  @override
  late final GeneratedColumn<bool> isDone = GeneratedColumn<bool>(
    'is_done',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_done" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _lastFetchedMeta = const VerificationMeta(
    'lastFetched',
  );
  @override
  late final GeneratedColumn<int> lastFetched = GeneratedColumn<int>(
    'last_fetched',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _syncedMeta = const VerificationMeta('synced');
  @override
  late final GeneratedColumn<bool> synced = GeneratedColumn<bool>(
    'synced',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("synced" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    detail,
    benefit,
    isDone,
    lastFetched,
    updatedAt,
    synced,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'workout_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<WorkoutEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('detail')) {
      context.handle(
        _detailMeta,
        detail.isAcceptableOrUnknown(data['detail']!, _detailMeta),
      );
    } else if (isInserting) {
      context.missing(_detailMeta);
    }
    if (data.containsKey('benefit')) {
      context.handle(
        _benefitMeta,
        benefit.isAcceptableOrUnknown(data['benefit']!, _benefitMeta),
      );
    } else if (isInserting) {
      context.missing(_benefitMeta);
    }
    if (data.containsKey('is_done')) {
      context.handle(
        _isDoneMeta,
        isDone.isAcceptableOrUnknown(data['is_done']!, _isDoneMeta),
      );
    }
    if (data.containsKey('last_fetched')) {
      context.handle(
        _lastFetchedMeta,
        lastFetched.isAcceptableOrUnknown(
          data['last_fetched']!,
          _lastFetchedMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_lastFetchedMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('synced')) {
      context.handle(
        _syncedMeta,
        synced.isAcceptableOrUnknown(data['synced']!, _syncedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  WorkoutEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WorkoutEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      detail: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}detail'],
      )!,
      benefit: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}benefit'],
      )!,
      isDone: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_done'],
      )!,
      lastFetched: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_fetched'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      synced: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}synced'],
      )!,
    );
  }

  @override
  $WorkoutEntriesTable createAlias(String alias) {
    return $WorkoutEntriesTable(attachedDatabase, alias);
  }
}

class WorkoutEntry extends DataClass implements Insertable<WorkoutEntry> {
  final String id;
  final String name;
  final String detail;
  final String benefit;
  final bool isDone;

  /// Penanda cache: kapan data ini terakhir diambil dari server (UTC millis).
  final int lastFetched;

  /// Schema v2: kapan baris ini terakhir diubah di perangkat (UTC millis).
  final int updatedAt;

  /// Schema v2: false = ada perubahan lokal yang belum dikirim ke server.
  /// Setiap penulisan lokal dimulai dengan synced = false (pola offline-first).
  final bool synced;
  const WorkoutEntry({
    required this.id,
    required this.name,
    required this.detail,
    required this.benefit,
    required this.isDone,
    required this.lastFetched,
    required this.updatedAt,
    required this.synced,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['detail'] = Variable<String>(detail);
    map['benefit'] = Variable<String>(benefit);
    map['is_done'] = Variable<bool>(isDone);
    map['last_fetched'] = Variable<int>(lastFetched);
    map['updated_at'] = Variable<int>(updatedAt);
    map['synced'] = Variable<bool>(synced);
    return map;
  }

  WorkoutEntriesCompanion toCompanion(bool nullToAbsent) {
    return WorkoutEntriesCompanion(
      id: Value(id),
      name: Value(name),
      detail: Value(detail),
      benefit: Value(benefit),
      isDone: Value(isDone),
      lastFetched: Value(lastFetched),
      updatedAt: Value(updatedAt),
      synced: Value(synced),
    );
  }

  factory WorkoutEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WorkoutEntry(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      detail: serializer.fromJson<String>(json['detail']),
      benefit: serializer.fromJson<String>(json['benefit']),
      isDone: serializer.fromJson<bool>(json['isDone']),
      lastFetched: serializer.fromJson<int>(json['lastFetched']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      synced: serializer.fromJson<bool>(json['synced']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'detail': serializer.toJson<String>(detail),
      'benefit': serializer.toJson<String>(benefit),
      'isDone': serializer.toJson<bool>(isDone),
      'lastFetched': serializer.toJson<int>(lastFetched),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'synced': serializer.toJson<bool>(synced),
    };
  }

  WorkoutEntry copyWith({
    String? id,
    String? name,
    String? detail,
    String? benefit,
    bool? isDone,
    int? lastFetched,
    int? updatedAt,
    bool? synced,
  }) => WorkoutEntry(
    id: id ?? this.id,
    name: name ?? this.name,
    detail: detail ?? this.detail,
    benefit: benefit ?? this.benefit,
    isDone: isDone ?? this.isDone,
    lastFetched: lastFetched ?? this.lastFetched,
    updatedAt: updatedAt ?? this.updatedAt,
    synced: synced ?? this.synced,
  );
  WorkoutEntry copyWithCompanion(WorkoutEntriesCompanion data) {
    return WorkoutEntry(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      detail: data.detail.present ? data.detail.value : this.detail,
      benefit: data.benefit.present ? data.benefit.value : this.benefit,
      isDone: data.isDone.present ? data.isDone.value : this.isDone,
      lastFetched: data.lastFetched.present
          ? data.lastFetched.value
          : this.lastFetched,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      synced: data.synced.present ? data.synced.value : this.synced,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WorkoutEntry(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('detail: $detail, ')
          ..write('benefit: $benefit, ')
          ..write('isDone: $isDone, ')
          ..write('lastFetched: $lastFetched, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('synced: $synced')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    detail,
    benefit,
    isDone,
    lastFetched,
    updatedAt,
    synced,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WorkoutEntry &&
          other.id == this.id &&
          other.name == this.name &&
          other.detail == this.detail &&
          other.benefit == this.benefit &&
          other.isDone == this.isDone &&
          other.lastFetched == this.lastFetched &&
          other.updatedAt == this.updatedAt &&
          other.synced == this.synced);
}

class WorkoutEntriesCompanion extends UpdateCompanion<WorkoutEntry> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> detail;
  final Value<String> benefit;
  final Value<bool> isDone;
  final Value<int> lastFetched;
  final Value<int> updatedAt;
  final Value<bool> synced;
  final Value<int> rowid;
  const WorkoutEntriesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.detail = const Value.absent(),
    this.benefit = const Value.absent(),
    this.isDone = const Value.absent(),
    this.lastFetched = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.synced = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  WorkoutEntriesCompanion.insert({
    required String id,
    required String name,
    required String detail,
    required String benefit,
    this.isDone = const Value.absent(),
    required int lastFetched,
    this.updatedAt = const Value.absent(),
    this.synced = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       detail = Value(detail),
       benefit = Value(benefit),
       lastFetched = Value(lastFetched);
  static Insertable<WorkoutEntry> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? detail,
    Expression<String>? benefit,
    Expression<bool>? isDone,
    Expression<int>? lastFetched,
    Expression<int>? updatedAt,
    Expression<bool>? synced,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (detail != null) 'detail': detail,
      if (benefit != null) 'benefit': benefit,
      if (isDone != null) 'is_done': isDone,
      if (lastFetched != null) 'last_fetched': lastFetched,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (synced != null) 'synced': synced,
      if (rowid != null) 'rowid': rowid,
    });
  }

  WorkoutEntriesCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? detail,
    Value<String>? benefit,
    Value<bool>? isDone,
    Value<int>? lastFetched,
    Value<int>? updatedAt,
    Value<bool>? synced,
    Value<int>? rowid,
  }) {
    return WorkoutEntriesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      detail: detail ?? this.detail,
      benefit: benefit ?? this.benefit,
      isDone: isDone ?? this.isDone,
      lastFetched: lastFetched ?? this.lastFetched,
      updatedAt: updatedAt ?? this.updatedAt,
      synced: synced ?? this.synced,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (detail.present) {
      map['detail'] = Variable<String>(detail.value);
    }
    if (benefit.present) {
      map['benefit'] = Variable<String>(benefit.value);
    }
    if (isDone.present) {
      map['is_done'] = Variable<bool>(isDone.value);
    }
    if (lastFetched.present) {
      map['last_fetched'] = Variable<int>(lastFetched.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (synced.present) {
      map['synced'] = Variable<bool>(synced.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WorkoutEntriesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('detail: $detail, ')
          ..write('benefit: $benefit, ')
          ..write('isDone: $isDone, ')
          ..write('lastFetched: $lastFetched, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('synced: $synced, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $WorkoutEntriesTable workoutEntries = $WorkoutEntriesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [workoutEntries];
}

typedef $$WorkoutEntriesTableCreateCompanionBuilder =
    WorkoutEntriesCompanion Function({
      required String id,
      required String name,
      required String detail,
      required String benefit,
      Value<bool> isDone,
      required int lastFetched,
      Value<int> updatedAt,
      Value<bool> synced,
      Value<int> rowid,
    });
typedef $$WorkoutEntriesTableUpdateCompanionBuilder =
    WorkoutEntriesCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String> detail,
      Value<String> benefit,
      Value<bool> isDone,
      Value<int> lastFetched,
      Value<int> updatedAt,
      Value<bool> synced,
      Value<int> rowid,
    });

class $$WorkoutEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $WorkoutEntriesTable> {
  $$WorkoutEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get detail => $composableBuilder(
    column: $table.detail,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get benefit => $composableBuilder(
    column: $table.benefit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDone => $composableBuilder(
    column: $table.isDone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastFetched => $composableBuilder(
    column: $table.lastFetched,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get synced => $composableBuilder(
    column: $table.synced,
    builder: (column) => ColumnFilters(column),
  );
}

class $$WorkoutEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $WorkoutEntriesTable> {
  $$WorkoutEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get detail => $composableBuilder(
    column: $table.detail,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get benefit => $composableBuilder(
    column: $table.benefit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDone => $composableBuilder(
    column: $table.isDone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastFetched => $composableBuilder(
    column: $table.lastFetched,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get synced => $composableBuilder(
    column: $table.synced,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$WorkoutEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $WorkoutEntriesTable> {
  $$WorkoutEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get detail =>
      $composableBuilder(column: $table.detail, builder: (column) => column);

  GeneratedColumn<String> get benefit =>
      $composableBuilder(column: $table.benefit, builder: (column) => column);

  GeneratedColumn<bool> get isDone =>
      $composableBuilder(column: $table.isDone, builder: (column) => column);

  GeneratedColumn<int> get lastFetched => $composableBuilder(
    column: $table.lastFetched,
    builder: (column) => column,
  );

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get synced =>
      $composableBuilder(column: $table.synced, builder: (column) => column);
}

class $$WorkoutEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WorkoutEntriesTable,
          WorkoutEntry,
          $$WorkoutEntriesTableFilterComposer,
          $$WorkoutEntriesTableOrderingComposer,
          $$WorkoutEntriesTableAnnotationComposer,
          $$WorkoutEntriesTableCreateCompanionBuilder,
          $$WorkoutEntriesTableUpdateCompanionBuilder,
          (
            WorkoutEntry,
            BaseReferences<_$AppDatabase, $WorkoutEntriesTable, WorkoutEntry>,
          ),
          WorkoutEntry,
          PrefetchHooks Function()
        > {
  $$WorkoutEntriesTableTableManager(
    _$AppDatabase db,
    $WorkoutEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WorkoutEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WorkoutEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WorkoutEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> detail = const Value.absent(),
                Value<String> benefit = const Value.absent(),
                Value<bool> isDone = const Value.absent(),
                Value<int> lastFetched = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<bool> synced = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WorkoutEntriesCompanion(
                id: id,
                name: name,
                detail: detail,
                benefit: benefit,
                isDone: isDone,
                lastFetched: lastFetched,
                updatedAt: updatedAt,
                synced: synced,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required String detail,
                required String benefit,
                Value<bool> isDone = const Value.absent(),
                required int lastFetched,
                Value<int> updatedAt = const Value.absent(),
                Value<bool> synced = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WorkoutEntriesCompanion.insert(
                id: id,
                name: name,
                detail: detail,
                benefit: benefit,
                isDone: isDone,
                lastFetched: lastFetched,
                updatedAt: updatedAt,
                synced: synced,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$WorkoutEntriesTable, WorkoutEntry>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $WorkoutEntriesTable,
                    WorkoutEntry
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$WorkoutEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WorkoutEntriesTable,
      WorkoutEntry,
      $$WorkoutEntriesTableFilterComposer,
      $$WorkoutEntriesTableOrderingComposer,
      $$WorkoutEntriesTableAnnotationComposer,
      $$WorkoutEntriesTableCreateCompanionBuilder,
      $$WorkoutEntriesTableUpdateCompanionBuilder,
      (
        WorkoutEntry,
        BaseReferences<_$AppDatabase, $WorkoutEntriesTable, WorkoutEntry>,
      ),
      WorkoutEntry,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$WorkoutEntriesTableTableManager get workoutEntries =>
      $$WorkoutEntriesTableTableManager(_db, _db.workoutEntries);
}
