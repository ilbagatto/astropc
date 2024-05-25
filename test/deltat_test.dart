import 'package:test/test.dart';
import 'package:astropc/timeutils.dart';

void main() {
  group('DeltaT', () {
    const cases = [
      (djd: -102146.5, exp: 119.51, text: 'historical start'), // 1620-05-01
      (djd: -346701.5, exp: 1820.325, text: 'after 948'), // # 950-10-01
      (djd: 44020.5, exp: 93.81, text: 'after 2010'), // 2020-07-10
      (djd: 109582.5, exp: 407.2, text: 'after 2100'), // ?
    ];

    for (final ({double djd, double exp, String text}) c in cases) {
      test('${c.text} - DJD ${c.djd} should be ${c.exp}s.', () {
        final got = deltaT(c.djd);
        expect(got, closeTo(c.exp, 0.1));
      });
    }
  });
}
