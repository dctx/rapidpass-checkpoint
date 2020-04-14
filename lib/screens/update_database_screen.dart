import 'dart:async';

import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:rapidpass_checkpoint/components/flavor_banner.dart';
import 'package:rapidpass_checkpoint/helpers/dialog_helper.dart';
import 'package:rapidpass_checkpoint/models/app_state.dart';
import 'package:rapidpass_checkpoint/models/database_sync_state.dart';
import 'package:rapidpass_checkpoint/repository/api_repository.dart';
import 'package:rapidpass_checkpoint/services/app_storage.dart';
import 'package:rapidpass_checkpoint/themes/default.dart';

class UpdateDatabaseScreen extends StatefulWidget {
  @override
  _UpdateDatabaseScreenState createState() => _UpdateDatabaseScreenState();
}

class _UpdateDatabaseScreenState extends State<UpdateDatabaseScreen> {
  AppState appState;

  bool _hasConnection = true;
  bool _isUpdating = false;
  int _progressValue = 0;
  bool _isStopped = false;

  final Connectivity _connectivity = Connectivity();
  StreamSubscription<ConnectivityResult> _connectivitySubscription;

  @override
  initState() {
    super.initState();

    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen((ConnectivityResult result) {
      bool _tempHasConnection;
      if (result == ConnectivityResult.none) {
        _tempHasConnection = false;
      } else {
        _tempHasConnection = true;
      }

      if (_tempHasConnection != _hasConnection) {
        _hasConnection = _tempHasConnection;
        setState(() {});
      }
    });
  }

