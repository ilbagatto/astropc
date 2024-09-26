// ignore_for_file: constant_identifier_names
library;

import '../misc/nutation.dart';
import '../mathutils.dart';
import 'orbit.dart';

/// Planets identifiers
enum PlanetId {
  Mercury,
  Venus,
  Mars,
  Jupiter,
  Saturn,
  Uranus,
  Neptune,
  Pluto,
}

/// Provides information that is outside of a planet's
/// class scope, yet required to calculate its position.
///
/// For instance, to calculate Mercury perturbations we need
/// to know mean anomalies of Venus and Jupiter.
abstract class CelestialContext {
  /// Number of Julian days elapsed since 1900, Jan 0.5.
  /// Actually, this is moment of time for which all calculations are done.
  double get t;

  /// Given [id] of a planet, return its mean anomaly **in radians**.
  /// [dt] parameter is a time correction necessary when calculating
  /// *true* (light-time corrected) planetary positions.
  double getMeanAnomaly(PlanetId id, [double dt = 0]);

  /// Given [id] of a planet, return its orbit instantiated for a given moment.
  OrbitInstance getOrbitInstance(PlanetId id);

  /// Mean anomaly of the Sun, in radians.
  double get sunMeanAnomaly;

  /// True geocentric coordinates of the Sun.
  Polar get sunGeocentric;

  /// Return Nutation.
  NutationRecord get nutation;

  /// Auxiliraly Sun-related elements needed for calculating perturbations.
  List<double> get auxSun;

  /// If true, then the true geocentric position will be corrected
  /// for nutation and aberration.
  bool get apparent;
}

/// Ecliptic posiion of a celestial body
///
typedef EclipticPosition = ({
  /// geocentric ecliptic longitude, arc-degrees
  double lambda,

  /// geocentric ecliptic latitude, arc-degrees
  double beta,

  /// distance from the Earth. A.U.
  double delta
});
