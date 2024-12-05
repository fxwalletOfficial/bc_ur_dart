import 'package:bc_ur_dart/bc_ur_dart.dart';
import 'package:test/test.dart';

void main() {
  test('Get xfp', () {
    final origin = 44262555;
    final result = getXfp(BigInt.from(origin));
    expect(result, '9b64a302');
  });

  test('Byte words decode', () {
    final result = toXfpCode('9b64a302');
    expect(result, BigInt.from(44262555));
  });
}
