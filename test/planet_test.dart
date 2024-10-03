import 'package:astropc/src/planets/orbit.dart';
import 'package:astropc/src/planets/pert.dart';
import 'package:astropc/src/planets/sphera.dart';
import 'package:test/test.dart';
import 'package:astropc/src/planets/planet.dart';

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

  group('Heliocentric', () {
    const delta = 1e-6;

    final OrbitInstance oi = (
      s: 0.20563138612828713,
      sa: 0.3870986,
      ph: 1.34752240012577,
      nd: 0.8402412010285969,
      ic: 0.12225040301524157,
      ma: 1.7277480419370512,
      dm: 0 // not used
    );
    final re = 0.9839698373786032;
    final lg = 8.379862816965847;
    final ma = 1.7277480419370512;
    final PertRecord pert = (
      dl: -0.001369031774972449,
      dr: -0.000013447032242762032,
      dml: 0,
      ds: 0,
      dm: 0,
      da: 0,
      dhl: 0
    );

    final got = Planet.calculateHeliocentric(oi, ma, re, lg, pert);

    final exp = (
      ll: -4.920247322912694,
      rpd: 0.4136118768849629,
      lpd: 3.459615494053153,
      spsi: 0.06116731001819705,
      cpsi: 0.9981275270150292,
      rho: 0.9858704400566043,
    );

    test('ll', () => expect(exp.ll, closeTo(got.ll, delta)));
    test('rpd', () => expect(exp.rpd, closeTo(got.rpd, delta)));
    test('lpd', () => expect(exp.lpd, closeTo(got.lpd, delta)));
    test('spsi', () => expect(exp.spsi, closeTo(got.spsi, delta)));
    test('cpsi', () => expect(exp.cpsi, closeTo(got.cpsi, delta)));
    test('rho', () => expect(exp.rho, closeTo(got.rho, delta)));
  });

  group('Positions', () {
    const delta = 1E-3; // result precision

    final cases = [
      (
        id: PlanetId.Mercury,
        pos: (lambda: 275.885, beta: 1.47425, delta: 0.986)
      ),
      (id: PlanetId.Venus, pos: (lambda: 264.157, beta: 1.42582, delta: 1.229)),
      (id: PlanetId.Mars, pos: (lambda: 214.982, beta: 1.67762, delta: 1.414)),
      (id: PlanetId.Jupiter, pos: (lambda: 270.3, beta: 0.29758, delta: 6.11)),
      (id: PlanetId.Saturn, pos: (lambda: 225.379, beta: 2.336, delta: 10.049)),
      (id: PlanetId.Uranus, pos: (lambda: 252.174, beta: 0.052, delta: 19.633)),
      (
        id: PlanetId.Neptune,
        pos: (lambda: 270.076, beta: 1.163, delta: 31.112)
      ),
      (id: PlanetId.Pluto, pos: (lambda: 212.08, beta: 16.882, delta: 29.861))
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
    const delta = 1E-2; // result precision

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
