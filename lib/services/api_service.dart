import 'dart:developer';
import 'dart:math';

import 'package:dio/adapter.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:rapidpass_checkpoint/data/app_database.dart';
import 'package:rapidpass_checkpoint/data/pass_csv_to_json_converter.dart';
import 'package:rapidpass_checkpoint/models/app_secrets.dart';
import 'package:rapidpass_checkpoint/models/control_code.dart';
import 'package:rapidpass_checkpoint/models/database_sync_state.dart';
import 'package:rapidpass_checkpoint/models/revoke_sync_state.dart';
import 'package:rapidpass_checkpoint/services/software_update_service.dart';

class ApiException implements Exception {
  final String message;
  final int statusCode;

  ApiException(this.message, {this.statusCode});
}

abstract class IApiService {
  Future<void> authenticateDevice({String imei, String masterKey});

  Future<AppSecrets> registerDevice(
      {String deviceId, String imei, String masterKey, String password});

  Future<String> loginDevice({String deviceId, String password});

  Future<DatabaseSyncState> getBatchPasses(
      String accessCode, DatabaseSyncState state);

  Future<void> verifyPlateNumber(String plateNumber);

  Future<void> verifyControlNumber(String controlNumber);

  Future<void> checkUpdate(final String accessToken);

  Future<RevokeSyncState> getRevokePasses(
      String accessToken, RevokeSyncState state);
}

class ApiService extends IApiService {
  final HttpClientAdapter httpClientAdapter;
  final String baseUrl;
  final String keycloakRealm;
  final String keycloakClient;
  final SoftwareUpdateService softwareUpdate;

  static const authenticateDevicePath = '/checkpoint/auth';
  static const registerDevicePath = '/checkpoint/register';
  static const loginDevicePath = '/openid-connect/token';
  static const getBatchPassesPath = '/batch/access-passes';
  static const getRevokePassesPath = '/checkpoint/revocations';

  ApiService({
    @required this.baseUrl,
    @required this.keycloakRealm,
    @required this.keycloakClient,
    HttpClientAdapter httpClientAdapter,
  })  : this.httpClientAdapter = httpClientAdapter != null
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
              accessCode: data['accessCode'],
              password: '');
        }
      }
      return Future.error('Unknown response from server.');
    } on DioError catch (e) {
      debugPrint(e.toString());
      if (e.response == null) {
        throw ApiException(
            'Network error. Please check your internet connection and try again.');
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
  Future<AppSecrets> registerDevice(
      {String deviceId, String imei, String masterKey, String password}) async {
    debugPrint(
        'registerDevice() deviceId: $deviceId, imei: $imei, masterKey: $masterKey, password: $password');
    final Dio client = Dio(BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: 30000,
        receiveTimeout: 60000,
        contentType: Headers.jsonContentType));
    client.httpClientAdapter = httpClientAdapter;

    try {
      final response = await client.post(registerDevicePath, data: {
        'deviceId': deviceId,
        'imei': imei,
        'masterKey': masterKey,
        'password': password
      });
      final statusCode = response.statusCode;
      final data = response.data;
      debugPrint('${inspect(data)}');
      debugPrint('statusCode: $statusCode');

      if (data == null) {
        return Future.error('No response from server.');
      } else if (data is List<dynamic>) {
        for (final key in data) {
          return AppSecrets(
              encryptionKey: key['encryptionKey'],
              signingKey:
                  key.containsKey('encryptionKey') ? key['signingKey'] : '',
              accessCode: '',
              password: password);
        }
      } else if (data is Map<String, dynamic>) {
        if (data.containsKey('message')) {
          return Future.error(data['message']);
        } else if (data.containsKey('encryptionKey')) {
          return AppSecrets(
              encryptionKey: data['encryptionKey'],
              signingKey:
                  data.containsKey('encryptionKey') ? data['signingKey'] : '',
              accessCode: '',
              password: password);
        }
      }
      return Future.error('Unknown response from server.');
    } on DioError catch (e) {
      if (e.response == null) {
        throw ApiException(
            'Network error. Please check your internet connection and try again.');
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
  Future<String> loginDevice({String deviceId, String password}) async {
    debugPrint('loginDevice() deviceID: $deviceId, password: $password, keycloakRealm: $keycloakRealm, keycloakClient: $keycloakClient');
    final Dio client = Dio(BaseOptions(
        baseUrl: 'https://id.cxpass.org/auth/realms/$keycloakRealm/protocol',
        connectTimeout: 30000,
        receiveTimeout: 60000,
        contentType: Headers.formUrlEncodedContentType));
    client.httpClientAdapter = httpClientAdapter;

    try {
      final response = await client.post(loginDevicePath, data: {
        'client_id': keycloakClient,
        'grant_type': 'password',
        'username': deviceId,
        'password': password
      });
      final statusCode = response.statusCode;
      final data = response.data;
      debugPrint('${inspect(data)}');

      if (data == null)
        throw ApiException('empty response', statusCode: response.statusCode);
      if (statusCode != 200)
        ApiException('invalid response', statusCode: statusCode);

      final accessToken = data['access_token'];
      return accessToken;
    } on DioError catch (e) {
      throw ApiException('Authentication Error', statusCode: e.response.statusCode);
    } catch (e) {
      rethrow;
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
  Future<void> checkUpdate(final String accessToken) async {
    return softwareUpdate.checkUpdate(accessToken);
  }

  @override
  Future<RevokeSyncState> getRevokePasses(
      String accessToken, RevokeSyncState state) async {
    debugPrint('getRevokePasses.state: $state');
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

    try {
      final Response response = await client
          .get(getRevokePassesPath, queryParameters: {'since': state.since});

      final list = response.data['data'];
      final listLength = list.length;
      final List<RevokePassesCompanion> receivedPasses = List();

      debugPrint('${inspect(response.data)}');
      debugPrint('Got $listLength rows...');

      for (final row in list.sublist(0, listLength)) {
        try {
          if (row['eventType'] != "RapidPassRevoked") continue;
          debugPrint('Got pass ${row['controlCode']}');
          final revokePass = RevokePass.fromJson(row);
          final companion = revokePass.createCompanion(true);
          receivedPasses.add(companion);
        } on FormatException catch (e) {
          debugPrint(e.toString());
        }
      }
      state.passesForInsert = receivedPasses;
      state.pageNumber = state.pageNumber + 1;
      state.totalPages = 1;
      return state;
    } catch (e) {
      rethrow;
    }
  }

  String generatePassword(int length) {
    var rand = new Random();
    var codeUnits = new List.generate(length, (index) {
      return rand.nextInt(33) + 89;
    });
    return new String.fromCharCodes(codeUnits);
  }
}
