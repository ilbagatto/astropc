import 'package:test/test.dart';
import 'package:astropc/misc.dart';

const delta = 1E-4; // result precision

void main() {
  // P.Duffett-Smith, "Astronomy With Your Personal Computer", p.54
  group('Mean Obliquity', () {
    final cases = [
      {
        'djd': 29120.5, // 1979-09-24.0
        'eps': 23.441916666666668
      },
      {
        'djd': 36524.5, // 2000-01-01.0
        'eps': 23.43927777777778
      }
    ];

    for (var c in cases) {
      test('eps at DJD #${c['djd']}',
          () => expect(obliquity(c['djd']!), closeTo(c['eps']!, delta)));
    }
  });

  // Meeus, "Astronomical Algorithms", second edition, p.148.
  group('True Obliquity', () {
    final djd = 31875.5; // 1987-04-10.0
    final deps = 9.443;
    test(
        'eps at DJD #$djd with deps $deps°',
        () => expect(obliquity(djd, deps: deps / 3600),
            closeTo(23.443569444444446, delta)));
  });
}
