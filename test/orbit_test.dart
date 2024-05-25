import 'package:test/test.dart';
import 'package:astropc/src/heliocentric/orbit.dart';

const delta = 1e-6;

void main() {
  final t = 0.8405338809034908;
  group('Terms', () {
    test('Standard terms', () {
      final terms = Terms.make(75.899697, 1.5554889, 0.0002947);
      final exp = 77.2073463265456;
      expect(terms.assemble(t), closeTo(exp, delta));
    });
    test('Mean longitude', () {
      final terms = MLTerms(178.179078, 415.2057519, 0.0003011);
      final exp = 176.2000171915306;
      expect(terms.assemble(t), closeTo(exp, delta));
    });
  });
  group('Osculation elements', () {
    final oe = OElements(
        ML: MLTerms(178.179078, 415.2057519, 3.011e-4),
        PH: Terms.make(75.899697, 1.5554889, 2.947e-4),
        EC: Terms.make(2.0561421e-1, 2.046e-5, -3e-8),
        IN: Terms.make(7.002881, 1.8608e-3, -1.83e-5),
        ND: Terms.make(47.145944, 1.1852083, 1.739e-4),
        SA: 3.870986e-1);
    final oi = oe.instantiate(t);
    test('Mean anomaly', () {
      expect(oi.ma, closeTo(1.7277480419370512, delta));
    });
    test('Mean daily motion', () {
      expect(oi.dm, closeTo(0.07142545459475612, delta));
    });
    test('Argument of perihelion', () {
      expect(oi.ph, closeTo(1.34752240012577, delta));
    });
    test('Eccentricity', () {
      expect(oi.s, closeTo(0.20563138612828713, delta));
    });
    test('Ascending node', () {
      expect(oi.nd, closeTo(0.8402412010285969, delta));
    });
    test('Inclination', () {
      expect(oi.ic, closeTo(0.12225040301524157, delta));
    });
    test('Major semi-axis', () {
      expect(oi.sa, closeTo(0.3870986, delta));
    });
  });
}
