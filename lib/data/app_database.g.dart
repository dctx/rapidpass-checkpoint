// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// **************************************************************************
// MoorGenerator
// **************************************************************************

// ignore_for_file: unnecessary_brace_in_string_interps, unnecessary_this
class ValidPass extends DataClass implements Insertable<ValidPass> {
  final int id;
  final int passType;
  final String apor;
  final int controlCode;
  final int validFrom;
  final int validUntil;
  final String idType;
  final String idOrPlate;
  final String company;
  final String homeAddress;
  final String status;
  ValidPass(
      {@required this.id,
      @required this.passType,
      this.apor,
      @required this.controlCode,
      this.validFrom,
      this.validUntil,
      this.idType,
      this.idOrPlate,
      this.company,
      this.homeAddress,
      this.status});
  factory ValidPass.fromData(Map<String, dynamic> data, GeneratedDatabase db,
      {String prefix}) {
    final effectivePrefix = prefix ?? '';
    final intType = db.typeSystem.forDartType<int>();
    final stringType = db.typeSystem.forDartType<String>();
    return ValidPass(
      id: intType.mapFromDatabaseResponse(data['${effectivePrefix}id']),
      passType:
          intType.mapFromDatabaseResponse(data['${effectivePrefix}pass_type']),
      apor: stringType.mapFromDatabaseResponse(data['${effectivePrefix}apor']),
      controlCode: intType
          .mapFromDatabaseResponse(data['${effectivePrefix}control_code']),
      validFrom:
          intType.mapFromDatabaseResponse(data['${effectivePrefix}valid_from']),
      validUntil: intType
          .mapFromDatabaseResponse(data['${effectivePrefix}valid_until']),
      idType:
          stringType.mapFromDatabaseResponse(data['${effectivePrefix}id_type']),
      idOrPlate: stringType
          .mapFromDatabaseResponse(data['${effectivePrefix}id_or_plate']),
      company:
          stringType.mapFromDatabaseResponse(data['${effectivePrefix}company']),
      homeAddress: stringType
          .mapFromDatabaseResponse(data['${effectivePrefix}home_address']),
      status:
          stringType.mapFromDatabaseResponse(data['${effectivePrefix}status']),
    );
  }
  factory ValidPass.fromJson(Map<String, dynamic> json,
      {ValueSerializer serializer}) {
    serializer ??= moorRuntimeOptions.defaultSerializer;
    return ValidPass(
      id: serializer.fromJson<int>(json['id']),
      passType: serializer.fromJson<int>(json['passType']),
      apor: serializer.fromJson<String>(json['apor']),
      controlCode: serializer.fromJson<int>(json['controlCode']),
      validFrom: serializer.fromJson<int>(json['validFrom']),
      validUntil: serializer.fromJson<int>(json['validUntil']),
      idType: serializer.fromJson<String>(json['idType']),
      idOrPlate: serializer.fromJson<String>(json['idOrPlate']),
      company: serializer.fromJson<String>(json['company']),
      homeAddress: serializer.fromJson<String>(json['homeAddress']),
      status: serializer.fromJson<String>(json['status']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer serializer}) {
    serializer ??= moorRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'passType': serializer.toJson<int>(passType),
      'apor': serializer.toJson<String>(apor),
      'controlCode': serializer.toJson<int>(controlCode),
      'validFrom': serializer.toJson<int>(validFrom),
      'validUntil': serializer.toJson<int>(validUntil),
      'idType': serializer.toJson<String>(idType),
      'idOrPlate': serializer.toJson<String>(idOrPlate),
      'company': serializer.toJson<String>(company),
      'homeAddress': serializer.toJson<String>(homeAddress),
      'status': serializer.toJson<String>(status),
    };
  }

  @override
  ValidPassesCompanion createCompanion(bool nullToAbsent) {
    return ValidPassesCompanion(
      id: id == null && nullToAbsent ? const Value.absent() : Value(id),
      passType: passType == null && nullToAbsent
          ? const Value.absent()
          : Value(passType),
      apor: apor == null && nullToAbsent ? const Value.absent() : Value(apor),
      controlCode: controlCode == null && nullToAbsent
          ? const Value.absent()
          : Value(controlCode),
      validFrom: validFrom == null && nullToAbsent
          ? const Value.absent()
          : Value(validFrom),
      validUntil: validUntil == null && nullToAbsent
          ? const Value.absent()
          : Value(validUntil),
      idType:
          idType == null && nullToAbsent ? const Value.absent() : Value(idType),
      idOrPlate: idOrPlate == null && nullToAbsent
          ? const Value.absent()
          : Value(idOrPlate),
      company: company == null && nullToAbsent
          ? const Value.absent()
          : Value(company),
      homeAddress: homeAddress == null && nullToAbsent
          ? const Value.absent()
          : Value(homeAddress),
      status:
          status == null && nullToAbsent ? const Value.absent() : Value(status),
    );
  }

