import 'dart:convert';
import 'dart:typed_data';

import 'package:bc_ur_dart/bc_ur_dart.dart';
import 'package:bip32/bip32.dart';

const String CRYPTO_MULTI_ACCOUNTS = 'CRYPTO-MULTI-ACCOUNTS';
const String MASTER_FINGERPRINT = '4245356866';

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

class CryptoMultiAccountsUR extends UR {
  // final BIP32 wallet;
  final List<CryptoAccountItem> chains;
  final String masterFingerprint;
  final String device;
  final String walletName;

  CryptoMultiAccountsUR({required UR ur, required this.chains, required this.device, required this.walletName, required this.masterFingerprint}) : super(payload: ur.payload, type: ur.type);

  // CryptoMultiAccountsUR.fromWallet({
  //   required this.name,
  //   required this.path,
  //   required this.wallet
  // }) : super.fromCBOR(
  //   type: CRYPTO_MULTI_ACCOUNTS,
  //   value: CborMap({
  //     CborSmallInt(3): CborBytes(wallet.publicKey),
  //     CborSmallInt(4): CborBytes(wallet.chainCode),
  //     CborSmallInt(6):  CborMap({
  //       CborSmallInt(1): CborList(getPath(path)),
  //       CborSmallInt(2): CborInt(BigInt.from(wallet.parentFingerprint))
  //     }, tags: [304]),
  //     CborSmallInt(8): CborInt(BigInt.from(wallet.parentFingerprint)),
  //     CborSmallInt(9): CborString(name)
  //   })
  // );

  static CryptoMultiAccountsUR fromUR({required UR ur}) {
    if (ur.type.toUpperCase() != CRYPTO_MULTI_ACCOUNTS) throw Exception('Invalid type');

    final data = ur.decodeCBOR() as CborMap;

    final masterFingerprint = (data[CborSmallInt(1)] as CborBigInt).toString();
    print(masterFingerprint);

    final chains = (data[CborSmallInt(2)] as CborList);
    List<CryptoAccountItem> chainList = [];

    for (final item in chains) {
      final chainInfo = CryptoAccountItem.fromCborMap(item as CborMap);
      if (chainInfo != null) chainList.add(chainInfo);
    }

    final name = data[CborSmallInt(3)].toString();
    final walletName = data[CborSmallInt(6)].toString();

    return CryptoMultiAccountsUR(ur: ur, chains: chainList, device: name, walletName: walletName, masterFingerprint: masterFingerprint);
  }

//   @override
//   String toString() => '''
// {
// "derivationPath":"$path"
// "masterFingerprint":"${hex.encode(wallet.fingerprint)}"
// "extendedPublicKey": "${wallet.toBase58()}",
// "chainCode": "${hex.encode(wallet.chainCode)}"
// "walletName":"$name"
// }
//   ''';
}

class CryptoAccountItem {
  final String path;
  final String chain;
  final BIP32 wallet;
  String coin;

  CryptoAccountItem({
    required this.path,
    required this.wallet,
    required this.chain,
    this.coin = '',
  });

  static CryptoAccountItem? fromCborMap(CborMap data) {
    if (data[CborSmallInt(4)] == null) return null;
    // Wallet.
    final publicKey = Uint8List.fromList((data[CborSmallInt(3)] as CborBytes).bytes);
    final chainCode = Uint8List.fromList((data[CborSmallInt(4)] as CborBytes).bytes);
    final wallet = BIP32.fromPublicKey(publicKey, chainCode);

    final parentFingerprint = (data[CborSmallInt(8)] as CborInt).toInt();

    // Path.
    final components = (data[CborSmallInt(6)] as CborMap)[CborSmallInt(1)] as CborList;
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

    wallet.parentFingerprint = parentFingerprint;
    wallet.depth = (components.length / 2).round();
    wallet.index = index;

    // Note.
    final note = data[CborSmallInt(10)].toString();
    final chains = (json.decode(note)['chain'] ?? []) as List;
    if (chains.isEmpty) return null;
    final chain = chains.first.toString();

    return CryptoAccountItem(path: path, wallet: wallet, chain: chain);
  }
}
