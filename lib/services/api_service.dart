import 'dart:developer';

import 'package:dio/adapter.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:rapidpass_checkpoint/data/app_database.dart';
import 'package:rapidpass_checkpoint/data/pass_csv_to_json_converter.dart';
import 'package:rapidpass_checkpoint/models/app_secrets.dart';
import 'package:rapidpass_checkpoint/models/control_code.dart';
import 'package:rapidpass_checkpoint/models/database_sync_state.dart';
import 'package:rapidpass_checkpoint/services/software_update_service.dart';

class ApiException implements Exception {
  final String message;
  final int statusCode;

  ApiException(this.message, {this.statusCode});
}

abstract class IApiService {
  Future<void> authenticateDevice({String imei, String masterKey});

  Future<DatabaseSyncState> getBatchPasses(
      String accessCode, DatabaseSyncState state);

  Future<void> verifyPlateNumber(String plateNumber);

  Future<void> verifyControlNumber(String controlNumber);

  Future<void> checkUpdate();
}

class ApiService extends IApiService {
  final HttpClientAdapter httpClientAdapter;
  final String baseUrl;
  final SoftwareUpdateService softwareUpdate;

  static const authenticateDevicePath = '/checkpoint/auth';
  static const getBatchPassesPath = '/batch/access-passes';

  ApiService({
    @required this.baseUrl,
    HttpClientAdapter httpClientAdapter,
  }) : this.httpClientAdapter = httpClientAdapter != null
            ? httpClientAdapter
            : DefaultHttpClientAdapter(),
        this.softwareUpdate = SoftwareUpdateService(
            baseUrl: baseUrl, httpClientAdapter: httpClientAdapter);

  static const int thirtySeconds = 30000;
  static const int tenSeconds = 10000;

  @override
  Future<AppSecrets> authenticateDevice(
      {final String imei, final String masterKey}) async {
    final Dio client = Dio(BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: thirtySeconds,
        receiveTimeout: tenSeconds,
        contentType: Headers.jsonContentType));
    client.httpClientAdapter = httpClientAdapter;
    try {
      final response = await client.post(authenticateDevicePath,
          data: {'imei': imei, 'masterKey': masterKey});
      final data = response.data;
      debugPrint('${inspect(data)}');
      if (data == null) {
        return Future.error('No response from server.');
      } else if (data is Map<String, dynamic>) {
        if (data.containsKey('message')) {
          return Future.error(data['message']);
        } else if (data.containsKey('signingKey') &&
            data.containsKey('encryptionKey') &&
            data.containsKey('accessCode')) {
          return AppSecrets(
              signingKey: data['signingKey'],
              encryptionKey: data['encryptionKey'],
              accessCode: data['accessCode']);
        }
      }
      return Future.error('Unknown response from server.');
    } on DioError catch (e) {
      debugPrint(e.toString());
      if (e.response == null) {
        throw ApiException(
            'Network error. Please check your internet connection.');
      }
      var statusCode = e.response.statusCode;
      debugPrint('statusCode: $statusCode');
      if (statusCode >= 500 && statusCode < 600) {
        throw ApiException('Server error ($statusCode)',
            statusCode: statusCode);
      } else if (statusCode == 401) {
        throw ApiException('Unauthorized', statusCode: 401);
      } else {
        final data = e.response.data;
        print(inspect(data));
        if (data == null) {
          throw ApiException('No response from server.');
        } else if (data is Map<String, dynamic> &&
            data.containsKey('message')) {
          var message = data['message'];
          debugPrint("message: '$message'");
          throw ApiException(message);
        } else {
          throw e;
        }
      }
    }
  }

  @override
  Future<DatabaseSyncState> getBatchPasses(
      final String accessToken, final DatabaseSyncState state) async {
    debugPrint('getBatchPasses.state: $state');
    if (state.totalPages > 0 && state.pageNumber > state.totalPages) {
      state.passesForInsert = List();
      return state;
    }
    final Dio client = Dio(BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: 30000,
        receiveTimeout: 60000,
        contentType: Headers.jsonContentType,
        headers: {'Authorization': 'Bearer $accessToken'}));
    client.httpClientAdapter = httpClientAdapter;
    final Response response =
        await client.get(getBatchPassesPath, queryParameters: {
      'lastSyncOn': state.lastSyncOn,
      'pageNumber': state.pageNumber,
      'pageSize': state.pageSize
    });

    try {
      final data = response.data;
      debugPrint('${inspect(data)}');
      if (state.totalPages == 0) {
        state.totalPages = data['totalPages'];
        state.totalRows = data['totalRows'];
      }
      final list = response.data['data'];
      final listLength = list.length;
      if (list.length < 2) {
        return state;
      }
      debugPrint('Got ${listLength - 1} rows...');
      final List<String> headers = list[0].cast<String>().toList();
      debugPrint('headers => $headers');
      final passCsvToJsonConverter = PassCsvToJsonConverter(headers: headers);
      final List<ValidPassesCompanion> receivedPasses = List();

      for (final row in list.sublist(1, listLength)) {
        try {
          final json = passCsvToJsonConverter.convert(row);
          debugPrint('Got pass ${ControlCode.encode(json['controlCode'])}');
          final validPass = ValidPass.fromJson(json);
          final companion = validPass.createCompanion(true);
          receivedPasses.add(companion);
        } on FormatException catch (e) {
          debugPrint(e.toString());
        }
      }
      state.passesForInsert = receivedPasses;
      state.pageNumber = state.pageNumber + 1;
      return state;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> verifyControlNumber(String controlNumber) {
    // TODO: implement verifyControlNumber
    return null;
  }

  @override
  Future<void> verifyPlateNumber(String plateNumber) {
    // TODO: implement verifyPlateNumber
    return null;
  }

  @override
  Future<void> checkUpdate() async {
    return softwareUpdate.checkUpdate();
  }
}
