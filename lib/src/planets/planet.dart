// ignore_for_file: constant_identifier_names
import 'dart:math';

import 'package:vector_math/vector_math.dart';

import '../../mathutils.dart';
import '../kepler.dart';
import 'orbit.dart';
import 'pert.dart';
import 'sphera.dart';

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

// Params of calculated planetary heliocentric orbit
typedef HelioRecord = ({
  double ll,
  double rpd,
  double lpd,
  double spsi,
  double cpsi,
  double rho
});

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

class Planet {
  /// Osculating elements of the orbit
  final OElements orbit;

  /// Planet identifier
  final PlanetId id;

  /// Planet name
  final String name;

  /// True if the planet is inner
  final bool isInner;

  /// Perturbations calculator
  final PertCalculator pertCalculator;

  /// Constructor
  Planet(
      {required this.id,
      required this.name,
      required this.orbit,
      required this.isInner,
      required this.pertCalculator});

  factory Planet.forId(PlanetId id) {
    switch (id) {
      case PlanetId.Mercury:
        return Planet(
            id: id,
            name: 'Mercury',
            orbit: OElements(
                ML: MLTerms(178.179078, 415.2057519, 3.011e-4),
                PH: Terms.make(75.899697, 1.5554889, 2.947e-4),
                EC: Terms.make(2.0561421e-1, 2.046e-5, -3e-8),
                IN: Terms.make(7.002881, 1.8608e-3, -1.83e-5),
                ND: Terms.make(47.145944, 1.1852083, 1.739e-4),
                SA: 3.870986e-1),
            isInner: true,
            pertCalculator: PertMercury());
      case PlanetId.Venus:
        return Planet(
            id: id,
            name: 'Venus',
            orbit: OElements(
                ML: MLTerms(342.767053, 162.5533664, 3.097e-4),
                PH: Terms.make(130.163833, 1.4080361, -9.764e-4),
                EC: Terms.make(6.82069e-3, -4.774e-5, 9.1e-8),
                IN: Terms.make(3.393631, 1.0058e-3, -1e-6),
                ND: Terms.make(75.779647, 8.9985e-1, 4.1e-4),
                SA: 7.233316e-1),
            isInner: true,
            pertCalculator: PertVenus());
      case PlanetId.Mars:
        return Planet(
            id: id,
            name: 'Mars',
            orbit: OElements(
                ML: MLTerms(293.737334, 53.17137642, 3.107e-4),
                PH: Terms.make(3.34218203e2, 1.8407584, 1.299e-4, -1.19e-6),
                EC: Terms.make(9.33129e-2, 9.2064e-5, -7.7e-8),
                IN: Terms.make(1.850333, -6.75e-4, 1.26e-5),
                ND: Terms.make(48.786442, 7.709917e-1, -1.4e-6, -5.33e-6),
                SA: 1.5236883),
            isInner: false,
            pertCalculator: PertMars());
      case PlanetId.Jupiter:
        return Planet(
            id: id,
            name: 'Jupiter',
            orbit: OElements(
                ML: MLTerms(238.049257, 8.434172183, 3.347e-4, -1.65e-6),
                PH: Terms.make(1.2720972e1, 1.6099617, 1.05627e-3, -3.43e-6),
                EC: Terms.make(4.833475e-2, 1.6418e-4, -4.676e-7, -1.7e-9),
                IN: Terms.make(1.308736, -5.6961e-3, 3.9e-6),
                ND: Terms.make(99.443414, 1.01053, 3.5222e-4, -8.51e-6),
                SA: 5.202561),
            isInner: false,
            pertCalculator: PertJupiter());
      case PlanetId.Saturn:
        return Planet(
            id: id,
            name: 'Saturn',
            orbit: OElements(
                ML: MLTerms(266.564377, 3.398638567, 3.245e-4, -5.8e-6),
                PH: Terms.make(9.1098214e1, 1.9584158, 8.2636e-4, 4.61e-6),
                EC: Terms.make(5.589232e-2, -3.455e-4, -7.28e-7, 7.4e-10),
                IN: Terms.make(2.492519, -3.9189e-3, -1.549e-5, 4e-8),
                ND: Terms.make(112.790414, 8.731951e-1, -1.5218e-4, -5.31e-6),
                SA: 9.554747),
            isInner: false,
            pertCalculator: PertSaturn());
      case PlanetId.Uranus:
        return Planet(
            id: id,
            name: 'Uranus',
            orbit: OElements(
                ML: MLTerms(244.19747, 1.194065406, 3.16e-4, -6e-7),
                PH: Terms.make(1.71548692e2, 1.4844328, 2.372e-4, -6.1e-7),
                EC: Terms.make(4.63444e-2, -2.658e-5, 7.7e-8),
                IN: Terms.make(7.72464e-1, 6.253e-4, 3.95e-5),
                ND: Terms.make(73.477111, 4.986678e-1, 1.3117e-3),
                SA: 19.21814),
            isInner: false,
            pertCalculator: PertUranus());
      case PlanetId.Neptune:
        return Planet(
            id: id,
            name: 'Neptune',
            orbit: OElements(
                ML: MLTerms(84.457994, 6.107942056e-1, 3.205e-4, -6e-7),
                PH: Terms.make(4.6727364e1, 1.4245744, 3.9082e-4, -6.05e-7),
                EC: Terms.make(8.99704e-3, 6.33e-6, -2e-9),
                IN: Terms.make(1.779242, -9.5436e-3, -9.1e-6),
                ND: Terms.make(130.681389, 1.098935, 2.4987e-4, -4.718e-6),
                SA: 30.10957),
            isInner: false,
            pertCalculator: PertNeptune());

      case PlanetId.Pluto:
        return Planet(
            id: id,
            name: 'Pluto',
            orbit: OElements(
                ML: MLTerms(95.3113544, 3.980332167e-1),
                PH: Terms.make(224.017),
                EC: Terms.make(2.5515e-1),
                IN: Terms.make(17.1329),
                ND: Terms.make(110.191),
                SA: 39.8151),
            isInner: false,
            pertCalculator: PertPluto());
    }
  }

