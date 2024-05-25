import 'package:astropc/src/heliocentric/helio.dart';
import 'package:astropc/src/heliocentric/orbit.dart';
import 'package:astropc/src/heliocentric/pert.dart';
import 'package:test/test.dart';

const delta = 1e-6;

void main() {
  group('Heliocentric', () {
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

    final got = calculateHeliocentric(oi, ma, re, lg, pert);

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
}
