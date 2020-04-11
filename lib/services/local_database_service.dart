import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:meta/meta.dart';
import 'package:moor/moor.dart';
import 'package:rapidpass_checkpoint/data/app_database.dart';
import 'package:rapidpass_checkpoint/models/control_code.dart';
import 'package:rapidpass_checkpoint/services/app_storage.dart';
import 'package:rapidpass_checkpoint/utils/aes.dart';

abstract class ILocalDatabaseService {
  Future<int> countPasses();
  Future<ValidPass> getValidPassByIdOrPlate(final String idOrPlate);
  Future<ValidPass> getValidPassByStringControlCode(final String controlCode);
  Future<ValidPass> getValidPassByIntegerControlCode(final int controlNumber);
  Future<int> insertValidPass(final ValidPassesCompanion companion);
  Future bulkInsertOrUpdate(final List<ValidPassesCompanion> forInserting);
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
}
