import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:moor/moor.dart';

part 'app_database.g.dart';

/// Remember to generate the code using
/// ```
/// flutter packages pub run build_runner build --delete-conflicting-outputs
/// ```
/// Or
/// ```
/// flutter packages pub run build_runner watch --delete-conflicting-outputs
/// ```
@DataClassName('ValidPass')
class ValidPasses extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get passType => integer()();

  TextColumn get apor => text().nullable()();

  IntColumn get controlCode => integer().customConstraint('UNIQUE')();

  IntColumn get validFrom => integer().nullable()();

  IntColumn get validUntil => integer().nullable()();

  TextColumn get idType => text().nullable()();

  TextColumn get idOrPlate => text().nullable()();

  TextColumn get company => text().nullable()();

  TextColumn get homeAddress => text().nullable()();

  TextColumn get status => text().nullable()();
}

@DataClassName('InvalidPass')
class InvalidPasses extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get controlCode => integer()();

  TextColumn get status => text()();
}

@DataClassName('UsageLog')
class UsageLogs extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get timestamp => integer()();

  IntColumn get controlNumber => integer().nullable()();

  IntColumn get mode => integer()();

  IntColumn get status => integer()();

  TextColumn get inputData => text()();

  RealColumn get latitude => real().nullable()();

  RealColumn get longitude => real().nullable()();
}

@DataClassName('RevokePass')
class RevokePasses extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get timestamp => integer()();

  TextColumn get controlCode => text()();
}

@UseMoor(tables: [ValidPasses, InvalidPasses, UsageLogs, RevokePasses])
class AppDatabase extends _$AppDatabase {
  AppDatabase(QueryExecutor executor) : super(executor);

