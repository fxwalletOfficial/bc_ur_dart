import 'dart:typed_data';
import 'package:bc_ur_dart/src/models/btc/gspl_tx_data.dart';
import 'package:bc_ur_dart/src/models/btc/psbt_sign_request.dart';
import 'package:cbor/cbor.dart';
import 'package:uuid/uuid.dart';

import 'package:bc_ur_dart/src/ur.dart';
import 'package:bc_ur_dart/src/utils/utils.dart';

const String BTC_SIGN_REQUEST = 'BTC-SIGN-REQUEST';

class GsplSignRequestUR extends UR {
  final String path;
  final Uint8List uuid;
  final GsplTxData gsplTxData;

  GsplSignRequestUR({required UR ur, required this.uuid, required this.path, required this.gsplTxData}) : super(payload: ur.payload, type: ur.type);

  factory GsplSignRequestUR.fromTypedTransaction({
    required String hex,
    required String path,
    required String xfp,
    required String origin,
    required List<GsplItem> inputs,
    GsplItem? change,
    Uint8List? uuid
  }) {
    uuid ??= _generateUUid();
    final GsplTxData gspl = GsplTxData(dataType: BtcSignDataType.TRANSACTION, inputs: inputs, change: change, hex: hex);

    final ur = UR.fromCBOR(
      uuid: uuid,
      type: BTC_SIGN_REQUEST,
      value: CborMap({
        CborSmallInt(1): CborBytes(uuid, tags: [37]),
        CborSmallInt(2): gspl.toCbor(),
        CborSmallInt(3): CborMap({
          CborSmallInt(1): CborList(getPath(path)),
          CborSmallInt(2): CborInt(toXfpCode(xfp))
        }, tags: [40304]),
        CborSmallInt(4): CborString(origin)
      })
    );

    final item = GsplSignRequestUR(ur: ur, uuid: uuid, gsplTxData: gspl, path: path);

    return item;
  }

  static Uint8List _generateUUid() => Uuid().v8obj().toBytes();
}
