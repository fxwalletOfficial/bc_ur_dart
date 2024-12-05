import 'dart:typed_data';

import 'package:cbor/cbor.dart';
import 'package:bc_ur_dart/src/ur.dart';

const String PSBT_SIGNATURE = 'PSBT-SIGNATURE';

class PsbtSignatureUR extends UR {
  final Uint8List uuid;
  final Uint8List signature;

  PsbtSignatureUR({required this.uuid, required this.signature, super.type, super.payload});

  factory PsbtSignatureUR.fromUR({required UR ur}) {
    if (ur.type.toUpperCase() != PSBT_SIGNATURE) throw Exception('Invalid type: ${ur.type}');

    final data = ur.decodeCBOR() as CborMap;

    final uuid = Uint8List.fromList((data[CborSmallInt(1)] as CborBytes).bytes);
    final signature = Uint8List.fromList((data[CborSmallInt(2)] as CborBytes).bytes);

    return PsbtSignatureUR(uuid: uuid, signature: signature, type: ur.type, payload: ur.payload);
  }
}
