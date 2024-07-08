/// Transforming between various types of celestial coordinates.
///
library;

import 'dart:math';
import 'package:vector_math/vector_math.dart';

import '../mathutils.dart';

/// @nodoc
const equToEcl = 1;

/// @nodoc
const eclToEqu = -1;

/// Converts between longitude/right ascension and latitude/declination.
/// The last argument is flag specifying the conversion direction:
/// [k] = 1 for equatorial -> ecliptical,
/// [k] =-1 for ecliptical -> etquatorial
///
/// Returns the pair of result coordinates.
///
/// All angular values are in *radians*.
(double, double) equecl(double x, double y, double e, int k) {
  final sinE = sin(e);
  final cosE = cos(e);
  final sinX = sin(x);
  final a = atan2(sinX * cosE + k * (tan(y) * sinE), cos(x));
  final b = asin(sin(y) * cosE - k * (cos(y) * sinE * sinX));
  return (reduceRad(a), b);
}

/// Converts between *azimuth/altitude* and *hour-angle/declination*.
/// The equations are symmetrical in the two pairs of coordinates so that
/// exactly the same code may be used to convert in either direction, there
/// is no need to specify direction with a swich (see Dufett-Smith, page 35).
///
/// Returns The pair of result coordinates.
/// All angular values are in *radians*.
(double, double) _equhor(double x, double y, double phi) {
  final sx = sin(x);
  final sy = sin(y);
  final sphi = sin(phi);
  final cx = cos(x);
  final cy = cos(y);
  final cphi = cos(phi);
  final sq = (sy * sphi) + (cy * cphi * cx);
  final q = asin(sq);
  final cp = (sy - (sphi * sq)) / (cphi * cos(q));
  var p = acos(cp);
  if (sx > 0) {
    p = pi2 - p;
  }
  return (p, q);
}

/// Intermediate function, converts radians to arc-degrees.
(double, double) _convertEquEcl(double x, double y, double e, int k) {
  final (a, b) = equecl(radians(x), radians(y), radians(e), k);
  return (degrees(a), degrees(b));
}

/// Intermediate function, converts radians to arc-degrees.
(double, double) _convertEquHor(double x, double y, double phi) {
  final (a, b) = _equhor(radians(x), radians(y), radians(phi));
  return (degrees(a), degrees(b));
}

/// Convert equatorial to ecliptical coordinates.
/// Arguments:
/// 1. [alpha]: right ascension
/// 2. [delta]: declination
/// 3. [eps]: obliquity of the ecliptic
///
/// Returns the pair of ecliptic coordinates, `(lambda, beta)`.
/// All angular values are in *arc-degrees*.
(double, double) equ2ecl(double alpha, double delta, double eps) {
  return _convertEquEcl(alpha, delta, eps, equToEcl);
}

/// Convert ecliptical to equatorial coordinates.
/// Arguments:
/// 1. [lambda]: longiude
/// 2. [beta]: latitude
/// 3. [eps]: obliquity of the ecliptic
///
/// Returns the pair of equatorial coordinates, `(alpha, delta)`.
///
/// All angular values are in *arc-degrees*.
(double, double) ecl2equ(double lambda, double beta, double eps) {
  return _convertEquEcl(lambda, beta, eps, eclToEqu);
}

/// Convert equatorial to horizontal coordinates.
///
/// Arguments:
/// 1. [h]: the local hour angle, in degrees, measured westwards from the South.
///   `h = LST - RA` (RA = Right Ascension)
/// 2. [delta]: declination, in degrees
/// 3. [phi]: the observer's latitude, in degrees, positive in the Nothern
///   hemisphere, negative in the Southern.
///
/// Returns the pair of coordinates:
/// 1. *azimuth*, in degrees, measured westward from the South
/// 2. *altitude*, in degrees, positive above the horizon
///
(double, double) equ2hor(double h, double delta, double phi) {
  return _convertEquHor(h, delta, phi);
}

/// Convert horizontal to equatorial coordinates.
///
/// Arguments:
/// 1. [az]: azimuth, in radians, measured westwards from the South.
///    `h = LST - RA` (RA = Right Ascension)
/// 2. alt: altitude, in radians, positive above the horizon
/// 3. phi: the observer's latitude, in radians, positive in the nothern
///    hemisphere, negative in the southern one
///
/// Returns the pair of coordinates:
/// 1. *hour angle*, in degrees
/// 2. *declination*, in degrees
///
(double, double) hor2equ(double az, double alt, double phi) {
  return _convertEquHor(az, alt, phi);
}
