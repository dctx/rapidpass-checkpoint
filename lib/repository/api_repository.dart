import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:meta/meta.dart';
import 'package:rapidpass_checkpoint/data/app_database.dart';
import 'package:rapidpass_checkpoint/models/database_sync_state.dart';
import 'package:rapidpass_checkpoint/models/revoke_sync_state.dart';
import 'package:rapidpass_checkpoint/services/api_service.dart';
import 'package:rapidpass_checkpoint/services/app_storage.dart';
import 'package:rapidpass_checkpoint/services/local_database_service.dart';

// TODO Rename this to RapidPassRepository
abstract class IApiRepository {
  Future<DatabaseSyncState> batchDownloadAndInsertPasses(
      final String accessCode);

  Future<DatabaseSyncState> continueBatchDownloadAndInsertPasses(
      final String accessCode, final DatabaseSyncState state);

  Future<void> verifyPlateNumber(String plateNumber);

  Future<void> verifyControlNumber(int controlNumber);

  Future<RevokeSyncState> downloadRevokePasses(
      final String accessCode, RevokeSyncState state);
}

class ApiRepository extends IApiRepository {
  final ApiService apiService;
  final LocalDatabaseService localDatabaseService;
  final String accessToken;

  ApiRepository(
      {@required this.apiService,
      @required this.localDatabaseService,
      @required this.accessToken});

  @override
  Future<DatabaseSyncState> batchDownloadAndInsertPasses(
      final String accessCode) async {
    final int before = await localDatabaseService.countPasses();
    debugPrint('before: $before');
    final int lastSyncOn = await AppStorage.getLastSyncOn();
    debugPrint('lastSyncOn: $lastSyncOn');
    final lastSyncOnDateTime =
        DateTime.fromMillisecondsSinceEpoch(lastSyncOn * 1000);
    final DateFormat dateFormat = new DateFormat.yMd().add_jm();
    debugPrint('lastSyncOnDateTime: ${dateFormat.format(lastSyncOnDateTime)}');
    final DatabaseSyncState state = DatabaseSyncState(lastSyncOn: lastSyncOn);
    try {
      await apiService
          .getBatchPasses(accessCode, state)
          .catchError((e) => throw Exception(e));
      await localDatabaseService.bulkInsertOrUpdate(state.passesForInsert);
      state.insertedRowsCount =
          state.insertedRowsCount + state.passesForInsert.length;
      debugPrint('state.insertedRowsCount: ${state.insertedRowsCount}');
      final int after = await localDatabaseService.countPasses();
      debugPrint('after: $after');
    } catch (e, stackTrace) {
      debugPrint(e.toString());
      debugPrintStack(stackTrace: stackTrace);
      state.exception = e;
      state.statusMessage = e.toString();
    }
    return state;
  }

  @override
  Future<DatabaseSyncState> continueBatchDownloadAndInsertPasses(
      final String accessCode, DatabaseSyncState state) async {
    // TODO Factor out common code with above
    final int before = await localDatabaseService.countPasses();
    debugPrint('before: $before');
    debugPrint('state.lastSyncOn: ${state.lastSyncOn}');
    try {
      await apiService
          .getBatchPasses(accessCode, state)
          .catchError((e) => throw Exception(e));
      await localDatabaseService.bulkInsertOrUpdate(state.passesForInsert);
      state.insertedRowsCount =
          state.insertedRowsCount + state.passesForInsert.length;
      debugPrint('state.insertedRowsCount: ${state.insertedRowsCount}');
      final int after = await localDatabaseService.countPasses();
      debugPrint('after: $after');
      return state;
    } catch (e, stackTrace) {
      debugPrint(e.toString());
      debugPrintStack(stackTrace: stackTrace);
      state.exception = e;
      state.statusMessage = e.toString();
    }
    return state;
  }

  @override
  Future<ValidPass> verifyControlNumber(int controlCodeNumber) async {
    return localDatabaseService
        .getValidPassByIntegerControlCode(controlCodeNumber);
  }

  @override
  Future<void> verifyPlateNumber(String plateNumber) {
    // TODO: implement verifyPlateNumber
    return apiService.verifyPlateNumber(plateNumber);
  }

  @override
  Future<RevokeSyncState> downloadRevokePasses(
      final String accessCode, RevokeSyncState state) async {
    try {
      await apiService
          .getRevokePasses(accessCode, state)
          .catchError((e) => throw Exception(e));
      await localDatabaseService
          .bulkInsertOrUpdateRevokePasses(state.passesForInsert);
      state.insertedRowsCount =
          state.insertedRowsCount + state.passesForInsert.length;
      state.passesForInsert.forEach((item) {
        state.since = item.timestamp.value > state.since
            ? item.timestamp.value
            : state.since;
      });
      debugPrint(
          'state.insertedRowsCount: ${state.insertedRowsCount}, state.since: ${state.since}');
    } catch (e, stackTrace) {
      debugPrint(e.toString());
      debugPrintStack(stackTrace: stackTrace);
      state.exception = e;
      state.statusMessage = e.toString();
    }
    return state;
  }
}
