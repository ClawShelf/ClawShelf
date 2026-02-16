// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_setting.dart';

// **************************************************************************
// _IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, invalid_use_of_protected_member, lines_longer_than_80_chars, constant_identifier_names, avoid_js_rounded_ints, no_leading_underscores_for_local_identifiers, require_trailing_commas, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_in_if_null_operators, library_private_types_in_public_api, prefer_const_constructors
// ignore_for_file: type=lint

extension GetUserSettingCollection on Isar {
  IsarCollection<int, UserSetting> get userSettings => this.collection();
}

final UserSettingSchema = IsarGeneratedSchema(
  schema: IsarSchema(
    name: 'UserSetting',
    idName: 'id',
    embedded: false,
    properties: [
      IsarPropertySchema(name: 'key', type: IsarType.string),
      IsarPropertySchema(name: 'stringValue', type: IsarType.string),
      IsarPropertySchema(name: 'intValue', type: IsarType.long),
      IsarPropertySchema(name: 'boolValue', type: IsarType.bool),
    ],
    indexes: [
      IsarIndexSchema(
        name: 'key',
        properties: ["key"],
        unique: true,
        hash: false,
      ),
    ],
  ),
  converter: IsarObjectConverter<int, UserSetting>(
    serialize: serializeUserSetting,
    deserialize: deserializeUserSetting,
    deserializeProperty: deserializeUserSettingProp,
  ),
  getEmbeddedSchemas: () => [],
);

@isarProtected
int serializeUserSetting(IsarWriter writer, UserSetting object) {
  {
    final value = object.key;
    if (value == null) {
      IsarCore.writeNull(writer, 1);
    } else {
      IsarCore.writeString(writer, 1, value);
    }
  }
  {
    final value = object.stringValue;
    if (value == null) {
      IsarCore.writeNull(writer, 2);
    } else {
      IsarCore.writeString(writer, 2, value);
    }
  }
  IsarCore.writeLong(writer, 3, object.intValue ?? -9223372036854775808);
  {
    final value = object.boolValue;
    if (value == null) {
      IsarCore.writeNull(writer, 4);
    } else {
      IsarCore.writeBool(writer, 4, value: value);
    }
  }
  return object.id;
}

@isarProtected
UserSetting deserializeUserSetting(IsarReader reader) {
  final int _id;
  _id = IsarCore.readId(reader);
  final object = UserSetting(id: _id);
  object.key = IsarCore.readString(reader, 1);
  object.stringValue = IsarCore.readString(reader, 2);
  {
    final value = IsarCore.readLong(reader, 3);
    if (value == -9223372036854775808) {
      object.intValue = null;
    } else {
      object.intValue = value;
    }
  }
  {
    if (IsarCore.readNull(reader, 4)) {
      object.boolValue = null;
    } else {
      object.boolValue = IsarCore.readBool(reader, 4);
    }
  }
  return object;
}

@isarProtected
dynamic deserializeUserSettingProp(IsarReader reader, int property) {
  switch (property) {
    case 0:
      return IsarCore.readId(reader);
    case 1:
      return IsarCore.readString(reader, 1);
    case 2:
      return IsarCore.readString(reader, 2);
    case 3:
      {
        final value = IsarCore.readLong(reader, 3);
        if (value == -9223372036854775808) {
          return null;
        } else {
          return value;
        }
      }
    case 4:
      {
        if (IsarCore.readNull(reader, 4)) {
          return null;
        } else {
          return IsarCore.readBool(reader, 4);
        }
      }
    default:
      throw ArgumentError('Unknown property: $property');
  }
}

sealed class _UserSettingUpdate {
  bool call({
    required int id,
    String? key,
    String? stringValue,
    int? intValue,
    bool? boolValue,
  });
}

class _UserSettingUpdateImpl implements _UserSettingUpdate {
  const _UserSettingUpdateImpl(this.collection);

  final IsarCollection<int, UserSetting> collection;

  @override
  bool call({
    required int id,
    Object? key = ignore,
    Object? stringValue = ignore,
    Object? intValue = ignore,
    Object? boolValue = ignore,
  }) {
    return collection.updateProperties(
          [id],
          {
            if (key != ignore) 1: key as String?,
            if (stringValue != ignore) 2: stringValue as String?,
            if (intValue != ignore) 3: intValue as int?,
            if (boolValue != ignore) 4: boolValue as bool?,
          },
        ) >
        0;
  }
}

sealed class _UserSettingUpdateAll {
  int call({
    required List<int> id,
    String? key,
    String? stringValue,
    int? intValue,
    bool? boolValue,
  });
}

class _UserSettingUpdateAllImpl implements _UserSettingUpdateAll {
  const _UserSettingUpdateAllImpl(this.collection);

  final IsarCollection<int, UserSetting> collection;

  @override
  int call({
    required List<int> id,
    Object? key = ignore,
    Object? stringValue = ignore,
    Object? intValue = ignore,
    Object? boolValue = ignore,
  }) {
    return collection.updateProperties(id, {
      if (key != ignore) 1: key as String?,
      if (stringValue != ignore) 2: stringValue as String?,
      if (intValue != ignore) 3: intValue as int?,
      if (boolValue != ignore) 4: boolValue as bool?,
    });
  }
}

extension UserSettingUpdate on IsarCollection<int, UserSetting> {
  _UserSettingUpdate get update => _UserSettingUpdateImpl(this);

  _UserSettingUpdateAll get updateAll => _UserSettingUpdateAllImpl(this);
}

sealed class _UserSettingQueryUpdate {
  int call({String? key, String? stringValue, int? intValue, bool? boolValue});
}

class _UserSettingQueryUpdateImpl implements _UserSettingQueryUpdate {
  const _UserSettingQueryUpdateImpl(this.query, {this.limit});

