import 'params.dart';

final BigInt _p = BigInt.parse(
    "115792089210356248762697446949407573530086143415290314195533631308867097853951",
    radix: 10);

final BigInt _n = BigInt.parse(
    "115792089210356248762697446949407573529996955224135760342422259061068512044369",
    radix: 10);

final BigInt _b = BigInt.parse(
    "0x5ac635d8aa3a93e7b3ebbd55769886bc651d06b0cc53b0f63bce3c3e27d2604b",
    radix: 16);

final BigInt _gx = BigInt.parse(
    "0x6b17d1f2e12c4247f8bce6e563a440f277037d812deb33a0f4a13945d898c296",
    radix: 16);

final BigInt _gy = BigInt.parse(
    "0x4fe342e2fe1a7f9b8ee7eb4a7c0f9e162bce33576b315ececbb6406837bf51f5",
    radix: 16);

class P256 extends CurveParams {
  P256() : super(_p, _n, _b, _gx, _gy, 224, 'P-224');
}
