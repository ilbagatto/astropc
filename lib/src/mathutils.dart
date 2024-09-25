library;

import 'dart:math';

/// `2 * PI` = 360 degrees in radians
final pi2 = pi * 2;

/// Decompose a floating-point number [x].
/// The result always keeps sign of the argument, e.g.:
/// `modf(-5.5)` will produce `-0.5, -5.0`.
///
///
/// Example:
/// `modf(3.1452)`  `[0.1452, 3.0]`
(double, int) modf(double x) {
  final i = x.truncate();
  return (x - i, i);
}

/// Calculates polynome: `a1 + a2*t + a3*t*t + a4*t*t*t...`
/// [t] s a number of Julian centuries elapsed since 1900, Jan 0.5
/// [terms] is a list of coefficients
/// Example `polynome(10.0, [1.0, 2.0, 3.0])` gives `321.0`.
double polynome(double t, List<double> terms) {
  final rev = List.from(terms.reversed);
  return rev.reduce((a, b) => a * t + b);
}

/// Reduces [x] to 0 >= x < [r]
double toRange(double x, double r) {
  final a = x % r;
  return a < 0 ? a + r : a;
}

/// Reduces x to `0 >= x < 360`
double reduceDeg(double x) => toRange(x, 360.0);

/// Reduces x to `0 >= x <  PI * 2`
double reduceRad(double x) => toRange(x, pi2);

/// Fractional part of [x].
/// The result always keeps sign of the argument, e.g.: `frac(-5.5) = -0.5`
double frac(double x) {
  var res = x.abs() % 1.0;
  return x < 0 ? -res : res;
}

/// Used with polinomial function for better accuracy.
double frac360(double x) => frac(x) * 360;

/// Given hours (or degrees), minutes and seconds,
/// return decimal hours (or degrees). In the case of hours (angles) < 0.
double ddd(int d, int m, [double s = 0]) {
  final sgn = d < 0 || m < 0 || s < 0 ? -1 : 1;
  return (d.abs() + (m.abs() + s.abs() / 60.0) / 60.0) * sgn;
}

(int, int, double) dms(double x) {
  int d, m;
  double s;
  (double, int) fi;
  fi = modf(x.abs());
  d = fi.$2;
  fi = modf(fi.$1 * 60);
  m = fi.$2;
  fi = modf(fi.$1 * 60);
  s = fi.$1 + fi.$2;

  if (x < 0) {
    if (d != 0) {
      d = -d;
    } else if (m != 0) {
      m = -m;
    } else {
      s = -s;
    }
  }
  return (d, m, s);
}

/// Convert [x], decimal degrees to:
/// zodiac sign number (zero based), zodiac degrees, minutes and seconds.
(int, int, int, double) zdms(double x) {
  final dmsRes = dms(x);
  final d = dmsRes.$1;
  final z = (d / 30).truncate();
  return (z, d % 30, dmsRes.$2, dmsRes.$3);
}

/// Calculate shortest arc in dergees between [a] and [b], degrees.
double shortestArc(double a, double b) {
  final x = (a - b).abs();
  return x > 180 ? 360 - x : x;
}

/// Calculate shortest arc in dergees between [a] and [b], radians
double shortestArcRad(double a, double b) {
  final x = (a - b).abs();
  return x > pi ? pi2 - x : x;
}

/// Polar coordinates
typedef Polar = ({
  double rho,

  /// Radial coordinate
  double phi

  /// Angular coordinate
});
