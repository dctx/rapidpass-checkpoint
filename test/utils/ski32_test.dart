import 'package:convert/convert.dart';
import 'package:rapidpass_checkpoint/utils/skip32.dart';
import 'package:test/test.dart';

void main() {
  test('Skip32.encrypt() works', () {
    final key = hex.decode('112233445566778899aa');
    final testCases = {1: 3030117256};
    testCases.forEach((plainText, cipherText) {
      expect(Skip32.encrypt(plainText, key), equals(cipherText));
      expect(Skip32.decrypt(cipherText, key), equals(plainText));
    });
  });
}
