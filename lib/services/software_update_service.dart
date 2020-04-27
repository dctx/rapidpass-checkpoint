import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'dart:isolate';

import 'package:connectivity/connectivity.dart';
import 'package:crypto/crypto.dart';
import 'package:dio/adapter.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:open_file/open_file.dart';
import 'package:package_info/package_info.dart';
import 'package:path_provider/path_provider.dart';

class SoftwareUpdateService {
  final HttpClientAdapter httpClientAdapter;
  final String baseUrl;

  static const checkUpdatePath = '/checkpoint/update';
  static const downloadFilePath = '/checkpoint/download';

  SoftwareUpdateService({@required this.baseUrl, httpClientAdapter})
      : this.httpClientAdapter = httpClientAdapter != null
            ? httpClientAdapter
            : DefaultHttpClientAdapter();

  Future<void> checkUpdate() async {
    final Dio client = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: 30000,
    ));
    client.httpClientAdapter = httpClientAdapter;

    try {
      final Connectivity _connectivity = Connectivity();
      final ConnectivityResult connectivityResult =
          await _connectivity.checkConnectivity();

      if (connectivityResult == ConnectivityResult.none) {
        throw Exception('No connectivity.');
      }

      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      print('appName: ${packageInfo.appName}');
      print('buildNumber: ${packageInfo.buildNumber}');
      print('packageName: ${packageInfo.packageName}');
      print('version: ${packageInfo.version}');

      final Response response =
          await client.get(checkUpdatePath, queryParameters: {
        'appName': packageInfo.appName,
        'buildNumber': packageInfo.buildNumber,
        'packageName': packageInfo.packageName,
        'version': packageInfo.version
      });
      var data = response.data;
      debugPrint('latest: ${inspect(data)}');

      final filename = data['file'];
      final version = data['version'];
      final hash = data['sha1'];
      if (filename == null || version == null || hash == null) {
        throw Exception('Invalid server response.');
      }

      final String localDirectory = await _cachePath;
      final String apkDownloadDir = '$localDirectory/apk';

      if (version == packageInfo.version) {
        final dir = Directory(apkDownloadDir);
        if (dir.existsSync()) {
          dir.listSync().forEach((f) {
            if (f.path.endsWith('.apk')) f.deleteSync();
          });
        }
        print('Software version is updated.');
        return;
      }

      final String filePath = '$apkDownloadDir/$filename';
      final File file = File(filePath);

      if (await file.exists() && !await checkHash(file, hash)) {
        await file.delete();
      }

      if (!await file.exists()) {
        CancelToken cancelToken = CancelToken();
        await client.download('$downloadFilePath/$filename', filePath,
            onReceiveProgress: showDownloadProgress, cancelToken: cancelToken);

        if (!await checkHash(file, hash)) {
          await file.delete();
          throw Exception('Incorrect hash value');
        }
      }

      print('installing update...');
      await OpenFile.open(filePath);
    } catch (e) {
      print('checkUpdate() exception: ' + e.toString());
    }
  }

  Future<String> get _cachePath async {
    final directory = await getTemporaryDirectory();
    return directory.path;
  }

  void showDownloadProgress(received, total) {
    if (total != -1) {
      print('Downloading update: ' +
          (received / total * 100).toStringAsFixed(0) +
          "%");
    }
  }

  static Future<bool> checkHash(File file, String hash) async {
    // computeHash() is very CPU-intensive. So it has to run in an Isolate
    // to avoid UI freezing. But using compute() crashes the app when app is
    // closed using Back button, then open again immediately, while
    // computeHash() is executing. As a workaround, computeCustom() is used.
    // String computedHash = await compute(computeHash, file);
    String computedHash = await computeCustom(computeHash, file);

    if (computedHash == hash) {
      return true;
    } else {
      print('[Hash mismatch] computedHash: $computedHash, expectedHash: $hash');
      return false;
    }
  }

  static String computeHash(File file) {
    List<int> data = file.readAsBytesSync();
    String hash = sha1.convert(data).toString();
    return hash;
  }
}

// Custom implementation of compute() function.
Future<R> computeCustom<Q, R>(ComputeCallback<Q, R> callback, Q message) async {
  final ReceivePort receivePort = ReceivePort();
  Isolate isolate = await Isolate.spawn(computeIsolate, receivePort.sendPort);
  final isolatePort = await receivePort.first;
  final messagePort = ReceivePort();
  await isolatePort.send([callback, message, messagePort.sendPort]);
  final res = await messagePort.first;
  isolate.kill();
  return res;
}

computeIsolate(SendPort sendPort) async {
  final ReceivePort receivePort = ReceivePort();
  sendPort.send(receivePort.sendPort);
  await for (var msg in receivePort) {
    final callback = msg[0];
    final data = msg[1];
    SendPort msgPort = msg[2];
    final res = callback(data);
    msgPort.send(res);
  }
}