  bool endianStatus = false;

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) {
        return m.createAll();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        debugPrint('onUpgrade(from: $from, to: $to)...');
        // see https://moor.simonbinder.eu/docs/advanced-features/migrations/
        if (from == 1) {
          await m.addColumn(validPasses, validPasses.status);
        }
        if (from <= 2) {
          await m.createTable(usageLogs);
          await m.createTable(revokePasses);
        }
      },
    );
  }

  Future<int> countPasses() async {
    var list = (await select(validPasses).get());
    return list.length;
  }

  Future<ValidPass> getValidPass(final int controlCode) async {
    return await (select(validPasses)
          ..where((u) => u.controlCode.equals(controlCode)))
        .getSingle();
  }

  Future<ValidPass> getValidPassByIdOrPlate(final String idOrPlate) async {
    return await (select(validPasses)
          ..where((u) => u.idOrPlate.equals(idOrPlate)))
        .getSingle();
  }

  Future updateValidPass(final ValidPassesCompanion validPassesCompanion) =>
      update(validPasses).replace(validPassesCompanion);

  Future insertValidPass(final ValidPassesCompanion validPassesCompanion) =>
      into(validPasses).insert(validPassesCompanion);

  Future insertOrUpdateAll(
      final List<ValidPassesCompanion> bulkInsertOrUpdate) {
    return transaction(() {
      List<Future> futures = List();
      for (final vpc in bulkInsertOrUpdate) {
        if (vpc.id != null &&
            vpc.id != Value.absent() &&
            vpc.id.value != null) {
          debugPrint('Updating pass id ${vpc.id.value}');
          futures.add(updateValidPass(vpc));
        } else {
          debugPrint('Inserting pass ${vpc.controlCode.value}');
          futures.add(insertValidPass(vpc));
        }
      }
      return Future.wait(futures);
    });
  }

  Future deleteValidPasses() {
    return delete(validPasses).go();
  }

  Future insertUsageLog(final UsageLogsCompanion usageLogsCompanion) =>
      into(usageLogs).insert(usageLogsCompanion);

  Future<List<UsageLog>> getUsageLogs() async {
    final List<UsageLog> res = (await select(usageLogs).get());

    if (endianStatus) {
      return Future.value(res.map((f) => convertUsageLog(f)).toList());
    } else {
      return Future.value(res);
    }
  }

  Future<List<UsageLog>> getUsageLogsByTimestamp(int start, int end) async {
    final List<UsageLog> res = await (select(usageLogs)
          ..where((t) => t.timestamp.isBetweenValues(start, end)))
        .get();

    if (endianStatus) {
      return Future.value(res.map((f) => convertUsageLog(f)).toList());
    } else {
      return Future.value(res);
    }
  }

  Future<List<UsageLog>> getUsageLogsByControlNumber(int controlNumber) async {
    final List<UsageLog> res = await (select(usageLogs)
          ..where((t) => t.controlNumber.equals(controlNumber)))
        .get();

    if (endianStatus) {
      return Future.value(res.map((f) => convertUsageLog(f)).toList());
    } else {
      return Future.value(res);
    }
  }

  Future deleteUsageLogs() {
    return delete(usageLogs).go();
  }

  Future<int> countRevokePasses() async {
    var list = (await select(revokePasses).get());
    return list.length;
  }

  Future<RevokePass> getRevokePass(final String controlCode) async {
    return await (select(revokePasses)
          ..where((u) => u.controlCode.equals(controlCode)))
        .getSingle();
  }

  Future updateRevokePass(final RevokePassesCompanion revokePassesCompanion) =>
      update(revokePasses).replace(revokePassesCompanion);

  Future insertRevokePass(final RevokePassesCompanion revokePassesCompanion) =>
      into(revokePasses).insert(revokePassesCompanion);

  Future insertOrUpdateAllRevokePasses(
      final List<RevokePassesCompanion> bulkData) {
    return transaction(() {
      List<Future> futures = List();
      for (final data in bulkData) {
        if (data.id != null &&
            data.id != Value.absent() &&
            data.id.value != null) {
          debugPrint('Updating revoke pass id ${data.id.value}');
          futures.add(updateRevokePass(data));
        } else {
          debugPrint('Inserting revoke pass ${data.controlCode.value}');
          futures.add(insertRevokePass(data));
        }
      }
      return Future.wait(futures);
    });
  }

  Future deleteRevokePasses() {
    return delete(revokePasses).go();
  }

  UsageLog convertUsageLog(UsageLog data) {
    return UsageLog(
        id: data.id,
        timestamp: convertEndianUint64(data.timestamp?.toUnsigned(64)),
        controlNumber: convertEndianUint64(data.controlNumber?.toUnsigned(64)),
        mode: convertEndianUint64(data.mode?.toUnsigned(64)),
        status: convertEndianUint64(data.status?.toUnsigned(64)),
        inputData: data.inputData,
        latitude: convertEndianDouble(data.latitude),
        longitude: convertEndianDouble(data.longitude));
  }

  int convertEndianUint64(int value) {
    if (value == null) return null;

    var byteData = new ByteData(8);
    byteData.setUint64(0, value);
    Uint32List uint32List1 = byteData.buffer.asUint32List();
    Uint32List uint32List2 = Uint32List.fromList(
        [uint32List1.elementAt(1), uint32List1.elementAt(0)]);
    byteData = ByteData.view(uint32List2.buffer);
    return byteData.getInt64(0);
  }

  double convertEndianDouble(double value) {
    if (value == null) return null;

    var byteData = new ByteData(8);
    byteData.setFloat64(0, value);
    Uint32List uint32List1 = byteData.buffer.asUint32List();
    Uint32List uint32List2 = Uint32List.fromList(
        [uint32List1.elementAt(1), uint32List1.elementAt(0)]);
    byteData = ByteData.view(uint32List2.buffer);
    return byteData.getFloat64(0);
  }

  Future<bool> checkEndianness() async {
    print('checking database endianness...');

    // make a test write to database
    final int insertId = await into(usageLogs).insert(UsageLog.fromJson({
      'timestamp': 1,
      'controlNumber': 1,
      'inputData': '',
      'mode': 1,
      'status': 1,
      'latitude': 1.0,
      'longitude': 1.0
    }));

    // read the written data
    final List<UsageLog> selectData =
        await ((select(usageLogs)..where((t) => t.timestamp.equals(1))).get());
    selectData.forEach((f) => print(f.toString()));

    // check if data is correct or not
    if (selectData.isNotEmpty && selectData[0].timestamp != 1) {
      endianStatus = true;
    } else {
      endianStatus = false;
    }

    // delete test data
    await ((delete(usageLogs)..where((t) => t.timestamp.equals(1))).go());
    return Future.value(endianStatus);
  }

  void setEndianness(final bool status) {
    endianStatus = status;
  }
}