  final IsarQuery<UserSetting> query;
  final int? limit;

  @override
  int call({
    Object? key = ignore,
    Object? stringValue = ignore,
    Object? intValue = ignore,
    Object? boolValue = ignore,
  }) {
    return query.updateProperties(limit: limit, {
      if (key != ignore) 1: key as String?,
      if (stringValue != ignore) 2: stringValue as String?,
      if (intValue != ignore) 3: intValue as int?,
      if (boolValue != ignore) 4: boolValue as bool?,
    });
  }
}

extension UserSettingQueryUpdate on IsarQuery<UserSetting> {
  _UserSettingQueryUpdate get updateFirst =>
      _UserSettingQueryUpdateImpl(this, limit: 1);

  _UserSettingQueryUpdate get updateAll => _UserSettingQueryUpdateImpl(this);
}

class _UserSettingQueryBuilderUpdateImpl implements _UserSettingQueryUpdate {
  const _UserSettingQueryBuilderUpdateImpl(this.query, {this.limit});

  final QueryBuilder<UserSetting, UserSetting, QOperations> query;
  final int? limit;

  @override
  int call({
    Object? key = ignore,
    Object? stringValue = ignore,
    Object? intValue = ignore,
    Object? boolValue = ignore,
  }) {
    final q = query.build();
    try {
      return q.updateProperties(limit: limit, {
        if (key != ignore) 1: key as String?,
        if (stringValue != ignore) 2: stringValue as String?,
        if (intValue != ignore) 3: intValue as int?,
        if (boolValue != ignore) 4: boolValue as bool?,
      });
    } finally {
      q.close();
    }
  }
}

extension UserSettingQueryBuilderUpdate
    on QueryBuilder<UserSetting, UserSetting, QOperations> {
  _UserSettingQueryUpdate get updateFirst =>
      _UserSettingQueryBuilderUpdateImpl(this, limit: 1);

  _UserSettingQueryUpdate get updateAll =>
      _UserSettingQueryBuilderUpdateImpl(this);
}

extension UserSettingQueryFilter
    on QueryBuilder<UserSetting, UserSetting, QFilterCondition> {
  QueryBuilder<UserSetting, UserSetting, QAfterFilterCondition> idEqualTo(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(property: 0, value: value),
      );
    });
  }

  QueryBuilder<UserSetting, UserSetting, QAfterFilterCondition> idGreaterThan(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(property: 0, value: value),
      );
    });
  }

  QueryBuilder<UserSetting, UserSetting, QAfterFilterCondition>
  idGreaterThanOrEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(property: 0, value: value),
      );
    });
  }

  QueryBuilder<UserSetting, UserSetting, QAfterFilterCondition> idLessThan(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(LessCondition(property: 0, value: value));
    });
  }

  QueryBuilder<UserSetting, UserSetting, QAfterFilterCondition>
  idLessThanOrEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(property: 0, value: value),
      );
    });
  }

  QueryBuilder<UserSetting, UserSetting, QAfterFilterCondition> idBetween(
    int lower,
    int upper,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(property: 0, lower: lower, upper: upper),
      );
    });
  }

  QueryBuilder<UserSetting, UserSetting, QAfterFilterCondition> keyIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const IsNullCondition(property: 1));
    });
  }

  QueryBuilder<UserSetting, UserSetting, QAfterFilterCondition> keyIsNotNull() {
    return QueryBuilder.apply(not(), (query) {
      return query.addFilterCondition(const IsNullCondition(property: 1));
    });
  }

  QueryBuilder<UserSetting, UserSetting, QAfterFilterCondition> keyEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(property: 1, value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<UserSetting, UserSetting, QAfterFilterCondition> keyGreaterThan(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(
          property: 1,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<UserSetting, UserSetting, QAfterFilterCondition>
  keyGreaterThanOrEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(
          property: 1,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<UserSetting, UserSetting, QAfterFilterCondition> keyLessThan(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(property: 1, value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<UserSetting, UserSetting, QAfterFilterCondition>
  keyLessThanOrEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(
          property: 1,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<UserSetting, UserSetting, QAfterFilterCondition> keyBetween(
    String? lower,
    String? upper, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(
          property: 1,
          lower: lower,
          upper: upper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<UserSetting, UserSetting, QAfterFilterCondition> keyStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        StartsWithCondition(
          property: 1,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<UserSetting, UserSetting, QAfterFilterCondition> keyEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EndsWithCondition(
          property: 1,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<UserSetting, UserSetting, QAfterFilterCondition> keyContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        ContainsCondition(
          property: 1,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<UserSetting, UserSetting, QAfterFilterCondition> keyMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        MatchesCondition(
          property: 1,
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<UserSetting, UserSetting, QAfterFilterCondition> keyIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const EqualCondition(property: 1, value: ''),
      );
    });
  }

  QueryBuilder<UserSetting, UserSetting, QAfterFilterCondition>
  keyIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterCondition(property: 1, value: ''),
      );
    });
  }

  QueryBuilder<UserSetting, UserSetting, QAfterFilterCondition>
  stringValueIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const IsNullCondition(property: 2));
    });
  }

  QueryBuilder<UserSetting, UserSetting, QAfterFilterCondition>
  stringValueIsNotNull() {
    return QueryBuilder.apply(not(), (query) {
      return query.addFilterCondition(const IsNullCondition(property: 2));
    });
  }

  QueryBuilder<UserSetting, UserSetting, QAfterFilterCondition>
  stringValueEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(property: 2, value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<UserSetting, UserSetting, QAfterFilterCondition>
  stringValueGreaterThan(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(
          property: 2,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<UserSetting, UserSetting, QAfterFilterCondition>
  stringValueGreaterThanOrEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(
          property: 2,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<UserSetting, UserSetting, QAfterFilterCondition>
  stringValueLessThan(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(property: 2, value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<UserSetting, UserSetting, QAfterFilterCondition>
  stringValueLessThanOrEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(
          property: 2,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<UserSetting, UserSetting, QAfterFilterCondition>
  stringValueBetween(
    String? lower,
    String? upper, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(
          property: 2,
          lower: lower,
          upper: upper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<UserSetting, UserSetting, QAfterFilterCondition>
  stringValueStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        StartsWithCondition(
          property: 2,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<UserSetting, UserSetting, QAfterFilterCondition>
  stringValueEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EndsWithCondition(
          property: 2,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<UserSetting, UserSetting, QAfterFilterCondition>
  stringValueContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        ContainsCondition(
          property: 2,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<UserSetting, UserSetting, QAfterFilterCondition>
  stringValueMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        MatchesCondition(
          property: 2,
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<UserSetting, UserSetting, QAfterFilterCondition>
  stringValueIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const EqualCondition(property: 2, value: ''),
      );
    });
  }

  QueryBuilder<UserSetting, UserSetting, QAfterFilterCondition>
  stringValueIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterCondition(property: 2, value: ''),
      );
    });
  }

  QueryBuilder<UserSetting, UserSetting, QAfterFilterCondition>
  intValueIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const IsNullCondition(property: 3));
    });
  }

  QueryBuilder<UserSetting, UserSetting, QAfterFilterCondition>
  intValueIsNotNull() {
    return QueryBuilder.apply(not(), (query) {
      return query.addFilterCondition(const IsNullCondition(property: 3));
    });
  }

  QueryBuilder<UserSetting, UserSetting, QAfterFilterCondition> intValueEqualTo(
    int? value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(property: 3, value: value),
      );
    });
  }

  QueryBuilder<UserSetting, UserSetting, QAfterFilterCondition>
  intValueGreaterThan(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(property: 3, value: value),
      );
    });
  }

  QueryBuilder<UserSetting, UserSetting, QAfterFilterCondition>
  intValueGreaterThanOrEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(property: 3, value: value),
      );
    });
  }

  QueryBuilder<UserSetting, UserSetting, QAfterFilterCondition>
  intValueLessThan(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(LessCondition(property: 3, value: value));
    });
  }

  QueryBuilder<UserSetting, UserSetting, QAfterFilterCondition>
  intValueLessThanOrEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(property: 3, value: value),
      );
    });
  }

  QueryBuilder<UserSetting, UserSetting, QAfterFilterCondition> intValueBetween(
    int? lower,
    int? upper,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(property: 3, lower: lower, upper: upper),
      );
    });
  }

  QueryBuilder<UserSetting, UserSetting, QAfterFilterCondition>
  boolValueIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const IsNullCondition(property: 4));
    });
  }

  QueryBuilder<UserSetting, UserSetting, QAfterFilterCondition>
  boolValueIsNotNull() {
    return QueryBuilder.apply(not(), (query) {
      return query.addFilterCondition(const IsNullCondition(property: 4));
    });
  }

  QueryBuilder<UserSetting, UserSetting, QAfterFilterCondition>
  boolValueEqualTo(bool? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(property: 4, value: value),
      );
    });
  }
}

