import 'dart:async';

import 'package:flutter/material.dart';
import 'package:rapidpass_checkpoint/common/constants/rapid_asset_constants.dart';
import 'package:rapidpass_checkpoint/components/rapid_main_menu_button.dart';
import 'package:rapidpass_checkpoint/models/scan_results.dart';
import 'package:rapidpass_checkpoint/services/pass_validation_service.dart';
import 'package:rapidpass_checkpoint/themes/default.dart';

class MainMenuScreen extends StatelessWidget {
  final String checkPointName;

  MainMenuScreen(this.checkPointName);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('RapidPass Checkpoint')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            MainMenu(),
          ],
        ),
      ),
    );
  }
}

class CheckPointWidget extends StatelessWidget {
  final String checkPointName;

  CheckPointWidget(this.checkPointName);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              'RapidPass Checkpoint:',
              textAlign: TextAlign.left,
              style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                  color: deepPurple600),
            ),
          ),
          Container(
            width: 320.0,
            height: 50.0,
            decoration: BoxDecoration(color: deepPurple600),
            child: Center(
              child: Text(
                this.checkPointName,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class MainMenu extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Text(
            "CHECK VIA:",
            style: Theme.of(context)
                .textTheme
                .body1
                .copyWith(fontWeight: FontWeight.bold),
          ),
          RapidMainMenuButton(
            title: 'Scan QR Code',
            iconPath: RapidAssetConstants.icQrCode,
            onPressed: () => _scanAndNavigate(context),
          ),
          RapidMainMenuButton(
            title: 'Plate Number',
            iconPath: RapidAssetConstants.icPlateNubmer,
            onPressed: () {
              Navigator.pushNamed(context, "/checkPlateNumber");
            },
          ),
          RapidMainMenuButton(
            title: 'Control Code',
            iconPath: RapidAssetConstants.icControlCode,
            onPressed: () {
              Navigator.pushNamed(context, '/checkControlCode');
            },
          ),
        ],
      ),
    );
  }

  Future _scanAndNavigate(final BuildContext context) async {
    final scanResults = await scanAndValidate(context);
    if (scanResults != null) {
      Navigator.pushNamed(context, '/scanResults', arguments: scanResults);
    }
  }

  static Future<ScanResults> scanAndValidate(final BuildContext context) async {
    final base64Encoded = await Navigator.pushNamed(context, '/scanQrCode');
    if (base64Encoded != null) {
      return PassValidationService.deserializeAndValidate(base64Encoded);
    }
  }

  static void _showDialog(BuildContext context, {String title, String body}) {
    // flutter defined function
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text(title),
          content: new Text(body),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new FlatButton(
              child: new Text("Close"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
