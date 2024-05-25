library;

import 'package:vector_math/vector_math.dart';
import 'pert.dart';
import 'planet.dart';
import 'common.dart';
import 'orbit.dart';
import '../../mathutils.dart';
import '../misc/nutation.dart' as libnut;
import '../../timeutils.dart';
import '../sun/sun.dart' as sun;

class CelestialSphera implements CelestialContext {
  final bool _apparent;
  final double _t; // time in centuries since Jan 1900, 0
  // lsn: longitude of Sun, arc-degrees
  // rsn: Sun-Earth distance, AU
  final Polar _sunGeo;
  final double _ms; // Sun mean anomaly in radians
  final libnut.NutationRecord _nut; // nutation in longitude and obliquity

  final List<double> _auxSun = [];
  final Map<PlanetId, OrbitInstance> _orbits = {};

  /// Private constructor.
  CelestialSphera._(
    this._t,
    this._sunGeo,
    this._ms,
    this._nut,
    this._apparent,
  );

  /// Factory that substitutes the constructor.
  factory CelestialSphera(
    double djd, {
    apparent = true,
  }) {
    final t = djd / daysPerCent;
    final ms = sun.meanAnomaly(t);
    return CelestialSphera._(t, sun.trueGeocentric(t, ms), radians(ms),
        libnut.nutation(t), apparent);
  }

  /// Auxiliraly Sun-related elements needed for calculating perturbations.
  /// Once calculated, the values are cached.
  @override
  List<double> get auxSun {
    if (_auxSun.isEmpty) {
      final vals = buildAuxSun(_t);
      _auxSun.addAll(vals);
    }
    return _auxSun;
  }

  /// Given [id] of a planet, return its mean anomaly **in radians**.
  /// [dt] parameter is a time correction necessary when calculating
  /// *true* (light-time corrected) planetary positions.
  @override
  double getMeanAnomaly(PlanetId id, [double dt = 0]) {
    double ma = getOrbitInstance(id).ma;
    if (dt != 0) {
      ma -= radians(dt * Planet.forId(id).orbit.DM);
    }
    return ma;
  }

  /// Nutation.
  @override
  libnut.NutationRecord get nutation => _nut;

  /// Given [id] of a planet, return its orbit instantiated for a given moment.
  /// Once calculated, the `OrbitInstance` record is saved to the cache.
  @override
  OrbitInstance getOrbitInstance(PlanetId id) {
    if (_orbits.containsKey(id)) {
      return _orbits[id]!;
    }

    final oi = Planet.forId(id).orbit.instantiate(_t);
    _orbits[id] = oi;
    return oi;
  }

  /// True geocentric coordinates of the Sun.
  @override
  Polar get sunGeocentric => _sunGeo;

  /// Mean anomaly of the Sun, in radians.
  @override
  double get sunMeanAnomaly => _ms;

  /// Number of Julian days elapsed since 1900, Jan 0.5.
  @override
  double get t => _t;

  /// If true, then the true geocentric position will be corrected
  /// for nutation and aberration.
  @override
  bool get apparent => _apparent;
}
