import 'dart:typed_data';

import 'package:cbor/cbor.dart';
import 'package:crypto_wallet_util/crypto_utils.dart';
import 'package:bc_ur_dart/src/ur.dart';
import 'package:bc_ur_dart/src/utils/utils.dart';

const String BTC_SIGNATURE = 'BTC-SIGNATURE';

class BtcSignatureUR extends UR {
  final Uint8List uuid;
  final Uint8List signature;

  BtcSignatureUR({required this.uuid, required this.signature, super.type, super.payload});

  factory BtcSignatureUR.fromUR({required UR ur}) {
    if (ur.type.toUpperCase() != BTC_SIGNATURE) throw Exception('Invalid type: ${ur.type}');

    final data = ur.decodeCBOR() as CborMap;

    final uuid = Uint8List.fromList((data[CborSmallInt(1)] as CborBytes).bytes);
    final signature = Uint8List.fromList((data[CborSmallInt(2)] as CborBytes).bytes);

    return BtcSignatureUR(uuid: uuid, signature: signature, type: ur.type, payload: ur.payload);
  }

  // factory BtcSignatureUR.fromSignature({required EthSignRequestUR request, required BigInt r, required BigInt s, required int v}) {
  //   v = getV(v: v, chainId: request.chainId, txType: request.txType);
  //   final signature = Uint8List.fromList(bigIntToByte(r, 32) + bigIntToByte(s, 32) + [v]);

  //   final ur = UR.fromCBOR(
  //     type: BTC_SIGNATURE,
  //     value: CborMap({
  //       CborSmallInt(1): CborBytes(request.uuid, tags: [37]),
  //       CborSmallInt(2): CborBytes(signature)
  //     })
  //   );

  //   return BtcSignatureUR(uuid: request.uuid, signature: signature, type: BTC_SIGNATURE, payload: ur.payload);
  // }
}
