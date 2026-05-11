/// Static data for ITF patterns.
class PatternInfo {
  const PatternInfo({
    required this.number,
    required this.name,
    required this.korean,
    required this.movements,
    required this.belt,
    this.locked = false,
    this.isCurrent = false,
  });

  final int number;
  final String name;
  final String korean;
  final int movements;
  final String belt;
  final bool locked;
  final bool isCurrent;
}

const patternsList = [
  PatternInfo(number: 1, name: 'Chon-Ji', korean: '천지', movements: 19, belt: 'White-Yellow', isCurrent: true),
  PatternInfo(number: 2, name: 'Dan-Gun', korean: '단군', movements: 21, belt: 'Yellow'),
  PatternInfo(number: 3, name: 'Do-San', korean: '도산', movements: 24, belt: 'Yellow-Green'),
  PatternInfo(number: 4, name: 'Won-Hyo', korean: '원효', movements: 28, belt: 'Green'),
  PatternInfo(number: 5, name: 'Yul-Gok', korean: '율곡', movements: 38, belt: 'Green-Blue'),
  PatternInfo(number: 6, name: 'Joong-Gun', korean: '중근', movements: 32, belt: 'Blue', locked: true),
  PatternInfo(number: 7, name: 'Toi-Gye', korean: '퇴계', movements: 37, belt: 'Blue-Red', locked: true),
  PatternInfo(number: 8, name: 'Hwa-Rang', korean: '화랑', movements: 29, belt: 'Red', locked: true),
  PatternInfo(number: 9, name: 'Choong-Moo', korean: '충무', movements: 30, belt: 'Red-Black', locked: true),
];