extension UserSettingQueryObject
    on QueryBuilder<UserSetting, UserSetting, QFilterCondition> {}

extension UserSettingQuerySortBy
    on QueryBuilder<UserSetting, UserSetting, QSortBy> {
  QueryBuilder<UserSetting, UserSetting, QAfterSortBy> sortById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(0);
    });
  }

  QueryBuilder<UserSetting, UserSetting, QAfterSortBy> sortByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(0, sort: Sort.desc);
    });
  }

  QueryBuilder<UserSetting, UserSetting, QAfterSortBy> sortByKey({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(1, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<UserSetting, UserSetting, QAfterSortBy> sortByKeyDesc({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(1, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<UserSetting, UserSetting, QAfterSortBy> sortByStringValue({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(2, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<UserSetting, UserSetting, QAfterSortBy> sortByStringValueDesc({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(2, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<UserSetting, UserSetting, QAfterSortBy> sortByIntValue() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(3);
    });
  }

  QueryBuilder<UserSetting, UserSetting, QAfterSortBy> sortByIntValueDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(3, sort: Sort.desc);
    });
  }

  QueryBuilder<UserSetting, UserSetting, QAfterSortBy> sortByBoolValue() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(4);
    });
  }

  QueryBuilder<UserSetting, UserSetting, QAfterSortBy> sortByBoolValueDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(4, sort: Sort.desc);
    });
  }
}

extension UserSettingQuerySortThenBy
    on QueryBuilder<UserSetting, UserSetting, QSortThenBy> {
  QueryBuilder<UserSetting, UserSetting, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(0);
    });
  }

  QueryBuilder<UserSetting, UserSetting, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(0, sort: Sort.desc);
    });
  }

  QueryBuilder<UserSetting, UserSetting, QAfterSortBy> thenByKey({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(1, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<UserSetting, UserSetting, QAfterSortBy> thenByKeyDesc({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(1, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<UserSetting, UserSetting, QAfterSortBy> thenByStringValue({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(2, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<UserSetting, UserSetting, QAfterSortBy> thenByStringValueDesc({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(2, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<UserSetting, UserSetting, QAfterSortBy> thenByIntValue() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(3);
    });
  }

  QueryBuilder<UserSetting, UserSetting, QAfterSortBy> thenByIntValueDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(3, sort: Sort.desc);
    });
  }

  QueryBuilder<UserSetting, UserSetting, QAfterSortBy> thenByBoolValue() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(4);
    });
  }

  QueryBuilder<UserSetting, UserSetting, QAfterSortBy> thenByBoolValueDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(4, sort: Sort.desc);
    });
  }
}

