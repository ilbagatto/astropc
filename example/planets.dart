import 'dart:io';
import 'dart:math';
import 'package:args/args.dart';
import 'package:astropc/mathutils.dart';
import 'package:astropc/planets.dart';
import 'package:astropc/moon.dart' as moon;
import 'package:astropc/sphera.dart';
import 'package:astropc/sun.dart' as sun;
import 'package:astropc/timeutils.dart';
import 'package:sprintf/sprintf.dart';

String getUsage(parser) {
  return '''
Displays positions of the Sun, the Moon and the 10 planets, including Pluto.

    planets [OPTIONS] [DJD] 

OPTIONS

${parser.usage}

DJD is a modified Julian day since 1900 January 0.5 (1989 December 31.5).

Example:
planets 23772.990277 # Feb 1, 1965, UT 11:46

''';
}

Iterable<(String name, EclipticPosition)> iterObjects(
    double djd, CelestialSphera sph) sync* {
  final djdEt = (djd + sph.deltaT / 86400.0);
  // Moon
  final mo = moon.apparent(djdEt);
  yield ("Moon", (lambda: mo.lambda, beta: mo.beta, delta: mo.delta));
  // Sun
  final su = sun.apparent(djdEt,
      dpsi: sph.nutation.deltaPsi, ignoreLightTravel: false);
  yield ("Sun", (lambda: su.phi, beta: 0.0, delta: su.rho));
  // Planets
  for (final id in PlanetId.values) {
    final pla = Planet.forId(id);
    final pos = pla.geocentricPosition(sph);
    yield (pla.name, (lambda: pos.lambda, beta: pos.beta, delta: pos.delta));
  }
}

Point<double> horizontalCoords(
    double djd, Point<double> geoCoords, Point<double> equ) {
  final lst = djdToSidereal(djd, lng: geoCoords.x);
  final h = lst * 15 - equ.x; // local hour angle
  final (azimuth, altitude) = equ2hor(h, equ.y, geoCoords.y);
  return Point(azimuth, altitude);
}

void displayObject(
    {required String name,
    required double djd,
    required EclipticPosition eclipticCoords,
    required CelestialSphera sphera,
    required CoordsType coordsType,
    required String format,
    required Point<double> geoCoords}) {
  Point<double> coords;
  switch (coordsType) {
    case CoordsType.equatorial:
    case CoordsType.horizontal:
      // equatorial coordinates
      final (alpha, delta) =
          ecl2equ(eclipticCoords.lambda, eclipticCoords.beta, sphera.obliquity);
      coords = Point(alpha, delta);
      if (coordsType == CoordsType.horizontal) {
        // convert equatorial coordinates to horizontal
        coords = horizontalCoords(djd, geoCoords, coords);
      }
    default:
      coords = Point(eclipticCoords.lambda, eclipticCoords.beta);
  }

  final x = coordsType == CoordsType.equatorial ? coords.x / 15.0 : coords.x;
  final sgn = coords.y < 0 ? '-' : '+';
  String xStr, yStr;
  switch (format) {
    case 'd':
      final xFmt = coordsType == CoordsType.equatorial ? '%05.2f' : '%06.2f';
      xStr = sprintf(xFmt, [x]);
      yStr = sprintf('%s%05.2f', [sgn, coords.y.abs()]);
    default:
      final xs = dms(x);
      final xFmt = coordsType == CoordsType.equatorial
          ? '%02d:%02d:%04.1f'
          : '%03d:%02d:%04.1f';
      xStr = sprintf(xFmt, [xs.$1, xs.$2, xs.$3]);
      final ys = dms(coords.y.abs());
      yStr = sprintf('%s%02d:%02d:%04.1f', [sgn, ys.$1, ys.$2, ys.$3]);
  }
  String row = sprintf("%-12s %s | %s | %s", [
    name,
    xStr,
    yStr,
    sprintf('%9.4f', [eclipticCoords.delta]),
  ]);
  print(row);
}

void main(List<String> arguments) {
  exitCode = 0;

  final parser = ArgParser()
    ..addFlag('help',
        abbr: 'h',
        negatable: false,
        defaultsTo: false,
        help: 'Displays this help information')
    ..addOption('coords',
        abbr: 'c',
        allowed: ['ecl', 'equ', 'hor'],
        defaultsTo: 'ecl',
        help: 'Celestial coordinates',
        allowedHelp: {
          'ecl': 'Ecliptic coordinates',
          'equ': 'Equatorial coordinates',
          'hor': 'Horizontal coordinates'
        })
    ..addOption('format',
        abbr: 'f',
        allowed: ['d', 's'],
        defaultsTo: 's',
        help: 'Format',
        allowedHelp: {
          'd': 'Decimal numbers',
          's': 'Sexigesimal numbers',
        })
    ..addOption('geolat',
        valueHelp: 'Decimal degrees',
        defaultsTo: '0.0',
        help: 'Geographical latitude, positive northwards')
    ..addOption('geolon',
        valueHelp: 'Decimal degrees',
        defaultsTo: '0.0',
        help: 'Geographical longitude, positive westwards')
    ..addSeparator('-------');

  try {
    final argResults = parser.parse(arguments);
    if (argResults['help']) {
      print(getUsage(parser));
      exit(exitCode);
    }

    CoordsType coords;
    switch (argResults['coords']) {
      case 'hor':
        coords = CoordsType.horizontal;
      case 'equ':
        coords = CoordsType.equatorial;
      default:
        coords = CoordsType.ecliptical;
    }
    final djd = double.parse(argResults.rest[0]);
    final lng = double.parse(argResults['geolon']);
    final lat = double.parse(argResults['geolat']);
    final sph = CelestialSphera(djd);

    for (final (obj, pos) in iterObjects(djd, sph)) {
      displayObject(
          name: obj,
          eclipticCoords: pos,
          sphera: sph,
          djd: djd,
          geoCoords: Point(lng, lat),
          coordsType: coords,
          format: argResults['format']);
    }
  } catch (e) {
    print(e);
    exitCode = 1;
  }
}
