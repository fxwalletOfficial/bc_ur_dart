import 'dart:typed_data';

import 'package:cbor/cbor.dart';
import 'package:convert/convert.dart';
import 'package:crypto_wallet_util/crypto_utils.dart';
import 'package:uuid/uuid.dart';
import 'package:web3dart/web3dart.dart';

import 'package:bc_ur_dart/src/ur.dart';
import 'package:bc_ur_dart/src/utils/utils.dart';

const String ETH_SIGN_REQUEST = 'ETH-SIGN-REQUEST';

class EthSignRequestUR extends UR {
  final Uint8List uuid;
  final int chainId;
  final EthSignDataType dataType;
  final Uint8List data;

  final EthereumAddress address;
  final String origin;

  EthTxType get txType => _tx.txType;

  EthTxData _tx = Eip1559TxData(data: EthTxDataRaw(nonce: 0, gasLimit: 0, value: BigInt.zero), network: TxNetwork(chainId: 1));
  EthTxData get tx => _tx;

  EthSignRequestUR({required UR ur, required this.uuid, required this.chainId, required this.dataType, required this.data, required this.address, this.origin = ''}) : super(payload: ur.payload, type: ur.type);

  factory EthSignRequestUR.fromTypedTransaction({required EthTxData tx, required String address, required String path, required String origin, Uint8List? uuid}) {
    uuid ??= _generateUUid();
    final dataType = EthSignDataType.ETH_TYPED_TRANSACTION;
    final addr = EthereumAddress.fromHex(address);
    final msg = tx.serialize(sig: false);

    final ur = UR.fromCBOR(
      type: ETH_SIGN_REQUEST,
      value: CborMap({
        CborSmallInt(1): CborBytes(uuid, tags: [37]),
        CborSmallInt(2): CborBytes(msg),
        CborSmallInt(3): CborSmallInt(dataType.index),
        CborSmallInt(4): CborSmallInt(tx.network.chainId),
        CborSmallInt(5):  CborMap({
          CborSmallInt(1): CborList(getPath(path)),
          CborSmallInt(2): CborInt(BigInt.from(4245356866))
        }, tags: [304]),
        CborSmallInt(6): CborBytes(addr.addressBytes),
        CborSmallInt(7): CborString(origin)
      })
    );

    final item = EthSignRequestUR(ur: ur, uuid: uuid, chainId: tx.network.chainId, dataType: dataType, data: msg, address: addr, origin: origin);
    item.setTx(tx);

    return item;
  }

  factory EthSignRequestUR.fromUR({required UR ur}) {
    if (ur.type.toUpperCase() != ETH_SIGN_REQUEST) throw Exception('Invalid type');

    final data = ur.decodeCBOR() as CborMap;

    final uuid = Uint8List.fromList((data[CborSmallInt(1)] as CborBytes).bytes);
    final msg = Uint8List.fromList((data[CborSmallInt(2)] as CborBytes).bytes);
    final dataType = EthSignDataType.values[(data[CborSmallInt(3)] as CborSmallInt).value];
    final chainId = (data[CborSmallInt(4)] as CborSmallInt).value;
    final address = EthereumAddress(Uint8List.fromList((data[CborSmallInt(6)] as CborBytes).bytes));
    final origin = data[CborSmallInt(7)] == null ? '' : (data[CborSmallInt(7)] as CborString).toString();

    final item = EthSignRequestUR(ur: ur, uuid: uuid, chainId: chainId, dataType: dataType, data: msg, address: address, origin: origin);

    switch (dataType) {
      case EthSignDataType.ETH_TRANSACTION_DATA:
      case EthSignDataType.ETH_TYPED_TRANSACTION:
        item.decodeTransaction();
        break;

      default:
        break;
    }

    return item;
  }

  void setTx(EthTxData item) => _tx = item;

  void decodeTransaction() {
    if (data.first == 2) {
      _tx = Eip1559TxData.deserialize(hex.encode(data));
    } else {
      _tx = LegacyTxData.deserialize(hex.encode(data), chainId: chainId);
    }

    _value = tx.data.value;
    _to = _tx.data.to;
    final input = stringToBytes(tx.data.data);
    if (input.length != 68) return;

    // Handle ERC-20 Simple token transfer information.
    _to = '0x${hex.encode(input.sublist(16, 36))}';
    _token = tx.data.to;
    _value = BigInt.parse(hex.encode(input.sublist(36)), radix: 16);
  }

  BigInt _value = BigInt.zero;
  BigInt get value => _value;

  String _to = '';
  String get to => _to;

  String _token = '';
  String get token => _token;

  static Uint8List _generateUUid() => Uuid().v8obj().toBytes();
}

enum EthSignDataType {
  NONE,
  ETH_TRANSACTION_DATA,
  ETH_TYPED_DATA,
  ETH_RAW_BYTES,
  ETH_TYPED_TRANSACTION
}