  @override
  dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }

  Widget _buildRecordListView() {
    final appState = Provider.of<AppState>(context, listen: false);
    final databaseSyncLog = appState.databaseSyncLog;

    return Expanded(
      flex: 3,
      child: LayoutBuilder(
        builder: (bContext, constraints) {
          return Container(
            height: constraints.maxHeight,
            width: constraints.maxWidth,
            child: databaseSyncLog.isNotEmpty
                ? ListView.separated(
                    separatorBuilder: (context, count) {
                      return const Divider(
                        height: 10,
                        color: Colors.grey,
                      );
                    },
                    itemBuilder: (bContext, index) => Container(
                      child: ListTile(
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                        title: Text(
                          '${databaseSyncLog[index]['count']} ${databaseSyncLog[index]['count'] > 1 ? 'records' : 'record'} added',
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                        trailing: Text(
                          '${DateFormat('MMM dd, yyyy hh:mm aaa').format(new DateTime.fromMillisecondsSinceEpoch(databaseSyncLog[index]['dateTime']))}',
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w500),
                        ),
                        onTap: () {},
                      ),
                    ),
                    itemCount: databaseSyncLog.length,
                  )
                : Container(
                    padding: EdgeInsets.all(20.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Icon(Icons.assignment,
                            size: constraints.maxHeight * 0.50,
                            color: Colors.grey),
                        Text(
                          'Log is Empty.',
                          style: Theme.of(context).textTheme.display1.apply(
                                color: Colors.grey,
                              ),
                          textAlign: TextAlign.center,
                        ),
                        const Padding(padding: EdgeInsets.only(bottom: 10)),
                        Text(
                          'Press the "Sync" button and start fetching the new updates.',
                          style: TextStyle(
                              fontSize: 20.0, color: Colors.grey[700]),
                          textAlign: TextAlign.center,
                        )
                      ],
                    ),
                  ),
          );
        },
      ),
    );
  }

  Widget _buildOfflineContent(Size screenSize) {
    return Expanded(
        child: Container(
      padding: EdgeInsets.all(20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(Icons.cloud_off, size: 200, color: Colors.grey),
          Text(
            'You are offline.',
            style: Theme.of(context).textTheme.display1.apply(
                  color: Colors.grey,
                ),
            textAlign: TextAlign.center,
          ),
          const Padding(padding: EdgeInsets.only(bottom: 10)),
          Text(
            'Please check your internet connection and try again.',
            style: TextStyle(fontSize: 20.0, color: Colors.grey[700]),
            textAlign: TextAlign.center,
          )
        ],
      ),
    ));
  }

  Widget _buildFooterContent() {
    final appState = Provider.of<AppState>(context, listen: false);

    return Container(
      padding: EdgeInsets.all(20.0),
      child: Column(
        children: <Widget>[
          SizedBox(
            width: 250,
            child: FlatButton(
              onPressed: _hasConnection
                  ? !_isUpdating ? () => _updateDatabase(context) : null
                  : null,
              child: Text(
                  _isUpdating
                      ? _isStopped
                          ? 'Stopping...'
                          : 'Please Wait... ($_progressValue%)'
                      : 'Sync',
                  style: TextStyle(fontSize: 16.0)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24.0),
              ),
              padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
              color: green300,
              disabledColor: _isUpdating ? Colors.green[200] : Colors.grey[400],
              textColor: Colors.white,
              disabledTextColor: Colors.white,
            ),
          ),
          SizedBox(height: 10),
          Container(
            child: appState.databaseLastUpdated > 0
                ? Text(
                    'UPDATED AS OF\n'
                    '${DateFormat('hh:mm aaa MMMM dd, yyyy').format(DateTime.fromMillisecondsSinceEpoch(appState.databaseLastUpdated))}\n'
                    'Total of ${appState.databaseRecordCount} ${appState.databaseRecordCount > 1 ? 'records' : 'record'}',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 10),
                  )
                : SizedBox(
                    height: MediaQuery.of(context).size.height * 0.05,
                  ),
          )
        ],
      ),
    );
  }

  Widget _showProgressBar() {
    return Expanded(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: LinearProgressIndicator(),
        ),
      ),
    );
  }

  Future<bool> _onWillPop() async {
    return _isUpdating
        ? (await DialogHelper.showAlertDialog(
              context,
              title: 'Database Sync is In-Progress',
              message: 'Do you want to stop?',
              onConfirm: () {
                setState(() {
                  _isStopped = true;
                });
              },
              onCancel: () {},
            )) ??
            false
        : true;
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    appState = Provider.of<AppState>(context, listen: false);

    return WillPopScope(
      onWillPop: _onWillPop,
      child: FlavorBanner(
        child: Scaffold(
          appBar: AppBar(
            title: Text('Update Database'),
          ),
          body: Column(
            children: <Widget>[
              !_hasConnection
                  ? _buildOfflineContent(screenSize)
                  : _isUpdating ? _showProgressBar() : _buildRecordListView(),
              _buildFooterContent(),
            ],
          ),
        ),
      ),
    );
  }

  Future _updateDatabase(final BuildContext context) async {
    setState(() {
      _isStopped = false;
      _progressValue = 0;
      _isUpdating = true;
    });

    final AppState appState = Provider.of<AppState>(context, listen: false);
    final ApiRepository apiRepository =
        Provider.of<ApiRepository>(context, listen: false);
    final accessCode = appState.appSecrets?.accessCode;
    final int lastSyncTimestamp = DateTime.now().millisecondsSinceEpoch;

    if (appState.databaseSyncLog.isEmpty) {
      await AppStorage.setLastSyncOn(0).then((timestamp) {
        debugPrint('After setLastSyncOn(), timestamp: $timestamp');
        appState.databaseLastUpdated = timestamp;
      });
    }

    DatabaseSyncState state =
        await apiRepository.batchDownloadAndInsertPasses(accessCode);

    // ! For Functionality Test
    // ! [Uncomment statement below to drive an update failure state]
    // state = null;
    if (state == null || state.exception != null) {
      if (state != null && state.exception != null) {
        debugPrint(
            '_updateDatabase() exception: ' + state.exception.toString());
      }

      DialogHelper.showAlertDialog(
        context,
        title: 'Database Sync Failed!',
        message:
            'There\'s something wrong while getting the new information from the database.',
      );

      setState(() {
        _isUpdating = false;
      });
      return;
    }

    final int totalPages = state.totalPages;
    debugPrint('state.totalPages: $totalPages');
    if (totalPages > 0) {
      while (state.pageNumber < totalPages) {
        setState(() {
          _progressValue = ((state.pageNumber / totalPages) * 100).truncate();
        });
        state = await apiRepository.continueBatchDownloadAndInsertPasses(
            accessCode, state);

        if (state == null || state.exception != null) {
          break;
        }

        if (_isStopped) {
          Navigator.of(context).pop(true);
          return;
        }
      }
    }

    if (state == null || state.exception != null) {
      if (state != null && state.exception != null) {
        debugPrint(
            '_updateDatabase() exception: ' + state.exception.toString());
      }

      DialogHelper.showAlertDialog(
        context,
        title: 'Database Sync Failed!',
        message:
            'There\'s something wrong while getting the new information from the database.',
      );

      setState(() {
        _isUpdating = false;
      });
      return;
    }

    int totalRecords = appState.databaseRecordCount;

    await AppStorage.setLastSyncOn(lastSyncTimestamp).then((timestamp) {
      debugPrint('After setLastSyncOnToNow(), timestamp: $timestamp');
      appState.databaseLastUpdated = timestamp;
    });

    if (state.insertedRowsCount > 0) {
      totalRecords = await apiRepository.localDatabaseService.countPasses();
      appState.databaseRecordCount = totalRecords;

      await AppStorage.addDatabaseSyncLog(
              {'count': state.insertedRowsCount, 'dateTime': lastSyncTimestamp})
          .then((r) => appState.addDatabaseSyncLog(r));
    }

    final String message = state.insertedRowsCount > 0
        ? 'Downloaded ${state.insertedRowsCount} new ${(state.insertedRowsCount > 1 ? 'records' : 'record')}.'
        : 'No new records found. Total ${totalRecords > 1 ? 'records' : 'record'} in database is $totalRecords.';

    DialogHelper.showAlertDialog(
      context,
      title: 'Database Synced!',
      message: message,
    );

    setState(() {
      _isUpdating = false;
    });
  }
}