extension UserSettingQueryWhereDistinct
    on QueryBuilder<UserSetting, UserSetting, QDistinct> {
  QueryBuilder<UserSetting, UserSetting, QAfterDistinct> distinctByKey({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(1, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<UserSetting, UserSetting, QAfterDistinct> distinctByStringValue({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(2, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<UserSetting, UserSetting, QAfterDistinct> distinctByIntValue() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(3);
    });
  }

  QueryBuilder<UserSetting, UserSetting, QAfterDistinct> distinctByBoolValue() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(4);
    });
  }
}

extension UserSettingQueryProperty1
    on QueryBuilder<UserSetting, UserSetting, QProperty> {
  QueryBuilder<UserSetting, int, QAfterProperty> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(0);
    });
  }

  QueryBuilder<UserSetting, String?, QAfterProperty> keyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(1);
    });
  }

  QueryBuilder<UserSetting, String?, QAfterProperty> stringValueProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(2);
    });
  }

  QueryBuilder<UserSetting, int?, QAfterProperty> intValueProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(3);
    });
  }

  QueryBuilder<UserSetting, bool?, QAfterProperty> boolValueProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(4);
    });
  }
}

extension UserSettingQueryProperty2<R>
    on QueryBuilder<UserSetting, R, QAfterProperty> {
  QueryBuilder<UserSetting, (R, int), QAfterProperty> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(0);
    });
  }

  QueryBuilder<UserSetting, (R, String?), QAfterProperty> keyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(1);
    });
  }

  QueryBuilder<UserSetting, (R, String?), QAfterProperty>
  stringValueProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(2);
    });
  }

  QueryBuilder<UserSetting, (R, int?), QAfterProperty> intValueProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(3);
    });
  }

  QueryBuilder<UserSetting, (R, bool?), QAfterProperty> boolValueProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(4);
    });
  }
}

extension UserSettingQueryProperty3<R1, R2>
    on QueryBuilder<UserSetting, (R1, R2), QAfterProperty> {
  QueryBuilder<UserSetting, (R1, R2, int), QOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(0);
    });
  }

  QueryBuilder<UserSetting, (R1, R2, String?), QOperations> keyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(1);
    });
  }

  QueryBuilder<UserSetting, (R1, R2, String?), QOperations>
  stringValueProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(2);
    });
  }

  QueryBuilder<UserSetting, (R1, R2, int?), QOperations> intValueProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(3);
    });
  }

  QueryBuilder<UserSetting, (R1, R2, bool?), QOperations> boolValueProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(4);
    });
  }
}

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, invalid_use_of_protected_member, lines_longer_than_80_chars, constant_identifier_names, avoid_js_rounded_ints, no_leading_underscores_for_local_identifiers, require_trailing_commas, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_in_if_null_operators, library_private_types_in_public_api, prefer_const_constructors
// ignore_for_file: type=lint

extension GetHistoryEntryCollection on Isar {
  IsarCollection<int, HistoryEntry> get historyEntrys => this.collection();
}

final HistoryEntrySchema = IsarGeneratedSchema(
  schema: IsarSchema(
    name: 'HistoryEntry',
    idName: 'id',
    embedded: false,
    properties: [
      IsarPropertySchema(name: 'docId', type: IsarType.string),
      IsarPropertySchema(name: 'title', type: IsarType.string),
      IsarPropertySchema(name: 'emoji', type: IsarType.string),
      IsarPropertySchema(name: 'summary', type: IsarType.string),
      IsarPropertySchema(name: 'lastViewed', type: IsarType.dateTime),
    ],
    indexes: [
      IsarIndexSchema(
        name: 'docId',
        properties: ["docId"],
        unique: true,
        hash: false,
      ),
    ],
  ),
  converter: IsarObjectConverter<int, HistoryEntry>(
    serialize: serializeHistoryEntry,
    deserialize: deserializeHistoryEntry,
    deserializeProperty: deserializeHistoryEntryProp,
  ),
  getEmbeddedSchemas: () => [],
);

@isarProtected
int serializeHistoryEntry(IsarWriter writer, HistoryEntry object) {
  {
    final value = object.docId;
    if (value == null) {
      IsarCore.writeNull(writer, 1);
    } else {
      IsarCore.writeString(writer, 1, value);
    }
  }
  {
    final value = object.title;
    if (value == null) {
      IsarCore.writeNull(writer, 2);
    } else {
      IsarCore.writeString(writer, 2, value);
    }
  }
  {
    final value = object.emoji;
    if (value == null) {
      IsarCore.writeNull(writer, 3);
    } else {
      IsarCore.writeString(writer, 3, value);
    }
  }
  {
    final value = object.summary;
    if (value == null) {
      IsarCore.writeNull(writer, 4);
    } else {
      IsarCore.writeString(writer, 4, value);
    }
  }
  IsarCore.writeLong(
    writer,
    5,
    object.lastViewed?.toUtc().microsecondsSinceEpoch ?? -9223372036854775808,
  );
  return object.id;
}

@isarProtected
HistoryEntry deserializeHistoryEntry(IsarReader reader) {
  final int _id;
  _id = IsarCore.readId(reader);
  final object = HistoryEntry(id: _id);
  object.docId = IsarCore.readString(reader, 1);
  object.title = IsarCore.readString(reader, 2);
  object.emoji = IsarCore.readString(reader, 3);
  object.summary = IsarCore.readString(reader, 4);
  {
    final value = IsarCore.readLong(reader, 5);
    if (value == -9223372036854775808) {
      object.lastViewed = null;
    } else {
      object.lastViewed = DateTime.fromMicrosecondsSinceEpoch(
        value,
        isUtc: true,
      ).toLocal();
    }
  }
  return object;
}

