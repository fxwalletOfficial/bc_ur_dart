import 'dart:math';
import 'dart:typed_data';

import 'package:cbor/cbor.dart';
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

BigInt byteToBigInt(Uint8List value) {
  BigInt result = BigInt.from(0);
  for (int i = 0; i < value.length; i++) {
    result += BigInt.from(value[value.length - i - 1]) << (8 * i);
  }
  return result;
}

Uint8List bigIntToByte(BigInt value, int? length) {
  String str = value.toRadixString(16);
  if (str.length % 2 == 1) str = '0$str';

  final len = length ?? (str.length / 2).round();
  final data = Uint8List(len);
  final buf = hex.decode(str);
  data.setAll(len - buf.length, buf);

  return data;
}

Uint8List stringToBytes(String value) {
  final item = value.replaceFirst('0x', '');
  return Uint8List.fromList(hex.decode(item));
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

final _pathReg = RegExp(r"/(\d+)('{0,1})");

List<CborValue> getPath(String path) {
  if (!path.startsWith('m/')) throw Exception('Invalid type');

  final items = <CborValue>[];
  final matches = _pathReg.allMatches(path);
  for (final match in matches) {
    final num = int.parse(match.group(1)!);
    final hardened = match.group(2)?.isNotEmpty ?? false;
    items.addAll([CborSmallInt(num), CborBool(hardened)]);
  }

  return items;
}

