import 'dart:convert';

class JwtDecoder {
  Map<String, dynamic> parsePayLoad(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) {
        throw Exception('invalid token');
      }
      final payload = _decodeBase64(parts[1]);
      final payloadMap = json.decode(payload);
      if (payloadMap is! Map<String, dynamic>) {
        throw Exception('invalid payload');
      }
      return payloadMap;
    } catch (e) {
      print(e);
      return null;
    }
  }

  Map<String, dynamic> parseHeader(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) {
        throw Exception('invalid token');
      }
      final payload = _decodeBase64(parts[0]);
      final payloadMap = json.decode(payload);
      if (payloadMap is! Map<String, dynamic>) {
        throw Exception('invalid payload');
      }
      return payloadMap;
    } catch (e) {
      print(e);
      return null;
    }
  }

  String _decodeBase64(String str) {
    String output = str.replaceAll('-', '+').replaceAll('_', '/');

    switch (output.length % 4) {
      case 0:
        break;
      case 2:
        output += '==';
        break;
      case 3:
        output += '=';
        break;
      default:
        throw Exception('Illegal base64url string!"');
    }

    return utf8.decode(base64Url.decode(output));
  }
}
