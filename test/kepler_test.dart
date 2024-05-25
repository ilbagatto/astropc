import 'package:test/test.dart';
import 'package:astropc/src/misc/kepler.dart';

const delta = 1E-4; // result precision

const cases = [
  {
    'm': 3.5208387374141448,
    's': 0.016718,
    'e': 3.5147440476661806,
    'ta': -2.774497552017826
  },
  {
    'm': 0.763009079752865,
    's': 0.965,
    'e': 1.7176273861066755,
    'ta': 2.9122563898777387
  }
];

void main() {
  group('Kepler equation', () {
    for (var c in cases) {
      final s = c['s'];
      final m = c['m'];
      test('s: $s, m: $m',
          () => expect(kepler(s!, m!), closeTo(c['e']!, delta)));
    }
  });

  group('True anomaly', () {
    for (var c in cases) {
      final s = c['s'];
      final e = c['e'];
      test('s: $s, e: $e',
          () => expect(trueAnomaly(s!, e!), closeTo(c['ta']!, delta)));
    }
  });
}
