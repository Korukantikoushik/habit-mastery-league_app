import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Basic math test', () {
    expect(2 + 2, 4);
  });

  test('XP logic test', () {
    int xp = 0;
    xp += 10;
    expect(xp, 10);
  });
}
