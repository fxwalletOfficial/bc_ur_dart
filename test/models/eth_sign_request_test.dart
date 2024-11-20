import 'dart:typed_data';

import 'package:bc_ur_dart/bc_ur_dart.dart';
import 'package:bc_ur_dart/src/models/eth/eth_sign_request.dart';
import 'package:bc_ur_dart/src/ur.dart';
import 'package:convert/convert.dart';
import 'package:crypto_wallet_util/crypto_utils.dart';
import 'package:test/test.dart';

void main() {
  final path = "m/44'/60'/0'/0/0";
  final chainId = 1;
  final address = '0x68c6Fe222de676e9db081253fd808922047626eC';
  final uuid = Uint8List.fromList([0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15]);
  final origin = 'wallet';
  final tx = Eip1559TxData(
    data: EthTxDataRaw(
      nonce: 0,
      gasLimit: 21000,
      value: BigInt.zero,
      to: '0xa12AD11e6699344e20758915695bD5538420E318',
      maxPriorityFeePerGas: 1000000000,
      maxFeePerGas: 2000000000,
      data: '0x62015bdc000000000000000000000000414ca8715310264d8610057f55d0b6e0fa39a720'
    ),
    network: TxNetwork(chainId: chainId)
  );

  final urs = [
    'UR:ETH-SIGN-REQUEST/1-3/LPADAXCSOYCYSTZCHFASHDENOSADTPDAGDAEADAOAXAAAHAMATAYASBKBDBNBTBABSAOHDGLAOYAGRADLALRFRNYSGAELRKTECMWAELFGMAYMWOYDRTTCKIYNLEEGLCXKPLDPYZTINDA',
    'UR:ETH-SIGN-REQUEST/2-3/LPAOAXCSOYCYSTZCHFASHDENBZINHPTLGULRCXVLCSLAOXIDADHPUOAEAEAEAEAEAEAEAEAEAEAEAEFPGSPDJSGUBEDSGTLNBEAHLBGOTIRPVTZSESOSCXRTAXAAAAADAHTAWLWKIMAH',
    'UR:ETH-SIGN-REQUEST/3-3/LPAXAXCSOYCYSTZCHFASHDENADDYOEADLECSDWYKCSFNYKAEYKAEWKAEWKAOCYZCBDADFWAMGHISSWZECPDPVAKOWLUYAYBGGUZCLALDCPAAKODSWPATIYKTHSJZJZIHJYAERLLRQDWN',
    'UR:ETH-SIGN-REQUEST/4-3/LPAAAXCSOYCYSTZCHFASHDENBBHKYTTYTANSBNCMAERFGYIDWKHPDEAEWKAOCYZCBDADFWAMGHISSWRSJTLPMSDAYTZCFEMWFXYAZMUOWZPRMTUOTLNBFGRLIDISISIEJSTAKINYBGLD',
    'UR:ETH-SIGN-REQUEST/5-3/LPAHAXCSOYCYSTZCHFASHDENOSADTPDAGDAEADAOAXAAAHAMATAYASBKBDBNBTBABSAOHDGLAOYAGRADLALRFRNYSGAELRKTECMWAELFGMAYMWOYDRTTCKIYNLEEGLCXKPLDSKSWDEKB',
    'UR:ETH-SIGN-REQUEST/6-3/LPAMAXCSOYCYSTZCHFASHDENPRISLSWTAXLRCLVYCWLROYIEAMGUTLBKBDBNBTBABSAOHDGLAOYAGRFZSFDWGESOTNDSSOWNDAMELBTSLFRNJYHPBWKOFMOLNYDYGECLJOGDHSVOSPHL',
    'UR:ETH-SIGN-REQUEST/7-3/LPATAXCSOYCYSTZCHFASHDENBZINHPTLGULRCXVLCSLAOXIDADHPUOAEAEAEAEAEAEAEAEAEAEAEAEFPGSPDJSGUBEDSGTLNBEAHLBGOTIRPVTZSESOSCXRTAXAAAAADAHTAATDKKKRO',
    'UR:ETH-SIGN-REQUEST/8-3/LPAYAXCSOYCYSTZCHFASHDENOSADTPDAGDAEADAOAXAAAHAMATAYASBKBDBNBTBABSAOHDGLAOYAGRADLALRFRNYSGAELRKTECMWAELFGMAYMWOYDRTTCKIYNLEEGLCXKPLDYLIDRHKP'
  ];

  test('Eth sign request typed transaction encode', () {
    final ur = EthSignRequestUR.fromTypedTransaction(tx: tx, address: address, path: path, uuid: uuid, origin: origin, xfp: MASTER_FINGERPRINT);
    ur.maxLength = 80;

    for (final item in urs) {
      expect(ur.next(), item);
    }
  });

  test('Eth sign request typed transaction decode', () {
    final ur = UR();
    for (final item in urs) {
      ur.read(item);
      if (ur.isComplete) break;
    }

    final request = EthSignRequestUR.fromUR(ur: ur);
    expect(hex.encode(request.uuid), hex.encode(uuid));
    expect(request.chainId, chainId);
    expect(request.dataType, EthSignDataType.ETH_TYPED_TRANSACTION);
    expect(hex.encode(request.data), hex.encode(tx.serialize(sig: false)));
    expect(request.address.toString().toLowerCase(), address.toLowerCase());
    expect(request.origin, origin);
  });
}
