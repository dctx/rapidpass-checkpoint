import 'package:flutter/foundation.dart';
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

@UseMoor(tables: [ValidPasses, InvalidPasses, UsageLogs])
class AppDatabase extends _$AppDatabase {
  AppDatabase(QueryExecutor executor) : super(executor);

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

  Future<List<UsageLog>> getUsageLogs() => (select(usageLogs).get());

  Future<List<UsageLog>> getUsageLogsByTimestamp(int start, int end) =>
      (select(usageLogs)..where((t) => t.timestamp.isBetweenValues(start, end)))
          .get();

  Future<List<UsageLog>> getUsageLogsByControlNumber(int controlNumber) =>
      (select(usageLogs)..where((t) => t.controlNumber.equals(controlNumber)))
          .get();

  Future deleteUsageLogs() => delete(usageLogs).go();
}
