import 'dart:convert';

/// Character '0'
const $0 = 0x30;

/// Character '9'
const $9 = 0x39;

/// A CrockfordCodec singleton
final crockford = CrockfordCodec();

const normalizationMap = {
  // 'I': '1'
  73: 49,
  // 'L': '1'
  76: 49,
  // 'i': '1'
  105: 49,
  // 'l': '1'
  108: 49,
  // 'O': '0'
  79: 48,
  // 'o': '0'
  111: 48,
};

String normalize(final String input) {
  final codeUnits = input.toUpperCase().codeUnits;
  final List<int> out = List(codeUnits.length);
  for (var i = 0; i < codeUnits.length; ++i) {
    final inp = codeUnits[i];
    out[i] = normalizationMap.containsKey(inp) ? normalizationMap[inp] : inp;
  }
  return AsciiDecoder().convert(out);
}

class CrockfordCodec extends Codec<int, String> {
  @override
  Converter<String, int> get decoder => CrockfordDecoder();

  @override
  Converter<int, String> get encoder => CrockfordEncoder(0);
}

const alphaEncodingMap = {
  97: 65,
  98: 66,
  99: 67,
  100: 68,
  101: 69,
  102: 70,
  103: 71,
  104: 72,
  105: 74,
  106: 75,
  107: 77,
  108: 78,
  109: 80,
  110: 81,
  111: 82,
  112: 83,
  113: 84,
  114: 86,
  115: 87,
  116: 88,
  117: 89,
  118: 90,
};

class CrockfordEncoder extends Converter<int, String> {
  final int padToLength;

  const CrockfordEncoder(this.padToLength);

  @override
  String convert(int input) {
    final rawBase32 = input.toRadixString(32).toLowerCase();
    final codeUnits = rawBase32.codeUnits;
    var length = codeUnits.length;
    final List<int> out = List();
    for (var i = padToLength - length; i > 0; --i) {
      out.add($0);
    }
    for (var i = 0; i < length; ++i) {
      final inp = codeUnits[i];
      out.add(inp <= $9 ? inp : alphaEncodingMap[codeUnits[i]]);
    }
    return AsciiDecoder().convert(out);
  }
}

final symbols = '0123456789ABCDEFGHJKMNPQRSTVWXYZ'.codeUnits;

class CrockfordDecoder extends Converter<String, int> {
  @override
  int convert(String input) {
    final codeUnits = normalize(input).codeUnits;
    var n = 0;
    for (int i = 0; i < codeUnits.length; ++i) {
      final index = symbols.indexOf(codeUnits[i]);
      if (index == -1) {
        throw new FormatException(
            "Invalid character encountered: '${input.substring(i, i + 1)}'",
            input,
            i);
      }
      n = (n << 5) + index;
    }
    return n;
  }
}
