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
  static const VerificationMeta _dayOfWeekMeta = const VerificationMeta(
    'dayOfWeek',
  );
  @override
  late final GeneratedColumn<String> dayOfWeek = GeneratedColumn<String>(
    'day_of_week',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
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
    dayOfWeek,
    category,
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
    if (data.containsKey('day_of_week')) {
      context.handle(
        _dayOfWeekMeta,
        dayOfWeek.isAcceptableOrUnknown(data['day_of_week']!, _dayOfWeekMeta),
      );
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
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
      dayOfWeek: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}day_of_week'],
      ),
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      ),
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

  /// Schema v3: hari dari rencana server, mis. "mon". Null untuk latihan lokal.
  final String? dayOfWeek;

  /// Schema v3: kategori latihan, mis. "strength", "cardio", "flexibility".
  final String? category;
  final bool isDone;

  /// Penanda cache: kapan data ini terakhir diambil dari server (UTC millis).
  final int lastFetched;

  /// Schema v2: kapan baris ini terakhir diubah di perangkat (UTC millis).
  final int updatedAt;

  /// Schema v2: false = ada perubahan lokal yang belum dikirim ke server.
  final bool synced;
  const WorkoutEntry({
    required this.id,
    required this.name,
    required this.detail,
    required this.benefit,
    this.dayOfWeek,
    this.category,
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
    if (!nullToAbsent || dayOfWeek != null) {
      map['day_of_week'] = Variable<String>(dayOfWeek);
    }
    if (!nullToAbsent || category != null) {
      map['category'] = Variable<String>(category);
    }
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
      dayOfWeek: dayOfWeek == null && nullToAbsent
          ? const Value.absent()
          : Value(dayOfWeek),
      category: category == null && nullToAbsent
          ? const Value.absent()
          : Value(category),
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
      dayOfWeek: serializer.fromJson<String?>(json['dayOfWeek']),
      category: serializer.fromJson<String?>(json['category']),
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
      'dayOfWeek': serializer.toJson<String?>(dayOfWeek),
      'category': serializer.toJson<String?>(category),
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
    Value<String?> dayOfWeek = const Value.absent(),
    Value<String?> category = const Value.absent(),
    bool? isDone,
    int? lastFetched,
    int? updatedAt,
    bool? synced,
  }) => WorkoutEntry(
    id: id ?? this.id,
    name: name ?? this.name,
    detail: detail ?? this.detail,
    benefit: benefit ?? this.benefit,
    dayOfWeek: dayOfWeek.present ? dayOfWeek.value : this.dayOfWeek,
    category: category.present ? category.value : this.category,
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
      dayOfWeek: data.dayOfWeek.present ? data.dayOfWeek.value : this.dayOfWeek,
      category: data.category.present ? data.category.value : this.category,
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
          ..write('dayOfWeek: $dayOfWeek, ')
          ..write('category: $category, ')
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
    dayOfWeek,
    category,
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
          other.dayOfWeek == this.dayOfWeek &&
          other.category == this.category &&
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
  final Value<String?> dayOfWeek;
  final Value<String?> category;
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
    this.dayOfWeek = const Value.absent(),
    this.category = const Value.absent(),
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
    this.dayOfWeek = const Value.absent(),
    this.category = const Value.absent(),
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
    Expression<String>? dayOfWeek,
    Expression<String>? category,
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
      if (dayOfWeek != null) 'day_of_week': dayOfWeek,
      if (category != null) 'category': category,
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
    Value<String?>? dayOfWeek,
    Value<String?>? category,
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
      dayOfWeek: dayOfWeek ?? this.dayOfWeek,
      category: category ?? this.category,
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
    if (dayOfWeek.present) {
      map['day_of_week'] = Variable<String>(dayOfWeek.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
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
          ..write('dayOfWeek: $dayOfWeek, ')
          ..write('category: $category, ')
          ..write('isDone: $isDone, ')
          ..write('lastFetched: $lastFetched, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('synced: $synced, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MealEntriesTable extends MealEntries
    with TableInfo<$MealEntriesTable, MealEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MealEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dayOfWeekMeta = const VerificationMeta(
    'dayOfWeek',
  );
  @override
  late final GeneratedColumn<String> dayOfWeek = GeneratedColumn<String>(
    'day_of_week',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _mealTypeMeta = const VerificationMeta(
    'mealType',
  );
  @override
  late final GeneratedColumn<String> mealType = GeneratedColumn<String>(
    'meal_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _foodNameMeta = const VerificationMeta(
    'foodName',
  );
  @override
  late final GeneratedColumn<String> foodName = GeneratedColumn<String>(
    'food_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _caloriesMeta = const VerificationMeta(
    'calories',
  );
  @override
  late final GeneratedColumn<int> calories = GeneratedColumn<int>(
    'calories',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _proteinGMeta = const VerificationMeta(
    'proteinG',
  );
  @override
  late final GeneratedColumn<double> proteinG = GeneratedColumn<double>(
    'protein_g',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _carbsGMeta = const VerificationMeta('carbsG');
  @override
  late final GeneratedColumn<double> carbsG = GeneratedColumn<double>(
    'carbs_g',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _fatGMeta = const VerificationMeta('fatG');
  @override
  late final GeneratedColumn<double> fatG = GeneratedColumn<double>(
    'fat_g',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
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
    dayOfWeek,
    mealType,
    foodName,
    calories,
    proteinG,
    carbsG,
    fatG,
    isDone,
    lastFetched,
    updatedAt,
    synced,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'meal_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<MealEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('day_of_week')) {
      context.handle(
        _dayOfWeekMeta,
        dayOfWeek.isAcceptableOrUnknown(data['day_of_week']!, _dayOfWeekMeta),
      );
    }
    if (data.containsKey('meal_type')) {
      context.handle(
        _mealTypeMeta,
        mealType.isAcceptableOrUnknown(data['meal_type']!, _mealTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_mealTypeMeta);
    }
    if (data.containsKey('food_name')) {
      context.handle(
        _foodNameMeta,
        foodName.isAcceptableOrUnknown(data['food_name']!, _foodNameMeta),
      );
    } else if (isInserting) {
      context.missing(_foodNameMeta);
    }
    if (data.containsKey('calories')) {
      context.handle(
        _caloriesMeta,
        calories.isAcceptableOrUnknown(data['calories']!, _caloriesMeta),
      );
    }
    if (data.containsKey('protein_g')) {
      context.handle(
        _proteinGMeta,
        proteinG.isAcceptableOrUnknown(data['protein_g']!, _proteinGMeta),
      );
    }
    if (data.containsKey('carbs_g')) {
      context.handle(
        _carbsGMeta,
        carbsG.isAcceptableOrUnknown(data['carbs_g']!, _carbsGMeta),
      );
    }
    if (data.containsKey('fat_g')) {
      context.handle(
        _fatGMeta,
        fatG.isAcceptableOrUnknown(data['fat_g']!, _fatGMeta),
      );
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
  MealEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MealEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      dayOfWeek: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}day_of_week'],
      ),
      mealType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}meal_type'],
      )!,
      foodName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}food_name'],
      )!,
      calories: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}calories'],
      ),
      proteinG: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}protein_g'],
      ),
      carbsG: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}carbs_g'],
      ),
      fatG: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}fat_g'],
      ),
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
  $MealEntriesTable createAlias(String alias) {
    return $MealEntriesTable(attachedDatabase, alias);
  }
}

class MealEntry extends DataClass implements Insertable<MealEntry> {
  final String id;
  final String? dayOfWeek;
  final String mealType;
  final String foodName;
  final int? calories;
  final double? proteinG;
  final double? carbsG;
  final double? fatG;
  final bool isDone;
  final int lastFetched;
  final int updatedAt;
  final bool synced;
  const MealEntry({
    required this.id,
    this.dayOfWeek,
    required this.mealType,
    required this.foodName,
    this.calories,
    this.proteinG,
    this.carbsG,
    this.fatG,
    required this.isDone,
    required this.lastFetched,
    required this.updatedAt,
    required this.synced,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || dayOfWeek != null) {
      map['day_of_week'] = Variable<String>(dayOfWeek);
    }
    map['meal_type'] = Variable<String>(mealType);
    map['food_name'] = Variable<String>(foodName);
    if (!nullToAbsent || calories != null) {
      map['calories'] = Variable<int>(calories);
    }
    if (!nullToAbsent || proteinG != null) {
      map['protein_g'] = Variable<double>(proteinG);
    }
    if (!nullToAbsent || carbsG != null) {
      map['carbs_g'] = Variable<double>(carbsG);
    }
    if (!nullToAbsent || fatG != null) {
      map['fat_g'] = Variable<double>(fatG);
    }
    map['is_done'] = Variable<bool>(isDone);
    map['last_fetched'] = Variable<int>(lastFetched);
    map['updated_at'] = Variable<int>(updatedAt);
    map['synced'] = Variable<bool>(synced);
    return map;
  }