@isarProtected
dynamic deserializeHistoryEntryProp(IsarReader reader, int property) {
  switch (property) {
    case 0:
      return IsarCore.readId(reader);
    case 1:
      return IsarCore.readString(reader, 1);
    case 2:
      return IsarCore.readString(reader, 2);
    case 3:
      return IsarCore.readString(reader, 3);
    case 4:
      return IsarCore.readString(reader, 4);
    case 5:
      {
        final value = IsarCore.readLong(reader, 5);
        if (value == -9223372036854775808) {
          return null;
        } else {
          return DateTime.fromMicrosecondsSinceEpoch(
            value,
            isUtc: true,
          ).toLocal();
        }
      }
    default:
      throw ArgumentError('Unknown property: $property');
  }
}

sealed class _HistoryEntryUpdate {
  bool call({
    required int id,
    String? docId,
    String? title,
    String? emoji,
    String? summary,
    DateTime? lastViewed,
  });
}

class _HistoryEntryUpdateImpl implements _HistoryEntryUpdate {
  const _HistoryEntryUpdateImpl(this.collection);

  final IsarCollection<int, HistoryEntry> collection;

  @override
  bool call({
    required int id,
    Object? docId = ignore,
    Object? title = ignore,
    Object? emoji = ignore,
    Object? summary = ignore,
    Object? lastViewed = ignore,
  }) {
    return collection.updateProperties(
          [id],
          {
            if (docId != ignore) 1: docId as String?,
            if (title != ignore) 2: title as String?,
            if (emoji != ignore) 3: emoji as String?,
            if (summary != ignore) 4: summary as String?,
            if (lastViewed != ignore) 5: lastViewed as DateTime?,
          },
        ) >
        0;
  }
}

sealed class _HistoryEntryUpdateAll {
  int call({
    required List<int> id,
    String? docId,
    String? title,
    String? emoji,
    String? summary,
    DateTime? lastViewed,
  });
}

class _HistoryEntryUpdateAllImpl implements _HistoryEntryUpdateAll {
  const _HistoryEntryUpdateAllImpl(this.collection);

  final IsarCollection<int, HistoryEntry> collection;

  @override
  int call({
    required List<int> id,
    Object? docId = ignore,
    Object? title = ignore,
    Object? emoji = ignore,
    Object? summary = ignore,
    Object? lastViewed = ignore,
  }) {
    return collection.updateProperties(id, {
      if (docId != ignore) 1: docId as String?,
      if (title != ignore) 2: title as String?,
      if (emoji != ignore) 3: emoji as String?,
      if (summary != ignore) 4: summary as String?,
      if (lastViewed != ignore) 5: lastViewed as DateTime?,
    });
  }
}

extension HistoryEntryUpdate on IsarCollection<int, HistoryEntry> {
  _HistoryEntryUpdate get update => _HistoryEntryUpdateImpl(this);

  _HistoryEntryUpdateAll get updateAll => _HistoryEntryUpdateAllImpl(this);
}

sealed class _HistoryEntryQueryUpdate {
  int call({
    String? docId,
    String? title,
    String? emoji,
    String? summary,
    DateTime? lastViewed,
  });
}

class _HistoryEntryQueryUpdateImpl implements _HistoryEntryQueryUpdate {
  const _HistoryEntryQueryUpdateImpl(this.query, {this.limit});

  final IsarQuery<HistoryEntry> query;
  final int? limit;

  @override
  int call({
    Object? docId = ignore,
    Object? title = ignore,
    Object? emoji = ignore,
    Object? summary = ignore,
    Object? lastViewed = ignore,
  }) {
    return query.updateProperties(limit: limit, {
      if (docId != ignore) 1: docId as String?,
      if (title != ignore) 2: title as String?,
      if (emoji != ignore) 3: emoji as String?,
      if (summary != ignore) 4: summary as String?,
      if (lastViewed != ignore) 5: lastViewed as DateTime?,
    });
  }
}

extension HistoryEntryQueryUpdate on IsarQuery<HistoryEntry> {
  _HistoryEntryQueryUpdate get updateFirst =>
      _HistoryEntryQueryUpdateImpl(this, limit: 1);

  _HistoryEntryQueryUpdate get updateAll => _HistoryEntryQueryUpdateImpl(this);
}

class _HistoryEntryQueryBuilderUpdateImpl implements _HistoryEntryQueryUpdate {
  const _HistoryEntryQueryBuilderUpdateImpl(this.query, {this.limit});

  final QueryBuilder<HistoryEntry, HistoryEntry, QOperations> query;
  final int? limit;

  @override
  int call({
    Object? docId = ignore,
    Object? title = ignore,
    Object? emoji = ignore,
    Object? summary = ignore,
    Object? lastViewed = ignore,
  }) {
    final q = query.build();
    try {
      return q.updateProperties(limit: limit, {
        if (docId != ignore) 1: docId as String?,
        if (title != ignore) 2: title as String?,
        if (emoji != ignore) 3: emoji as String?,
        if (summary != ignore) 4: summary as String?,
        if (lastViewed != ignore) 5: lastViewed as DateTime?,
      });
    } finally {
      q.close();
    }
  }
}

extension HistoryEntryQueryBuilderUpdate
    on QueryBuilder<HistoryEntry, HistoryEntry, QOperations> {
  _HistoryEntryQueryUpdate get updateFirst =>
      _HistoryEntryQueryBuilderUpdateImpl(this, limit: 1);

  _HistoryEntryQueryUpdate get updateAll =>
      _HistoryEntryQueryBuilderUpdateImpl(this);
}

