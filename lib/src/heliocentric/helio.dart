library;

import 'dart:math';

import 'package:vector_math/vector_math.dart';

import '../../mathutils.dart';
import '../misc/kepler.dart';
import 'orbit.dart';
import 'pert.dart';

// Params of calculated planetary heliocentric orbit
typedef HelioRecord = ({
  double ll,
  double rpd,
  double lpd,
  double spsi,
  double cpsi,
  double rho
});

/// Core part of heliocentric position calculation.
/// [oi] are osculating elements of the obit instantiated for
/// that moment.
/// [ma] - mean anomaly of the planet
/// [re] - Sun-Earth distance
/// [lg] - lonitude of the Earth
/// [pert] - PertRecord instance
HelioRecord calculateHeliocentric(
    OrbitInstance oi, double ma, double re, double lg, PertRecord pert) {
  final s = oi.s + pert.ds; // eccentricity corrected
  ma = reduceRad(ma + pert.dm); // mean anomaly corrected
  final ea = kepler(s, ma); // eccentric anomaly
  final nu = trueAnomaly(s, ea); // true anomaly
  // radius-vector
  final rp = (oi.sa + pert.da) * (1 - s * s) / (1 + s * cos(nu)) + pert.dr;
  final lp = nu + oi.ph + (pert.dml - pert.dm); // planet's orbital longitude
  final lo = lp - oi.nd;
  final sinLo = sin(lo);
  final spsi = sinLo * sin(oi.ic);
  final y = sinLo * cos(oi.ic);
  final psi = asin(spsi) + pert.dhl; // heliocentric latitude
  final lpd = atan2(y, cos(lo)) + oi.nd + radians(pert.dl);
  final cpsi = cos(psi);
  final ll = lpd - lg;
  // distance from the Earth
  final rho = sqrt(re * re + rp * rp - 2 * re * rp * cpsi * cos(ll));

  return (
    ll: ll,
    rpd: rp * cpsi,
    lpd: lpd,
    spsi: sin(psi), // not the same as spsi, for now psi is corrected
    cpsi: cpsi,
    rho: rho
  );
}
