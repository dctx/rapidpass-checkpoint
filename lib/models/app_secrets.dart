class AppSecrets {
  final String signingKey;
  final String encryptionKey;
  String accessCode;
  String password;
  AppSecrets(
      {this.signingKey, this.encryptionKey, this.accessCode, this.password});
}
