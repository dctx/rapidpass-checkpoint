import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:rapidpass_checkpoint/data/app_database.dart';
import 'package:rapidpass_checkpoint/models/app_state.dart';
import 'package:rapidpass_checkpoint/models/scan_results.dart';
import 'package:rapidpass_checkpoint/models/user_location.dart';
import 'package:rapidpass_checkpoint/repository/api_repository.dart';
import 'package:rapidpass_checkpoint/services/local_database_service.dart';
import 'package:rapidpass_checkpoint/services/pass_validation_service.dart';

class UsageLogInfo {
  final ScanResults scanResult;
  final UsageLog usageLog;

  UsageLogInfo(this.usageLog, this.scanResult);
}

class UsageLogService {
  UsageLogService();

  static Future<void> insertUsageLog(
      final BuildContext context, ScanResults result) async {
    final ApiRepository apiRepository =
        Provider.of<ApiRepository>(context, listen: false);
    final UserLocation userLocation =
        Provider.of<UserLocation>(context, listen: false);

    if (result == null ||
        result.inputData == null ||
        result.mode.value == null ||
        result.status.value == null) {
      return;
    }

    // convert coordinates (floating-point) into q30 format (fixed-point)
    const int fixedPoint_q30 = 1073741824; //2^30
    final int latitude = userLocation?.latitude != null
        ? ((userLocation.latitude / 180) * fixedPoint_q30).truncate()
        : null;
    final int longitude = userLocation?.longitude != null
        ? ((userLocation.longitude / 180) * fixedPoint_q30).truncate()
        : null;

    await apiRepository.localDatabaseService.insertUsageLog(UsageLog.fromJson({
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'controlNumber': result?.qrData?.controlCode,
      'inputData': result.inputData,
      'mode': result.mode.value,
      'status': result.status.value,
      'latitude': latitude,
      'longitude': longitude
    }).createCompanion(true));
  }

  static Future<List<UsageLogInfo>> getUsageLogs24Hour(
      final BuildContext context, int timestamp) async {
    final ApiRepository apiRepository =
        Provider.of<ApiRepository>(context, listen: false);
    final AppState appState = Provider.of<AppState>(context, listen: false);
    final PassValidationService passValidationService =
        Provider.of<PassValidationService>(context, listen: false);

    var logs =
        await apiRepository.localDatabaseService.getUsageLogs24Hours(timestamp);
    List<UsageLogInfo> res = [];

    for (UsageLog log in logs) {
      ScanResults sr;
      if (log.mode == ScanMode.QR_CODE.value) {
        sr = PassValidationService.deserializeAndValidate(
            appState.appSecrets, log.inputData);
      } else if (log.mode == ScanMode.CONTROL_NUMBER.value) {
        sr = await passValidationService
            .checkControlNumber(int.parse(log.inputData));
      } else if (log.mode == ScanMode.PLATE_NUMBER.value) {
        sr = await passValidationService.checkPlateNumber(log.inputData);
      } else if (log.mode == ScanMode.CONTROL_CODE.value) {
        sr = await passValidationService.checkControlCode(log.inputData);
      } else {
        sr = ScanResults(null, status: ScanResultStatus.INVALID_QRCODE);
      }
      res.add(UsageLogInfo(log, sr));
    }
    return res;
  }

  static Future<List<UsageDateLog>> getUsageLogByDate(
      final BuildContext context) async {
    final ApiRepository apiRepository =
        Provider.of<ApiRepository>(context, listen: false);
    return await apiRepository.localDatabaseService.getUsageDateLog();
  }

  static Future<List<UsageLog>> getUsageLogByControlNumber(
      final BuildContext context, int controlNumber) async {
    final ApiRepository apiRepository =
        Provider.of<ApiRepository>(context, listen: false);
    return await apiRepository.localDatabaseService
        .getUsageLogsByControlNumber(controlNumber);
  }

  static Future<void> deleteUsageLog(BuildContext context) {
    final ApiRepository apiRepository =
        Provider.of<ApiRepository>(context, listen: false);
    return apiRepository.localDatabaseService.deleteUsageLogs();
  }
}
