import 'package:audioplayers/audio_cache.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:rapidpass_checkpoint/components/flavor_banner.dart';
import 'package:rapidpass_checkpoint/components/pass_results_card.dart';
import 'package:rapidpass_checkpoint/models/apor.dart';
import 'package:rapidpass_checkpoint/models/qr_data.dart';
import 'package:rapidpass_checkpoint/models/scan_results.dart';
import 'package:rapidpass_checkpoint/screens/main_menu.dart';
import 'package:rapidpass_checkpoint/services/usage_log_service.dart';
import 'package:rapidpass_checkpoint/themes/default.dart';

const borderRadius = 12.0;

/// Pass or Fail screen
class ScanResultScreen extends StatefulWidget {
  final ScanResults scanResults;

  const ScanResultScreen(this.scanResults);

  @override
  _ScanResultScreenState createState() => _ScanResultScreenState();
}

class _ScanResultScreenState extends State<ScanResultScreen> {
  @override
  void initState() {
    super.initState();

    if (widget.scanResults.isValid) {
      _playNotificationApproved();
    } else {
      _playNotificationRejected();
    }
  }

  @override
  Widget build(BuildContext context) {
    final scanResults = widget.scanResults;
    final qrData = scanResults.qrData;
    final tableData = qrData != null
        ? {
            RapidPassField.name: qrData.name ?? '',
            RapidPassField.passType: (qrData.passType == PassType.Vehicle)
                ? "V - Vehicle"
                : "I - Individual",
            RapidPassField.controlCode: '${qrData.controlCodeAsString()}',
            RapidPassField.idOrPlate: qrData.idOrPlate,
            RapidPassField.apor: qrData.purpose(),
            RapidPassField.validFrom: qrData.validFromDisplayDate(),
            RapidPassField.validUntil: qrData.validUntilDisplayDate(),
          }
        : {
            RapidPassField.name: '',
            RapidPassField.passType: '',
            RapidPassField.controlCode: '',
            RapidPassField.idOrPlate: '',
            RapidPassField.apor: '',
            RapidPassField.validFrom: '',
            RapidPassField.validUntil: '',
          };
    final passResultsData = tableData.entries.map((e) {
      var field = e.key;
      final String label = (field == RapidPassField.idOrPlate)
          ? (qrData?.passType == PassType.Vehicle)
              ? 'Plate Number'
              : 'ID Number'
          : getFieldName(field);

      String errorMessage;
      final error = scanResults.findErrorForSource(field);
      if (error != null) {
        errorMessage = error.errorMessage;
      }
      final value =
          field == RapidPassField.apor && aporCodes.containsKey(e.value)
              ? aporCodes[e.value] + ' (${e.value})'
              : e.value;

      return error == null
          ? PassResultsTableRow(label: label, value: value)
          : PassResultsTableRow(
              label: label, value: value, errorMessage: errorMessage);
    }).toList();

    final resultMessage = scanResults.resultMessage;
    final resultSubMessage = scanResults.resultSubMessage;
    final notRapidPass = resultMessage == 'NOT A VALID RAPIDPASS QR CODE';
    final card = scanResults.isValid
        ? PassResultsCard(
            iconName: 'check',
            headerText: resultMessage,
            data: passResultsData,
            color: green300)
        : PassResultsCard(
            iconName: 'error',
            headerText: resultMessage,
            subHeaderText: resultSubMessage,
            data: passResultsData,
            color: notRapidPass ? amber : Colors.red,
            allRed: scanResults.allRed,
            headerOnly: resultSubMessage == 'QR CODE INVALID' || notRapidPass);
    return Theme(
        data: Green.buildFor(context),
        child: WillPopScope(
          onWillPop: () async {
            Navigator.popUntil(context, ModalRoute.withName("/menu"));
            return false;
          },
          child: FlavorBanner(
            child: Scaffold(
              appBar: AppBar(title: Text('Result')),
              body: SingleChildScrollView(
                child: Center(
                  child: Column(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20.0, vertical: 10.0),
                        child: card,
                      ),
                      const SizedBox(height: 5),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
//                        if (widget.scanResults.isValid)
//                          InkWell(
//                            onTap: () =>
//                                Navigator.pushNamed(context, '/viewMoreInfo'),
//                            child: Container(
//                              padding: EdgeInsets.symmetric(
//                                  vertical: 13.0, horizontal: 20.0),
//                              child: OutlineButton(
//                                borderSide: BorderSide(color: green300),
//                                highlightedBorderColor: green300,
//                                focusColor: green300,
//                                child: Text('View More Information',
//                                    style: TextStyle(fontSize: 16)),
//                                shape: RoundedRectangleBorder(
//                                  borderRadius: BorderRadius.circular(30.0),
//                                ),
//                                color: green300,
//                                textColor: green300,
//                                padding: EdgeInsets.symmetric(
//                                  horizontal: 16.0,
//                                  vertical: 20.0,
//                                ),
//                                onPressed: () => Navigator.pushNamed(
//                                    context, '/viewMoreInfo'),
//                              ),
//                            ),
//                          ),
                          if (scanResults.isValid)
                            Padding(padding: EdgeInsets.only(top: 16.0)),
                          InkWell(
                            onTap: () => _scanAndNavigate(context),
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  vertical: 15.0, horizontal: 20.0),
                              child: FlatButton(
                                child: Text('Scan another QR',
                                    style: TextStyle(fontSize: 16)),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25.0),
                                ),
                                color: green300,
                                textColor: Colors.white,
                                padding: EdgeInsets.symmetric(vertical: 35.0),
                                onPressed: () => _scanAndNavigate(context),
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: () => Navigator.popUntil(
                                context, ModalRoute.withName('/menu')),
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  vertical: 13.0, horizontal: 20.0),
                              child: OutlineButton(
                                borderSide: BorderSide(color: green300),
                                highlightedBorderColor: green300,
                                focusColor: green300,
                                child: Text('Return to checker page',
                                    style: TextStyle(fontSize: 16)),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30.0),
                                ),
                                color: green300,
                                textColor: green300,
                                padding: EdgeInsets.symmetric(
                                  horizontal: 16.0,
                                  vertical: 20.0,
                                ),
                                onPressed: () => Navigator.popUntil(
                                    context, ModalRoute.withName('/menu')),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ));
  }

  Future _scanAndNavigate(final BuildContext context) async {
    final scanResults = await MainMenu.scanAndValidate(context);

    await UsageLogService.insertUsageLog(context, scanResults);

    if (scanResults == null) {
      Navigator.popUntil(context, ModalRoute.withName("/menu"));
      return;
    }
    if (scanResults is ScanResults) {
      Navigator.popAndPushNamed(context, '/scanResults',
          arguments: scanResults);
    }
  }

  Future<AudioPlayer> _playNotificationApproved() async {
    AudioCache cache = new AudioCache();
    return await cache.play("notification_approved.mp3");
  }

  Future<AudioPlayer> _playNotificationRejected() async {
    AudioCache cache = new AudioCache();
    return await cache.play("notification_denied.mp3");
  }
}
