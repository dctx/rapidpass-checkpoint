import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rapidpass_checkpoint/components/flavor_banner.dart';
import 'package:rapidpass_checkpoint/screens/usage_log_detail_screen.dart';
import 'package:rapidpass_checkpoint/services/local_database_service.dart';
import 'package:rapidpass_checkpoint/services/usage_log_service.dart';

class UsageLogScreen extends StatefulWidget {
  @override
  _UsageLogScreenState createState() => _UsageLogScreenState();
}

class _UsageLogScreenState extends State<UsageLogScreen> {
  List<UsageDateLog> _cachedLogs = [];

  Future<List<UsageDateLog>> _getUsageDateLog(
      final BuildContext context) async {
    if (_cachedLogs.isEmpty) {
      return UsageLogService.getUsageLogByDate(context).then((res) {
        res.forEach((log) => _cachedLogs.add((log)));
        return _cachedLogs;
      });
    } else {
      return _cachedLogs;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FlavorBanner(
      child: Scaffold(
          appBar: AppBar(title: Text('Usage Log')),
          body: Padding(
              padding: EdgeInsets.all(8.0),
              child: FutureBuilder(
                  future: _getUsageDateLog(context),
                  builder: (bContext, bSnapshot) {
                    if (bSnapshot.connectionState == ConnectionState.done) {
                      final List<UsageDateLog> logs = bSnapshot.data;
                      return logs.isNotEmpty
                          ? ListView.separated(
                              key: PageStorageKey(0),
                              itemCount: logs.length,
                              separatorBuilder: (context, count) {
                                return const Divider(
                                  height: 2,
                                  color: Colors.grey,
                                );
                              },
                              itemBuilder: (bContext, index) =>
                                  _buildDateLog(logs[logs.length - index - 1]),
                            )
                          : _buildEmptyLog();
                    } else {
                      return CircularProgressIndicator();
                    }
                  }))),
    );
  }

  _buildDateLog(UsageDateLog log) {
    return Container(
      height: 50.0,
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 30, vertical: 0),
        title: Text(
          '${log.scanned} RapidPass',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
        trailing: Text(
          '${DateFormat('MMM dd, yyyy').format(new DateTime.fromMillisecondsSinceEpoch(log.timestamp * 1000))}',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        onTap: () => Navigator.pushNamed(context, '/usageLogDetail',
            arguments: UsageLogDetailArgs(log.timestamp)),
      ),
    );
  }

  _buildEmptyLog() {
    Size size = MediaQuery.of(context).size;
    return Container(
      padding: EdgeInsets.all(20.0),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Icon(Icons.assignment, size: size.width * 0.25, color: Colors.grey),
            SizedBox(
              height: 20.0,
            ),
            Text(
              'Log is Empty.',
              style: Theme.of(context).textTheme.display1.apply(
                    color: Colors.grey,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
