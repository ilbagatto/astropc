import 'package:test/test.dart';
import 'package:astropc/moon.dart';

const delta = 1e-2;

const cases = [
  {
    'date': [1984, 9, 1],
    'quarter': QuarterType.newMoon,
    'djd': 30919.3097 //[1984, 8, 26, 19, 26]
  },
  {
    'date': [1984, 9, 1],
    'quarter': QuarterType.fullMoon,
    'djd': 30933.79236 //[1984, 9, 10, 7, 1]
  },
  {
    'date': [1968, 12, 12],
    'quarter': QuarterType.newMoon,
    'djd': 25190.263194 // [1968, 12, 19, 18, 19]
  },
  {
    'date': [1968, 12, 12],
    'quarter': QuarterType.fullMoon,
    'djd': 25205.26944 // [1969, 1, 3, 18, 28]
  },
  {
    'date': [1974, 4, 1],
    'quarter': QuarterType.newMoon,
    'djd': 27110.39166 // [1974, 3, 23, 21, 24]
  },
  {
    'date': [1974, 4, 1],
    'quarter': QuarterType.fullMoon,
    'djd': 27124.375 //[1974, 4, 6, 21, 0]
  },
  {
    'date': [1977, 2, 15],
    'quarter': QuarterType.newMoon,
    'djd': 28172.65118
  },
  {
    'date': [1965, 2, 1],
    'quarter': QuarterType.firstQuarter,
    'djd': 23780.87026
  },
  {
    'date': [1965, 2, 1],
    'quarter': QuarterType.fullMoon,
    'djd': 23787.52007
  },
  {
    'date': [2044, 1, 1],
    'quarter': QuarterType.lastQuarter,
    'djd': 52616.49186
  },
  {
    'date': [2019, 8, 21],
    'quarter': QuarterType.newMoon,
    'djd': 43705.94287
  },
  {
    'date': [2019, 8, 21],
    'quarter': QuarterType.firstQuarter,
    'djd': 43712.63302
  },
  {
    'date': [2019, 8, 21],
    'quarter': QuarterType.fullMoon,
    'djd': 43720.69049
  },
  {
    'date': [2019, 8, 21],
    'quarter': QuarterType.lastQuarter,
    'djd': 43728.61252
  }
];

void main() {
  group('Closest', () {
    for (var c in cases) {
      List d = c['date'] as List<dynamic>;
      final ye = d[0];
      final mo = d[1];
      final da = d[2];
      final djd = c['djd'];
      final q = QuarterQuery(Quarter(c['quarter'] as QuarterType));
      test('${c['quarter']} to $ye-$mo-$da',
          () => expect(q.findClosest(ye, mo, da), closeTo(djd as num, delta)));
    }
  });
}