  MealEntriesCompanion toCompanion(bool nullToAbsent) {
    return MealEntriesCompanion(
      id: Value(id),
      dayOfWeek: dayOfWeek == null && nullToAbsent
          ? const Value.absent()
          : Value(dayOfWeek),
      mealType: Value(mealType),
      foodName: Value(foodName),
      calories: calories == null && nullToAbsent
          ? const Value.absent()
          : Value(calories),
      proteinG: proteinG == null && nullToAbsent
          ? const Value.absent()
          : Value(proteinG),
      carbsG: carbsG == null && nullToAbsent
          ? const Value.absent()
          : Value(carbsG),
      fatG: fatG == null && nullToAbsent ? const Value.absent() : Value(fatG),
      isDone: Value(isDone),
      lastFetched: Value(lastFetched),
      updatedAt: Value(updatedAt),
      synced: Value(synced),
    );
  }

  factory MealEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MealEntry(
      id: serializer.fromJson<String>(json['id']),
      dayOfWeek: serializer.fromJson<String?>(json['dayOfWeek']),
      mealType: serializer.fromJson<String>(json['mealType']),
      foodName: serializer.fromJson<String>(json['foodName']),
      calories: serializer.fromJson<int?>(json['calories']),
      proteinG: serializer.fromJson<double?>(json['proteinG']),
      carbsG: serializer.fromJson<double?>(json['carbsG']),
      fatG: serializer.fromJson<double?>(json['fatG']),
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
      'dayOfWeek': serializer.toJson<String?>(dayOfWeek),
      'mealType': serializer.toJson<String>(mealType),
      'foodName': serializer.toJson<String>(foodName),
      'calories': serializer.toJson<int?>(calories),
      'proteinG': serializer.toJson<double?>(proteinG),
      'carbsG': serializer.toJson<double?>(carbsG),
      'fatG': serializer.toJson<double?>(fatG),
      'isDone': serializer.toJson<bool>(isDone),
      'lastFetched': serializer.toJson<int>(lastFetched),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'synced': serializer.toJson<bool>(synced),
    };
  }

  MealEntry copyWith({
    String? id,
    Value<String?> dayOfWeek = const Value.absent(),
    String? mealType,
    String? foodName,
    Value<int?> calories = const Value.absent(),
    Value<double?> proteinG = const Value.absent(),
    Value<double?> carbsG = const Value.absent(),
    Value<double?> fatG = const Value.absent(),
    bool? isDone,
    int? lastFetched,
    int? updatedAt,
    bool? synced,
  }) => MealEntry(
    id: id ?? this.id,
    dayOfWeek: dayOfWeek.present ? dayOfWeek.value : this.dayOfWeek,
    mealType: mealType ?? this.mealType,
    foodName: foodName ?? this.foodName,
    calories: calories.present ? calories.value : this.calories,
    proteinG: proteinG.present ? proteinG.value : this.proteinG,
    carbsG: carbsG.present ? carbsG.value : this.carbsG,
    fatG: fatG.present ? fatG.value : this.fatG,
    isDone: isDone ?? this.isDone,
    lastFetched: lastFetched ?? this.lastFetched,
    updatedAt: updatedAt ?? this.updatedAt,
    synced: synced ?? this.synced,
  );
  MealEntry copyWithCompanion(MealEntriesCompanion data) {
    return MealEntry(
      id: data.id.present ? data.id.value : this.id,
      dayOfWeek: data.dayOfWeek.present ? data.dayOfWeek.value : this.dayOfWeek,
      mealType: data.mealType.present ? data.mealType.value : this.mealType,
      foodName: data.foodName.present ? data.foodName.value : this.foodName,
      calories: data.calories.present ? data.calories.value : this.calories,
      proteinG: data.proteinG.present ? data.proteinG.value : this.proteinG,
      carbsG: data.carbsG.present ? data.carbsG.value : this.carbsG,
      fatG: data.fatG.present ? data.fatG.value : this.fatG,
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
    return (StringBuffer('MealEntry(')
          ..write('id: $id, ')
          ..write('dayOfWeek: $dayOfWeek, ')
          ..write('mealType: $mealType, ')
          ..write('foodName: $foodName, ')
          ..write('calories: $calories, ')
          ..write('proteinG: $proteinG, ')
          ..write('carbsG: $carbsG, ')
          ..write('fatG: $fatG, ')
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
    dayOfWeek,
    mealType,
    foodName,
    calories,
    proteinG,
    carbsG,
    fatG,
    isDone,
    lastFetched,
    updatedAt,
    synced,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MealEntry &&
          other.id == this.id &&
          other.dayOfWeek == this.dayOfWeek &&
          other.mealType == this.mealType &&
          other.foodName == this.foodName &&
          other.calories == this.calories &&
          other.proteinG == this.proteinG &&
          other.carbsG == this.carbsG &&
          other.fatG == this.fatG &&
          other.isDone == this.isDone &&
          other.lastFetched == this.lastFetched &&
          other.updatedAt == this.updatedAt &&
          other.synced == this.synced);
}

class MealEntriesCompanion extends UpdateCompanion<MealEntry> {
  final Value<String> id;
  final Value<String?> dayOfWeek;
  final Value<String> mealType;
  final Value<String> foodName;
  final Value<int?> calories;
  final Value<double?> proteinG;
  final Value<double?> carbsG;
  final Value<double?> fatG;
  final Value<bool> isDone;
  final Value<int> lastFetched;
  final Value<int> updatedAt;
  final Value<bool> synced;
  final Value<int> rowid;
  const MealEntriesCompanion({
    this.id = const Value.absent(),
    this.dayOfWeek = const Value.absent(),
    this.mealType = const Value.absent(),
    this.foodName = const Value.absent(),
    this.calories = const Value.absent(),
    this.proteinG = const Value.absent(),
    this.carbsG = const Value.absent(),
    this.fatG = const Value.absent(),
    this.isDone = const Value.absent(),
    this.lastFetched = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.synced = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MealEntriesCompanion.insert({
    required String id,
    this.dayOfWeek = const Value.absent(),
    required String mealType,
    required String foodName,
    this.calories = const Value.absent(),
    this.proteinG = const Value.absent(),
    this.carbsG = const Value.absent(),
    this.fatG = const Value.absent(),
    this.isDone = const Value.absent(),
    required int lastFetched,
    this.updatedAt = const Value.absent(),
    this.synced = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       mealType = Value(mealType),
       foodName = Value(foodName),
       lastFetched = Value(lastFetched);
  static Insertable<MealEntry> custom({
    Expression<String>? id,
    Expression<String>? dayOfWeek,
    Expression<String>? mealType,
    Expression<String>? foodName,
    Expression<int>? calories,
    Expression<double>? proteinG,
    Expression<double>? carbsG,
    Expression<double>? fatG,
    Expression<bool>? isDone,
    Expression<int>? lastFetched,
    Expression<int>? updatedAt,
    Expression<bool>? synced,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (dayOfWeek != null) 'day_of_week': dayOfWeek,
      if (mealType != null) 'meal_type': mealType,
      if (foodName != null) 'food_name': foodName,
      if (calories != null) 'calories': calories,
      if (proteinG != null) 'protein_g': proteinG,
      if (carbsG != null) 'carbs_g': carbsG,
      if (fatG != null) 'fat_g': fatG,
      if (isDone != null) 'is_done': isDone,
      if (lastFetched != null) 'last_fetched': lastFetched,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (synced != null) 'synced': synced,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MealEntriesCompanion copyWith({
    Value<String>? id,
    Value<String?>? dayOfWeek,
    Value<String>? mealType,
    Value<String>? foodName,
    Value<int?>? calories,
    Value<double?>? proteinG,
    Value<double?>? carbsG,
    Value<double?>? fatG,
    Value<bool>? isDone,
    Value<int>? lastFetched,
    Value<int>? updatedAt,
    Value<bool>? synced,
    Value<int>? rowid,
  }) {
    return MealEntriesCompanion(
      id: id ?? this.id,
      dayOfWeek: dayOfWeek ?? this.dayOfWeek,
      mealType: mealType ?? this.mealType,
      foodName: foodName ?? this.foodName,
      calories: calories ?? this.calories,
      proteinG: proteinG ?? this.proteinG,
      carbsG: carbsG ?? this.carbsG,
      fatG: fatG ?? this.fatG,
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
    if (dayOfWeek.present) {
      map['day_of_week'] = Variable<String>(dayOfWeek.value);
    }
    if (mealType.present) {
      map['meal_type'] = Variable<String>(mealType.value);
    }
    if (foodName.present) {
      map['food_name'] = Variable<String>(foodName.value);
    }
    if (calories.present) {
      map['calories'] = Variable<int>(calories.value);
    }
    if (proteinG.present) {
      map['protein_g'] = Variable<double>(proteinG.value);
    }
    if (carbsG.present) {
      map['carbs_g'] = Variable<double>(carbsG.value);
    }
    if (fatG.present) {
      map['fat_g'] = Variable<double>(fatG.value);
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
    return (StringBuffer('MealEntriesCompanion(')
          ..write('id: $id, ')
          ..write('dayOfWeek: $dayOfWeek, ')
          ..write('mealType: $mealType, ')
          ..write('foodName: $foodName, ')
          ..write('calories: $calories, ')
          ..write('proteinG: $proteinG, ')
          ..write('carbsG: $carbsG, ')
          ..write('fatG: $fatG, ')
          ..write('isDone: $isDone, ')
          ..write('lastFetched: $lastFetched, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('synced: $synced, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TargetEntriesTable extends TargetEntries
    with TableInfo<$TargetEntriesTable, TargetEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TargetEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _weekStartDateMeta = const VerificationMeta(
    'weekStartDate',
  );
  @override
  late final GeneratedColumn<String> weekStartDate = GeneratedColumn<String>(
    'week_start_date',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _targetStepsMeta = const VerificationMeta(
    'targetSteps',
  );
  @override
  late final GeneratedColumn<int> targetSteps = GeneratedColumn<int>(
    'target_steps',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _targetWaterLitersMeta = const VerificationMeta(
    'targetWaterLiters',
  );
  @override
  late final GeneratedColumn<double> targetWaterLiters =
      GeneratedColumn<double>(
        'target_water_liters',
        aliasedName,
        true,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _targetCaloriesMeta = const VerificationMeta(
    'targetCalories',
  );
  @override
  late final GeneratedColumn<int> targetCalories = GeneratedColumn<int>(
    'target_calories',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
    'source',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
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
  @override
  List<GeneratedColumn> get $columns => [
    id,
    weekStartDate,
    targetSteps,
    targetWaterLiters,
    targetCalories,
    source,
    lastFetched,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'target_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<TargetEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('week_start_date')) {
      context.handle(
        _weekStartDateMeta,
        weekStartDate.isAcceptableOrUnknown(
          data['week_start_date']!,
          _weekStartDateMeta,
        ),
      );
    }
    if (data.containsKey('target_steps')) {
      context.handle(
        _targetStepsMeta,
        targetSteps.isAcceptableOrUnknown(
          data['target_steps']!,
          _targetStepsMeta,
        ),
      );
    }
    if (data.containsKey('target_water_liters')) {
      context.handle(
        _targetWaterLitersMeta,
        targetWaterLiters.isAcceptableOrUnknown(
          data['target_water_liters']!,
          _targetWaterLitersMeta,
        ),
      );
    }
    if (data.containsKey('target_calories')) {
      context.handle(
        _targetCaloriesMeta,
        targetCalories.isAcceptableOrUnknown(
          data['target_calories']!,
          _targetCaloriesMeta,
        ),
      );
    }
    if (data.containsKey('source')) {
      context.handle(
        _sourceMeta,
        source.isAcceptableOrUnknown(data['source']!, _sourceMeta),
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
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TargetEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TargetEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      weekStartDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}week_start_date'],
      ),
      targetSteps: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}target_steps'],
      ),
      targetWaterLiters: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}target_water_liters'],
      ),
      targetCalories: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}target_calories'],
      ),
      source: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source'],
      ),
      lastFetched: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_fetched'],
      )!,
    );
  }

  @override
  $TargetEntriesTable createAlias(String alias) {
    return $TargetEntriesTable(attachedDatabase, alias);
  }
}

class TargetEntry extends DataClass implements Insertable<TargetEntry> {
  final String id;
  final String? weekStartDate;
  final int? targetSteps;
  final double? targetWaterLiters;
  final int? targetCalories;
  final String? source;
  final int lastFetched;
  const TargetEntry({
    required this.id,
    this.weekStartDate,
    this.targetSteps,
    this.targetWaterLiters,
    this.targetCalories,
    this.source,
    required this.lastFetched,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || weekStartDate != null) {
      map['week_start_date'] = Variable<String>(weekStartDate);
    }
    if (!nullToAbsent || targetSteps != null) {
      map['target_steps'] = Variable<int>(targetSteps);
    }
    if (!nullToAbsent || targetWaterLiters != null) {
      map['target_water_liters'] = Variable<double>(targetWaterLiters);
    }
    if (!nullToAbsent || targetCalories != null) {
      map['target_calories'] = Variable<int>(targetCalories);
    }
    if (!nullToAbsent || source != null) {
      map['source'] = Variable<String>(source);
    }
    map['last_fetched'] = Variable<int>(lastFetched);
    return map;
  }

  TargetEntriesCompanion toCompanion(bool nullToAbsent) {
    return TargetEntriesCompanion(
      id: Value(id),
      weekStartDate: weekStartDate == null && nullToAbsent
          ? const Value.absent()
          : Value(weekStartDate),
      targetSteps: targetSteps == null && nullToAbsent
          ? const Value.absent()
          : Value(targetSteps),
      targetWaterLiters: targetWaterLiters == null && nullToAbsent
          ? const Value.absent()
          : Value(targetWaterLiters),
      targetCalories: targetCalories == null && nullToAbsent
          ? const Value.absent()
          : Value(targetCalories),
      source: source == null && nullToAbsent
          ? const Value.absent()
          : Value(source),
      lastFetched: Value(lastFetched),
    );
  }

  factory TargetEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TargetEntry(
      id: serializer.fromJson<String>(json['id']),
      weekStartDate: serializer.fromJson<String?>(json['weekStartDate']),
      targetSteps: serializer.fromJson<int?>(json['targetSteps']),
      targetWaterLiters: serializer.fromJson<double?>(
        json['targetWaterLiters'],
      ),
      targetCalories: serializer.fromJson<int?>(json['targetCalories']),
      source: serializer.fromJson<String?>(json['source']),
      lastFetched: serializer.fromJson<int>(json['lastFetched']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'weekStartDate': serializer.toJson<String?>(weekStartDate),
      'targetSteps': serializer.toJson<int?>(targetSteps),
      'targetWaterLiters': serializer.toJson<double?>(targetWaterLiters),
      'targetCalories': serializer.toJson<int?>(targetCalories),
      'source': serializer.toJson<String?>(source),
      'lastFetched': serializer.toJson<int>(lastFetched),
    };
  }

  TargetEntry copyWith({
    String? id,
    Value<String?> weekStartDate = const Value.absent(),
    Value<int?> targetSteps = const Value.absent(),
    Value<double?> targetWaterLiters = const Value.absent(),
    Value<int?> targetCalories = const Value.absent(),
    Value<String?> source = const Value.absent(),
    int? lastFetched,
  }) => TargetEntry(
    id: id ?? this.id,
    weekStartDate: weekStartDate.present
        ? weekStartDate.value
        : this.weekStartDate,
    targetSteps: targetSteps.present ? targetSteps.value : this.targetSteps,
    targetWaterLiters: targetWaterLiters.present
        ? targetWaterLiters.value
        : this.targetWaterLiters,
    targetCalories: targetCalories.present
        ? targetCalories.value
        : this.targetCalories,
    source: source.present ? source.value : this.source,
    lastFetched: lastFetched ?? this.lastFetched,
  );
  TargetEntry copyWithCompanion(TargetEntriesCompanion data) {
    return TargetEntry(
      id: data.id.present ? data.id.value : this.id,
      weekStartDate: data.weekStartDate.present
          ? data.weekStartDate.value
          : this.weekStartDate,
      targetSteps: data.targetSteps.present
          ? data.targetSteps.value
          : this.targetSteps,
      targetWaterLiters: data.targetWaterLiters.present
          ? data.targetWaterLiters.value
          : this.targetWaterLiters,
      targetCalories: data.targetCalories.present
          ? data.targetCalories.value
          : this.targetCalories,
      source: data.source.present ? data.source.value : this.source,
      lastFetched: data.lastFetched.present
          ? data.lastFetched.value
          : this.lastFetched,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TargetEntry(')
          ..write('id: $id, ')
          ..write('weekStartDate: $weekStartDate, ')
          ..write('targetSteps: $targetSteps, ')
          ..write('targetWaterLiters: $targetWaterLiters, ')
          ..write('targetCalories: $targetCalories, ')
          ..write('source: $source, ')
          ..write('lastFetched: $lastFetched')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    weekStartDate,
    targetSteps,
    targetWaterLiters,
    targetCalories,
    source,
    lastFetched,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TargetEntry &&
          other.id == this.id &&
          other.weekStartDate == this.weekStartDate &&
          other.targetSteps == this.targetSteps &&
          other.targetWaterLiters == this.targetWaterLiters &&
          other.targetCalories == this.targetCalories &&
          other.source == this.source &&
          other.lastFetched == this.lastFetched);
}

class TargetEntriesCompanion extends UpdateCompanion<TargetEntry> {
  final Value<String> id;
  final Value<String?> weekStartDate;
  final Value<int?> targetSteps;
  final Value<double?> targetWaterLiters;
  final Value<int?> targetCalories;
  final Value<String?> source;
  final Value<int> lastFetched;
  final Value<int> rowid;
  const TargetEntriesCompanion({
    this.id = const Value.absent(),
    this.weekStartDate = const Value.absent(),
    this.targetSteps = const Value.absent(),
    this.targetWaterLiters = const Value.absent(),
    this.targetCalories = const Value.absent(),
    this.source = const Value.absent(),
    this.lastFetched = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TargetEntriesCompanion.insert({
    required String id,
    this.weekStartDate = const Value.absent(),
    this.targetSteps = const Value.absent(),
    this.targetWaterLiters = const Value.absent(),
    this.targetCalories = const Value.absent(),
    this.source = const Value.absent(),
    required int lastFetched,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       lastFetched = Value(lastFetched);
  static Insertable<TargetEntry> custom({
    Expression<String>? id,
    Expression<String>? weekStartDate,
    Expression<int>? targetSteps,
    Expression<double>? targetWaterLiters,
    Expression<int>? targetCalories,
    Expression<String>? source,
    Expression<int>? lastFetched,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (weekStartDate != null) 'week_start_date': weekStartDate,
      if (targetSteps != null) 'target_steps': targetSteps,
      if (targetWaterLiters != null) 'target_water_liters': targetWaterLiters,
      if (targetCalories != null) 'target_calories': targetCalories,
      if (source != null) 'source': source,
      if (lastFetched != null) 'last_fetched': lastFetched,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TargetEntriesCompanion copyWith({
    Value<String>? id,
    Value<String?>? weekStartDate,
    Value<int?>? targetSteps,
    Value<double?>? targetWaterLiters,
    Value<int?>? targetCalories,
    Value<String?>? source,
    Value<int>? lastFetched,
    Value<int>? rowid,
  }) {
    return TargetEntriesCompanion(
      id: id ?? this.id,
      weekStartDate: weekStartDate ?? this.weekStartDate,
      targetSteps: targetSteps ?? this.targetSteps,
      targetWaterLiters: targetWaterLiters ?? this.targetWaterLiters,
      targetCalories: targetCalories ?? this.targetCalories,
      source: source ?? this.source,
      lastFetched: lastFetched ?? this.lastFetched,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (weekStartDate.present) {
      map['week_start_date'] = Variable<String>(weekStartDate.value);
    }
    if (targetSteps.present) {
      map['target_steps'] = Variable<int>(targetSteps.value);
    }
    if (targetWaterLiters.present) {
      map['target_water_liters'] = Variable<double>(targetWaterLiters.value);
    }
    if (targetCalories.present) {
      map['target_calories'] = Variable<int>(targetCalories.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (lastFetched.present) {
      map['last_fetched'] = Variable<int>(lastFetched.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TargetEntriesCompanion(')
          ..write('id: $id, ')
          ..write('weekStartDate: $weekStartDate, ')
          ..write('targetSteps: $targetSteps, ')
          ..write('targetWaterLiters: $targetWaterLiters, ')
          ..write('targetCalories: $targetCalories, ')
          ..write('source: $source, ')
          ..write('lastFetched: $lastFetched, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DailyLogEntriesTable extends DailyLogEntries
    with TableInfo<$DailyLogEntriesTable, DailyLogEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DailyLogEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _logDateMeta = const VerificationMeta(
    'logDate',
  );
  @override
  late final GeneratedColumn<String> logDate = GeneratedColumn<String>(
    'log_date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _weightKgMeta = const VerificationMeta(
    'weightKg',
  );
  @override
  late final GeneratedColumn<double> weightKg = GeneratedColumn<double>(
    'weight_kg',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _stepsMeta = const VerificationMeta('steps');
  @override
  late final GeneratedColumn<int> steps = GeneratedColumn<int>(
    'steps',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _waterLitersMeta = const VerificationMeta(
    'waterLiters',
  );
  @override
  late final GeneratedColumn<double> waterLiters = GeneratedColumn<double>(
    'water_liters',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _caloriesBurnedMeta = const VerificationMeta(
    'caloriesBurned',
  );
  @override
  late final GeneratedColumn<double> caloriesBurned = GeneratedColumn<double>(
    'calories_burned',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
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
    logDate,
    weightKg,
    steps,
    waterLiters,
    caloriesBurned,
    lastFetched,
    updatedAt,
    synced,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'daily_log_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<DailyLogEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('log_date')) {
      context.handle(
        _logDateMeta,
        logDate.isAcceptableOrUnknown(data['log_date']!, _logDateMeta),
      );
    } else if (isInserting) {
      context.missing(_logDateMeta);
    }
    if (data.containsKey('weight_kg')) {
      context.handle(
        _weightKgMeta,
        weightKg.isAcceptableOrUnknown(data['weight_kg']!, _weightKgMeta),
      );
    }
    if (data.containsKey('steps')) {
      context.handle(
        _stepsMeta,
        steps.isAcceptableOrUnknown(data['steps']!, _stepsMeta),
      );
    }
    if (data.containsKey('water_liters')) {
      context.handle(
        _waterLitersMeta,
        waterLiters.isAcceptableOrUnknown(
          data['water_liters']!,
          _waterLitersMeta,
        ),
      );
    }
    if (data.containsKey('calories_burned')) {
      context.handle(
        _caloriesBurnedMeta,
        caloriesBurned.isAcceptableOrUnknown(
          data['calories_burned']!,
          _caloriesBurnedMeta,
        ),
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
  Set<GeneratedColumn> get $primaryKey => {logDate};
  @override
  DailyLogEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DailyLogEntry(
      logDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}log_date'],
      )!,
      weightKg: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}weight_kg'],
      ),
      steps: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}steps'],
      ),
      waterLiters: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}water_liters'],
      ),
      caloriesBurned: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}calories_burned'],
      ),
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
  $DailyLogEntriesTable createAlias(String alias) {
    return $DailyLogEntriesTable(attachedDatabase, alias);
  }
}

class DailyLogEntry extends DataClass implements Insertable<DailyLogEntry> {
  final String logDate;
  final double? weightKg;
  final int? steps;
  final double? waterLiters;
  final double? caloriesBurned;
  final int lastFetched;
  final int updatedAt;
  final bool synced;
  const DailyLogEntry({
    required this.logDate,
    this.weightKg,
    this.steps,
    this.waterLiters,
    this.caloriesBurned,
    required this.lastFetched,
    required this.updatedAt,
    required this.synced,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['log_date'] = Variable<String>(logDate);
    if (!nullToAbsent || weightKg != null) {
      map['weight_kg'] = Variable<double>(weightKg);
    }
    if (!nullToAbsent || steps != null) {
      map['steps'] = Variable<int>(steps);
    }
    if (!nullToAbsent || waterLiters != null) {
      map['water_liters'] = Variable<double>(waterLiters);
    }
    if (!nullToAbsent || caloriesBurned != null) {
      map['calories_burned'] = Variable<double>(caloriesBurned);
    }
    map['last_fetched'] = Variable<int>(lastFetched);
    map['updated_at'] = Variable<int>(updatedAt);
    map['synced'] = Variable<bool>(synced);
    return map;
  }

  DailyLogEntriesCompanion toCompanion(bool nullToAbsent) {
    return DailyLogEntriesCompanion(
      logDate: Value(logDate),
      weightKg: weightKg == null && nullToAbsent
          ? const Value.absent()
          : Value(weightKg),
      steps: steps == null && nullToAbsent
          ? const Value.absent()
          : Value(steps),
      waterLiters: waterLiters == null && nullToAbsent
          ? const Value.absent()
          : Value(waterLiters),
      caloriesBurned: caloriesBurned == null && nullToAbsent
          ? const Value.absent()
          : Value(caloriesBurned),
      lastFetched: Value(lastFetched),
      updatedAt: Value(updatedAt),
      synced: Value(synced),
    );
  }

  factory DailyLogEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DailyLogEntry(
      logDate: serializer.fromJson<String>(json['logDate']),
      weightKg: serializer.fromJson<double?>(json['weightKg']),
      steps: serializer.fromJson<int?>(json['steps']),
      waterLiters: serializer.fromJson<double?>(json['waterLiters']),
      caloriesBurned: serializer.fromJson<double?>(json['caloriesBurned']),
      lastFetched: serializer.fromJson<int>(json['lastFetched']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      synced: serializer.fromJson<bool>(json['synced']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'logDate': serializer.toJson<String>(logDate),
      'weightKg': serializer.toJson<double?>(weightKg),
      'steps': serializer.toJson<int?>(steps),
      'waterLiters': serializer.toJson<double?>(waterLiters),
      'caloriesBurned': serializer.toJson<double?>(caloriesBurned),
      'lastFetched': serializer.toJson<int>(lastFetched),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'synced': serializer.toJson<bool>(synced),
    };
  }

  DailyLogEntry copyWith({
    String? logDate,
    Value<double?> weightKg = const Value.absent(),
    Value<int?> steps = const Value.absent(),
    Value<double?> waterLiters = const Value.absent(),
    Value<double?> caloriesBurned = const Value.absent(),
    int? lastFetched,
    int? updatedAt,
    bool? synced,
  }) => DailyLogEntry(
    logDate: logDate ?? this.logDate,
    weightKg: weightKg.present ? weightKg.value : this.weightKg,
    steps: steps.present ? steps.value : this.steps,
    waterLiters: waterLiters.present ? waterLiters.value : this.waterLiters,
    caloriesBurned: caloriesBurned.present
        ? caloriesBurned.value
        : this.caloriesBurned,
    lastFetched: lastFetched ?? this.lastFetched,
    updatedAt: updatedAt ?? this.updatedAt,
    synced: synced ?? this.synced,
  );
  DailyLogEntry copyWithCompanion(DailyLogEntriesCompanion data) {
    return DailyLogEntry(
      logDate: data.logDate.present ? data.logDate.value : this.logDate,
      weightKg: data.weightKg.present ? data.weightKg.value : this.weightKg,
      steps: data.steps.present ? data.steps.value : this.steps,
      waterLiters: data.waterLiters.present
          ? data.waterLiters.value
          : this.waterLiters,
      caloriesBurned: data.caloriesBurned.present
          ? data.caloriesBurned.value
          : this.caloriesBurned,
      lastFetched: data.lastFetched.present
          ? data.lastFetched.value
          : this.lastFetched,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      synced: data.synced.present ? data.synced.value : this.synced,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DailyLogEntry(')
          ..write('logDate: $logDate, ')
          ..write('weightKg: $weightKg, ')
          ..write('steps: $steps, ')
          ..write('waterLiters: $waterLiters, ')
          ..write('caloriesBurned: $caloriesBurned, ')
          ..write('lastFetched: $lastFetched, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('synced: $synced')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    logDate,
    weightKg,
    steps,
    waterLiters,
    caloriesBurned,
    lastFetched,
    updatedAt,
    synced,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DailyLogEntry &&
          other.logDate == this.logDate &&
          other.weightKg == this.weightKg &&
          other.steps == this.steps &&
          other.waterLiters == this.waterLiters &&
          other.caloriesBurned == this.caloriesBurned &&
          other.lastFetched == this.lastFetched &&
          other.updatedAt == this.updatedAt &&
          other.synced == this.synced);
}

class DailyLogEntriesCompanion extends UpdateCompanion<DailyLogEntry> {
  final Value<String> logDate;
  final Value<double?> weightKg;
  final Value<int?> steps;
  final Value<double?> waterLiters;
  final Value<double?> caloriesBurned;
  final Value<int> lastFetched;
  final Value<int> updatedAt;
  final Value<bool> synced;
  final Value<int> rowid;
  const DailyLogEntriesCompanion({
    this.logDate = const Value.absent(),
    this.weightKg = const Value.absent(),
    this.steps = const Value.absent(),
    this.waterLiters = const Value.absent(),
    this.caloriesBurned = const Value.absent(),
    this.lastFetched = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.synced = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DailyLogEntriesCompanion.insert({
    required String logDate,
    this.weightKg = const Value.absent(),
    this.steps = const Value.absent(),
    this.waterLiters = const Value.absent(),
    this.caloriesBurned = const Value.absent(),
    required int lastFetched,
    this.updatedAt = const Value.absent(),
    this.synced = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : logDate = Value(logDate),
       lastFetched = Value(lastFetched);
  static Insertable<DailyLogEntry> custom({
    Expression<String>? logDate,
    Expression<double>? weightKg,
    Expression<int>? steps,
    Expression<double>? waterLiters,
    Expression<double>? caloriesBurned,
    Expression<int>? lastFetched,
    Expression<int>? updatedAt,
    Expression<bool>? synced,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (logDate != null) 'log_date': logDate,
      if (weightKg != null) 'weight_kg': weightKg,
      if (steps != null) 'steps': steps,
      if (waterLiters != null) 'water_liters': waterLiters,
      if (caloriesBurned != null) 'calories_burned': caloriesBurned,
      if (lastFetched != null) 'last_fetched': lastFetched,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (synced != null) 'synced': synced,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DailyLogEntriesCompanion copyWith({
    Value<String>? logDate,
    Value<double?>? weightKg,
    Value<int?>? steps,
    Value<double?>? waterLiters,
    Value<double?>? caloriesBurned,
    Value<int>? lastFetched,
    Value<int>? updatedAt,
    Value<bool>? synced,
    Value<int>? rowid,
  }) {
    return DailyLogEntriesCompanion(
      logDate: logDate ?? this.logDate,
      weightKg: weightKg ?? this.weightKg,
      steps: steps ?? this.steps,
      waterLiters: waterLiters ?? this.waterLiters,
      caloriesBurned: caloriesBurned ?? this.caloriesBurned,
      lastFetched: lastFetched ?? this.lastFetched,
      updatedAt: updatedAt ?? this.updatedAt,
      synced: synced ?? this.synced,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (logDate.present) {
      map['log_date'] = Variable<String>(logDate.value);
    }
    if (weightKg.present) {
      map['weight_kg'] = Variable<double>(weightKg.value);
    }
    if (steps.present) {
      map['steps'] = Variable<int>(steps.value);
    }
    if (waterLiters.present) {
      map['water_liters'] = Variable<double>(waterLiters.value);
    }
    if (caloriesBurned.present) {
      map['calories_burned'] = Variable<double>(caloriesBurned.value);
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
    return (StringBuffer('DailyLogEntriesCompanion(')
          ..write('logDate: $logDate, ')
          ..write('weightKg: $weightKg, ')
          ..write('steps: $steps, ')
          ..write('waterLiters: $waterLiters, ')
          ..write('caloriesBurned: $caloriesBurned, ')
          ..write('lastFetched: $lastFetched, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('synced: $synced, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ClientProfileEntriesTable extends ClientProfileEntries
    with TableInfo<$ClientProfileEntriesTable, ClientProfileEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ClientProfileEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _payloadMeta = const VerificationMeta(
    'payload',
  );
  @override
  late final GeneratedColumn<String> payload = GeneratedColumn<String>(
    'payload',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
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
  @override
  List<GeneratedColumn> get $columns => [id, payload, lastFetched];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'client_profile_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<ClientProfileEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('payload')) {
      context.handle(
        _payloadMeta,
        payload.isAcceptableOrUnknown(data['payload']!, _payloadMeta),
      );
    } else if (isInserting) {
      context.missing(_payloadMeta);
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
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ClientProfileEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ClientProfileEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      payload: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload'],
      )!,
      lastFetched: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_fetched'],
      )!,
    );
  }

  @override
  $ClientProfileEntriesTable createAlias(String alias) {
    return $ClientProfileEntriesTable(attachedDatabase, alias);
  }
}

class ClientProfileEntry extends DataClass
    implements Insertable<ClientProfileEntry> {
  final String id;
  final String payload;
  final int lastFetched;
  const ClientProfileEntry({
    required this.id,
    required this.payload,
    required this.lastFetched,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['payload'] = Variable<String>(payload);
    map['last_fetched'] = Variable<int>(lastFetched);
    return map;
  }

  ClientProfileEntriesCompanion toCompanion(bool nullToAbsent) {
    return ClientProfileEntriesCompanion(
      id: Value(id),
      payload: Value(payload),
      lastFetched: Value(lastFetched),
    );
  }

  factory ClientProfileEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ClientProfileEntry(
      id: serializer.fromJson<String>(json['id']),
      payload: serializer.fromJson<String>(json['payload']),
      lastFetched: serializer.fromJson<int>(json['lastFetched']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'payload': serializer.toJson<String>(payload),
      'lastFetched': serializer.toJson<int>(lastFetched),
    };
  }

  ClientProfileEntry copyWith({
    String? id,
    String? payload,
    int? lastFetched,
  }) => ClientProfileEntry(
    id: id ?? this.id,
    payload: payload ?? this.payload,
    lastFetched: lastFetched ?? this.lastFetched,
  );
  ClientProfileEntry copyWithCompanion(ClientProfileEntriesCompanion data) {
    return ClientProfileEntry(
      id: data.id.present ? data.id.value : this.id,
      payload: data.payload.present ? data.payload.value : this.payload,
      lastFetched: data.lastFetched.present
          ? data.lastFetched.value
          : this.lastFetched,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ClientProfileEntry(')
          ..write('id: $id, ')
          ..write('payload: $payload, ')
          ..write('lastFetched: $lastFetched')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, payload, lastFetched);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ClientProfileEntry &&
          other.id == this.id &&
          other.payload == this.payload &&
          other.lastFetched == this.lastFetched);
}

class ClientProfileEntriesCompanion
    extends UpdateCompanion<ClientProfileEntry> {
  final Value<String> id;
  final Value<String> payload;
  final Value<int> lastFetched;
  final Value<int> rowid;
  const ClientProfileEntriesCompanion({
    this.id = const Value.absent(),
    this.payload = const Value.absent(),
    this.lastFetched = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ClientProfileEntriesCompanion.insert({
    required String id,
    required String payload,
    required int lastFetched,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       payload = Value(payload),
       lastFetched = Value(lastFetched);
  static Insertable<ClientProfileEntry> custom({
    Expression<String>? id,
    Expression<String>? payload,
    Expression<int>? lastFetched,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (payload != null) 'payload': payload,
      if (lastFetched != null) 'last_fetched': lastFetched,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ClientProfileEntriesCompanion copyWith({
    Value<String>? id,
    Value<String>? payload,
    Value<int>? lastFetched,
    Value<int>? rowid,
  }) {
    return ClientProfileEntriesCompanion(
      id: id ?? this.id,
      payload: payload ?? this.payload,
      lastFetched: lastFetched ?? this.lastFetched,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (payload.present) {
      map['payload'] = Variable<String>(payload.value);
    }
    if (lastFetched.present) {
      map['last_fetched'] = Variable<int>(lastFetched.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ClientProfileEntriesCompanion(')
          ..write('id: $id, ')
          ..write('payload: $payload, ')
          ..write('lastFetched: $lastFetched, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $WorkoutEntriesTable workoutEntries = $WorkoutEntriesTable(this);
  late final $MealEntriesTable mealEntries = $MealEntriesTable(this);
  late final $TargetEntriesTable targetEntries = $TargetEntriesTable(this);
  late final $DailyLogEntriesTable dailyLogEntries = $DailyLogEntriesTable(
    this,
  );
  late final $ClientProfileEntriesTable clientProfileEntries =
      $ClientProfileEntriesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    workoutEntries,
    mealEntries,
    targetEntries,
    dailyLogEntries,
    clientProfileEntries,
  ];
}

typedef $$WorkoutEntriesTableCreateCompanionBuilder =
    WorkoutEntriesCompanion Function({
      required String id,
      required String name,
      required String detail,
      required String benefit,
      Value<String?> dayOfWeek,
      Value<String?> category,
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
      Value<String?> dayOfWeek,
      Value<String?> category,
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

  ColumnFilters<String> get dayOfWeek => $composableBuilder(
    column: $table.dayOfWeek,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
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

  ColumnOrderings<String> get dayOfWeek => $composableBuilder(
    column: $table.dayOfWeek,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
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

  GeneratedColumn<String> get dayOfWeek =>
      $composableBuilder(column: $table.dayOfWeek, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

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
                Value<String?> dayOfWeek = const Value.absent(),
                Value<String?> category = const Value.absent(),
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
                dayOfWeek: dayOfWeek,
                category: category,
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
                Value<String?> dayOfWeek = const Value.absent(),
                Value<String?> category = const Value.absent(),
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
                dayOfWeek: dayOfWeek,
                category: category,
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
typedef $$MealEntriesTableCreateCompanionBuilder =
    MealEntriesCompanion Function({
      required String id,
      Value<String?> dayOfWeek,
      required String mealType,
      required String foodName,
      Value<int?> calories,
      Value<double?> proteinG,
      Value<double?> carbsG,
      Value<double?> fatG,
      Value<bool> isDone,
      required int lastFetched,
      Value<int> updatedAt,
      Value<bool> synced,
      Value<int> rowid,
    });
typedef $$MealEntriesTableUpdateCompanionBuilder =
    MealEntriesCompanion Function({
      Value<String> id,
      Value<String?> dayOfWeek,
      Value<String> mealType,
      Value<String> foodName,
      Value<int?> calories,
      Value<double?> proteinG,
      Value<double?> carbsG,
      Value<double?> fatG,
      Value<bool> isDone,
      Value<int> lastFetched,
      Value<int> updatedAt,
      Value<bool> synced,
      Value<int> rowid,
    });

class $$MealEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $MealEntriesTable> {
  $$MealEntriesTableFilterComposer({
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

  ColumnFilters<String> get dayOfWeek => $composableBuilder(
    column: $table.dayOfWeek,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mealType => $composableBuilder(
    column: $table.mealType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get foodName => $composableBuilder(
    column: $table.foodName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get calories => $composableBuilder(
    column: $table.calories,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get proteinG => $composableBuilder(
    column: $table.proteinG,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get carbsG => $composableBuilder(
    column: $table.carbsG,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get fatG => $composableBuilder(
    column: $table.fatG,
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

class $$MealEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $MealEntriesTable> {
  $$MealEntriesTableOrderingComposer({
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

  ColumnOrderings<String> get dayOfWeek => $composableBuilder(
    column: $table.dayOfWeek,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mealType => $composableBuilder(
    column: $table.mealType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get foodName => $composableBuilder(
    column: $table.foodName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get calories => $composableBuilder(
    column: $table.calories,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get proteinG => $composableBuilder(
    column: $table.proteinG,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get carbsG => $composableBuilder(
    column: $table.carbsG,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get fatG => $composableBuilder(
    column: $table.fatG,
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

class $$MealEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $MealEntriesTable> {
  $$MealEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get dayOfWeek =>
      $composableBuilder(column: $table.dayOfWeek, builder: (column) => column);

  GeneratedColumn<String> get mealType =>
      $composableBuilder(column: $table.mealType, builder: (column) => column);

  GeneratedColumn<String> get foodName =>
      $composableBuilder(column: $table.foodName, builder: (column) => column);

  GeneratedColumn<int> get calories =>
      $composableBuilder(column: $table.calories, builder: (column) => column);

  GeneratedColumn<double> get proteinG =>
      $composableBuilder(column: $table.proteinG, builder: (column) => column);

  GeneratedColumn<double> get carbsG =>
      $composableBuilder(column: $table.carbsG, builder: (column) => column);

  GeneratedColumn<double> get fatG =>
      $composableBuilder(column: $table.fatG, builder: (column) => column);

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

class $$MealEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MealEntriesTable,
          MealEntry,
          $$MealEntriesTableFilterComposer,
          $$MealEntriesTableOrderingComposer,
          $$MealEntriesTableAnnotationComposer,
          $$MealEntriesTableCreateCompanionBuilder,
          $$MealEntriesTableUpdateCompanionBuilder,
          (
            MealEntry,
            BaseReferences<_$AppDatabase, $MealEntriesTable, MealEntry>,
          ),
          MealEntry,
          PrefetchHooks Function()
        > {
  $$MealEntriesTableTableManager(_$AppDatabase db, $MealEntriesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MealEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MealEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MealEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String?> dayOfWeek = const Value.absent(),
                Value<String> mealType = const Value.absent(),
                Value<String> foodName = const Value.absent(),
                Value<int?> calories = const Value.absent(),
                Value<double?> proteinG = const Value.absent(),
                Value<double?> carbsG = const Value.absent(),
                Value<double?> fatG = const Value.absent(),
                Value<bool> isDone = const Value.absent(),
                Value<int> lastFetched = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<bool> synced = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MealEntriesCompanion(
                id: id,
                dayOfWeek: dayOfWeek,
                mealType: mealType,
                foodName: foodName,
                calories: calories,
                proteinG: proteinG,
                carbsG: carbsG,
                fatG: fatG,
                isDone: isDone,
                lastFetched: lastFetched,
                updatedAt: updatedAt,
                synced: synced,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String?> dayOfWeek = const Value.absent(),
                required String mealType,
                required String foodName,
                Value<int?> calories = const Value.absent(),
                Value<double?> proteinG = const Value.absent(),
                Value<double?> carbsG = const Value.absent(),
                Value<double?> fatG = const Value.absent(),
                Value<bool> isDone = const Value.absent(),
                required int lastFetched,
                Value<int> updatedAt = const Value.absent(),
                Value<bool> synced = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MealEntriesCompanion.insert(
                id: id,
                dayOfWeek: dayOfWeek,
                mealType: mealType,
                foodName: foodName,
                calories: calories,
                proteinG: proteinG,
                carbsG: carbsG,
                fatG: fatG,
                isDone: isDone,
                lastFetched: lastFetched,
                updatedAt: updatedAt,
                synced: synced,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$MealEntriesTable, MealEntry>(table),
                  BaseReferences<_$AppDatabase, $MealEntriesTable, MealEntry>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MealEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MealEntriesTable,
      MealEntry,
      $$MealEntriesTableFilterComposer,
      $$MealEntriesTableOrderingComposer,
      $$MealEntriesTableAnnotationComposer,
      $$MealEntriesTableCreateCompanionBuilder,
      $$MealEntriesTableUpdateCompanionBuilder,
      (MealEntry, BaseReferences<_$AppDatabase, $MealEntriesTable, MealEntry>),
      MealEntry,
      PrefetchHooks Function()
    >;
typedef $$TargetEntriesTableCreateCompanionBuilder =
    TargetEntriesCompanion Function({
      required String id,
      Value<String?> weekStartDate,
      Value<int?> targetSteps,
      Value<double?> targetWaterLiters,
      Value<int?> targetCalories,
      Value<String?> source,
      required int lastFetched,
      Value<int> rowid,
    });
typedef $$TargetEntriesTableUpdateCompanionBuilder =
    TargetEntriesCompanion Function({
      Value<String> id,
      Value<String?> weekStartDate,
      Value<int?> targetSteps,
      Value<double?> targetWaterLiters,
      Value<int?> targetCalories,
      Value<String?> source,
      Value<int> lastFetched,
      Value<int> rowid,
    });

class $$TargetEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $TargetEntriesTable> {
  $$TargetEntriesTableFilterComposer({
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

  ColumnFilters<String> get weekStartDate => $composableBuilder(
    column: $table.weekStartDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get targetSteps => $composableBuilder(
    column: $table.targetSteps,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get targetWaterLiters => $composableBuilder(
    column: $table.targetWaterLiters,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get targetCalories => $composableBuilder(
    column: $table.targetCalories,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastFetched => $composableBuilder(
    column: $table.lastFetched,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TargetEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $TargetEntriesTable> {
  $$TargetEntriesTableOrderingComposer({
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

  ColumnOrderings<String> get weekStartDate => $composableBuilder(
    column: $table.weekStartDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get targetSteps => $composableBuilder(
    column: $table.targetSteps,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get targetWaterLiters => $composableBuilder(
    column: $table.targetWaterLiters,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get targetCalories => $composableBuilder(
    column: $table.targetCalories,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastFetched => $composableBuilder(
    column: $table.lastFetched,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TargetEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $TargetEntriesTable> {
  $$TargetEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get weekStartDate => $composableBuilder(
    column: $table.weekStartDate,
    builder: (column) => column,
  );

  GeneratedColumn<int> get targetSteps => $composableBuilder(
    column: $table.targetSteps,
    builder: (column) => column,
  );

  GeneratedColumn<double> get targetWaterLiters => $composableBuilder(
    column: $table.targetWaterLiters,
    builder: (column) => column,
  );

  GeneratedColumn<int> get targetCalories => $composableBuilder(
    column: $table.targetCalories,
    builder: (column) => column,
  );

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<int> get lastFetched => $composableBuilder(
    column: $table.lastFetched,
    builder: (column) => column,
  );
}

class $$TargetEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TargetEntriesTable,
          TargetEntry,
          $$TargetEntriesTableFilterComposer,
          $$TargetEntriesTableOrderingComposer,
          $$TargetEntriesTableAnnotationComposer,
          $$TargetEntriesTableCreateCompanionBuilder,
          $$TargetEntriesTableUpdateCompanionBuilder,
          (
            TargetEntry,
            BaseReferences<_$AppDatabase, $TargetEntriesTable, TargetEntry>,
          ),
          TargetEntry,
          PrefetchHooks Function()
        > {
  $$TargetEntriesTableTableManager(_$AppDatabase db, $TargetEntriesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TargetEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TargetEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TargetEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String?> weekStartDate = const Value.absent(),
                Value<int?> targetSteps = const Value.absent(),
                Value<double?> targetWaterLiters = const Value.absent(),
                Value<int?> targetCalories = const Value.absent(),
                Value<String?> source = const Value.absent(),
                Value<int> lastFetched = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TargetEntriesCompanion(
                id: id,
                weekStartDate: weekStartDate,
                targetSteps: targetSteps,
                targetWaterLiters: targetWaterLiters,
                targetCalories: targetCalories,
                source: source,
                lastFetched: lastFetched,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String?> weekStartDate = const Value.absent(),
                Value<int?> targetSteps = const Value.absent(),
                Value<double?> targetWaterLiters = const Value.absent(),
                Value<int?> targetCalories = const Value.absent(),
                Value<String?> source = const Value.absent(),
                required int lastFetched,
                Value<int> rowid = const Value.absent(),
              }) => TargetEntriesCompanion.insert(
                id: id,
                weekStartDate: weekStartDate,
                targetSteps: targetSteps,
                targetWaterLiters: targetWaterLiters,
                targetCalories: targetCalories,
                source: source,
                lastFetched: lastFetched,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$TargetEntriesTable, TargetEntry>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $TargetEntriesTable,
                    TargetEntry
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TargetEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TargetEntriesTable,
      TargetEntry,
      $$TargetEntriesTableFilterComposer,
      $$TargetEntriesTableOrderingComposer,
      $$TargetEntriesTableAnnotationComposer,
      $$TargetEntriesTableCreateCompanionBuilder,
      $$TargetEntriesTableUpdateCompanionBuilder,
      (
        TargetEntry,
        BaseReferences<_$AppDatabase, $TargetEntriesTable, TargetEntry>,
      ),
      TargetEntry,
      PrefetchHooks Function()
    >;
typedef $$DailyLogEntriesTableCreateCompanionBuilder =
    DailyLogEntriesCompanion Function({
      required String logDate,
      Value<double?> weightKg,
      Value<int?> steps,
      Value<double?> waterLiters,
      Value<double?> caloriesBurned,
      required int lastFetched,
      Value<int> updatedAt,
      Value<bool> synced,
      Value<int> rowid,
    });
typedef $$DailyLogEntriesTableUpdateCompanionBuilder =
    DailyLogEntriesCompanion Function({
      Value<String> logDate,
      Value<double?> weightKg,
      Value<int?> steps,
      Value<double?> waterLiters,
      Value<double?> caloriesBurned,
      Value<int> lastFetched,
      Value<int> updatedAt,
      Value<bool> synced,
      Value<int> rowid,
    });

class $$DailyLogEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $DailyLogEntriesTable> {
  $$DailyLogEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get logDate => $composableBuilder(
    column: $table.logDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get weightKg => $composableBuilder(
    column: $table.weightKg,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get steps => $composableBuilder(
    column: $table.steps,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get waterLiters => $composableBuilder(
    column: $table.waterLiters,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get caloriesBurned => $composableBuilder(
    column: $table.caloriesBurned,
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

class $$DailyLogEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $DailyLogEntriesTable> {
  $$DailyLogEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get logDate => $composableBuilder(
    column: $table.logDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get weightKg => $composableBuilder(
    column: $table.weightKg,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get steps => $composableBuilder(
    column: $table.steps,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get waterLiters => $composableBuilder(
    column: $table.waterLiters,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get caloriesBurned => $composableBuilder(
    column: $table.caloriesBurned,
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

class $$DailyLogEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $DailyLogEntriesTable> {
  $$DailyLogEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get logDate =>
      $composableBuilder(column: $table.logDate, builder: (column) => column);

  GeneratedColumn<double> get weightKg =>
      $composableBuilder(column: $table.weightKg, builder: (column) => column);

  GeneratedColumn<int> get steps =>
      $composableBuilder(column: $table.steps, builder: (column) => column);

  GeneratedColumn<double> get waterLiters => $composableBuilder(
    column: $table.waterLiters,
    builder: (column) => column,
  );

  GeneratedColumn<double> get caloriesBurned => $composableBuilder(
    column: $table.caloriesBurned,
    builder: (column) => column,
  );

  GeneratedColumn<int> get lastFetched => $composableBuilder(
    column: $table.lastFetched,
    builder: (column) => column,
  );

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get synced =>
      $composableBuilder(column: $table.synced, builder: (column) => column);
}

class $$DailyLogEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DailyLogEntriesTable,
          DailyLogEntry,
          $$DailyLogEntriesTableFilterComposer,
          $$DailyLogEntriesTableOrderingComposer,
          $$DailyLogEntriesTableAnnotationComposer,
          $$DailyLogEntriesTableCreateCompanionBuilder,
          $$DailyLogEntriesTableUpdateCompanionBuilder,
          (
            DailyLogEntry,
            BaseReferences<_$AppDatabase, $DailyLogEntriesTable, DailyLogEntry>,
          ),
          DailyLogEntry,
          PrefetchHooks Function()
        > {
  $$DailyLogEntriesTableTableManager(
    _$AppDatabase db,
    $DailyLogEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DailyLogEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DailyLogEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DailyLogEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> logDate = const Value.absent(),
                Value<double?> weightKg = const Value.absent(),
                Value<int?> steps = const Value.absent(),
                Value<double?> waterLiters = const Value.absent(),
                Value<double?> caloriesBurned = const Value.absent(),
                Value<int> lastFetched = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<bool> synced = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DailyLogEntriesCompanion(
                logDate: logDate,
                weightKg: weightKg,
                steps: steps,
                waterLiters: waterLiters,
                caloriesBurned: caloriesBurned,
                lastFetched: lastFetched,
                updatedAt: updatedAt,
                synced: synced,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String logDate,
                Value<double?> weightKg = const Value.absent(),
                Value<int?> steps = const Value.absent(),
                Value<double?> waterLiters = const Value.absent(),
                Value<double?> caloriesBurned = const Value.absent(),
                required int lastFetched,
                Value<int> updatedAt = const Value.absent(),
                Value<bool> synced = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DailyLogEntriesCompanion.insert(
                logDate: logDate,
                weightKg: weightKg,
                steps: steps,
                waterLiters: waterLiters,
                caloriesBurned: caloriesBurned,
                lastFetched: lastFetched,
                updatedAt: updatedAt,
                synced: synced,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$DailyLogEntriesTable, DailyLogEntry>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $DailyLogEntriesTable,
                    DailyLogEntry
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DailyLogEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DailyLogEntriesTable,
      DailyLogEntry,
      $$DailyLogEntriesTableFilterComposer,
      $$DailyLogEntriesTableOrderingComposer,
      $$DailyLogEntriesTableAnnotationComposer,
      $$DailyLogEntriesTableCreateCompanionBuilder,
      $$DailyLogEntriesTableUpdateCompanionBuilder,
      (
        DailyLogEntry,
        BaseReferences<_$AppDatabase, $DailyLogEntriesTable, DailyLogEntry>,
      ),
      DailyLogEntry,
      PrefetchHooks Function()
    >;
typedef $$ClientProfileEntriesTableCreateCompanionBuilder =
    ClientProfileEntriesCompanion Function({
      required String id,
      required String payload,
      required int lastFetched,
      Value<int> rowid,
    });
typedef $$ClientProfileEntriesTableUpdateCompanionBuilder =
    ClientProfileEntriesCompanion Function({
      Value<String> id,
      Value<String> payload,
      Value<int> lastFetched,
      Value<int> rowid,
    });

class $$ClientProfileEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $ClientProfileEntriesTable> {
  $$ClientProfileEntriesTableFilterComposer({
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

  ColumnFilters<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastFetched => $composableBuilder(
    column: $table.lastFetched,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ClientProfileEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $ClientProfileEntriesTable> {
  $$ClientProfileEntriesTableOrderingComposer({
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

  ColumnOrderings<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastFetched => $composableBuilder(
    column: $table.lastFetched,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ClientProfileEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ClientProfileEntriesTable> {
  $$ClientProfileEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get payload =>
      $composableBuilder(column: $table.payload, builder: (column) => column);

  GeneratedColumn<int> get lastFetched => $composableBuilder(
    column: $table.lastFetched,
    builder: (column) => column,
  );
}

class $$ClientProfileEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ClientProfileEntriesTable,
          ClientProfileEntry,
          $$ClientProfileEntriesTableFilterComposer,
          $$ClientProfileEntriesTableOrderingComposer,
          $$ClientProfileEntriesTableAnnotationComposer,
          $$ClientProfileEntriesTableCreateCompanionBuilder,
          $$ClientProfileEntriesTableUpdateCompanionBuilder,
          (
            ClientProfileEntry,
            BaseReferences<
              _$AppDatabase,
              $ClientProfileEntriesTable,
              ClientProfileEntry
            >,
          ),
          ClientProfileEntry,
          PrefetchHooks Function()
        > {
  $$ClientProfileEntriesTableTableManager(
    _$AppDatabase db,
    $ClientProfileEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ClientProfileEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ClientProfileEntriesTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$ClientProfileEntriesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> payload = const Value.absent(),
                Value<int> lastFetched = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ClientProfileEntriesCompanion(
                id: id,
                payload: payload,
                lastFetched: lastFetched,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String payload,
                required int lastFetched,
                Value<int> rowid = const Value.absent(),
              }) => ClientProfileEntriesCompanion.insert(
                id: id,
                payload: payload,
                lastFetched: lastFetched,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ClientProfileEntriesTable, ClientProfileEntry>(
                    table,
                  ),
                  BaseReferences<
                    _$AppDatabase,
                    $ClientProfileEntriesTable,
                    ClientProfileEntry
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ClientProfileEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ClientProfileEntriesTable,
      ClientProfileEntry,
      $$ClientProfileEntriesTableFilterComposer,
      $$ClientProfileEntriesTableOrderingComposer,
      $$ClientProfileEntriesTableAnnotationComposer,
      $$ClientProfileEntriesTableCreateCompanionBuilder,
      $$ClientProfileEntriesTableUpdateCompanionBuilder,
      (
        ClientProfileEntry,
        BaseReferences<
          _$AppDatabase,
          $ClientProfileEntriesTable,
          ClientProfileEntry
        >,
      ),
      ClientProfileEntry,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$WorkoutEntriesTableTableManager get workoutEntries =>
      $$WorkoutEntriesTableTableManager(_db, _db.workoutEntries);
  $$MealEntriesTableTableManager get mealEntries =>
      $$MealEntriesTableTableManager(_db, _db.mealEntries);
  $$TargetEntriesTableTableManager get targetEntries =>
      $$TargetEntriesTableTableManager(_db, _db.targetEntries);
  $$DailyLogEntriesTableTableManager get dailyLogEntries =>
      $$DailyLogEntriesTableTableManager(_db, _db.dailyLogEntries);
  $$ClientProfileEntriesTableTableManager get clientProfileEntries =>
      $$ClientProfileEntriesTableTableManager(_db, _db.clientProfileEntries);
}
