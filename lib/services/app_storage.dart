import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:rapidpass_checkpoint/models/app_secrets.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppStorage {
  // Create storage
  static final secureStorage = new FlutterSecureStorage();

  static const _masterQrCodeKey = 'rapidPass.masterQrCode';
  static const _databaseEncryptionKeyKey = 'rapidPass.databaseEncryptionKey';
  static const _signingKeyKey = 'rapidPass.signingKey';
  static const _encryptionKeyKey = 'rapidPass.encryptionKey';
  static const _accessCodeKey = 'rapidPass.accessCode';
  static const _accessPassword = 'rapidPass.accessPassword';
  static const _lastSyncOnKey = 'revokeLastSyncOn';
  static const _databaseSyncLogKey = "revokeSyncLog";

  static Future<void> setMasterQrCode(final String masterQrCode) async {
    if (masterQrCode == null) return;
    return secureStorage.write(key: _masterQrCodeKey, value: masterQrCode);
  }

  static Future<void> resetMasterQrCode() {
    return secureStorage.delete(key: _masterQrCodeKey);
  }

  static Future<String> getMasterQrCode() {
    return secureStorage.read(key: _masterQrCodeKey);
  }

  static Future<int> getLastSyncOn() =>
      SharedPreferences.getInstance().then((prefs) =>
          prefs.containsKey(_lastSyncOnKey) ? prefs.getInt(_lastSyncOnKey) : 0);

  static Future<int> setLastSyncOn(int timestamp) {
    timestamp = timestamp ~/ 1000;
    return SharedPreferences.getInstance().then((prefs) =>
        prefs.setInt(_lastSyncOnKey, timestamp).then((_) => timestamp));
  }

  static Future<int> setLastSyncOnToNow() {
    final DateTime now = DateTime.now();
    final int timestamp = now.millisecondsSinceEpoch ~/ 1000;
    debugPrint('timestamp: $timestamp');
    return SharedPreferences.getInstance().then((prefs) =>
        prefs.setInt(_lastSyncOnKey, timestamp).then((_) => timestamp));
  }

  static Future<dynamic> addDatabaseSyncLog(obj) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Map<String, dynamic> jsonObj = Map<String, dynamic>();
    String jsonStr = prefs.containsKey(_databaseSyncLogKey)
        ? prefs.getString(_databaseSyncLogKey)
        : '{}';

    try {
      jsonObj = json.decode(jsonStr);
    } catch (e) {
      debugPrint('addDatabaseSyncLog() exception:' + e.toString());
      jsonObj = {};
    }

    if (jsonObj['records'] == null) {
      jsonObj['records'] = [];
    }
    jsonObj['records'].add(obj);
    prefs.setString(_databaseSyncLogKey, json.encode(jsonObj));
    return obj;
  }

  static Future<dynamic> getDatabaseSyncLog() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Map<String, dynamic> jsonObj = Map<String, dynamic>();
    String jsonStr = prefs.containsKey(_databaseSyncLogKey)
        ? prefs.getString(_databaseSyncLogKey)
        : '{}';

    try {
      jsonObj = json.decode(jsonStr);
    } catch (e) {
      debugPrint('getDatabaseSyncLog() exception:' + e.toString());
      jsonObj = {};
    }

    if (jsonObj['records'] == null) {
      jsonObj['records'] = [];
    }
    return jsonObj['records'];
  }

  static Future<void> clearDatabaseSyncLog() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Map<String, dynamic> jsonObj = Map<String, dynamic>();
    String jsonStr = prefs.containsKey(_databaseSyncLogKey)
        ? prefs.getString(_databaseSyncLogKey)
        : '{}';

    try {
      jsonObj = json.decode(jsonStr);
    } catch (e) {
      debugPrint('addDatabaseSyncLog() exception:' + e.toString());
      jsonObj = {};
    }

    jsonObj['records'] = [];
    prefs.setString(_databaseSyncLogKey, json.encode(jsonObj));
  }

  static Future<AppSecrets> setAppSecrets(final AppSecrets appSecrets) {
    return Future.wait([
      secureStorage.write(key: _signingKeyKey, value: appSecrets.signingKey),
      secureStorage.write(
          key: _encryptionKeyKey, value: appSecrets.encryptionKey),
      secureStorage.write(key: _accessCodeKey, value: appSecrets.accessCode),
      secureStorage.write(key: _accessPassword, value: appSecrets.password)
    ]).then((_) {
      debugPrint('AppSecrets saved!');
      return appSecrets;
    });
  }

  static Future<AppSecrets> getAppSecrets() {
    return Future.wait([
      secureStorage.read(key: _signingKeyKey),
      secureStorage.read(key: _encryptionKeyKey),
      secureStorage.read(key: _accessCodeKey),
      secureStorage.read(key: _accessPassword)
    ]).then((res) {
      debugPrint('appSecrets: ' + res.toString());

      if (res[0] == null || res[1] == null || res[2] == null) {
        return null;
      } else {
        return AppSecrets(
            signingKey: res[0],
            encryptionKey: res[1],
            accessCode: res[2],
            password: res[3]);
      }
    }).catchError((e) {
      throw (null);
    });
  }

  static Future<Uint8List> getDatabaseEncryptionKey() =>
      secureStorage.read(key: _databaseEncryptionKeyKey).then((value) {
        if (value != null) {
          return Base64Codec().decode(value);
        } else {
          final Uint8List key = generateRandomEncryptionKey();
          final String encodedKey = Base64Codec().encode(key);
          debugPrint('Generated key: $key');
          secureStorage.write(
              key: _databaseEncryptionKeyKey, value: encodedKey);
          return key;
        }
      });

  @visibleForTesting
  static Uint8List generateRandomEncryptionKey() {
    final Random random = Random.secure();
    return Uint8List.fromList(
        List<int>.generate(16, (i) => random.nextInt(256)));
  }
}
