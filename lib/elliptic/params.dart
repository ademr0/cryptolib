import 'curve.dart';

/// CurveParams contains the parameters of an elliptic curve.
class CurveParams implements Curve {
  final BigInt p; // The order of underlying field.
  final BigInt n; // The order of the base point.
  final BigInt b; // The constant term of the curve equation.
  final BigInt gx; // The x coordinate of the base point.
  final BigInt gy; // The y coordinate of the base point.
  final int bitSize; // The bit size of the underlying field.
  final String name; // The name of the curve.

  CurveParams(
      this.p, this.n, this.b, this.gx, this.gy, this.bitSize, this.name);

  @override
  CurveParams get params => this;

  // CurveParams operates, internally, on Jacobian coordinates.
  // For a given (x, y) point, the Jacobian coordinates are:
  // (x1, y1, z1) where x = x1/z1^2, y = y1/z1^3.

  // polynomial returns x^3 - 3x + b.
  BigInt polynomial(BigInt x) {
    BigInt x3 = x * x * x;
    BigInt threeX = (x << 1) + x;
    return ((x3 - threeX) + b) % p;
  }

  // isOnCurve reports whether the given (x, y) point is on the curve.
  @override
  bool isOnCurve(BigInt x, BigInt y) {
    // For now this function does not constant-time.
    if (x < BigInt.zero || x >= p || y < BigInt.zero || y >= p) {
      return false;
    }

    // y^2 = x^3 - 3x + b
    BigInt y2 = y * y % p;
    return polynomial(x) == y2;
  }

  // zForAffine returns the z value for the given affine point.
  // If x and y are zero, it assumes the point is at infinity because
  // (0, 0) is not a valid point on the curve.
  BigInt zForAffine(BigInt x, BigInt y) {
    if (x != BigInt.zero || y != BigInt.zero) {
      return BigInt.one;
    }
    return BigInt.zero;
  }

  // affineFromJacobian returns the affine coordinates for the given Jacobian.
  List<BigInt> affineFromJacobian(List<BigInt> jacobian) {
    if (jacobian.isEmpty || jacobian.length != 3) {
      throw Exception('invalid jacobian point');
    }
    BigInt x = jacobian[0];
    BigInt y = jacobian[1];
    BigInt z = jacobian[2];
    if (z == BigInt.zero) {
      return [BigInt.zero, BigInt.zero];
    }

    BigInt zInv = z.modInverse(p);
    BigInt zInvsq = zInv * zInv;

    BigInt xOut = x * zInvsq % p;
    zInvsq = zInvsq * zInv;
    BigInt yOut = y * zInvsq % p;
    return [xOut, yOut];
  }

  @override
  List<BigInt> add(BigInt x1, BigInt y1, BigInt x2, BigInt y2) {
    // If point is not on curve, panic.
    if (!isOnCurve(x1, y1) || !isOnCurve(x2, y2)) {
      throw Exception('point not on curve');
    }

    BigInt z1 = zForAffine(x1, y1);
    BigInt z2 = zForAffine(x2, y2);
    return affineFromJacobian(addJacobian(x1, y1, z1, x2, y2, z2));
  }

  // addJacobian returns the sum of the two given points in Jacobian coordinates.
  List<BigInt> addJacobian(
      BigInt x1, BigInt y1, BigInt z1, BigInt x2, BigInt y2, BigInt z2) {
    BigInt x3, y3, z3;
    if (z1 == BigInt.zero) {
      x3 = x2;
      y3 = y2;
      z3 = z2;
      return [x3, y3, z3];
    }
    if (z2 == BigInt.zero) {
      x3 = x1;
      y3 = y1;
      z3 = z1;
      return [x3, y3, z3];
    }

    BigInt z1z1 = z1 * z1 % p;
    BigInt z2z2 = z2 * z2 % p;

    BigInt u1 = x1 * z2z2 % p;
    BigInt u2 = x2 * z1z1 % p;

    BigInt h = u2 - u1;

    bool xEqual = h == BigInt.zero;

    if (h < BigInt.zero) {
      h = h + p;
    }

    BigInt i = h << 1;
    i = i * i;
    BigInt j = h * i;

    BigInt s1 = y1 * z2 * z2z2 % p;
    BigInt s2 = y2 * z1 * z1z1 % p;

    BigInt r = s2 - s1;
    if (r < BigInt.zero) {
      r = r + p;
    }

    bool yEqual = r == BigInt.zero;
    if (xEqual && yEqual) {
      return doubleJacobian(x1, y1, z1);
    }
    r = r << 1;
    BigInt v = u1 * i;

    x3 = r;
    x3 = ((x3 * x3) - j - v - v) % p;

    y3 = r;
    v = v - x3;
    y3 = y3 * v;
    s1 = (s1 * j) << 1;
    y3 = (y3 - s1) % p;

    z3 = z1 + z2;
    z3 = ((z3 * z3) - z1z1 - z2z2) * h % p;

    return [x3, y3, z3];
  }

  @override
  List<BigInt> double(BigInt x1, BigInt y1) {
    if (!isOnCurve(x1, y1)) {
      throw Exception('point not on curve');
    }

    BigInt z1 = zForAffine(x1, y1);
    return affineFromJacobian(doubleJacobian(x1, y1, z1));
  }

  // doubleJacobian returns the double of the given point in Jacobian coordinates.
  List<BigInt> doubleJacobian(BigInt x, BigInt y, BigInt z) {
    BigInt delta = z * z % p;
    BigInt gamma = y * y % p;
    BigInt alpha = x - delta;
    if (alpha < BigInt.zero) {
      alpha = alpha + p;
    }
    BigInt alpha2 = x + delta;
    alpha = alpha * alpha2;
    alpha2 = alpha << 1;
    alpha = alpha + alpha2;

    BigInt beta = x * gamma;
    BigInt x3 = alpha * alpha;
    BigInt beta8 = (beta << 3) % p;
    x3 = x3 - beta8;
    if (x3 < BigInt.zero) {
      x3 = x3 + p;
    }
    x3 = x3 % p;

    BigInt z3 = y + z;
    z3 = z3 * z3 - gamma;
    if (z3 < BigInt.zero) {
      z3 = z3 + p;
    }
    z3 = z3 - delta;
    if (z3 < BigInt.zero) {
      z3 = z3 + p;
    }
    z3 = z3 % p;

    beta = (beta << 2) - x3;
    if (beta < BigInt.zero) {
      beta = beta + p;
    }

    BigInt y3 = alpha * beta;

    gamma = ((gamma * gamma) << 3) % p;

    y3 = y3 - gamma;
    if (y3 < BigInt.zero) {
      y3 = y3 + p;
    }
    y3 = y3 % p;

    return [x3, y3, z3];
  }

  @override
  List<BigInt> scalarMult(BigInt bx, BigInt by, List<int> k) {
    if (!isOnCurve(bx, by)) {
      throw Exception('point not on curve');
    }

    BigInt bz = BigInt.one;
    List<BigInt> res = [BigInt.zero, BigInt.zero, BigInt.zero];

    for (int byte in k) {
      for (int bitnum = 0; bitnum < 8; bitnum++) {
        res = doubleJacobian(res[0], res[1], res[2]);
        if (byte & 0x80 == 0x80) {
          res = addJacobian(bx, by, bz, res[0], res[1], res[2]);
        }
        byte = byte << 1;
      }
    }

    return affineFromJacobian(res);
  }

  @override
  List<BigInt> scalarBaseMult(List<int> k) {
    return scalarMult(gx, gy, k);
  }
}
