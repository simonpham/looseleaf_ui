import 'dart:typed_data';

import 'package:looseleaf_ink/src/core/core.dart';

final ByteData _bits = ByteData(8);

int _hiWord(double x) {
  _bits.setFloat64(0, x, Endian.little);
  return _bits.getInt32(4, Endian.little);
}

int _loWord(double x) {
  _bits.setFloat64(0, x, Endian.little);
  return _bits.getUint32(0, Endian.little);
}

double _zeroLo(double x) {
  _bits.setFloat64(0, x, Endian.little);
  _bits.setUint32(0, 0, Endian.little);
  return _bits.getFloat64(0, Endian.little);
}

const double _pio2Hi = 1.57079632679489655800e+00;
const double _pio2Lo = 6.12323399573676603587e-17;
const double _pio4Hi = 7.85398163397448278999e-01;
const double _pS0 = 1.66666666666666657415e-01;
const double _pS1 = -3.25565818622400915405e-01;
const double _pS2 = 2.01212532134862925881e-01;
const double _pS3 = -4.00555345006794114027e-02;
const double _pS4 = 7.91534994289814532176e-04;
const double _pS5 = 3.47933107596021167570e-05;
const double _qS1 = -2.40339491173441421878e+00;
const double _qS2 = 2.02094576023350569471e+00;
const double _qS3 = -6.88283971605453293030e-01;
const double _qS4 = 7.70381505559019352791e-02;

double _p(double t) =>
    t * (_pS0 + t * (_pS1 + t * (_pS2 + t * (_pS3 + t * (_pS4 + t * _pS5)))));

double _q(double t) => 1 + t * (_qS1 + t * (_qS2 + t * (_qS3 + t * _qS4)));

/// `Math.asin` as V8 computes it (fdlibm `e_asin.c`).
double jsAsin(double x) {
  final hx = _hiWord(x);
  final ix = hx & 0x7fffffff;
  if (ix >= 0x3ff00000) {
    if (((ix - 0x3ff00000) | _loWord(x)) == 0) return x * _pio2Hi + x * _pio2Lo;
    return double.nan;
  }
  if (ix < 0x3fe00000) {
    if (ix < 0x3e400000) return x;
    final t = x * x;
    return x + x * (_p(t) / _q(t));
  }
  final t = (1 - x.abs()) * 0.5;
  final p = _p(t);
  final q = _q(t);
  final s = JsMath.sqrt(t);
  final double r;
  if (ix >= 0x3FEF3333) {
    r = _pio2Hi - (2.0 * (s + s * (p / q)) - _pio2Lo);
    return switch (hx > 0) {
      true => r,
      false => -r,
    };
  }
  final w = _zeroLo(s);
  final c = (t - w * w) / (s + w);
  final pp = 2.0 * s * (p / q) - (_pio2Lo - 2.0 * c);
  final qq = _pio4Hi - 2.0 * w;
  r = _pio4Hi - (pp - qq);
  return switch (hx > 0) {
    true => r,
    false => -r,
  };
}