  ValidPass copyWith(
          {int id,
          int passType,
          String apor,
          int controlCode,
          int validFrom,
          int validUntil,
          String idType,
          String idOrPlate,
          String company,
          String homeAddress,
          String status}) =>
      ValidPass(
        id: id ?? this.id,
        passType: passType ?? this.passType,
        apor: apor ?? this.apor,
        controlCode: controlCode ?? this.controlCode,
        validFrom: validFrom ?? this.validFrom,
        validUntil: validUntil ?? this.validUntil,
        idType: idType ?? this.idType,
        idOrPlate: idOrPlate ?? this.idOrPlate,
        company: company ?? this.company,
        homeAddress: homeAddress ?? this.homeAddress,
        status: status ?? this.status,
      );
  @override
  String toString() {
    return (StringBuffer('ValidPass(')
          ..write('id: $id, ')
          ..write('passType: $passType, ')
          ..write('apor: $apor, ')
          ..write('controlCode: $controlCode, ')
          ..write('validFrom: $validFrom, ')
          ..write('validUntil: $validUntil, ')
          ..write('idType: $idType, ')
          ..write('idOrPlate: $idOrPlate, ')
          ..write('company: $company, ')
          ..write('homeAddress: $homeAddress, ')
          ..write('status: $status')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => $mrjf($mrjc(
      id.hashCode,
      $mrjc(
          passType.hashCode,
          $mrjc(
              apor.hashCode,
              $mrjc(
                  controlCode.hashCode,
                  $mrjc(
                      validFrom.hashCode,
                      $mrjc(
                          validUntil.hashCode,
                          $mrjc(
                              idType.hashCode,
                              $mrjc(
                                  idOrPlate.hashCode,
                                  $mrjc(
                                      company.hashCode,
                                      $mrjc(homeAddress.hashCode,
                                          status.hashCode)))))))))));
  @override
  bool operator ==(dynamic other) =>
      identical(this, other) ||
      (other is ValidPass &&
          other.id == this.id &&
          other.passType == this.passType &&
          other.apor == this.apor &&
          other.controlCode == this.controlCode &&
          other.validFrom == this.validFrom &&
          other.validUntil == this.validUntil &&
          other.idType == this.idType &&
          other.idOrPlate == this.idOrPlate &&
          other.company == this.company &&
          other.homeAddress == this.homeAddress &&
          other.status == this.status);
}

class ValidPassesCompanion extends UpdateCompanion<ValidPass> {
  final Value<int> id;
  final Value<int> passType;
  final Value<String> apor;
  final Value<int> controlCode;
  final Value<int> validFrom;
  final Value<int> validUntil;
  final Value<String> idType;
  final Value<String> idOrPlate;
  final Value<String> company;
  final Value<String> homeAddress;
  final Value<String> status;
  const ValidPassesCompanion({
    this.id = const Value.absent(),
    this.passType = const Value.absent(),
    this.apor = const Value.absent(),
    this.controlCode = const Value.absent(),
    this.validFrom = const Value.absent(),
    this.validUntil = const Value.absent(),
    this.idType = const Value.absent(),
    this.idOrPlate = const Value.absent(),
    this.company = const Value.absent(),
    this.homeAddress = const Value.absent(),
    this.status = const Value.absent(),
  });
  ValidPassesCompanion.insert({
    this.id = const Value.absent(),
    @required int passType,
    this.apor = const Value.absent(),
    @required int controlCode,
    this.validFrom = const Value.absent(),
    this.validUntil = const Value.absent(),
    this.idType = const Value.absent(),
    this.idOrPlate = const Value.absent(),
    this.company = const Value.absent(),
    this.homeAddress = const Value.absent(),
    this.status = const Value.absent(),
  })  : passType = Value(passType),
        controlCode = Value(controlCode);
  ValidPassesCompanion copyWith(
      {Value<int> id,
      Value<int> passType,
      Value<String> apor,
      Value<int> controlCode,
      Value<int> validFrom,
      Value<int> validUntil,
      Value<String> idType,
      Value<String> idOrPlate,
      Value<String> company,
      Value<String> homeAddress,
      Value<String> status}) {
    return ValidPassesCompanion(
      id: id ?? this.id,
      passType: passType ?? this.passType,
      apor: apor ?? this.apor,
      controlCode: controlCode ?? this.controlCode,
      validFrom: validFrom ?? this.validFrom,
      validUntil: validUntil ?? this.validUntil,
      idType: idType ?? this.idType,
      idOrPlate: idOrPlate ?? this.idOrPlate,
      company: company ?? this.company,
      homeAddress: homeAddress ?? this.homeAddress,
      status: status ?? this.status,
    );
  }
}

class $ValidPassesTable extends ValidPasses
    with TableInfo<$ValidPassesTable, ValidPass> {
  final GeneratedDatabase _db;
  final String _alias;
  $ValidPassesTable(this._db, [this._alias]);
  final VerificationMeta _idMeta = const VerificationMeta('id');
  GeneratedIntColumn _id;
  @override
  GeneratedIntColumn get id => _id ??= _constructId();
  GeneratedIntColumn _constructId() {
    return GeneratedIntColumn('id', $tableName, false,
        hasAutoIncrement: true, declaredAsPrimaryKey: true);
  }

  final VerificationMeta _passTypeMeta = const VerificationMeta('passType');
  GeneratedIntColumn _passType;
  @override
  GeneratedIntColumn get passType => _passType ??= _constructPassType();
  GeneratedIntColumn _constructPassType() {
    return GeneratedIntColumn(
      'pass_type',
      $tableName,
      false,
    );
  }

  final VerificationMeta _aporMeta = const VerificationMeta('apor');
  GeneratedTextColumn _apor;
  @override
  GeneratedTextColumn get apor => _apor ??= _constructApor();
  GeneratedTextColumn _constructApor() {
    return GeneratedTextColumn(
      'apor',
      $tableName,
      true,
    );
  }

  final VerificationMeta _controlCodeMeta =
      const VerificationMeta('controlCode');
  GeneratedIntColumn _controlCode;
  @override
  GeneratedIntColumn get controlCode =>
      _controlCode ??= _constructControlCode();
  GeneratedIntColumn _constructControlCode() {
    return GeneratedIntColumn('control_code', $tableName, false,
        $customConstraints: 'UNIQUE');
  }

  final VerificationMeta _validFromMeta = const VerificationMeta('validFrom');
  GeneratedIntColumn _validFrom;
  @override
  GeneratedIntColumn get validFrom => _validFrom ??= _constructValidFrom();
  GeneratedIntColumn _constructValidFrom() {
    return GeneratedIntColumn(
      'valid_from',
      $tableName,
      true,
    );
  }

  final VerificationMeta _validUntilMeta = const VerificationMeta('validUntil');
  GeneratedIntColumn _validUntil;
  @override
  GeneratedIntColumn get validUntil => _validUntil ??= _constructValidUntil();
  GeneratedIntColumn _constructValidUntil() {
    return GeneratedIntColumn(
      'valid_until',
      $tableName,
      true,
    );
  }

  final VerificationMeta _idTypeMeta = const VerificationMeta('idType');
  GeneratedTextColumn _idType;
  @override
  GeneratedTextColumn get idType => _idType ??= _constructIdType();
  GeneratedTextColumn _constructIdType() {
    return GeneratedTextColumn(
      'id_type',
      $tableName,
      true,
    );
  }

  final VerificationMeta _idOrPlateMeta = const VerificationMeta('idOrPlate');
  GeneratedTextColumn _idOrPlate;
  @override
  GeneratedTextColumn get idOrPlate => _idOrPlate ??= _constructIdOrPlate();
  GeneratedTextColumn _constructIdOrPlate() {
    return GeneratedTextColumn(
      'id_or_plate',
      $tableName,
      true,
    );
  }

  final VerificationMeta _companyMeta = const VerificationMeta('company');
  GeneratedTextColumn _company;
  @override
  GeneratedTextColumn get company => _company ??= _constructCompany();
  GeneratedTextColumn _constructCompany() {
    return GeneratedTextColumn(
      'company',
      $tableName,
      true,
    );
  }

  final VerificationMeta _homeAddressMeta =
      const VerificationMeta('homeAddress');
  GeneratedTextColumn _homeAddress;
  @override
  GeneratedTextColumn get homeAddress =>
      _homeAddress ??= _constructHomeAddress();
  GeneratedTextColumn _constructHomeAddress() {
    return GeneratedTextColumn(
      'home_address',
      $tableName,
      true,
    );
  }

  final VerificationMeta _statusMeta = const VerificationMeta('status');
  GeneratedTextColumn _status;
  @override
  GeneratedTextColumn get status => _status ??= _constructStatus();
  GeneratedTextColumn _constructStatus() {
    return GeneratedTextColumn(
      'status',
      $tableName,
      true,
    );
  }

  @override
  List<GeneratedColumn> get $columns => [
        id,
        passType,
        apor,
        controlCode,
        validFrom,
        validUntil,
        idType,
        idOrPlate,
        company,
        homeAddress,
        status
      ];
  @override
  $ValidPassesTable get asDslTable => this;
  @override
  String get $tableName => _alias ?? 'valid_passes';
  @override
  final String actualTableName = 'valid_passes';
  @override
  VerificationContext validateIntegrity(ValidPassesCompanion d,
      {bool isInserting = false}) {
    final context = VerificationContext();
    if (d.id.present) {
      context.handle(_idMeta, id.isAcceptableValue(d.id.value, _idMeta));
    }
    if (d.passType.present) {
      context.handle(_passTypeMeta,
          passType.isAcceptableValue(d.passType.value, _passTypeMeta));
    } else if (isInserting) {
      context.missing(_passTypeMeta);
    }
    if (d.apor.present) {
      context.handle(
          _aporMeta, apor.isAcceptableValue(d.apor.value, _aporMeta));
    }
    if (d.controlCode.present) {
      context.handle(_controlCodeMeta,
          controlCode.isAcceptableValue(d.controlCode.value, _controlCodeMeta));
    } else if (isInserting) {
      context.missing(_controlCodeMeta);
    }
    if (d.validFrom.present) {
      context.handle(_validFromMeta,
          validFrom.isAcceptableValue(d.validFrom.value, _validFromMeta));
    }
    if (d.validUntil.present) {
      context.handle(_validUntilMeta,
          validUntil.isAcceptableValue(d.validUntil.value, _validUntilMeta));
    }
    if (d.idType.present) {
      context.handle(
          _idTypeMeta, idType.isAcceptableValue(d.idType.value, _idTypeMeta));
    }
    if (d.idOrPlate.present) {
      context.handle(_idOrPlateMeta,
          idOrPlate.isAcceptableValue(d.idOrPlate.value, _idOrPlateMeta));
    }
    if (d.company.present) {
      context.handle(_companyMeta,
          company.isAcceptableValue(d.company.value, _companyMeta));
    }
    if (d.homeAddress.present) {
      context.handle(_homeAddressMeta,
          homeAddress.isAcceptableValue(d.homeAddress.value, _homeAddressMeta));
    }
    if (d.status.present) {
      context.handle(
          _statusMeta, status.isAcceptableValue(d.status.value, _statusMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ValidPass map(Map<String, dynamic> data, {String tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : null;
    return ValidPass.fromData(data, _db, prefix: effectivePrefix);
  }

  @override
  Map<String, Variable> entityToSql(ValidPassesCompanion d) {
    final map = <String, Variable>{};
    if (d.id.present) {
      map['id'] = Variable<int, IntType>(d.id.value);
    }
    if (d.passType.present) {
      map['pass_type'] = Variable<int, IntType>(d.passType.value);
    }
    if (d.apor.present) {
      map['apor'] = Variable<String, StringType>(d.apor.value);
    }
    if (d.controlCode.present) {
      map['control_code'] = Variable<int, IntType>(d.controlCode.value);
    }
    if (d.validFrom.present) {
      map['valid_from'] = Variable<int, IntType>(d.validFrom.value);
    }
    if (d.validUntil.present) {
      map['valid_until'] = Variable<int, IntType>(d.validUntil.value);
    }
    if (d.idType.present) {
      map['id_type'] = Variable<String, StringType>(d.idType.value);
    }
    if (d.idOrPlate.present) {
      map['id_or_plate'] = Variable<String, StringType>(d.idOrPlate.value);
    }
    if (d.company.present) {
      map['company'] = Variable<String, StringType>(d.company.value);
    }
    if (d.homeAddress.present) {
      map['home_address'] = Variable<String, StringType>(d.homeAddress.value);
    }
    if (d.status.present) {
      map['status'] = Variable<String, StringType>(d.status.value);
    }
    return map;
  }

  @override
  $ValidPassesTable createAlias(String alias) {
    return $ValidPassesTable(_db, alias);
  }
}

class InvalidPass extends DataClass implements Insertable<InvalidPass> {
  final int id;
  final int controlCode;
  final String status;
  InvalidPass(
      {@required this.id, @required this.controlCode, @required this.status});
  factory InvalidPass.fromData(Map<String, dynamic> data, GeneratedDatabase db,
      {String prefix}) {
    final effectivePrefix = prefix ?? '';
    final intType = db.typeSystem.forDartType<int>();
    final stringType = db.typeSystem.forDartType<String>();
    return InvalidPass(
      id: intType.mapFromDatabaseResponse(data['${effectivePrefix}id']),
      controlCode: intType
          .mapFromDatabaseResponse(data['${effectivePrefix}control_code']),
      status:
          stringType.mapFromDatabaseResponse(data['${effectivePrefix}status']),
    );
  }
  factory InvalidPass.fromJson(Map<String, dynamic> json,
      {ValueSerializer serializer}) {
    serializer ??= moorRuntimeOptions.defaultSerializer;
    return InvalidPass(
      id: serializer.fromJson<int>(json['id']),
      controlCode: serializer.fromJson<int>(json['controlCode']),
      status: serializer.fromJson<String>(json['status']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer serializer}) {
    serializer ??= moorRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'controlCode': serializer.toJson<int>(controlCode),
      'status': serializer.toJson<String>(status),
    };
  }

  @override
  InvalidPassesCompanion createCompanion(bool nullToAbsent) {
    return InvalidPassesCompanion(
      id: id == null && nullToAbsent ? const Value.absent() : Value(id),
      controlCode: controlCode == null && nullToAbsent
          ? const Value.absent()
          : Value(controlCode),
      status:
          status == null && nullToAbsent ? const Value.absent() : Value(status),
    );
  }

  InvalidPass copyWith({int id, int controlCode, String status}) => InvalidPass(
        id: id ?? this.id,
        controlCode: controlCode ?? this.controlCode,
        status: status ?? this.status,
      );
  @override
  String toString() {
    return (StringBuffer('InvalidPass(')
          ..write('id: $id, ')
          ..write('controlCode: $controlCode, ')
          ..write('status: $status')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      $mrjf($mrjc(id.hashCode, $mrjc(controlCode.hashCode, status.hashCode)));
  @override
  bool operator ==(dynamic other) =>
      identical(this, other) ||
      (other is InvalidPass &&
          other.id == this.id &&
          other.controlCode == this.controlCode &&
          other.status == this.status);
}

class InvalidPassesCompanion extends UpdateCompanion<InvalidPass> {
  final Value<int> id;
  final Value<int> controlCode;
  final Value<String> status;
  const InvalidPassesCompanion({
    this.id = const Value.absent(),
    this.controlCode = const Value.absent(),
    this.status = const Value.absent(),
  });
  InvalidPassesCompanion.insert({
    this.id = const Value.absent(),
    @required int controlCode,
    @required String status,
  })  : controlCode = Value(controlCode),
        status = Value(status);
  InvalidPassesCompanion copyWith(
      {Value<int> id, Value<int> controlCode, Value<String> status}) {
    return InvalidPassesCompanion(
      id: id ?? this.id,
      controlCode: controlCode ?? this.controlCode,
      status: status ?? this.status,
    );
  }
}

class $InvalidPassesTable extends InvalidPasses
    with TableInfo<$InvalidPassesTable, InvalidPass> {
  final GeneratedDatabase _db;
  final String _alias;
  $InvalidPassesTable(this._db, [this._alias]);
  final VerificationMeta _idMeta = const VerificationMeta('id');
  GeneratedIntColumn _id;
  @override
  GeneratedIntColumn get id => _id ??= _constructId();
  GeneratedIntColumn _constructId() {
    return GeneratedIntColumn('id', $tableName, false,
        hasAutoIncrement: true, declaredAsPrimaryKey: true);
  }

  final VerificationMeta _controlCodeMeta =
      const VerificationMeta('controlCode');
  GeneratedIntColumn _controlCode;
  @override
  GeneratedIntColumn get controlCode =>
      _controlCode ??= _constructControlCode();
  GeneratedIntColumn _constructControlCode() {
    return GeneratedIntColumn(
      'control_code',
      $tableName,
      false,
    );
  }

  final VerificationMeta _statusMeta = const VerificationMeta('status');
  GeneratedTextColumn _status;
  @override
  GeneratedTextColumn get status => _status ??= _constructStatus();
  GeneratedTextColumn _constructStatus() {
    return GeneratedTextColumn(
      'status',
      $tableName,
      false,
    );
  }

  @override
  List<GeneratedColumn> get $columns => [id, controlCode, status];
  @override
  $InvalidPassesTable get asDslTable => this;
  @override
  String get $tableName => _alias ?? 'invalid_passes';
  @override
  final String actualTableName = 'invalid_passes';
  @override
  VerificationContext validateIntegrity(InvalidPassesCompanion d,
      {bool isInserting = false}) {
    final context = VerificationContext();
    if (d.id.present) {
      context.handle(_idMeta, id.isAcceptableValue(d.id.value, _idMeta));
    }
    if (d.controlCode.present) {
      context.handle(_controlCodeMeta,
          controlCode.isAcceptableValue(d.controlCode.value, _controlCodeMeta));
    } else if (isInserting) {
      context.missing(_controlCodeMeta);
    }
    if (d.status.present) {
      context.handle(
          _statusMeta, status.isAcceptableValue(d.status.value, _statusMeta));
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  InvalidPass map(Map<String, dynamic> data, {String tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : null;
    return InvalidPass.fromData(data, _db, prefix: effectivePrefix);
  }

  @override
  Map<String, Variable> entityToSql(InvalidPassesCompanion d) {
    final map = <String, Variable>{};
    if (d.id.present) {
      map['id'] = Variable<int, IntType>(d.id.value);
    }
    if (d.controlCode.present) {
      map['control_code'] = Variable<int, IntType>(d.controlCode.value);
    }
    if (d.status.present) {
      map['status'] = Variable<String, StringType>(d.status.value);
    }
    return map;
  }

  @override
  $InvalidPassesTable createAlias(String alias) {
    return $InvalidPassesTable(_db, alias);
  }
}

class UsageLog extends DataClass implements Insertable<UsageLog> {
  final int id;
  final int timestamp;
  final int controlNumber;
  final int mode;
  final int status;
  final String inputData;
  final double latitude;
  final double longitude;
  UsageLog(
      {@required this.id,
      @required this.timestamp,
      this.controlNumber,
      @required this.mode,
      @required this.status,
      @required this.inputData,
      this.latitude,
      this.longitude});
  factory UsageLog.fromData(Map<String, dynamic> data, GeneratedDatabase db,
      {String prefix}) {
    final effectivePrefix = prefix ?? '';
    final intType = db.typeSystem.forDartType<int>();
    final stringType = db.typeSystem.forDartType<String>();
    final doubleType = db.typeSystem.forDartType<double>();
    return UsageLog(
      id: intType.mapFromDatabaseResponse(data['${effectivePrefix}id']),
      timestamp:
          intType.mapFromDatabaseResponse(data['${effectivePrefix}timestamp']),
      controlNumber: intType
          .mapFromDatabaseResponse(data['${effectivePrefix}control_number']),
      mode: intType.mapFromDatabaseResponse(data['${effectivePrefix}mode']),
      status: intType.mapFromDatabaseResponse(data['${effectivePrefix}status']),
      inputData: stringType
          .mapFromDatabaseResponse(data['${effectivePrefix}input_data']),
      latitude: doubleType
          .mapFromDatabaseResponse(data['${effectivePrefix}latitude']),
      longitude: doubleType
          .mapFromDatabaseResponse(data['${effectivePrefix}longitude']),
    );
  }
  factory UsageLog.fromJson(Map<String, dynamic> json,
      {ValueSerializer serializer}) {
    serializer ??= moorRuntimeOptions.defaultSerializer;
    return UsageLog(
      id: serializer.fromJson<int>(json['id']),
      timestamp: serializer.fromJson<int>(json['timestamp']),
      controlNumber: serializer.fromJson<int>(json['controlNumber']),
      mode: serializer.fromJson<int>(json['mode']),
      status: serializer.fromJson<int>(json['status']),
      inputData: serializer.fromJson<String>(json['inputData']),
      latitude: serializer.fromJson<double>(json['latitude']),
      longitude: serializer.fromJson<double>(json['longitude']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer serializer}) {
    serializer ??= moorRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'timestamp': serializer.toJson<int>(timestamp),
      'controlNumber': serializer.toJson<int>(controlNumber),
      'mode': serializer.toJson<int>(mode),
      'status': serializer.toJson<int>(status),
      'inputData': serializer.toJson<String>(inputData),
      'latitude': serializer.toJson<double>(latitude),
      'longitude': serializer.toJson<double>(longitude),
    };
  }

  @override
  UsageLogsCompanion createCompanion(bool nullToAbsent) {
    return UsageLogsCompanion(
      id: id == null && nullToAbsent ? const Value.absent() : Value(id),
      timestamp: timestamp == null && nullToAbsent
          ? const Value.absent()
          : Value(timestamp),
      controlNumber: controlNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(controlNumber),
      mode: mode == null && nullToAbsent ? const Value.absent() : Value(mode),
      status:
          status == null && nullToAbsent ? const Value.absent() : Value(status),
      inputData: inputData == null && nullToAbsent
          ? const Value.absent()
          : Value(inputData),
      latitude: latitude == null && nullToAbsent
          ? const Value.absent()
          : Value(latitude),
      longitude: longitude == null && nullToAbsent
          ? const Value.absent()
          : Value(longitude),
    );
  }

  UsageLog copyWith(
          {int id,
          int timestamp,
          int controlNumber,
          int mode,
          int status,
          String inputData,
          double latitude,
          double longitude}) =>
      UsageLog(
        id: id ?? this.id,
        timestamp: timestamp ?? this.timestamp,
        controlNumber: controlNumber ?? this.controlNumber,
        mode: mode ?? this.mode,
        status: status ?? this.status,
        inputData: inputData ?? this.inputData,
        latitude: latitude ?? this.latitude,
        longitude: longitude ?? this.longitude,
      );
  @override
  String toString() {
    return (StringBuffer('UsageLog(')
          ..write('id: $id, ')
          ..write('timestamp: $timestamp, ')
          ..write('controlNumber: $controlNumber, ')
          ..write('mode: $mode, ')
          ..write('status: $status, ')
          ..write('inputData: $inputData, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => $mrjf($mrjc(
      id.hashCode,
      $mrjc(
          timestamp.hashCode,
          $mrjc(
              controlNumber.hashCode,
              $mrjc(
                  mode.hashCode,
                  $mrjc(
                      status.hashCode,
                      $mrjc(inputData.hashCode,
                          $mrjc(latitude.hashCode, longitude.hashCode))))))));
  @override
  bool operator ==(dynamic other) =>
      identical(this, other) ||
      (other is UsageLog &&
          other.id == this.id &&
          other.timestamp == this.timestamp &&
          other.controlNumber == this.controlNumber &&
          other.mode == this.mode &&
          other.status == this.status &&
          other.inputData == this.inputData &&
          other.latitude == this.latitude &&
          other.longitude == this.longitude);
}

class UsageLogsCompanion extends UpdateCompanion<UsageLog> {
  final Value<int> id;
  final Value<int> timestamp;
  final Value<int> controlNumber;
  final Value<int> mode;
  final Value<int> status;
  final Value<String> inputData;
  final Value<double> latitude;
  final Value<double> longitude;
  const UsageLogsCompanion({
    this.id = const Value.absent(),
    this.timestamp = const Value.absent(),
    this.controlNumber = const Value.absent(),
    this.mode = const Value.absent(),
    this.status = const Value.absent(),
    this.inputData = const Value.absent(),
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
  });
  UsageLogsCompanion.insert({
    this.id = const Value.absent(),
    @required int timestamp,
    this.controlNumber = const Value.absent(),
    @required int mode,
    @required int status,
    @required String inputData,
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
  })  : timestamp = Value(timestamp),
        mode = Value(mode),
        status = Value(status),
        inputData = Value(inputData);
  UsageLogsCompanion copyWith(
      {Value<int> id,
      Value<int> timestamp,
      Value<int> controlNumber,
      Value<int> mode,
      Value<int> status,
      Value<String> inputData,
      Value<double> latitude,
      Value<double> longitude}) {
    return UsageLogsCompanion(
      id: id ?? this.id,
      timestamp: timestamp ?? this.timestamp,
      controlNumber: controlNumber ?? this.controlNumber,
      mode: mode ?? this.mode,
      status: status ?? this.status,
      inputData: inputData ?? this.inputData,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }
}

class $UsageLogsTable extends UsageLogs
    with TableInfo<$UsageLogsTable, UsageLog> {
  final GeneratedDatabase _db;
  final String _alias;
  $UsageLogsTable(this._db, [this._alias]);
  final VerificationMeta _idMeta = const VerificationMeta('id');
  GeneratedIntColumn _id;
  @override
  GeneratedIntColumn get id => _id ??= _constructId();
  GeneratedIntColumn _constructId() {
    return GeneratedIntColumn('id', $tableName, false,
        hasAutoIncrement: true, declaredAsPrimaryKey: true);
  }

  final VerificationMeta _timestampMeta = const VerificationMeta('timestamp');
  GeneratedIntColumn _timestamp;
  @override
  GeneratedIntColumn get timestamp => _timestamp ??= _constructTimestamp();
  GeneratedIntColumn _constructTimestamp() {
    return GeneratedIntColumn(
      'timestamp',
      $tableName,
      false,
    );
  }

  final VerificationMeta _controlNumberMeta =
      const VerificationMeta('controlNumber');
  GeneratedIntColumn _controlNumber;
  @override
  GeneratedIntColumn get controlNumber =>
      _controlNumber ??= _constructControlNumber();
  GeneratedIntColumn _constructControlNumber() {
    return GeneratedIntColumn(
      'control_number',
      $tableName,
      true,
    );
  }

  final VerificationMeta _modeMeta = const VerificationMeta('mode');
  GeneratedIntColumn _mode;
  @override
  GeneratedIntColumn get mode => _mode ??= _constructMode();
  GeneratedIntColumn _constructMode() {
    return GeneratedIntColumn(
      'mode',
      $tableName,
      false,
    );
  }

  final VerificationMeta _statusMeta = const VerificationMeta('status');
  GeneratedIntColumn _status;
  @override
  GeneratedIntColumn get status => _status ??= _constructStatus();
  GeneratedIntColumn _constructStatus() {
    return GeneratedIntColumn(
      'status',
      $tableName,
      false,
    );
  }

  final VerificationMeta _inputDataMeta = const VerificationMeta('inputData');
  GeneratedTextColumn _inputData;
  @override
  GeneratedTextColumn get inputData => _inputData ??= _constructInputData();
  GeneratedTextColumn _constructInputData() {
    return GeneratedTextColumn(
      'input_data',
      $tableName,
      false,
    );
  }

  final VerificationMeta _latitudeMeta = const VerificationMeta('latitude');
  GeneratedRealColumn _latitude;
  @override
  GeneratedRealColumn get latitude => _latitude ??= _constructLatitude();
  GeneratedRealColumn _constructLatitude() {
    return GeneratedRealColumn(
      'latitude',
      $tableName,
      true,
    );
  }

  final VerificationMeta _longitudeMeta = const VerificationMeta('longitude');
  GeneratedRealColumn _longitude;
  @override
  GeneratedRealColumn get longitude => _longitude ??= _constructLongitude();
  GeneratedRealColumn _constructLongitude() {
    return GeneratedRealColumn(
      'longitude',
      $tableName,
      true,
    );
  }

  @override
  List<GeneratedColumn> get $columns => [
        id,
        timestamp,
        controlNumber,
        mode,
        status,
        inputData,
        latitude,
        longitude
      ];
  @override
  $UsageLogsTable get asDslTable => this;
  @override
  String get $tableName => _alias ?? 'usage_logs';
  @override
  final String actualTableName = 'usage_logs';
  @override
  VerificationContext validateIntegrity(UsageLogsCompanion d,
      {bool isInserting = false}) {
    final context = VerificationContext();
    if (d.id.present) {
      context.handle(_idMeta, id.isAcceptableValue(d.id.value, _idMeta));
    }
    if (d.timestamp.present) {
      context.handle(_timestampMeta,
          timestamp.isAcceptableValue(d.timestamp.value, _timestampMeta));
    } else if (isInserting) {
      context.missing(_timestampMeta);
    }
    if (d.controlNumber.present) {
      context.handle(
          _controlNumberMeta,
          controlNumber.isAcceptableValue(
              d.controlNumber.value, _controlNumberMeta));
    }
    if (d.mode.present) {
      context.handle(
          _modeMeta, mode.isAcceptableValue(d.mode.value, _modeMeta));
    } else if (isInserting) {
      context.missing(_modeMeta);
    }
    if (d.status.present) {
      context.handle(
          _statusMeta, status.isAcceptableValue(d.status.value, _statusMeta));
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (d.inputData.present) {
      context.handle(_inputDataMeta,
          inputData.isAcceptableValue(d.inputData.value, _inputDataMeta));
    } else if (isInserting) {
      context.missing(_inputDataMeta);
    }
    if (d.latitude.present) {
      context.handle(_latitudeMeta,
          latitude.isAcceptableValue(d.latitude.value, _latitudeMeta));
    }
    if (d.longitude.present) {
      context.handle(_longitudeMeta,
          longitude.isAcceptableValue(d.longitude.value, _longitudeMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  UsageLog map(Map<String, dynamic> data, {String tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : null;
    return UsageLog.fromData(data, _db, prefix: effectivePrefix);
  }

  @override
  Map<String, Variable> entityToSql(UsageLogsCompanion d) {
    final map = <String, Variable>{};
    if (d.id.present) {
      map['id'] = Variable<int, IntType>(d.id.value);
    }
    if (d.timestamp.present) {
      map['timestamp'] = Variable<int, IntType>(d.timestamp.value);
    }
    if (d.controlNumber.present) {
      map['control_number'] = Variable<int, IntType>(d.controlNumber.value);
    }
    if (d.mode.present) {
      map['mode'] = Variable<int, IntType>(d.mode.value);
    }
    if (d.status.present) {
      map['status'] = Variable<int, IntType>(d.status.value);
    }
    if (d.inputData.present) {
      map['input_data'] = Variable<String, StringType>(d.inputData.value);
    }
    if (d.latitude.present) {
      map['latitude'] = Variable<double, RealType>(d.latitude.value);
    }
    if (d.longitude.present) {
      map['longitude'] = Variable<double, RealType>(d.longitude.value);
    }
    return map;
  }

  @override
  $UsageLogsTable createAlias(String alias) {
    return $UsageLogsTable(_db, alias);
  }
}

class RevokePass extends DataClass implements Insertable<RevokePass> {
  final int id;
  final int timestamp;
  final String controlCode;
  RevokePass(
      {@required this.id,
      @required this.timestamp,
      @required this.controlCode});
  factory RevokePass.fromData(Map<String, dynamic> data, GeneratedDatabase db,
      {String prefix}) {
    final effectivePrefix = prefix ?? '';
    final intType = db.typeSystem.forDartType<int>();
    final stringType = db.typeSystem.forDartType<String>();
    return RevokePass(
      id: intType.mapFromDatabaseResponse(data['${effectivePrefix}id']),
      timestamp:
          intType.mapFromDatabaseResponse(data['${effectivePrefix}timestamp']),
      controlCode: stringType
          .mapFromDatabaseResponse(data['${effectivePrefix}control_code']),
    );
  }
  factory RevokePass.fromJson(Map<String, dynamic> json,
      {ValueSerializer serializer}) {
    serializer ??= moorRuntimeOptions.defaultSerializer;
    return RevokePass(
      id: serializer.fromJson<int>(json['id']),
      timestamp: serializer.fromJson<int>(json['timestamp']),
      controlCode: serializer.fromJson<String>(json['controlCode']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer serializer}) {
    serializer ??= moorRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'timestamp': serializer.toJson<int>(timestamp),
      'controlCode': serializer.toJson<String>(controlCode),
    };
  }

  @override
  RevokePassesCompanion createCompanion(bool nullToAbsent) {
    return RevokePassesCompanion(
      id: id == null && nullToAbsent ? const Value.absent() : Value(id),
      timestamp: timestamp == null && nullToAbsent
          ? const Value.absent()
          : Value(timestamp),
      controlCode: controlCode == null && nullToAbsent
          ? const Value.absent()
          : Value(controlCode),
    );
  }

  RevokePass copyWith({int id, int timestamp, String controlCode}) =>
      RevokePass(
        id: id ?? this.id,
        timestamp: timestamp ?? this.timestamp,
        controlCode: controlCode ?? this.controlCode,
      );
  @override
  String toString() {
    return (StringBuffer('RevokePass(')
          ..write('id: $id, ')
          ..write('timestamp: $timestamp, ')
          ..write('controlCode: $controlCode')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => $mrjf(
      $mrjc(id.hashCode, $mrjc(timestamp.hashCode, controlCode.hashCode)));
  @override
  bool operator ==(dynamic other) =>
      identical(this, other) ||
      (other is RevokePass &&
          other.id == this.id &&
          other.timestamp == this.timestamp &&
          other.controlCode == this.controlCode);
}

class RevokePassesCompanion extends UpdateCompanion<RevokePass> {
  final Value<int> id;
  final Value<int> timestamp;
  final Value<String> controlCode;
  const RevokePassesCompanion({
    this.id = const Value.absent(),
    this.timestamp = const Value.absent(),
    this.controlCode = const Value.absent(),
  });
  RevokePassesCompanion.insert({
    this.id = const Value.absent(),
    @required int timestamp,
    @required String controlCode,
  })  : timestamp = Value(timestamp),
        controlCode = Value(controlCode);
  RevokePassesCompanion copyWith(
      {Value<int> id, Value<int> timestamp, Value<String> controlCode}) {
    return RevokePassesCompanion(
      id: id ?? this.id,
      timestamp: timestamp ?? this.timestamp,
      controlCode: controlCode ?? this.controlCode,
    );
  }
}

class $RevokePassesTable extends RevokePasses
    with TableInfo<$RevokePassesTable, RevokePass> {
  final GeneratedDatabase _db;
  final String _alias;
  $RevokePassesTable(this._db, [this._alias]);
  final VerificationMeta _idMeta = const VerificationMeta('id');
  GeneratedIntColumn _id;
  @override
  GeneratedIntColumn get id => _id ??= _constructId();
  GeneratedIntColumn _constructId() {
    return GeneratedIntColumn('id', $tableName, false,
        hasAutoIncrement: true, declaredAsPrimaryKey: true);
  }

  final VerificationMeta _timestampMeta = const VerificationMeta('timestamp');
  GeneratedIntColumn _timestamp;
  @override
  GeneratedIntColumn get timestamp => _timestamp ??= _constructTimestamp();
  GeneratedIntColumn _constructTimestamp() {
    return GeneratedIntColumn(
      'timestamp',
      $tableName,
      false,
    );
  }

  final VerificationMeta _controlCodeMeta =
      const VerificationMeta('controlCode');
  GeneratedTextColumn _controlCode;
  @override
  GeneratedTextColumn get controlCode =>
      _controlCode ??= _constructControlCode();
  GeneratedTextColumn _constructControlCode() {
    return GeneratedTextColumn(
      'control_code',
      $tableName,
      false,
    );
  }

  @override
  List<GeneratedColumn> get $columns => [id, timestamp, controlCode];
  @override
  $RevokePassesTable get asDslTable => this;
  @override
  String get $tableName => _alias ?? 'revoke_passes';
  @override
  final String actualTableName = 'revoke_passes';
  @override
  VerificationContext validateIntegrity(RevokePassesCompanion d,
      {bool isInserting = false}) {
    final context = VerificationContext();
    if (d.id.present) {
      context.handle(_idMeta, id.isAcceptableValue(d.id.value, _idMeta));
    }
    if (d.timestamp.present) {
      context.handle(_timestampMeta,
          timestamp.isAcceptableValue(d.timestamp.value, _timestampMeta));
    } else if (isInserting) {
      context.missing(_timestampMeta);
    }
    if (d.controlCode.present) {
      context.handle(_controlCodeMeta,
          controlCode.isAcceptableValue(d.controlCode.value, _controlCodeMeta));
    } else if (isInserting) {
      context.missing(_controlCodeMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RevokePass map(Map<String, dynamic> data, {String tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : null;
    return RevokePass.fromData(data, _db, prefix: effectivePrefix);
  }

  @override
  Map<String, Variable> entityToSql(RevokePassesCompanion d) {
    final map = <String, Variable>{};
    if (d.id.present) {
      map['id'] = Variable<int, IntType>(d.id.value);
    }
    if (d.timestamp.present) {
      map['timestamp'] = Variable<int, IntType>(d.timestamp.value);
    }
    if (d.controlCode.present) {
      map['control_code'] = Variable<String, StringType>(d.controlCode.value);
    }
    return map;
  }

  @override
  $RevokePassesTable createAlias(String alias) {
    return $RevokePassesTable(_db, alias);
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(SqlTypeSystem.defaultInstance, e);
  $ValidPassesTable _validPasses;
  $ValidPassesTable get validPasses => _validPasses ??= $ValidPassesTable(this);
  $InvalidPassesTable _invalidPasses;
  $InvalidPassesTable get invalidPasses =>
      _invalidPasses ??= $InvalidPassesTable(this);
  $UsageLogsTable _usageLogs;
  $UsageLogsTable get usageLogs => _usageLogs ??= $UsageLogsTable(this);
  $RevokePassesTable _revokePasses;
  $RevokePassesTable get revokePasses =>
      _revokePasses ??= $RevokePassesTable(this);
  @override
  Iterable<TableInfo> get allTables => allSchemaEntities.whereType<TableInfo>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [validPasses, invalidPasses, usageLogs, revokePasses];
}
