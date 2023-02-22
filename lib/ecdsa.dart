import 'elliptic.dart';

class PublicKey {
  final Curve _c;
  final BigInt X;
  final BigInt Y;

  PublicKey(this._c, this.X, this.Y);
}

class PrivateKey {
  final PublicKey _pk;
  final BigInt D;

  PrivateKey(this._pk, this.D);

  PublicKey get public => _pk;
}
