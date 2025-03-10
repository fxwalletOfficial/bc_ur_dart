import 'dart:typed_data';

import 'package:cbor/cbor.dart';
import 'package:uuid/uuid.dart';

import 'package:bc_ur_dart/src/ur.dart';
import 'package:bc_ur_dart/src/utils/utils.dart';

const String PSBT_SIGN_REQUEST = 'PSBT-SIGN-REQUEST';

class PsbtSignRequestUR extends UR {
  final Uint8List uuid;
  final BtcSignDataType dataType;
  final String psbt;
  final String path;
  final String xfp;

  PsbtSignRequestUR({required UR ur, required this.uuid, required this.dataType, required this.psbt, required this.path, required this.xfp}) : super(payload: ur.payload, type: ur.type);

  factory PsbtSignRequestUR.fromTypedTransaction({
    required String path,
    required String psbt,
    required String xfp,
    required String origin,
    Uint8List? uuid,
    bool xfpReverse = true
  }) {
    uuid ??= _generateUUid();
    final dataType = BtcSignDataType.TRANSACTION;

    final ur = UR.fromCBOR(
      type: PSBT_SIGN_REQUEST,
      value: CborMap({
        CborSmallInt(1): CborBytes(uuid, tags: [37]),
        CborSmallInt(2): CborBytes(fromHex(psbt), tags: [40310]),
        CborSmallInt(3): CborMap({
          CborSmallInt(1): CborList(getPath(path)),
          if (xfp.isNotEmpty) CborSmallInt(2): CborInt(toXfpCode(xfp, bigEndian: xfpReverse))
        }, tags: [40304]),
        CborSmallInt(4): CborString(origin)
      })
    );

    final item = PsbtSignRequestUR(ur: ur, uuid: uuid, path: path, psbt: psbt, dataType: dataType, xfp: xfp);

    return item;
  }

  static Uint8List _generateUUid() => Uuid().v8obj().toBytes();
}

enum BtcSignDataType {
  ZERO,
  TRANSACTION,
  MESSAGE
}
