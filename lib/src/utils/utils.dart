import 'dart:math';
import 'dart:typed_data';

import 'package:convert/convert.dart';
import 'package:crypto/crypto.dart' as crypto;

Uint8List intToByte(int value, int length) {
  final data = Uint8List(length);

  String str = value.toRadixString(16);
  if (str.length % 2 == 1) str = '0$str';

  final buf = hex.decode(str);
  data.setAll(length - buf.length, buf);

  return data;
}

Uint8List sha256(List<int> value) {
  final digest = crypto.sha256.convert(value);
  return Uint8List.fromList(digest.bytes);
}

bool arraysEqual(List a, List b) {
  if (a.length != b.length) return false;
  return a.every((e) => b.contains(e));
}

List<int> bufferXOR(List<int> a, List<int> b) {
  final length = max(a.length, b.length);
  final result = List.filled(length, 0);

  for (var i = 0; i < length; i++) {
    result[i] = a[i] ^ b[i];
  }
  return result;
}

