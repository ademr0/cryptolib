import 'params.dart';

final BigInt _p = BigInt.parse(
    "26959946667150639794667015087019630673557916260026308143510066298881",
    radix: 10);

final BigInt _n = BigInt.parse(
    "26959946667150639794667015087019625940457807714424391721682722368061",
    radix: 10);

final BigInt _b = BigInt.parse(
    "0xb4050a850c04b3abf54132565044b0b7d7bfd8ba270b39432355ffb4",
    radix: 16);

final BigInt _gx = BigInt.parse(
    "0xb70e0cbd6bb4bf7f321390b94a03c1d356c21122343280d6115c1d21",
    radix: 16);

final BigInt _gy = BigInt.parse(
    "0xbd376388b5f723fb4c22dfe6cd4375a05a07476444d5819985007e34",
    radix: 16);

class P224 extends CurveParams {
  P224() : super(_p, _n, _b, _gx, _gy, 224, 'P-224');
}
