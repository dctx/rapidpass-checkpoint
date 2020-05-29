import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:provider/provider.dart';
import 'package:rapidpass_checkpoint/common/constants/rapid_asset_constants.dart';
import 'package:rapidpass_checkpoint/components/flavor_banner.dart';
import 'package:rapidpass_checkpoint/components/rapid_main_menu_button.dart';
import 'package:rapidpass_checkpoint/models/app_state.dart';
import 'package:rapidpass_checkpoint/models/scan_results.dart';
import 'package:rapidpass_checkpoint/models/usage_stats.dart';
import 'package:rapidpass_checkpoint/screens/qr_scanner_screen.dart';
import 'package:rapidpass_checkpoint/services/pass_validation_service.dart';
import 'package:rapidpass_checkpoint/services/usage_log_service.dart';
import 'package:rapidpass_checkpoint/themes/default.dart';

class MainMenuScreen extends StatelessWidget {
  @override
  Widget build(final BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        // However we got here, on 'Back' go back all the way to the Welcome screen
        Navigator.popUntil(context, ModalRoute.withName('/'));
        return Future.value(false);
      },
      child: FlavorBanner(
        child: Scaffold(
          appBar: AppBar(title: Text('RapidPass Checkpoint')),
          body: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  MainMenu(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class MainMenu extends StatelessWidget {
  ProgressDialog progressDialog;

  @override
  Widget build(BuildContext context) {
    progressDialog = ProgressDialog(context, type: ProgressDialogType.Download)
      ..style(
          message: 'Updating Database...',
          borderRadius: 10.0,
          backgroundColor: Colors.white,
          progressWidget: CircularProgressIndicator(),
          elevation: 10.0,
          insetAnimCurve: Curves.easeInOut,
          progress: 0.0,
          maxProgress: 100.0,
          progressTextStyle: TextStyle(
              color: Colors.black, fontSize: 13.0, fontWeight: FontWeight.w400),
          messageTextStyle: TextStyle(
              color: Colors.black,
              fontSize: 19.0,
              fontWeight: FontWeight.w600));
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          RapidMainMenuButton(
            title: 'Scan QR Code',
            iconPath: RapidAssetConstants.icQrCode,
            iconPathInverted: RapidAssetConstants.icQrCodeWhite,
            onPressed: () => _scanAndNavigate(context),
          ),
          FutureBuilder(
              future: _getUsageStats(context),
              builder: (bContext, bSnapshot) {
                if (bSnapshot.connectionState == ConnectionState.done) {
                  return bSnapshot.hasData
                      ? _buildStatsWidget(stats: bSnapshot.data)
                      : CircularProgressIndicator();
                } else {
                  return CircularProgressIndicator();
                }
              }),
          Padding(
            padding: const EdgeInsets.only(top: 40.0, bottom: 20.0),
            child: SizedBox(
              height: 48.0,
              width: 300.0,
              child: RaisedButton(
                color: green300,
                shape: new RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24.0)),
                onPressed: () {
                  debugPrint('Update Database pressed');
                  Navigator.pushNamed(context, '/updateDatabase');
                },
                child: Text('Update Database',
                    style: TextStyle(
                        // Not sure how to get rid of color: Colors.white here
                        color: Colors.white,
                        fontSize: 18.0)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future _scanAndNavigate(final BuildContext context) async {
    final scanResults = await MainMenu.scanAndValidate(context);

    await UsageLogService.insertUsageLog(context, scanResults);

    debugPrint('scanAndValidate() returned $scanResults');
    if (scanResults is ScanResults) {
      Navigator.pushNamed(context, '/scanResults', arguments: scanResults);
    }
  }

  static Future<ScanResults> scanAndValidate(final BuildContext context) async {
    // TODO Make this not timing sensitive
    final AppState appState = Provider.of<AppState>(context, listen: false);
    final PassValidationService passValidationService =
        Provider.of<PassValidationService>(context, listen: false);
    try {
      // final String base64Encoded = await BarcodeScanner.scan();
      final base64Encoded = await Navigator.pushNamed(context, '/scanQr',
          arguments: QrScannerScreenArgs(
              message:
                  'Position the QR image inside the frame. It will scan automatically.'));

      debugPrint('base64Encoded: $base64Encoded');
      if (base64Encoded == null) {
        // 'Back' button pressed on scanner
        return null;
      } else {
        final ScanResults deserializedQrCode =
            PassValidationService.deserializeAndValidate(
                appState.appSecrets, base64Encoded);
        debugPrint('deserializedQrCode.isValid: ${deserializedQrCode.isValid}');
        if (deserializedQrCode.isValid) {
          return await passValidationService
              .checkRevokePass(deserializedQrCode);
        } else {
          return deserializedQrCode;
        }
      }
    } catch (e) {
      debugPrint('Error occured: $e');
    }
    return null;
  }

  Future<UsageStats> _getUsageStats(BuildContext context) {
    final appState = Provider.of<AppState>(context, listen: true);

    // get 12 midnight timestamp today
    int timestampToday = appState.stats
        .getMidnightTimestamp(DateTime.now().millisecondsSinceEpoch ~/ 1000);

    if (appState.stats.oneDay.timestamp == 0 ||
        appState.stats.oneDay.timestamp != timestampToday) {
      // query database and update cached data (appState.stats)
      return UsageLogService.getUsageLogByDate(context).then((res) {
        // get timestamp of last 6 days
        int timestampLastWeek = timestampToday - (60 * 60 * 24 * 6);
        appState.stats.oneDay.timestamp = timestampToday;
        appState.stats.oneWeek.timestamp = timestampLastWeek;
        appState.stats.oneDay.resetStats();
        appState.stats.oneWeek.resetStats();

        res.forEach((final log) {
          if (log.timestamp == timestampToday) {
            appState.stats.oneDay.scanned = log.scanned;
            appState.stats.oneDay.approved = log.approved;
            appState.stats.oneDay.denied = log.denied;
          }
          if ((log.timestamp <= timestampToday) &&
              (log.timestamp >= timestampLastWeek)) {
            appState.stats.oneWeek.scanned += log.scanned;
            appState.stats.oneWeek.approved += log.approved;
            appState.stats.oneWeek.denied += log.denied;
          }
        });
        return appState.stats;
      });
    } else {
      // return cached data (appState.stats) to minimize database query
      return Future.value(appState.stats);
    }
  }

  _buildStatsWidget({final UsageStats stats}) {
    String dateToday =
        '${DateFormat('MMMM dd, yyyy').format(DateTime.fromMillisecondsSinceEpoch(stats.oneDay.timestamp * 1000))}';
    String dateWeek =
        '${DateFormat('MMMM dd, yyyy').format(DateTime.fromMillisecondsSinceEpoch(stats.oneWeek.timestamp * 1000))}';

    return Column(
      children: <Widget>[
        _buildStatsRow(
            title: 'Today ($dateToday)',
            scanned: stats.oneDay.scanned,
            approved: stats.oneDay.approved,
            denied: stats.oneDay.denied),
        _buildStatsRow(
            title: 'This Week ($dateWeek to $dateToday)',
            scanned: stats.oneWeek.scanned,
            approved: stats.oneWeek.approved,
            denied: stats.oneWeek.denied)
      ],
    );
  }

  _buildStatsRow({title, scanned, approved, denied}) {
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 40.0, 0, 10.0),
          child: Text(
            title,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        Container(
          height: 70.0,
          child: Row(
            children: <Widget>[
              _buildStatsColumn('SCANNED', '$scanned', false),
              _buildStatsColumn('APPROVED', '$approved', true),
              _buildStatsColumn('DENIED', '$denied', false),
            ],
          ),
        )
      ],
    );
  }

  _buildStatsColumn(name, value, isCenter) {
    return Expanded(
        flex: 1,
        child: Center(
            child: Container(
          constraints: BoxConstraints.expand(),
          decoration: BoxDecoration(
              border: Border(
                  top: BorderSide(width: 1.0, color: green300),
                  bottom: BorderSide(width: 1.0, color: green300),
                  left: isCenter
                      ? BorderSide(width: 1.0, color: green300)
                      : BorderSide.none,
                  right: isCenter
                      ? BorderSide(width: 1.0, color: green300)
                      : BorderSide.none)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(name),
              SizedBox(
                height: 8.0,
              ),
              Text(
                value,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ],
          ),
        )));
  }
}
