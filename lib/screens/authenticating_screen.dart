import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import 'package:rapidpass_checkpoint/components/flavor_banner.dart';
import 'package:rapidpass_checkpoint/helpers/dialog_helper.dart';
import 'package:rapidpass_checkpoint/models/app_secrets.dart';
import 'package:rapidpass_checkpoint/models/app_state.dart';
import 'package:rapidpass_checkpoint/repository/api_repository.dart';
import 'package:rapidpass_checkpoint/services/api_service.dart';
import 'package:rapidpass_checkpoint/services/app_storage.dart';
import 'package:rapidpass_checkpoint/themes/default.dart';
import 'package:rapidpass_checkpoint/viewmodel/device_info_model.dart';

class AuthenticatingScreen extends StatefulWidget {
  final Function(BuildContext context) onSuccess;
  final Function(BuildContext context) onError;

  AuthenticatingScreen({this.onSuccess, this.onError});

  @override
  State<StatefulWidget> createState() => AuthenticatingScreenState();
}

class AuthenticatingScreenState extends State<AuthenticatingScreen> {
  Future<AppSecrets> _futureAppSecrets;

  @override
  void initState() {
    final ApiRepository apiRepository =
        Provider.of<ApiRepository>(context, listen: false);
    final DeviceInfoModel deviceInfoModel =
        Provider.of<DeviceInfoModel>(context, listen: false);
    final AppState appState = Provider.of<AppState>(context, listen: false);
    _futureAppSecrets = _authenticate(
            apiRepository.apiService,
            deviceInfoModel.deviceId,
            deviceInfoModel.imei,
            appState.masterQrCode)
        .then((appSecrets) {
      appState.setAppSecrets(appSecrets).then((_) => widget.onSuccess(context));
      return appSecrets;
    }).catchError((e) async {
      debugPrint('catchError(${e.toString()})');
      String title = 'Authentication error';
      String message = e.toString();
      if (e is ApiException) {
        message = e.message;
        final statusCode = e.statusCode;
        debugPrint('e.statusCode: $statusCode');
        if (statusCode != null) {
          if (statusCode == 401) {
            appState.masterQrCode = null;
            await AppStorage.resetMasterQrCode();
            message =
                'Unauthorized. Device is not yet registered or Master QR is incorrect. Please contact Administrator.';
          } else if (statusCode >= 500 && statusCode < 600) {
            title = 'Server error';
          }
        }
      }
      await DialogHelper.showAlertDialog(context,
              title: title, message: message)
          .then((_) {
        widget.onError(context);
      });
    });
    super.initState();
  }

  @override
  Widget build(final BuildContext context) {
    return FlavorBanner(
      child: Scaffold(
          appBar: AppBar(title: Text('Connecting to API')),
          body: Center(
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                SpinKitWave(
                  color: deepPurple600,
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 20.0, left: 8.0),
                  child: FutureBuilder<AppSecrets>(
                      future: _futureAppSecrets,
                      builder: (_, snapshot) => Text(snapshot.hasData
                          ? 'Logged in'
                          : 'Authenticating...')),
                )
              ]))),
    );
  }

  Future<AppSecrets> _authenticate(
      final ApiService apiService,
      final String deviceId,
      final String imei,
      final String masterQrCode) async {
    try {
      final String password = apiService.generatePassword(20);
      final AppSecrets appSecrets = await apiService.registerDevice(
          deviceId: deviceId,
          imei: imei,
          masterKey: masterQrCode,
          password: password);
      await apiService
          .loginDevice(deviceId: deviceId, password: password)
          .then((res) {
        appSecrets.accessCode = res;
      });
      return Future.value(appSecrets);
    } catch (e) {
      print('_authenticate() exception');
      rethrow;
    }
  }
}
