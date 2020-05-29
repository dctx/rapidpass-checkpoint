import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:package_info/package_info.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:rapidpass_checkpoint/common/constants/rapid_asset_constants.dart';
import 'package:rapidpass_checkpoint/components/flavor_banner.dart';
import 'package:rapidpass_checkpoint/flavor.dart';
import 'package:rapidpass_checkpoint/helpers/dialog_helper.dart';
import 'package:rapidpass_checkpoint/models/app_state.dart';
import 'package:rapidpass_checkpoint/models/user_location.dart';
import 'package:rapidpass_checkpoint/repository/api_repository.dart';
import 'package:rapidpass_checkpoint/screens/credits_screen.dart';
import 'package:rapidpass_checkpoint/screens/qr_scanner_screen.dart';
import 'package:rapidpass_checkpoint/services/app_storage.dart';
import 'package:rapidpass_checkpoint/themes/default.dart';
import 'package:rapidpass_checkpoint/viewmodel/device_info_model.dart';

class WelcomeScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return WelcomeScreenState();
  }
}

class WelcomeScreenState extends State<WelcomeScreen>
    with WidgetsBindingObserver {
  // A list of required permissions to be accepted in order for app to properly run
  List<Permission> _requiredPermissions = [
    Permission.phone,
    Permission.location,
    Permission.camera
  ];

  // A flag to determined if app was navigated away (background) using openAppSettings()
  bool _isFromAppSettings = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    final appState = Provider.of<AppState>(context, listen: false);
    _checkRequiredPermissions();
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      final code = await AppStorage.getMasterQrCode();
      if (code != null) {
        debugPrint("Got masterQrCode: '${code.substring(1, 16)}...'");
        // TODO there must be a cleaner way to do this
        appState.masterQrCode = code;
      }
      appState.packageInfo = await PackageInfo.fromPlatform();

      final apiRepository = Provider.of<ApiRepository>(context, listen: false);
      appState.databaseRecordCount =
          await apiRepository.localDatabaseService.countRevokePasses();

      final appSecrets = await AppStorage.getAppSecrets();
      if (appSecrets != null) {
        appState.appSecrets = appSecrets;
      }

      if (kReleaseMode) {
        final DeviceInfoModel deviceInfoModel =
            Provider.of<DeviceInfoModel>(context, listen: false);
        apiRepository.checkUpdate(appState, deviceInfoModel);
      }

      apiRepository.localDatabaseService.appDatabase.checkEndianness();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    // Will be called when app is in foreground & if it triggered the background activity using openAppSettings()
    if (state == AppLifecycleState.resumed && _isFromAppSettings) {
      _isFromAppSettings = false;
      _checkRequiredPermissions();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Purple.buildFor(context),
      child: FlavorBanner(
        child: Scaffold(
          backgroundColor: deepPurple600,
          body: Container(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(
                      top: MediaQuery.of(context).size.height * 0.07,
                      bottom: MediaQuery.of(context).size.height * 0.05,
                    ),
                    child: InkWell(
                      onDoubleTap: () => Navigator.of(context).push(
                        CreditsScreen(),
                      ),
                      borderRadius: BorderRadius.circular(100),
                      child: SvgPicture.asset(
                        RapidAssetConstants.rapidPassLogo,
                      ),
                    ),
                  ),
                  Text(
                    'Welcome to',
                    style: TextStyle(fontSize: 27.0),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    'RapidPass.ph\nCheckpoint',
                    softWrap: true,
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 32.0),
                    textAlign: TextAlign.center,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 10.0),
                    child: Selector<AppState, PackageInfo>(
                        selector: (_, appState) => appState.packageInfo,
                        builder: (_, PackageInfo packageInfo, __) {
                          if (packageInfo != null) {
                            final String versionText = Flavor.isProduction
                                ? packageInfo.version
                                : '${packageInfo.version}+${packageInfo.buildNumber}';
                            return Text('Version $versionText');
                          } else {
                            return Text('');
                          }
                        }),
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                      top: MediaQuery.of(context).size.height * 0.05,
                    ),
                    child: Consumer<AppState>(
                        builder: (context, appState, child) =>
                            appState.databaseLastUpdatedText != null
                                ? Text(
                                    appState.databaseLastUpdatedText,
                                    style: TextStyle(
                                      fontSize: 15.0,
                                    ),
                                    textAlign: TextAlign.center,
                                  )
                                : Container()),
                  ),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.symmetric(
                              vertical:
                                  MediaQuery.of(context).size.height * 0.02),
                          child: SizedBox(
                            height: 48,
                            width: MediaQuery.of(context).size.width * 0.8,
                            child: Consumer<ApiRepository>(
                              builder: (_, apiRepository, __) => RaisedButton(
                                shape: new RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(24.0)),
                                // only enable the 'Start' button once we have an ApiRepository
                                onPressed: apiRepository != null
                                    ? () => _startButtonPressed(context)
                                    : null,
                                child: Text(
                                  'START',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18.0,
                                    letterSpacing: 1.5,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Selector<DeviceInfoModel, String>(
                          selector: (_, model) => model.deviceId,
                          builder: (_, String deviceId, __) {
                            if (deviceId == null)
                              return Text('Retrieving IMEI...');
                            return Text('DEVICE ID: $deviceId');
                          },
                        ),
                      ],
                    ),
                  ),
                  Container(
                    height: MediaQuery.of(context).size.height * 0.1,
                    padding: EdgeInsets.only(
                      left: MediaQuery.of(context).size.width * 0.05,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        _buildFooter('About'),
                        _buildFooter('Need Help?'),
                        _buildFooter('Privacy Policy'),
                        IconButton(
                          icon: Icon(
                            Icons.settings,
                            color: Colors.white70,
                          ),
                          onPressed: () =>
                              Navigator.pushNamed(context, '/settings'),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _startButtonPressed(final BuildContext context) async {
    final AppState appState = Provider.of<AppState>(context, listen: false);
    debugPrint('_startButtonPressed()');
    if (appState.masterQrCode == null) {
      final code = await Navigator.pushNamed(context, '/scanQr',
          arguments: QrScannerScreenArgs(
              title: 'Scan Master QR Code',
              message:
                  'Position the Master QR image inside the frame. It will scan automatically.'));
      debugPrint("QrScannerScreen returned $code");
      if (code != null) {
        await AppStorage.setMasterQrCode(code).then((_) {
          appState.masterQrCode = code;
          Navigator.pushNamed(context, '/authenticatingScreen');
        });
      }

      // Navigator.pushNamed(context, '/masterQrScannerScreen').then((code) async {
      //   debugPrint("masterQrScannerScreen returned $code");
      //   if (code != null) {
      //     await AppStorage.setMasterQrCode(code).then((_) {
      //       appState.masterQrCode = code;
      //       Navigator.pushNamed(context, '/authenticatingScreen');
      //     });
      //   }
      // });
    } else if (appState.appSecrets == null) {
      var appSecrets = await AppStorage.getAppSecrets();
      if (appSecrets == null) {
        Navigator.pushNamed(context, '/authenticatingScreen');
      } else {
        appState.appSecrets = appSecrets;
        Navigator.pushNamed(context, '/menu');
      }
    } else {
      Navigator.pushNamed(context, '/menu');
    }
  }

  Widget _buildFooter(String title) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context,
          "/${title.replaceAll(' ', '_').replaceAll('?', '').toLowerCase()}"),
      child: Text(
        title,
        style: TextStyle(
            color: Colors.white70,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.0,
            decoration: TextDecoration.underline),
      ),
    );
  }

  void _checkRequiredPermissions() async {
    final Map<Permission, PermissionStatus> permissions =
        await _requiredPermissions.request();
    debugPrint('permissions => $permissions');

    bool isDeniedPermanently = permissions.values
        .any((PermissionStatus status) => status.isPermanentlyDenied);
    if (isDeniedPermanently) return _onPermissionDeniedPermanently();

    bool isAllGranted =
        permissions.values.every((PermissionStatus status) => status.isGranted);
    if (!isAllGranted) return _onPermissionDenied();

    _onAllPermissionGranted();
  }

  void _onAllPermissionGranted() {
    Provider.of<DeviceInfoModel>(context, listen: false).getDeviceId();
    Provider.of<DeviceInfoModel>(context, listen: false).getImei();
    Provider.of<UserLocation>(context, listen: false);
  }

  void _onPermissionDeniedPermanently() {
    DialogHelper.showAlertDialog(context,
        title: 'Some permission was denied permanently',
        message:
            'In order for the app to run properly, you must tap OPEN SETTINGS and grant the CAMERA, LOCATION, and PHONE permission.',
        dismissible: false,
        onWillPop: () async => false,
        cancelText: 'EXIT APP',
        onCancel: () => SystemNavigator.pop(),
        confirmText: 'OPEN SETTINGS',
        onConfirm: () {
          _isFromAppSettings = true;
          openAppSettings();
        });
  }

  void _onPermissionDenied() {
    DialogHelper.showAlertDialog(
      context,
      title: 'Some permission was denied',
      message:
          'In order for the app to run properly, we need you to allow all permissions requested.',
      dismissible: false,
      onWillPop: () async => false,
      cancelText: 'EXIT APP',
      onCancel: () => SystemNavigator.pop(),
      confirmText: 'ALLOW PERMISSIONS',
      onConfirm: () => _checkRequiredPermissions(),
    );
  }
}
