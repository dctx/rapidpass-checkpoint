import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import 'package:rapidpass_checkpoint/helpers/dialog_helper.dart';
import 'package:rapidpass_checkpoint/models/app_secrets.dart';
import 'package:rapidpass_checkpoint/models/app_state.dart';
import 'package:rapidpass_checkpoint/repository/api_repository.dart';
import 'package:rapidpass_checkpoint/services/api_service.dart';
import 'package:rapidpass_checkpoint/services/app_storage.dart';
import 'package:rapidpass_checkpoint/themes/default.dart';
import 'package:rapidpass_checkpoint/viewmodel/device_info_model.dart';

class AuthenticatingScreen extends StatefulWidget {
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
    _futureAppSecrets = _authenticate(apiRepository.apiService,
            deviceInfoModel.imei, appState.masterQrCode)
        .then((appSecrets) {
      appState
          .setAppSecrets(appSecrets)
          .then((_) => Navigator.pushReplacementNamed(context, '/menu'));
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
                'Unauthorized. Please try scanning the master QR code again.';
          } else if (statusCode >= 500 && statusCode < 600) {
            title = 'Server error';
          }
        }
      }
      await DialogHelper.showAlertDialog(context,
              title: title, message: message)
          .then((_) {
        Navigator.popUntil(context, ModalRoute.withName('/'));
      });
    });
    super.initState();
  }

  @override
  Widget build(final BuildContext context) {
    return Scaffold(
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
                    builder: (_, snapshot) => Text(
                        snapshot.hasData ? 'Logged in' : 'Authenticating...')),
              )
            ])));
  }

  Future<AppSecrets> _authenticate(final ApiService apiService,
      final String imei, final String masterQrCode) async {
    return apiService.authenticateDevice(imei: imei, masterKey: masterQrCode);
  }
}
