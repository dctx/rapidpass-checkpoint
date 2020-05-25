import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:moor/moor.dart';

enum Environment { dev, prod }

class Flavor {
  final Environment environment;
  final String apiBaseUrl;
  final String keycloakRealm;
  final String keycloakClient;
  static Flavor _instance;

  factory Flavor(
      {@required Environment environment,
      @required String apiBaseUrl,
      @required String keycloakRealm,
      @required String keycloakClient}) {
    _instance ??= Flavor._internal(
        environment, apiBaseUrl, keycloakRealm, keycloakClient);
    return _instance;
  }

  Flavor._internal(this.environment, this.apiBaseUrl, this.keycloakRealm,
      this.keycloakClient);

  static Flavor get instance => _instance;

  static bool get isProduction => _instance.environment == Environment.prod;

  static bool get isDevelopment => _instance.environment == Environment.dev;
}
