import 'package:astropc/timeutils.dart';
import 'package:test/test.dart';
import 'package:astropc/sphera.dart';

const delta = 1E-4; // result precision

var cases = [
  {
    'djd': -15804.5, // 1856 Sept. 23
    'dpsi': -0.00127601021242336,
    'deps': 0.00256293723137559,
  },
  {
    'djd': 36524.5, // 2000 Jan. 1
    'dpsi': -0.00387728730373955,
    'deps': -0.00159919822661103,
  },
  {
    'djd': 28805.69, // 1978 Nov 17
    'dpsi': -9.195562346652888e-04,
    'deps': -2.635113483663831e-03,
  },
  {
    'djd': julDay(1989, 2, 4),
    'dpsi': 0.0023055555555555555,
    'deps': 0.0022944444444444444,
  },
  {
    'djd': julDay(2000, 1, 1.5),
    'dpsi': -0.003877777777777778,
    'deps': -0.0016,
  },
  {
    'djd': julDay(1995, 4, 23),
    'dpsi': 0.0026472222222222223,
    'deps': -0.002013888888888889,
  },
  {
    'djd': julDay(1965, 2, 1),
    'dpsi': -0.0042774118548615766,
    'deps': 0.000425,
  },
];

void main() {
  group('Nutation', () {
    for (var c in cases) {
      final t = c['djd']! / 36525;
      var nut = nutation(t);
      test('dpsi at DJD #${c['djd']}',
          () => expect(nut.deltaPsi, closeTo(c['dpsi']!, delta)));
      test('deps at DJD #${c['djd']}',
          () => expect(nut.deltaEps, closeTo(c['deps']!, delta)));
    }
  });
}
