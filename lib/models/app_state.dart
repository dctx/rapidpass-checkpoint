import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:package_info/package_info.dart';
import 'package:rapidpass_checkpoint/models/usage_stats.dart';
import 'package:rapidpass_checkpoint/services/app_storage.dart';

import 'app_secrets.dart';

class AppState extends ChangeNotifier {
  DateTime _databaseLastUpdated;
  String _masterQrCode;
  AppSecrets _appSecrets;
  PackageInfo _packageInfo;
  dynamic _databaseSyncLog = [];
  int _databaseRecordCount = 0;
  UsageStats stats = UsageStats();

  static final DateFormat dateFormat = DateFormat.yMMMd('en_US').add_jm();

  String get databaseLastUpdatedText => (_databaseLastUpdated != null)
      ? 'Database last updated on ${dateFormat.format(_databaseLastUpdated)}'
      : null;

  DateTime get databaseLastUpdatedDateTime => _databaseLastUpdated ?? null;

  int get databaseLastUpdated => _databaseLastUpdated != null
      ? _databaseLastUpdated.millisecondsSinceEpoch
      : 0;

  set databaseLastUpdated(final int timestamp) {
    debugPrint('databaseLastUpdated($timestamp)');
    this._databaseLastUpdated = timestamp > 0
        ? DateTime.fromMillisecondsSinceEpoch(timestamp * 1000)
        : null;
    notifyListeners();
  }

  dynamic get databaseSyncLog => _databaseSyncLog;

  dynamic addDatabaseSyncLog(Object data) {
    this._databaseSyncLog.add(data);
    notifyListeners();
    return data;
  }

  void clearDatabaseSyncLog() {
    this._databaseSyncLog = [];
    notifyListeners();
  }

  int get databaseRecordCount => _databaseRecordCount;

  set databaseRecordCount(int value) {
    this._databaseRecordCount = value;
    notifyListeners();
  }

  String get masterQrCode => this._masterQrCode;

  set masterQrCode(final String masterQrCode) {
    this._masterQrCode = masterQrCode;
    notifyListeners();
  }

  AppSecrets get appSecrets => this._appSecrets;

  set appSecrets(AppSecrets value) {
    this._appSecrets = value;
    notifyListeners();
  }

  Future<AppSecrets> setAppSecrets(final AppSecrets appSecrets) {
    this._appSecrets = appSecrets;
    return AppStorage.setAppSecrets(appSecrets).then((secrets) {
      notifyListeners();
      return secrets;
    });
  }

  PackageInfo get packageInfo => this._packageInfo;

  set packageInfo(final PackageInfo packageInfo) {
    this._packageInfo = packageInfo;
    notifyListeners();
  }
}
