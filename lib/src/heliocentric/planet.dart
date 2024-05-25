import 'dart:math';

import 'package:astropc/src/heliocentric/helio.dart';
import 'package:vector_math/vector_math.dart';

import '../../mathutils.dart';
import 'common.dart';
import 'orbit.dart';
import 'pert.dart';
import 'planets/jupiter.dart';
import 'planets/mars.dart';
import 'planets/mercury.dart';
import 'planets/neptune.dart';
import 'planets/pluto.dart';
import 'planets/saturn.dart';
import 'planets/uranus.dart';
import 'planets/venus.dart';

abstract class Planet {
  /// Osculating elements of the orbit
  final OElements orbit;

  /// Planet identifier
  final PlanetId id;

  /// Planet name
  final String name;

  /// True if the planet is inner
  final bool isInner;

  /// Constructor
  Planet.create(this.id, this.name, this.orbit, this.isInner);

  factory Planet.forId(PlanetId id) {
    switch (id) {
      case PlanetId.Mercury:
        return Mercury();
      case PlanetId.Venus:
        return Venus();
      case PlanetId.Mars:
        return Mars();
      case PlanetId.Jupiter:
        return Jupiter();
      case PlanetId.Saturn:
        return Saturn();
      case PlanetId.Uranus:
        return Uranus();
      case PlanetId.Neptune:
        return Neptune();
      case PlanetId.Pluto:
        return Pluto();
    }
  }

  factory Planet.forName(String name) {
    switch (name) {
      case "Mercury":
        return Mercury();
      case "Venus":
        return Venus();
      case "Mars":
        return Mars();
      case "Jupiter":
        return Jupiter();
      case "Saturn":
        return Saturn();
      case "Uranus":
        return Uranus();
      case "Neptune":
        return Neptune();
      case "Pluto":
        return Pluto();
    }

    throw 'Unknown planet name: $name';
  }

  PertRecord calculatePerturbations(CelestialContext ctx, [double dt = 0]);

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
      CelestialContext ctx, OrbitInstance oi, double lg, double rg,
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

  EclipticPosition geocentricPosition(CelestialContext ctx) {
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
