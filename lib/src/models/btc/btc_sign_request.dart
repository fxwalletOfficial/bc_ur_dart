import 'dart:typed_data';

import 'package:cbor/cbor.dart';
import 'package:uuid/uuid.dart';

import 'package:bc_ur_dart/src/ur.dart';
import 'package:bc_ur_dart/src/utils/utils.dart';

const String BTC_SIGN_REQUEST = 'BTC-SIGN-REQUEST';

class BtcSignRequestUR extends UR {
  final Uint8List uuid;
  final BtcSignDataType dataType;
  final String psbt;
  final String path;

  BtcSignRequestUR({required UR ur, required this.uuid, required this.dataType, required this.psbt, required this.path}) : super(payload: ur.payload, type: ur.type);

  factory BtcSignRequestUR.fromTypedTransaction({required String path, Uint8List? uuid, required String psbt, required String xfp, required String origin}) {
    uuid ??= _generateUUid();
    final dataType = BtcSignDataType.TRANSACTION;

    final ur = UR.fromCBOR(
      uuid: uuid,
      type: BTC_SIGN_REQUEST,
      value: CborMap({
        CborSmallInt(1): CborBytes(uuid, tags: [37]),
        CborSmallInt(2): CborBytes(stringToBytes(psbt)),
        CborSmallInt(3):  CborMap({
          CborSmallInt(1): CborList(getPath(path)),
          CborSmallInt(2): CborInt(BigInt.parse(xfp))
        }, tags: [304]),
        CborSmallInt(4): CborString(origin)
      })
    );

    final item = BtcSignRequestUR(ur: ur, uuid: uuid, path: path, psbt: psbt, dataType: dataType);

    return item;
  }

  // factory BtcSignRequestUR.fromUR({required UR ur}) {
  //   if (ur.type.toUpperCase() != BTC_SIGN_REQUEST) throw Exception('Invalid type');

  //   final data = ur.decodeCBOR() as CborMap;

  //   final uuid = Uint8List.fromList((data[CborSmallInt(1)] as CborBytes).bytes);
  //   final msg = Uint8List.fromList((data[CborSmallInt(2)] as CborBytes).bytes);
  //   final dataType = EthSignDataType.values[(data[CborSmallInt(3)] as CborSmallInt).value];
  //   final chainId = (data[CborSmallInt(4)] as CborSmallInt).value;
  //   final address = EthereumAddress(Uint8List.fromList((data[CborSmallInt(6)] as CborBytes).bytes));
  //   final origin = data[CborSmallInt(7)] == null ? '' : (data[CborSmallInt(7)] as CborString).toString();

  //   final item = BtcSignRequestUR(ur: ur, uuid: uuid, chainId: chainId, dataType: dataType, data: msg, address: address, origin: origin);

  //   switch (dataType) {
  //     case EthSignDataType.ETH_TRANSACTION_DATA:
  //     case EthSignDataType.ETH_TYPED_TRANSACTION:
  //       item.decodeTransaction();
  //       break;

  //     default:
  //       break;
  //   }

  //   return item;
  // }

  // void setTx(EthTxData item) => _tx = item;

  // void decodeTransaction() {
  //   if (data.first == 2) {
  //     _tx = Eip1559TxData.deserialize(hex.encode(data));
  //   } else {
  //     _tx = LegacyTxData.deserialize(hex.encode(data));
  //   }

  //   _value = tx.data.value;
  //   _to = _tx.data.to;
  //   final input = stringToBytes(tx.data.data);
  //   if (input.length != 68) return;

  //   // Handle ERC-20 Simple token transfer information.
  //   _to = '0x${hex.encode(input.sublist(16, 36))}';
  //   _token = tx.data.to;
  //   _value = BigInt.parse(hex.encode(input.sublist(36)), radix: 16);
  // }

  BigInt _value = BigInt.zero;
  BigInt get value => _value;

  String _to = '';
  String get to => _to;

  String _token = '';
  String get token => _token;

  static Uint8List _generateUUid() => Uuid().v8obj().toBytes();
}

enum BtcSignDataType {
  ZERO,
  TRANSACTION,
  MESSAGE
}
