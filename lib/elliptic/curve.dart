import 'params.dart';

/// Curve is an interface that other elliptic curves must implement.
abstract class Curve {
  /// params returns the curve parameters.
  CurveParams get params;

  /// isOnCurve reports whether the given (x, y) point is on the curve.
  ///
  /// Note: this is a low-level unsafe API. For ECDH, use the cryptolib/ecdh.dart
  /// library instead.
  bool isOnCurve(BigInt x, BigInt y);

  /// add returns the sum of the two given points.
  ///
  /// Note: this is a low-level unsafe API.
  List<BigInt> add(BigInt x1, BigInt y1, BigInt x2, BigInt y2);

  /// double returns the sum of the given point with itself.
  ///
  /// Note: this is a low-level unsafe API.
  List<BigInt> double(BigInt x, BigInt y1);

  /// scalarMult returns the product of the given point and scalar.
  ///
  /// Note: this is a low-level unsafe API.
  List<BigInt> scalarMult(BigInt bx, BigInt by, List<int> k);

  /// scalarBaseMult returns the product of the base point and scalar.
  ///
  /// Note: this is a low-level unsafe API.
  List<BigInt> scalarBaseMult(List<int> k);
}
