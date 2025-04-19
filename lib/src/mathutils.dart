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
  return terms.reversed.fold(0.0, (a, b) => a * t + b);
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

/// Converts the fractional part of a revolution count [x] into degrees.
///
/// This function is commonly used in astronomical or astrological calculations
/// to isolate the non-integer part of a number representing full revolutions
/// (e.g., Julian centuries, orbital periods, etc.) and convert it into
/// an angle in degrees.
///
/// The result preserves the sign of the fractional part:
///   - `frac360(1.25)` → `90.0`
///   - `frac360(-1.25)` → `-90.0`
///
/// This differs from `x % 360`, which returns a value in the range [0, 360).
///
/// Example:
///   ```dart
///   final angle = frac360(2.75); // returns 270.0
///   ```
double frac360(double x) => frac(x) * 360;

/// Converts (deg, min, sec) to decimal degrees.
double ddd(int deg, int min, [double sec = 0.0]) {
  final sign = deg < 0 || min < 0 || sec < 0 ? -1 : 1;
  return sign *
      (deg.abs() + (min.abs() + sec.abs() / 60.0) / 60.0);
}

/// Converts decimal degrees to (deg, min, sec).
/// The sign is only applied to the first non-zero component.
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

/// Returns the shortest distance (arc length) in degrees between angles [a] and [b].
///
/// The result is always positive and in the range [0, 180].
/// Useful when comparing angles regardless of direction (e.g., aspect orbs).
double shortestArc(double a, double b) {
  final x = (a - b).abs();
  return x > 180 ? 360 - x : x;
}

/// Calculate shortest arc in dergees between [a] and [b], radians
double shortestArcRad(double a, double b) {
  final x = (a - b).abs();
  return x > pi ? pi2 - x : x;
}

/// Returns the signed angular difference `b - a`, normalized to [-180, 180] degrees.
///
/// This accounts for circular wrap-around (e.g., from 359° to 1°),
/// and is useful when determining the direction and amount of angular motion.
double diffAngle(double a, double b) {
  final x = (b < a) ? b + 360 - a : b - a;
  return x > 180 ? x - 360 : x;
}

/// Polar coordinates
typedef Polar = ({
  double rho,

  /// Radial coordinate
  double phi

  /// Angular coordinate
});
