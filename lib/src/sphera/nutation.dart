/// Calculates effects of nutation on the ecliptic longitude, **dpsi**, and on
/// the obliquity of the ecliptic, **deps** with accuracy of about 1 arcsecond.
///
/// Source: P.Duffett-Smith, "Astronomy with Your PC", 2 edition.
library;

import 'dart:math';
import 'package:vector_math/vector_math.dart';
import '../mathutils.dart';

typedef NutationRecord = ({
  double deltaPsi, // Nutation in longitude, arc-degrees
  double deltaEps // Nutation in obliquity, arc-degrees
});

NutationRecord nutation(double t) {
  final t2 = t * t;

  final ls = radians(2.796967E2 + 3.030E-4 * t2 + frac360(1.000021358E2 * t));
  final ms = radians(3.584758E2 - 1.500E-4 * t2 + frac360(9.999736056E1 * t));
  final ld = radians(2.704342E2 - 1.133E-3 * t2 + frac360(1.336855231E3 * t));
  final md = radians(2.961046E2 + 9.192E-3 * t2 + frac360(1.325552359E3 * t));
  final nm = radians(2.591833E2 + 2.078E-3 * t2 - frac360(5.372616667 * t));
  final tls = ls + ls;
  final tld = ld + ld;
  final tnm = nm + nm;

  double dpsi = (-17.2327 - 1.737e-2 * t) * sin(nm) +
      (-1.2729 - 1.3E-4 * t) * sin(tls) +
      2.088e-1 * sin(tnm) -
      2.037e-1 * sin(tld) +
      (1.261e-1 - 3.1e-4 * t) * sin(ms) +
      6.75e-2 * sin(md) -
      (4.97e-2 - 1.2e-4 * t) * sin(tls + ms) -
      3.42e-2 * sin(tld - nm) -
      2.61e-2 * sin(tld + md) +
      2.14e-2 * sin(tls - ms) -
      1.49e-2 * sin(tls - tld + md) +
      1.24e-2 * sin(tls - nm) +
      1.14e-2 * sin(tld - md);
  dpsi /= 3600;

  double deps = (9.21 + 9.1e-4 * t) * cos(nm) +
      (5.522e-1 - 2.9e-4 * t) * cos(tls) -
      9.04e-2 * cos(tnm) +
      8.84e-2 * cos(tld) +
      2.16e-2 * cos(tls + ms) +
      1.83e-2 * cos(tld - nm) +
      1.13e-2 * cos(tld + md) -
      9.3e-3 * cos(tls - ms) -
      6.6e-3 * cos(tls - nm);
  deps /= 3600;

  return (
    deltaPsi: dpsi,
    deltaEps: deps
  ); //  1965-2-1 11:46 dpsi = -0.0042774118548615766
}
