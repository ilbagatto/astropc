import 'package:astropc/src/planets/sphera.dart';
import 'package:test/test.dart';
import 'package:astropc/src/planets/planet.dart';
import 'package:astropc/src/planets/common.dart';

typedef PlanPos = ({PlanetId id, EclipticPosition pos});

void main() {
  group('Factory methods', () {
    test('Get planet by name', () {
      const names = [
        'Mercury',
        'Venus',
        'Mars',
        'Jupiter',
        'Saturn',
        'Uranus',
        'Neptune',
        'Pluto'
      ];

      for (final name in names) {
        final pla = Planet.forName(name);
        switch (name) {
          case 'Mercury':
            expect(pla.id == PlanetId.Mercury, true);
          case 'Venus':
            expect(pla.id == PlanetId.Venus, true);
          case 'Mars':
            expect(pla.id == PlanetId.Mars, true);
          case 'Jupiter':
            expect(pla.id == PlanetId.Jupiter, true);
          case 'Saturn':
            expect(pla.id == PlanetId.Saturn, true);
          case 'Uranus':
            expect(pla.id == PlanetId.Uranus, true);
          case 'Neptune':
            expect(pla.id == PlanetId.Neptune, true);
          case 'Pluto':
            expect(pla.id == PlanetId.Pluto, true);
        }
      }
    });
  });

  group('Positions', () {
    const delta = 1E-4; // result precision

    final cases = [
      (
        id: PlanetId.Mercury,
        pos: (lambda: 275.88530, beta: 1.47425, delta: 0.98587)
      ),
      (
        id: PlanetId.Venus,
        pos: (lambda: 264.15699, beta: 1.42582, delta: 1.22905)
      ),
      (
        id: PlanetId.Mars,
        pos: (lambda: 214.98173, beta: 1.67762, delta: 1.41366)
      ),
      (
        id: PlanetId.Jupiter,
        pos: (lambda: 270.30024, beta: 0.29758, delta: 6.10966)
      ),
      (
        id: PlanetId.Saturn,
        pos: (lambda: 225.37862, beta: 2.33550, delta: 10.04942)
      ),
      (
        id: PlanetId.Uranus,
        pos: (lambda: 252.17354, beta: 0.05160, delta: 19.63393)
      ),
      (
        id: PlanetId.Neptune,
        pos: (lambda: 270.07638, beta: 1.16314, delta: 31.11160)
      ),
      (
        id: PlanetId.Pluto,
        pos: (lambda: 212.07989, beta: 16.88244, delta: 29.86118)
      )
    ];
    final sph = CelestialSphera(30700.5, apparent: false);
    for (var c in cases) {
      final pla = Planet.forId(c.id);
      final got = pla.geocentricPosition(sph);
      test('$pla Lon.', () => expect(got.lambda, closeTo(c.pos.lambda, delta)));
      test('$pla Lat.', () => expect(got.beta, closeTo(c.pos.beta, delta)));
      test('$pla Dist.', () => expect(got.delta, closeTo(c.pos.delta, delta)));
    }
  });

  group('Duffett-Smith examples', () {
    const delta = 1E-3; // result precision

    final cases = [
      (
        id: PlanetId.Mercury,
        pos: (lambda: 45.9319, beta: -2.78797, delta: 0.999897)
      ),
      (
        id: PlanetId.Saturn,
        pos: (lambda: 221.2009, beta: 2.56691, delta: 8.956587)
      )
    ];

    final sph = CelestialSphera(30830.5, apparent: false); // 1984 May 30

    for (var c in cases) {
      final pla = Planet.forId(c.id);
      final got = pla.geocentricPosition(sph);
      test('$pla Lon.', () => expect(got.lambda, closeTo(c.pos.lambda, delta)));
      test('$pla Lat.', () => expect(got.beta, closeTo(c.pos.beta, delta)));
      test('$pla Dist.', () => expect(got.delta, closeTo(c.pos.delta, delta)));
    }
  });
}
