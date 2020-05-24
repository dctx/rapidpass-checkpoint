import 'package:device_info/device_info.dart';
import 'package:flutter/material.dart';
import 'package:imei_plugin/imei_plugin.dart';

class DeviceInfoModel extends ChangeNotifier {
  String _imei;
  String get imei => _imei;
  String _deviceId;
  String get deviceId => _deviceId;

  DeviceInfoModel() {
    debugPrint('initialized imei => $_imei');
  }

  Future<String> getImei() async {
    _imei = await ImeiPlugin.getImei();
    debugPrint('imei => $_imei');
    notifyListeners();
    return _imei;
  }

  Future<String> getDeviceId() async {
    AndroidDeviceInfo androidInfo = await DeviceInfoPlugin().androidInfo;
    debugPrint(
        'Device Manufacturer - ${androidInfo.manufacturer}, Model : ${androidInfo.brand} ${androidInfo.model}, Android Version : ${androidInfo.version.release}');

    _deviceId = androidInfo.androidId.toUpperCase();
    debugPrint('deviceId => $_deviceId');
    return _deviceId;
  }
}
