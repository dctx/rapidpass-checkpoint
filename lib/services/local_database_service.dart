import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:meta/meta.dart';
import 'package:moor/moor.dart';
import 'package:rapidpass_checkpoint/data/app_database.dart';
import 'package:rapidpass_checkpoint/models/control_code.dart';
import 'package:rapidpass_checkpoint/models/scan_results.dart';
import 'package:rapidpass_checkpoint/services/app_storage.dart';
import 'package:rapidpass_checkpoint/utils/aes.dart';

abstract class ILocalDatabaseService {
  Future<int> countPasses();

  Future<ValidPass> getValidPassByIdOrPlate(final String idOrPlate);

  Future<ValidPass> getValidPassByStringControlCode(final String controlCode);

  Future<ValidPass> getValidPassByIntegerControlCode(final int controlNumber);

  Future<int> insertValidPass(final ValidPassesCompanion companion);

  Future bulkInsertOrUpdate(final List<ValidPassesCompanion> forInserting);

  Future deleteValidPasses();

  Future<List<UsageLog>> getUsageLogs();

  Future<List<UsageLog>> getUsageLogs24Hours(int timestamp);

  Future<List<UsageLog>> getUsageLogsByControlNumber(int controlNumber);

  Future<List<UsageDateLog>> getUsageDateLog();

  Future<int> insertUsageLog(final UsageLogsCompanion companion);

  Future deleteUsageLogs();

  Future<int> countRevokePasses();

  Future<RevokePass> getRevokePass(final String controlCode);

  Future<int> insertRevokePass(final RevokePassesCompanion companion);

  Future bulkInsertOrUpdateRevokePasses(
      final List<RevokePassesCompanion> forInserting);

  Future deleteRevokePasses();

  void dispose();
}

// TODO: Additional logic while retrieving the data from local db should be placed here
class LocalDatabaseService implements ILocalDatabaseService {
  final Uint8List encryptionKey;
  final AppDatabase appDatabase;

  LocalDatabaseService(
      {@required this.encryptionKey, @required this.appDatabase});

  @override
  Future<ValidPass> getValidPassByStringControlCode(final String controlCode) {
    return getValidPassByIntegerControlCode(ControlCode.decode(controlCode));
  }

  @override
  Future<ValidPass> getValidPassByIntegerControlCode(
      final int controlCodeAsInt) {
    debugPrint(
        'getValidPassByIntegerControlCode($controlCodeAsInt [${ControlCode.encode(controlCodeAsInt)}])');
    return appDatabase.getValidPass(controlCodeAsInt).then((validPass) async {
      debugPrint('validPass: $validPass');
      if (validPass == null) {
        return null;
      } else {
        final Uint8List encryptionKey =
            await AppStorage.getDatabaseEncryptionKey();
        return decryptIdOrPlate(encryptionKey, validPass);
      }
    });
  }

  @override
  Future<ValidPass> getValidPassByIdOrPlate(final String idOrPlate) async {
    debugPrint("LocalDatabaseService.getValidPassByIdOrPlate('$idOrPlate')");
    final Uint8List encryptionKey = await AppStorage.getDatabaseEncryptionKey();
    final String encryptedIdOrPlate =
        encryptIdOrPlateValue(encryptionKey, idOrPlate);
    debugPrint("encryptedIdOrPlate: '$encryptedIdOrPlate'");
    return appDatabase
        .getValidPassByIdOrPlate(encryptedIdOrPlate)
        .then((validPass) async {
      debugPrint('validPass: $validPass');
      if (validPass == null) {
        return null;
      } else {
        return decryptIdOrPlate(encryptionKey, validPass);
      }
    });
  }

  // Close and clear all expensive resources needed as this class gets killed.
  @override
  void dispose() async {
    await appDatabase.close();
  }

  @override
  Future<int> insertValidPass(final ValidPassesCompanion companion) async {
    final Uint8List encryptionKey = await AppStorage.getDatabaseEncryptionKey();
    final ValidPassesCompanion encrypted =
        encryptIdOrPlate(encryptionKey, companion);
    return appDatabase.insertValidPass(encrypted);
  }

  static String encryptIdOrPlateValue(
      final Uint8List encryptionKey, final String value) {
    final Uint8List plainText = utf8.encode(value);
    final Uint8List encrypted =
        Aes.encrypt(key: encryptionKey, plainText: plainText);
    return Base64Encoder().convert(encrypted);
  }

  static String decryptIdOrPlateValue(
      final Uint8List encryptionKey, final String encryptedValue) {
    final Uint8List cipherText = Base64Decoder().convert(encryptedValue);
    final decrypted = Aes.decrypt(key: encryptionKey, cipherText: cipherText);
    return utf8.decode(decrypted);
  }

  ValidPassesCompanion encryptIdOrPlate(
      final Uint8List encryptionKey, final ValidPassesCompanion companion) {
    if (companion == null) {
      return null;
    }
    if (companion.idOrPlate == null ||
        companion.idOrPlate == Value.absent() ||
        companion.idOrPlate.value == null) {
      return companion.copyWith(idOrPlate: Value.absent());
    }
    final String encryptedValue =
        encryptIdOrPlateValue(encryptionKey, companion.idOrPlate.value);
    return companion.copyWith(idOrPlate: Value(encryptedValue));
  }