extension HistoryEntryQueryFilter
    on QueryBuilder<HistoryEntry, HistoryEntry, QFilterCondition> {
  QueryBuilder<HistoryEntry, HistoryEntry, QAfterFilterCondition> idEqualTo(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(property: 0, value: value),
      );
    });
  }

  QueryBuilder<HistoryEntry, HistoryEntry, QAfterFilterCondition> idGreaterThan(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(property: 0, value: value),
      );
    });
  }

  QueryBuilder<HistoryEntry, HistoryEntry, QAfterFilterCondition>
  idGreaterThanOrEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(property: 0, value: value),
      );
    });
  }

  QueryBuilder<HistoryEntry, HistoryEntry, QAfterFilterCondition> idLessThan(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(LessCondition(property: 0, value: value));
    });
  }

  QueryBuilder<HistoryEntry, HistoryEntry, QAfterFilterCondition>
  idLessThanOrEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(property: 0, value: value),
      );
    });
  }

  QueryBuilder<HistoryEntry, HistoryEntry, QAfterFilterCondition> idBetween(
    int lower,
    int upper,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(property: 0, lower: lower, upper: upper),
      );
    });
  }

  QueryBuilder<HistoryEntry, HistoryEntry, QAfterFilterCondition>
  docIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const IsNullCondition(property: 1));
    });
  }

  QueryBuilder<HistoryEntry, HistoryEntry, QAfterFilterCondition>
  docIdIsNotNull() {
    return QueryBuilder.apply(not(), (query) {
      return query.addFilterCondition(const IsNullCondition(property: 1));
    });
  }

  QueryBuilder<HistoryEntry, HistoryEntry, QAfterFilterCondition> docIdEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(property: 1, value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<HistoryEntry, HistoryEntry, QAfterFilterCondition>
  docIdGreaterThan(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(
          property: 1,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<HistoryEntry, HistoryEntry, QAfterFilterCondition>
  docIdGreaterThanOrEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(
          property: 1,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<HistoryEntry, HistoryEntry, QAfterFilterCondition> docIdLessThan(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(property: 1, value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<HistoryEntry, HistoryEntry, QAfterFilterCondition>
  docIdLessThanOrEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(
          property: 1,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<HistoryEntry, HistoryEntry, QAfterFilterCondition> docIdBetween(
    String? lower,
    String? upper, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(
          property: 1,
          lower: lower,
          upper: upper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<HistoryEntry, HistoryEntry, QAfterFilterCondition>
  docIdStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        StartsWithCondition(
          property: 1,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<HistoryEntry, HistoryEntry, QAfterFilterCondition> docIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EndsWithCondition(
          property: 1,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<HistoryEntry, HistoryEntry, QAfterFilterCondition> docIdContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        ContainsCondition(
          property: 1,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<HistoryEntry, HistoryEntry, QAfterFilterCondition> docIdMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        MatchesCondition(
          property: 1,
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<HistoryEntry, HistoryEntry, QAfterFilterCondition>
  docIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const EqualCondition(property: 1, value: ''),
      );
    });
  }

  QueryBuilder<HistoryEntry, HistoryEntry, QAfterFilterCondition>
  docIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterCondition(property: 1, value: ''),
      );
    });
  }

  QueryBuilder<HistoryEntry, HistoryEntry, QAfterFilterCondition>
  titleIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const IsNullCondition(property: 2));
    });
  }

  QueryBuilder<HistoryEntry, HistoryEntry, QAfterFilterCondition>
  titleIsNotNull() {
    return QueryBuilder.apply(not(), (query) {
      return query.addFilterCondition(const IsNullCondition(property: 2));
    });
  }

  QueryBuilder<HistoryEntry, HistoryEntry, QAfterFilterCondition> titleEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(property: 2, value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<HistoryEntry, HistoryEntry, QAfterFilterCondition>
  titleGreaterThan(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(
          property: 2,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<HistoryEntry, HistoryEntry, QAfterFilterCondition>
  titleGreaterThanOrEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(
          property: 2,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<HistoryEntry, HistoryEntry, QAfterFilterCondition> titleLessThan(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(property: 2, value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<HistoryEntry, HistoryEntry, QAfterFilterCondition>
  titleLessThanOrEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(
          property: 2,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<HistoryEntry, HistoryEntry, QAfterFilterCondition> titleBetween(
    String? lower,
    String? upper, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(
          property: 2,
          lower: lower,
          upper: upper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<HistoryEntry, HistoryEntry, QAfterFilterCondition>
  titleStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        StartsWithCondition(
          property: 2,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<HistoryEntry, HistoryEntry, QAfterFilterCondition> titleEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EndsWithCondition(
          property: 2,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<HistoryEntry, HistoryEntry, QAfterFilterCondition> titleContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        ContainsCondition(
          property: 2,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<HistoryEntry, HistoryEntry, QAfterFilterCondition> titleMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        MatchesCondition(
          property: 2,
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<HistoryEntry, HistoryEntry, QAfterFilterCondition>
  titleIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const EqualCondition(property: 2, value: ''),
      );
    });
  }

  QueryBuilder<HistoryEntry, HistoryEntry, QAfterFilterCondition>
  titleIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterCondition(property: 2, value: ''),
      );
    });
  }

  QueryBuilder<HistoryEntry, HistoryEntry, QAfterFilterCondition>
  emojiIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const IsNullCondition(property: 3));
    });
  }

  QueryBuilder<HistoryEntry, HistoryEntry, QAfterFilterCondition>
  emojiIsNotNull() {
    return QueryBuilder.apply(not(), (query) {
      return query.addFilterCondition(const IsNullCondition(property: 3));
    });
  }

  QueryBuilder<HistoryEntry, HistoryEntry, QAfterFilterCondition> emojiEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(property: 3, value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<HistoryEntry, HistoryEntry, QAfterFilterCondition>
  emojiGreaterThan(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(
          property: 3,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<HistoryEntry, HistoryEntry, QAfterFilterCondition>
  emojiGreaterThanOrEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(
          property: 3,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<HistoryEntry, HistoryEntry, QAfterFilterCondition> emojiLessThan(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(property: 3, value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<HistoryEntry, HistoryEntry, QAfterFilterCondition>
  emojiLessThanOrEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(
          property: 3,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<HistoryEntry, HistoryEntry, QAfterFilterCondition> emojiBetween(
    String? lower,
    String? upper, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(
          property: 3,
          lower: lower,
          upper: upper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<HistoryEntry, HistoryEntry, QAfterFilterCondition>
  emojiStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        StartsWithCondition(
          property: 3,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<HistoryEntry, HistoryEntry, QAfterFilterCondition> emojiEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EndsWithCondition(
          property: 3,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<HistoryEntry, HistoryEntry, QAfterFilterCondition> emojiContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        ContainsCondition(
          property: 3,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<HistoryEntry, HistoryEntry, QAfterFilterCondition> emojiMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        MatchesCondition(
          property: 3,
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<HistoryEntry, HistoryEntry, QAfterFilterCondition>
  emojiIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const EqualCondition(property: 3, value: ''),
      );
    });
  }

  QueryBuilder<HistoryEntry, HistoryEntry, QAfterFilterCondition>
  emojiIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterCondition(property: 3, value: ''),
      );
    });
  }

  QueryBuilder<HistoryEntry, HistoryEntry, QAfterFilterCondition>
  summaryIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const IsNullCondition(property: 4));
    });
  }

  QueryBuilder<HistoryEntry, HistoryEntry, QAfterFilterCondition>
  summaryIsNotNull() {
    return QueryBuilder.apply(not(), (query) {
      return query.addFilterCondition(const IsNullCondition(property: 4));
    });
  }

  QueryBuilder<HistoryEntry, HistoryEntry, QAfterFilterCondition>
  summaryEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(property: 4, value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<HistoryEntry, HistoryEntry, QAfterFilterCondition>
  summaryGreaterThan(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(
          property: 4,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<HistoryEntry, HistoryEntry, QAfterFilterCondition>
  summaryGreaterThanOrEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(
          property: 4,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<HistoryEntry, HistoryEntry, QAfterFilterCondition>
  summaryLessThan(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(property: 4, value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<HistoryEntry, HistoryEntry, QAfterFilterCondition>
  summaryLessThanOrEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(
          property: 4,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<HistoryEntry, HistoryEntry, QAfterFilterCondition>
  summaryBetween(String? lower, String? upper, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(
          property: 4,
          lower: lower,
          upper: upper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<HistoryEntry, HistoryEntry, QAfterFilterCondition>
  summaryStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        StartsWithCondition(
          property: 4,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<HistoryEntry, HistoryEntry, QAfterFilterCondition>
  summaryEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EndsWithCondition(
          property: 4,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<HistoryEntry, HistoryEntry, QAfterFilterCondition>
  summaryContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        ContainsCondition(
          property: 4,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<HistoryEntry, HistoryEntry, QAfterFilterCondition>
  summaryMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        MatchesCondition(
          property: 4,
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<HistoryEntry, HistoryEntry, QAfterFilterCondition>
  summaryIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const EqualCondition(property: 4, value: ''),
      );
    });
  }

  QueryBuilder<HistoryEntry, HistoryEntry, QAfterFilterCondition>
  summaryIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterCondition(property: 4, value: ''),
      );
    });
  }

  QueryBuilder<HistoryEntry, HistoryEntry, QAfterFilterCondition>
  lastViewedIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const IsNullCondition(property: 5));
    });
  }

  QueryBuilder<HistoryEntry, HistoryEntry, QAfterFilterCondition>
  lastViewedIsNotNull() {
    return QueryBuilder.apply(not(), (query) {
      return query.addFilterCondition(const IsNullCondition(property: 5));
    });
  }

  QueryBuilder<HistoryEntry, HistoryEntry, QAfterFilterCondition>
  lastViewedEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(property: 5, value: value),
      );
    });
  }

  QueryBuilder<HistoryEntry, HistoryEntry, QAfterFilterCondition>
  lastViewedGreaterThan(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(property: 5, value: value),
      );
    });
  }

  QueryBuilder<HistoryEntry, HistoryEntry, QAfterFilterCondition>
  lastViewedGreaterThanOrEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(property: 5, value: value),
      );
    });
  }

  QueryBuilder<HistoryEntry, HistoryEntry, QAfterFilterCondition>
  lastViewedLessThan(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(LessCondition(property: 5, value: value));
    });
  }

  QueryBuilder<HistoryEntry, HistoryEntry, QAfterFilterCondition>
  lastViewedLessThanOrEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(property: 5, value: value),
      );
    });
  }

  QueryBuilder<HistoryEntry, HistoryEntry, QAfterFilterCondition>
  lastViewedBetween(DateTime? lower, DateTime? upper) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(property: 5, lower: lower, upper: upper),
      );
    });
  }
}

