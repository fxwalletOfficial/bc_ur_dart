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

  PsbtSignRequestUR({required UR ur, required this.uuid, required this.dataType, required this.psbt, required this.path}) : super(payload: ur.payload, type: ur.type);

  factory PsbtSignRequestUR.fromTypedTransaction({required String path, Uint8List? uuid, required String psbt, required String xfp, required String origin}) {
    uuid ??= _generateUUid();
    final dataType = BtcSignDataType.TRANSACTION;

    final ur = UR.fromCBOR(
      uuid: uuid,
      type: PSBT_SIGN_REQUEST,
      value: CborMap({
        CborSmallInt(1): CborBytes(uuid, tags: [37]),
        CborSmallInt(2): CborBytes(fromHex(psbt), tags: [40310]),
        CborSmallInt(3): CborMap({
          CborSmallInt(1): CborList(getPath(path)),
          CborSmallInt(2): CborInt(toXfpCode(xfp))
        }, tags: [40304]),
        CborSmallInt(4): CborString(origin)
      })
    );

    final item = PsbtSignRequestUR(ur: ur, uuid: uuid, path: path, psbt: psbt, dataType: dataType);

    return item;
  }

  static Uint8List _generateUUid() => Uuid().v8obj().toBytes();
}

enum BtcSignDataType {
  ZERO,
  TRANSACTION,
  MESSAGE
}
