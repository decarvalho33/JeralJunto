import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:jeraljunto/core/utils/input_formatters.dart';

void main() {
  test('JoinCodeInputFormatter uppercases, filters, and limits to 6', () {
    const formatter = JoinCodeInputFormatter();
    final result = formatter.formatEditUpdate(
      const TextEditingValue(text: ''),
      const TextEditingValue(text: 'ab-12c3xyz'),
    );

    expect(result.text, 'AB12C3');
  });

  test('normalizeJoinCode uppercases and strips invalid chars', () {
    expect(normalizeJoinCode('a!b@c#1'), 'ABC1');
  });
}
