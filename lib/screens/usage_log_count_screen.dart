import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rapidpass_checkpoint/components/flavor_banner.dart';
import 'package:rapidpass_checkpoint/data/app_database.dart';
import 'package:rapidpass_checkpoint/models/apor.dart';
import 'package:rapidpass_checkpoint/models/qr_data.dart';
import 'package:rapidpass_checkpoint/models/scan_results.dart';
import 'package:rapidpass_checkpoint/services/usage_log_service.dart';
import 'package:rapidpass_checkpoint/themes/default.dart';

class UsageLogCountArgs {
  final QrData qrData;

  UsageLogCountArgs(this.qrData);
}

class UsageLogCountScreen extends StatefulWidget {
  final UsageLogCountArgs args;

  const UsageLogCountScreen(this.args);

  @override
  _UsageLogCountScreenState createState() => _UsageLogCountScreenState();
}

class _UsageLogCountScreenState extends State<UsageLogCountScreen> {
  @override
  Widget build(BuildContext context) {
    return FlavorBanner(
      child: Scaffold(
          appBar: AppBar(title: Text('RapidPass Usage History')),
          body: Padding(
              padding: EdgeInsets.all(10.0),
              child: SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    _buildRapidPassDetails(widget.args.qrData),
                    SizedBox(
                      height: 10.0,
                    ),
                    _buildUsageHistory(widget.args.qrData),
                  ],
                ),
              ))),
    );
  }

  _buildRapidPassDetails(QrData qrData) {
    return Container(
      decoration: BoxDecoration(
          border: Border.all(color: green300, width: 1.0),
          borderRadius: BorderRadius.circular(12.0)),
      child: Column(
        children: <Widget>[
          Container(
            height: 40.0,
            decoration: BoxDecoration(
                color: green300,
                border: Border.all(color: green300, width: 1.0),
                borderRadius: BorderRadius.circular(11.0)),
            child: SizedBox.expand(
              child: Center(
                child: Text('RapidPass Information',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold)),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _buildFieldRow(
                  'Pass Type',
                  qrData.passType == PassType.Individual
                      ? 'I - INDIVIDUAL'
                      : 'V - VEHICHLE',
                ),
                _buildFieldRow(
                  'Control Code',
                  qrData.controlCodeAsString(),
                ),
                _buildFieldRow(
                  'ID Number',
                  qrData.idOrPlate,
                ),
                _buildFieldRow(
                  'APOR',
                  '${aporCodes[qrData.apor] != null ? '${qrData.apor} - ${aporCodes[qrData.apor]}' : '${qrData.apor}'}',
                ),
                _buildFieldRow(
                  'Valid From',
                  '${DateFormat('MMM dd, yyyy hh:mm aaa').format(new DateTime.fromMillisecondsSinceEpoch(qrData.validFrom * 1000))}',
                ),
                _buildFieldRow(
                  'Valid Until',
                  '${DateFormat('MMM dd, yyyy hh:mm aaa').format(new DateTime.fromMillisecondsSinceEpoch(qrData.validUntil * 1000))}',
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  _buildFieldRow(name, value) {
    Color color = Colors.black;
    return Row(
      children: <Widget>[
        Expanded(
          flex: 2,
          child: Text(name,
              style: TextStyle(
                  fontSize: 14, fontWeight: FontWeight.w500, color: color)),
        ),
        Expanded(
            flex: 5,
            child: Text(value,
                textAlign: TextAlign.right,
                style: TextStyle(
                    fontSize: 14, fontWeight: FontWeight.w500, color: color)))
      ],
    );
  }

  _buildUsageHistory(QrData qrData) {
    return Container(
      child: Column(
        children: <Widget>[
          Container(
            height: 40.0,
            child: SizedBox.expand(
              child: Center(
                child: Text('Usage History',
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold)),
              ),
            ),
          ),
          _buildUsageHistoryList(qrData),
        ],
      ),
    );
  }

  _buildUsageHistoryList(QrData qrData) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: FutureBuilder(
          future: UsageLogService.getUsageLogByControlNumber(
              context, widget.args.qrData.controlCode),
          builder: (bContext, bSnapshot) {
            if (bSnapshot.connectionState == ConnectionState.done) {
              final List<UsageLog> logs = bSnapshot.data;
              return ListView.separated(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: logs.length,
                separatorBuilder: (context, count) {
                  return const SizedBox(height: 10);
                },
                itemBuilder: (bContext, index) {
                  final UsageLog log = logs[logs.length - index - 1];
                  return _buildUsageItem(log);
                },
              );
            } else {
              return CircularProgressIndicator();
            }
          }),
    );
  }

  _buildUsageItem(UsageLog log) {
    ScanResultStatus status = ScanResultStatus.getStatusFromValue(log.status);
    Color color =
        status == ScanResultStatus.ENTRY_APPROVED ? Colors.black : Colors.red;
    return Row(
      children: <Widget>[
        Expanded(
          flex: 1,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                '${status.mainMessage}',
                style: TextStyle(color: color),
              ),
              status != ScanResultStatus.ENTRY_APPROVED
                  ? Text(
                      '${status.subMessage}',
                      style: TextStyle(color: color),
                    )
                  : SizedBox.shrink()
            ],
          ),
        ),
        Expanded(
          flex: 1,
          child: Text(
            '${DateFormat('MMM dd, yyyy hh:mm aaa').format(new DateTime.fromMillisecondsSinceEpoch(log.timestamp))}',
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }
}
