import 'package:rapidpass_checkpoint/utils/base32_crockford.dart';
import 'package:test/test.dart';

void main() {
  test('CrockfordEncoder.convert(int) works', () {
    final CrockfordEncoder encoder = CrockfordEncoder(7);
    final testCases = {
      0: '0000000',
      2491777155: '2A8B043',
      987654321: '0XDWT5H'
    };
    testCases.forEach((input, expected) {
      expect(encoder.convert(input), equals(expected));
    });
  });
  test('normalize() works', () {
    final testCases = {
      '': '',
      '0': '0',
      '0123456789abcdefgHJKMNPQRSTVwxyz': '0123456789ABCDEFGHJKMNPQRSTVWXYZ',
      'ILilOo': '111100'
    };
    testCases.forEach((input, expected) {
      expect(normalize(input), equals(expected));
    });
  });
  test('Base32Crockford.decode(String) works', () {
    final testCases = {
      '': 0,
      '0': 0,
      'Z': 31,
      '10': 32,
      'abc091': int.parse('abc091', radix: 32),
      'ILilOo': int.parse('111100', radix: 32)
    };
    testCases.forEach((input, expected) {
      expect(crockford.decode(input), equals(expected));
    });
  });
}