  factory Planet.forName(String name) {
    switch (name) {
      case "Mercury":
        return Planet.forId(PlanetId.Mercury);
      case "Venus":
        return Planet.forId(PlanetId.Venus);
      case "Mars":
        return Planet.forId(PlanetId.Mars);
      case "Jupiter":
        return Planet.forId(PlanetId.Jupiter);
      case "Saturn":
        return Planet.forId(PlanetId.Saturn);
      case "Uranus":
        return Planet.forId(PlanetId.Uranus);
      case "Neptune":
        return Planet.forId(PlanetId.Neptune);
      case "Pluto":
        return Planet.forId(PlanetId.Pluto);
    }

    throw 'Unknown planet name: $name';
  }

  /// Core part of heliocentric position calculation.
  /// [oi] are osculating elements of the obit instantiated for
  /// that moment.
  /// [ma] - mean anomaly of the planet
  /// [re] - Sun-Earth distance
  /// [lg] - lonitude of the Earth
  /// [pert] - PertRecord instance
  static HelioRecord calculateHeliocentric(
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

  /// Calculates perturbations.
  /// [ctx] is a context, [dt] is optional `delta-T` in seconds.
  /// Typically, some members of the returned PertRecord instance are
  /// initialized while others contain zeroes.
  PertRecord calculatePerturbations(CelestialSphera ctx, [double dt = 0]) {
    return pertCalculator.calculatePerturbations(ctx, dt);
  }

  /// Calculate heliocentric position taking account of the finit light-travel
  /// time between the Earth and the planet.
  ///
  /// This method is recursive.
  ///
  /// > When we view a planet now, we see it in the position it occupied t
  /// > hours ago, given by *t = 0.1386 x RH*, where RH is the distance in AU
  /// > between the Earth and the planet. In this routine, an approximate position
  /// > for the planet is first calculated, neglecting the light-travel time.
  /// > Then a second pass is made through the program using the light-travel
  /// > time based on the approximate position found on the first pass.
  /// > <cite>_Peter Duffett-Smith, p.137-138</cite>
  ///
  HelioRecord _getCorrectedHelio(
      CelestialSphera ctx, OrbitInstance oi, double lg, double rg,
      [double dt = 0, double rho = 0]) {
    final ma = ctx.getMeanAnomaly(id, dt);
    final pert = calculatePerturbations(ctx, dt);
    final h = calculateHeliocentric(oi, ma, rg, lg, pert);
    if (dt == 0) {
      // take account of the finit light-travel time between the Earth and the planet.
      // h.rho is the Earth-planet distance
      return _getCorrectedHelio(ctx, oi, lg, rg, h.rho * 5.775518e-3, h.rho);
    }
    return (
      ll: h.ll,
      rpd: h.rpd,
      lpd: h.lpd,
      spsi: h.spsi, // not the same as spsi, for now psi is corrected
      cpsi: h.cpsi,
      rho: rho
    );
  }

  EclipticPosition geocentricPosition(CelestialSphera ctx) {
    final sg = ctx.sunGeocentric;
    // convert logitude of the Sun to Earth's position
    final lg = radians(sg.phi) + pi;
    final rsn = sg.rho; // Sun-Earth distance
    final oi = orbit.instantiate(ctx.t);
    // heliocentric position corrected for light-time travel
    HelioRecord h = _getCorrectedHelio(ctx, oi, lg, rsn);

    // Convert to geocentric
    final sll = sin(h.ll);
    final cll = cos(h.ll);
    // geocentric ecliptic longitude
    var lam = isInner
        ? atan2(-1 * h.rpd * sll, rsn - h.rpd * cll) + lg + pi
        : atan2(rsn * sll, h.rpd - rsn * cll) + h.lpd;
    lam = reduceRad(lam);
    // geocentric latitude
    var bet = atan(h.rpd * h.spsi * sin(lam - h.lpd) / (h.cpsi * rsn * sll));

    if (ctx.apparent) {
      // nutation
      lam += radians(ctx.nutation.deltaPsi);
      // aberration
      final a = lg - lam;
      lam -= (9.9387e-5 * cos(a) / cos(bet));
      lam = reduceRad(lam);
      bet -= (9.9387e-5 * sin(a) * sin(bet));
    }

    return (lambda: degrees(lam), beta: degrees(bet), delta: h.rho);
  }
}
