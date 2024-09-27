import 'package:astropc/planets.dart';
import 'package:test/test.dart';
import 'package:vector_math/vector_math.dart';

const delta = 1E-4; // result precision

void main() {
  final djd = 30700.5;
  final sph = CelestialSphera(djd);

  group('Properties', () {
    test('T', () => expect(sph.t, closeTo(0.8405338809034908, delta)));
    test('Sun longitude',
        () => expect(sph.sunGeocentric.phi, closeTo(300.1307723107521, delta)));
    test(
        'Earth-Sun distance',
        () =>
            expect(sph.sunGeocentric.rho, closeTo(0.9839698373786032, delta)));
    test(
        'Sun Mean Anomaly',
        () => expect(
            sph.sunMeanAnomaly, closeTo(radians(16.89671827974547), delta)));
    test(
        'Delta-Psi',
        () => expect(
            sph.nutation.deltaPsi, closeTo(-0.004176852920102668, delta)));
    test(
        'Delta-Eps',
        () => expect(
            sph.nutation.deltaEps, closeTo(0.0006849657311651972, delta)));
    test('Obliquity',
        () => expect(sph.obliquity, closeTo(23.442041099302447, delta)));
  });

  group('Mean Anomalies', () {
    test(
        'Mercury',
        () => expect(sph.getMeanAnomaly(PlanetId.Mercury),
            closeTo(1.7277480419370512, delta)));
    test(
        'Venus',
        () => expect(sph.getMeanAnomaly(PlanetId.Venus),
            closeTo(1.3753354318768864, delta)));

    test(
        'Mars',
        () => expect(sph.getMeanAnomaly(PlanetId.Mars),
            closeTo(3.616595436914378, delta)));

    test(
        'Jupiter',
        () => expect(sph.getMeanAnomaly(PlanetId.Jupiter),
            closeTo(4.469600429159891, delta)));

    test(
        'Saturn',
        () => expect(sph.getMeanAnomaly(PlanetId.Saturn),
            closeTo(2.133162332104278, delta)));

    test(
        'Uranus',
        () => expect(sph.getMeanAnomaly(PlanetId.Uranus),
            closeTo(1.2691334849854374, delta)));

    test(
        'Neptune',
        () => expect(sph.getMeanAnomaly(PlanetId.Neptune),
            closeTo(3.863368991888066, delta)));

    test(
        'Pluto',
        () => expect(sph.getMeanAnomaly(PlanetId.Pluto),
            closeTo(6.138953042601936, delta)));
  });
}