  ValidPass decryptIdOrPlate(
      final Uint8List encryptionKey, final ValidPass validPass) {
    if (validPass == null) {
      return validPass;
    }
    if (validPass.idOrPlate == null || validPass.idOrPlate.isEmpty) {
      return validPass;
    }
    final String idOrPlate =
        decryptIdOrPlateValue(encryptionKey, validPass.idOrPlate);
    return validPass.copyWith(idOrPlate: idOrPlate);
  }

  @override
  Future<int> countPasses() async {
    return appDatabase.countPasses();
  }

  @override
  Future bulkInsertOrUpdate(
      final List<ValidPassesCompanion> forInserting) async {
    final futures = forInserting.map((fi) =>
        getValidPassByIntegerControlCode(fi.controlCode.value).then((existing) {
          if (existing == null) {
            return encryptIdOrPlate(this.encryptionKey, fi);
          } else {
            debugPrint('existing: $existing');
            final ValidPassesCompanion forUpdate =
                fi.copyWith(id: Value(existing.id));
            return encryptIdOrPlate(this.encryptionKey, forUpdate);
          }
        }));
    return Future.wait(futures.toList()).then((bulkInsertOrUpdate) =>
        appDatabase.insertOrUpdateAll(bulkInsertOrUpdate));
  }

  @override
  Future deleteValidPasses() {
    return appDatabase.deleteValidPasses();
  }

  @override
  Future deleteUsageLogs() {
    return appDatabase.deleteUsageLogs();
  }

  @override
  Future<List<UsageLog>> getUsageLogs() {
    return appDatabase.getUsageLogs();
  }

  @override
  Future<List<UsageLog>> getUsageLogs24Hours(int timestamp) {
    return appDatabase.getUsageLogsByTimestamp(
        timestamp, timestamp + (1000 * 60 * 60 * 24));
  }

  @override
  Future<List<UsageLog>> getUsageLogsByControlNumber(int controlNumber) {
    return appDatabase.getUsageLogsByControlNumber(controlNumber);
  }

  @override
  Future<List<UsageDateLog>> getUsageDateLog() async {
    List<UsageLog> res = await appDatabase.getUsageLogs();
    const int milliseconds1Hour = 1000 * 60 * 60;

    // group per day starting from 12 midnight of current timezone
    final int timeZoneOffset = DateTime.now().timeZoneOffset.inHours;
    dynamic stats = {};
    for (UsageLog log in res) {
      int date = (log.timestamp + (milliseconds1Hour * timeZoneOffset)) ~/
          (milliseconds1Hour * 24);
      String key = ((date * (milliseconds1Hour * 24)) -
              (milliseconds1Hour * timeZoneOffset))
          .toString();
      if (stats[key] == null) {
        stats[key] = {};
        stats[key]['scanned'] = 0;
        stats[key]['approved'] = 0;
        stats[key]['denied'] = 0;
      }

      stats[key]['scanned']++;
      if (log.status == ScanResultStatus.ENTRY_APPROVED.value) {
        stats[key]['approved']++;
      } else {
        stats[key]['denied']++;
      }
    }

    List<UsageDateLog> usageDateLog = [];
    stats.forEach((final key, final value) {
      usageDateLog.add(UsageDateLog(
          timestamp: int.parse(key),
          scanned: value['scanned'],
          approved: value['approved'],
          denied: value['denied']));
    });
    return usageDateLog;
  }

  @override
  Future<int> insertUsageLog(UsageLogsCompanion companion) {
    return appDatabase.insertUsageLog(companion);
  }

  @override
  Future<int> countRevokePasses() async {
    return appDatabase.countRevokePasses();
  }

  @override
  Future<RevokePass> getRevokePass(final String controlCode) {
    return appDatabase.getRevokePass(controlCode).then((revokePass) async {
      if (revokePass == null) {
        return null;
      } else {
        return revokePass;
      }
    });
  }

  @override
  Future<int> insertRevokePass(final RevokePassesCompanion companion) async {
    return appDatabase.insertRevokePass(companion);
  }

  @override
  Future bulkInsertOrUpdateRevokePasses(
      final List<RevokePassesCompanion> forInserting) async {
    final futures = forInserting
        .map((fi) => getRevokePass(fi.controlCode.value).then((existing) {
              if (existing == null) {
                return fi;
              } else {
                debugPrint('existing: $existing');
                final RevokePassesCompanion forUpdate =
                    fi.copyWith(id: Value(existing.id));
                return forUpdate;
              }
            }));
    return Future.wait(futures.toList()).then((bulkInsertOrUpdate) =>
        appDatabase.insertOrUpdateAllRevokePasses(bulkInsertOrUpdate));
  }

  @override
  Future deleteRevokePasses() async {
    return appDatabase.deleteRevokePasses();
  }
}

class UsageDateLog {
  int timestamp;
  int scanned;
  int approved;
  int denied;

  UsageDateLog({this.timestamp, this.scanned, this.approved, this.denied});

  @override
  String toString() {
    return '{ timestamp: ${timestamp.toString()}, scanned:${scanned.toString()}, approved:${approved.toString()}, denied:${denied.toString()} }';
  }
}
