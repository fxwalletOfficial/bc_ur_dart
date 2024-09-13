import 'dart:typed_data';

import 'package:bip32/bip32.dart';
import 'package:cbor/cbor.dart';
import 'package:convert/convert.dart';

import 'package:bc_ur_dart/src/ur.dart';
import 'package:bc_ur_dart/src/utils/utils.dart';

const String CRYPTO_HD_KEY = 'CRYPTO-HDKEY';

/// ; An hd-key must be a derived key.
/// hd-key = {
///     derived-key
/// }
/// ; A derived key must be public, has an optional chain code, and
/// ; may carry additional metadata about its use and derivation.
/// ; To maintain isomorphism with [BIP32] and allow keys to be derived from
/// ; this key `chain-code`, `origin`, and `parent-fingerprint` must be present.
/// ; If `origin` contains only a single derivation step and also contains `source-fingerprint`,
/// ; then `parent-fingerprint` MUST be identical to `source-fingerprint` or may be omitted.
/// derived-key = (
///     key-data: key-data-bytes,
///     ? chain-code: chain-code-bytes       ; omit if no further keys may be derived from this key
///     ? origin: #6.304(crypto-keypath),    ; How the key was derived
///     ? name: text,                        ; A short name for this key.
///     ? source: text,                      ; The device info or any other description for this key
/// )
/// key-data = 3
/// chain-code = 4
/// origin = 6
/// name = 9
/// source = 10
///
/// uint8 = uint .size 1
/// key-data-bytes = bytes .size 33
/// chain-code-bytes = bytes .size 32

class CryptoHDKeyUR extends UR {
  final BIP32 wallet;
  final String path;
  final String name;

  CryptoHDKeyUR({required UR ur, required this.path, required this.name, required this.wallet}) : super(payload: ur.payload, type: ur.type);

  CryptoHDKeyUR.fromWallet({
    required this.name,
    required this.path,
    required this.wallet
  }) : super.fromCBOR(
    type: CRYPTO_HD_KEY,
    value: CborMap({
      CborSmallInt(3): CborBytes(wallet.publicKey),
      CborSmallInt(4): CborBytes(wallet.chainCode),
      CborSmallInt(6):  CborMap({
        CborSmallInt(1): CborList(getPath(path)),
        CborSmallInt(2): CborInt(BigInt.from(wallet.parentFingerprint))
      }, tags: [304]),
      CborSmallInt(8): CborInt(BigInt.from(wallet.parentFingerprint)),
      CborSmallInt(9): CborString(name)
    })
  );

  static CryptoHDKeyUR fromUR({required UR ur}) {
    if (ur.type.toUpperCase() != CRYPTO_HD_KEY) throw Exception('Invalid type');

    final data = ur.decodeCBOR() as CborMap;

    final publicKey = Uint8List.fromList((data[CborSmallInt(3)] as CborBytes).bytes);
    final chainCode = Uint8List.fromList((data[CborSmallInt(4)] as CborBytes).bytes);
    final parentFingerprint = (data[CborSmallInt(8)] as CborInt).toInt();
    final components = (data[CborSmallInt(6)] as CborMap)[CborSmallInt(1)] as CborList;
    final name = (data[CborSmallInt(9)] as CborString).toString();

    String path = 'm';
    int index = 0;
    for (final item in components) {
      if (item is CborSmallInt) {
        path += '/${item.value}';
        index = item.value;
      }

      if (item is CborBool && item.value) {
        path += "'";
        index += HIGHEST_BIT;
      }
    }

    final wallet = BIP32.fromPublicKey(publicKey, chainCode);
    wallet.parentFingerprint = parentFingerprint;
    wallet.depth = (components.length / 2).round();
    wallet.index = index;

    return CryptoHDKeyUR(ur: ur, wallet: wallet, path: path, name: name);
  }

  @override
  String toString() => '''
{
"derivationPath":"$path"
"masterFingerprint":"${hex.encode(wallet.fingerprint)}"
"extendedPublicKey": "${wallet.toBase58()}",
"chainCode": "${hex.encode(wallet.chainCode)}"
"walletName":"$name"
}
  ''';
}