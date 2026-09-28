import 'package:era_wallet/era_chain.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('formatEra', () {
    test('formats null and zero values', () {
      expect(formatEra(null), '0');
      expect(formatEra(BigInt.zero), '0');
    });

    test('formats whole and fractional ERA values', () {
      expect(formatEra(kEraUnit), '1');
      expect(formatEra(kEraUnit * BigInt.from(12)), '12');
      expect(
        formatEra(kEraUnit + BigInt.from(5) * BigInt.from(10).pow(17)),
        '1.5',
      );
      expect(
        formatEra(kEraUnit + BigInt.from(123450000000000000)),
        '1.12345',
      );
    });

    test('formats negative values', () {
      expect(formatEra(-kEraUnit), '-1');
      expect(
        formatEra(-(kEraUnit + BigInt.from(25) * BigInt.from(10).pow(16))),
        '-1.25',
      );
    });
  });

  group('parseEraToUnits', () {
    test('parses valid values', () {
      expect(parseEraToUnits('1'), kEraUnit);
      expect(parseEraToUnits('0.5'), BigInt.from(5) * BigInt.from(10).pow(17));
      expect(
        parseEraToUnits('1.12345'),
        kEraUnit + BigInt.from(123450000000000000),
      );
      expect(parseEraToUnits('-2'), -(kEraUnit * BigInt.from(2)));
    });

    test('trims and truncates excess precision', () {
      expect(
        parseEraToUnits(' 1.123456789012345678999 '),
        BigInt.parse('1123456789012345678'),
      );
    });

    test('rejects invalid values', () {
      expect(parseEraToUnits(''), isNull);
      expect(parseEraToUnits('abc'), isNull);
      expect(parseEraToUnits('1.2.3'), isNull);
      expect(parseEraToUnits('--1'), isNull);
    });
  });
}
