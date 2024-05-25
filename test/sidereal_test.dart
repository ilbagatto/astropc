import 'package:test/test.dart';
import 'package:astropc/timeutils.dart';

const cases = [
  {
    'djd': 30923.851053,
    'lst': 7.072111,
    'utc': 8.425278,
    'ok': true
  }, // 1984-08-31.4
  {
    'djd': 683.498611,
    'lst': 3.525306,
    'utc': 23.966667,
    'ok': false
  }, // 1901-11-15.0
  {
    'djd': 682.501389,
    'lst': 3.526444,
    'utc': 0.033333,
    'ok': false
  }, // 1901-11-14.0
  {'djd': 29332.108931, 'lst': 4.668119, 'utc': 14.614353, 'ok': true}
]; // 1980-04-22.6

void main() {
  group('UTC -> GST', () {
    for (var c in cases) {
      var arg = c['djd'];
      var exp = c['lst'];
      test('DJD $arg == GST $exp',
          () => expect(djdToSidereal(arg as double), closeTo(exp as num, 0.4)));
    }
  });

  group('GST -> UTC, non-ambiguous', () {
    for (var c in cases.where((x) => x['ok'] == true)) {
      var djd = c['djd']!;
      var lst = c['lst']!;
      var exp = c['utc'];
      siderealToUTC(
          lst: lst as double,
          djd: djd as double,
          callback: (utc, amb) {
            test('GST $lst == UTC $exp', () {
              expect(utc, closeTo(exp as num, 1e-4));
              expect(amb, equals(false));
            });
          });
    }
  });

  group('GST -> UTC, ambiguous', () {
    for (var c in cases.where((x) => x['ok'] == false)) {
      var djd = c['djd']!;
      var lst = c['lst']!;
      var exp = c['utc'];
      siderealToUTC(
          lst: lst as double,
          djd: djd as double,
          callback: (utc, amb) =>
              test('GST $lst == UTC $exp', () => expect(amb, equals(true))));
    }
  });
}