extension HistoryEntryQueryObject
    on QueryBuilder<HistoryEntry, HistoryEntry, QFilterCondition> {}

extension HistoryEntryQuerySortBy
    on QueryBuilder<HistoryEntry, HistoryEntry, QSortBy> {
  QueryBuilder<HistoryEntry, HistoryEntry, QAfterSortBy> sortById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(0);
    });
  }

  QueryBuilder<HistoryEntry, HistoryEntry, QAfterSortBy> sortByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(0, sort: Sort.desc);
    });
  }

  QueryBuilder<HistoryEntry, HistoryEntry, QAfterSortBy> sortByDocId({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(1, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<HistoryEntry, HistoryEntry, QAfterSortBy> sortByDocIdDesc({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(1, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<HistoryEntry, HistoryEntry, QAfterSortBy> sortByTitle({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(2, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<HistoryEntry, HistoryEntry, QAfterSortBy> sortByTitleDesc({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(2, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<HistoryEntry, HistoryEntry, QAfterSortBy> sortByEmoji({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(3, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<HistoryEntry, HistoryEntry, QAfterSortBy> sortByEmojiDesc({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(3, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<HistoryEntry, HistoryEntry, QAfterSortBy> sortBySummary({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(4, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<HistoryEntry, HistoryEntry, QAfterSortBy> sortBySummaryDesc({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(4, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<HistoryEntry, HistoryEntry, QAfterSortBy> sortByLastViewed() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(5);
    });
  }

  QueryBuilder<HistoryEntry, HistoryEntry, QAfterSortBy>
  sortByLastViewedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(5, sort: Sort.desc);
    });
  }
}

extension HistoryEntryQuerySortThenBy
    on QueryBuilder<HistoryEntry, HistoryEntry, QSortThenBy> {
  QueryBuilder<HistoryEntry, HistoryEntry, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(0);
    });
  }

  QueryBuilder<HistoryEntry, HistoryEntry, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(0, sort: Sort.desc);
    });
  }

  QueryBuilder<HistoryEntry, HistoryEntry, QAfterSortBy> thenByDocId({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(1, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<HistoryEntry, HistoryEntry, QAfterSortBy> thenByDocIdDesc({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(1, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<HistoryEntry, HistoryEntry, QAfterSortBy> thenByTitle({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(2, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<HistoryEntry, HistoryEntry, QAfterSortBy> thenByTitleDesc({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(2, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<HistoryEntry, HistoryEntry, QAfterSortBy> thenByEmoji({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(3, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<HistoryEntry, HistoryEntry, QAfterSortBy> thenByEmojiDesc({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(3, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<HistoryEntry, HistoryEntry, QAfterSortBy> thenBySummary({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(4, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<HistoryEntry, HistoryEntry, QAfterSortBy> thenBySummaryDesc({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(4, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<HistoryEntry, HistoryEntry, QAfterSortBy> thenByLastViewed() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(5);
    });
  }

  QueryBuilder<HistoryEntry, HistoryEntry, QAfterSortBy>
  thenByLastViewedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(5, sort: Sort.desc);
    });
  }
}

extension HistoryEntryQueryWhereDistinct
    on QueryBuilder<HistoryEntry, HistoryEntry, QDistinct> {
  QueryBuilder<HistoryEntry, HistoryEntry, QAfterDistinct> distinctByDocId({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(1, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<HistoryEntry, HistoryEntry, QAfterDistinct> distinctByTitle({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(2, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<HistoryEntry, HistoryEntry, QAfterDistinct> distinctByEmoji({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(3, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<HistoryEntry, HistoryEntry, QAfterDistinct> distinctBySummary({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(4, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<HistoryEntry, HistoryEntry, QAfterDistinct>
  distinctByLastViewed() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(5);
    });
  }
}

extension HistoryEntryQueryProperty1
    on QueryBuilder<HistoryEntry, HistoryEntry, QProperty> {
  QueryBuilder<HistoryEntry, int, QAfterProperty> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(0);
    });
  }

  QueryBuilder<HistoryEntry, String?, QAfterProperty> docIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(1);
    });
  }

  QueryBuilder<HistoryEntry, String?, QAfterProperty> titleProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(2);
    });
  }

  QueryBuilder<HistoryEntry, String?, QAfterProperty> emojiProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(3);
    });
  }

  QueryBuilder<HistoryEntry, String?, QAfterProperty> summaryProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(4);
    });
  }

  QueryBuilder<HistoryEntry, DateTime?, QAfterProperty> lastViewedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(5);
    });
  }
}

extension HistoryEntryQueryProperty2<R>
    on QueryBuilder<HistoryEntry, R, QAfterProperty> {
  QueryBuilder<HistoryEntry, (R, int), QAfterProperty> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(0);
    });
  }

  QueryBuilder<HistoryEntry, (R, String?), QAfterProperty> docIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(1);
    });
  }

  QueryBuilder<HistoryEntry, (R, String?), QAfterProperty> titleProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(2);
    });
  }

  QueryBuilder<HistoryEntry, (R, String?), QAfterProperty> emojiProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(3);
    });
  }

  QueryBuilder<HistoryEntry, (R, String?), QAfterProperty> summaryProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(4);
    });
  }

  QueryBuilder<HistoryEntry, (R, DateTime?), QAfterProperty>
  lastViewedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(5);
    });
  }
}

extension HistoryEntryQueryProperty3<R1, R2>
    on QueryBuilder<HistoryEntry, (R1, R2), QAfterProperty> {
  QueryBuilder<HistoryEntry, (R1, R2, int), QOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(0);
    });
  }

  QueryBuilder<HistoryEntry, (R1, R2, String?), QOperations> docIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(1);
    });
  }

  QueryBuilder<HistoryEntry, (R1, R2, String?), QOperations> titleProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(2);
    });
  }

  QueryBuilder<HistoryEntry, (R1, R2, String?), QOperations> emojiProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(3);
    });
  }

  QueryBuilder<HistoryEntry, (R1, R2, String?), QOperations> summaryProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(4);
    });
  }

  QueryBuilder<HistoryEntry, (R1, R2, DateTime?), QOperations>
  lastViewedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(5);
    });
  }
}
