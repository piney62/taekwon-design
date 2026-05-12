class ItfPattern {
  const ItfPattern({
    required this.name,
    required this.slug,
    required this.korean,
    required this.moves,
    required this.meaningKo,
    required this.meaningEn,
    required this.beltKo,
    required this.beltEn,
  });

  final String name;
  final String slug;   // 봉사기 정적 파일 경로용 (예: "chon_ji")
  final String korean;
  final int moves;
  final String meaningKo;
  final String meaningEn;
  final String beltKo;
  final String beltEn;
}

const itfPatterns = [
  ItfPattern(
    name: 'Chon-Ji',
    slug: 'chon_ji',
    korean: '천지',
    moves: 19,
    meaningKo: '하늘(天)과 땅(地). 동양사상에서 세계의 창조, 인간의 시작을 의미.',
    meaningEn:
        'Heaven and Earth — symbolizes the creation of the world and the beginning of human life.',
    beltKo: '10급 (흰띠)',
    beltEn: '10th Kup (White Belt)',
  ),
  ItfPattern(
    name: 'Dan-Gun',
    slug: 'dan_gun',
    korean: '단군',
    moves: 21,
    meaningKo: '한국 건국 신화의 단군왕검을 기리는 품새.',
    meaningEn:
        'Named after the holy Dan-Gun, legendary founder of Korea in 2333 BC.',
    beltKo: '9급 (흰노란 줄띠)',
    beltEn: '9th Kup (White/Yellow Stripe)',
  ),
  ItfPattern(
    name: 'Do-San',
    slug: 'do_san',
    korean: '도산',
    moves: 24,
    meaningKo: '독립운동가이자 교육자 안창호(島山)의 애국 정신.',
    meaningEn:
        'Pseudonym of the patriot Ahn Chang-Ho (1876–1938), who devoted himself to the Korean independence movement and education.',
    beltKo: '8급 (노란띠)',
    beltEn: '8th Kup (Yellow Belt)',
  ),
  ItfPattern(
    name: 'Won-Hyo',
    slug: 'won_hyo',
    korean: '원효',
    moves: 28,
    meaningKo: '불교를 신라에 전파한 고승 원효 대사(617년).',
    meaningEn:
        'The noted monk Won-Hyo who introduced Buddhism to the Silla Dynasty in 686 AD.',
    beltKo: '7급 (노란초록 줄띠)',
    beltEn: '7th Kup (Yellow/Green Stripe)',
  ),
  ItfPattern(
    name: 'Yul-Gok',
    slug: 'yul_gok',
    korean: '율곡',
    moves: 38,
    meaningKo: '조선시대 유학자 이이(栗谷)의 호. 38동작은 그가 태어난 38° 위도선.',
    meaningEn:
        'Pseudonym of the philosopher Yi I (1536–84). The 38 movements refer to his birthplace on the 38th parallel.',
    beltKo: '6급 (초록띠)',
    beltEn: '6th Kup (Green Belt)',
  ),
  ItfPattern(
    name: 'Joong-Gun',
    slug: 'joong_gun',
    korean: '중근',
    moves: 32,
    meaningKo: '하얼빈에서 이토 히로부미를 처단한 안중근 의사. 32동작은 그의 나이.',
    meaningEn:
        'Named after Ahn Joong-Gun who assassinated Hirobumi Ito. 32 moves = his age at execution.',
    beltKo: '5급 (초록파랑 줄띠)',
    beltEn: '5th Kup (Green/Blue Stripe)',
  ),
  ItfPattern(
    name: 'Toi-Gye',
    slug: 'toi_gye',
    korean: '퇴계',
    moves: 37,
    meaningKo: '조선시대 대유학자 이황의 호. 37동작은 그의 출생지 37° 위도.',
    meaningEn:
        'Pen name of Yi Hwang (1501–70), revered Confucian scholar. 37 moves = his birthplace at 37°N.',
    beltKo: '4급 (파란띠)',
    beltEn: '4th Kup (Blue Belt)',
  ),
  ItfPattern(
    name: 'Hwa-Rang',
    slug: 'hwa_rang',
    korean: '화랑',
    moves: 29,
    meaningKo: '신라 청소년 무사 집단 화랑도. 29동작은 제29보병사단을 기리는 것.',
    meaningEn:
        'Named after the Hwa-Rang youth warriors of the Silla Dynasty. 29 moves = 29th Infantry Division.',
    beltKo: '3급 (파란빨강 줄띠)',
    beltEn: '3rd Kup (Blue/Red Stripe)',
  ),
  ItfPattern(
    name: 'Choong-Moo',
    slug: 'choong_moo',
    korean: '충무',
    moves: 30,
    meaningKo: '이순신 장군의 시호. 마지막 동작이 왼손인 것은 그의 죽음 당시 완성되지 못한 뜻.',
    meaningEn:
        'Name given to the great Admiral Yi Sun-Sin. The left-hand punch at the end symbolizes his untimely death before full victory.',
    beltKo: '2급 (빨간띠)',
    beltEn: '2nd Kup (Red Belt)',
  ),
  ItfPattern(
    name: 'Kwang-Gae',
    slug: 'kwang_gae',
    korean: '광개',
    moves: 39,
    meaningKo: '고구려의 광개토대왕. 39동작은 그의 재위 기간(391~412).',
    meaningEn:
        'Named after the famous Kwang-Gae-Toh-Wang, 19th King of the Koguryo Dynasty. 39 moves = 391–430 AD.',
    beltKo: '1급 (빨강검정 줄띠)',
    beltEn: '1st Kup (Red/Black Stripe)',
  ),
  ItfPattern(
    name: 'Po-Eun',
    slug: 'po_eun',
    korean: '포은',
    moves: 36,
    meaningKo: '고려말 학자이자 충신 정몽주의 호. 고려에 대한 절의를 나타냄.',
    meaningEn:
        'Pseudonym of a loyal subject Chong Mong-Chu (1400) who was a famous poet and loyal to the Koryo Dynasty.',
    beltKo: '1단',
    beltEn: '1st Dan',
  ),
  ItfPattern(
    name: 'Ge-Baek',
    slug: 'ge_baek',
    korean: '계백',
    moves: 44,
    meaningKo: '백제의 명장 계백 장군. 군인으로서의 기백.',
    meaningEn:
        'Named after Ge-Baek, a great general in the Baekje Dynasty (660 AD) known for his strict military discipline.',
    beltKo: '1단',
    beltEn: '1st Dan',
  ),
  ItfPattern(
    name: 'Eui-Am',
    slug: 'eui_am',
    korean: '의암',
    moves: 45,
    meaningKo: '3.1 독립운동 민족대표 33인 중 한 명인 손병희의 호.',
    meaningEn:
        'Pen name of Son Byong-Hi, leader of the Korean Independence Movement on March 1, 1919.',
    beltKo: '2단',
    beltEn: '2nd Dan',
  ),
  ItfPattern(
    name: 'Choong-Jang',
    slug: 'choong_jang',
    korean: '충장',
    moves: 52,
    meaningKo: '조선 중기 장군 김덕령의 시호. 28세에 억울하게 처형된 비운의 장군.',
    meaningEn:
        'Pseudonym of General Kim Duck-Ryang who lived in the Yi Dynasty (1567–96). Executed unjustly at 28.',
    beltKo: '2단',
    beltEn: '2nd Dan',
  ),
  ItfPattern(
    name: 'Juche',
    slug: 'juche',
    korean: '주체',
    moves: 45,
    meaningKo: '주체 철학 — 자신이 삶의 주인이라는 사상.',
    meaningEn:
        'A philosophical idea that man is the master of everything and decides everything. Replaced Kodang in the 1986 revision.',
    beltKo: '2단',
    beltEn: '2nd Dan',
  ),
  ItfPattern(
    name: 'Sam-Il',
    slug: 'sam_il',
    korean: '삼일',
    moves: 33,
    meaningKo: '1919년 3월 1일 독립만세운동. 33동작은 민족대표 33인.',
    meaningEn:
        'The March 1st Korean Independence Movement (1919). 33 moves = 33 national representatives.',
    beltKo: '3단',
    beltEn: '3rd Dan',
  ),
  ItfPattern(
    name: 'Yoo-Sin',
    slug: 'yoo_sin',
    korean: '유신',
    moves: 68,
    meaningKo: '신라 삼국통일의 주역 김유신 장군. 68동작은 그가 입대한 나이(68세).',
    meaningEn:
        'Named after General Kim Yoo-Sin, commander-in-chief of the Silla forces. 68 moves = his rank (68th general).',
    beltKo: '3단',
    beltEn: '3rd Dan',
  ),
  ItfPattern(
    name: 'Choi-Yong',
    slug: 'choi_yong',
    korean: '최영',
    moves: 46,
    meaningKo: '고려 말 충신 최영 장군. 청렴결백한 군인 정신.',
    meaningEn:
        'Named after General Choi Yong, premier and commander-in-chief of the Koryo armed forces in the 14th century.',
    beltKo: '3단',
    beltEn: '3rd Dan',
  ),
  ItfPattern(
    name: 'Yon-Gae',
    slug: 'yon_gae',
    korean: '연개',
    moves: 49,
    meaningKo: '고구려의 재상이자 명장 연개소문. 수나라와 당나라에 맞선 영웅.',
    meaningEn:
        'Named after a famous general in the Koguryo Dynasty, Yon Gae Somoon. He drove out the forces of Tang Dynasty.',
    beltKo: '4단',
    beltEn: '4th Dan',
  ),
  ItfPattern(
    name: 'Ul-Ji',
    slug: 'ul_ji',
    korean: '을지',
    moves: 42,
    meaningKo: '고구려의 명장 을지문덕. 살수대첩에서 수나라 30만 대군을 격파.',
    meaningEn:
        'Named after General Ul-Ji Moon Dok who successfully defended Korea against 300,000 Sui troops.',
    beltKo: '4단',
    beltEn: '4th Dan',
  ),
  ItfPattern(
    name: 'Moon-Moo',
    slug: 'moon_moo',
    korean: '문무',
    moves: 61,
    meaningKo: '삼국통일을 완수한 신라 30대 문무왕. 수중릉에 묻히길 원했던 왕.',
    meaningEn:
        'Named after the 30th King of Silla (661–681) who unified the three kingdoms. He was buried in the sea.',
    beltKo: '4단',
    beltEn: '4th Dan',
  ),
  ItfPattern(
    name: 'So-San',
    slug: 'so_san',
    korean: '서산',
    moves: 72,
    meaningKo: '임진왜란 때 의병을 이끈 서산대사. 72동작은 그의 나이.',
    meaningEn:
        'Pseudonym of the great monk Choi Hyong Ung (1520–1604) who organized monk soldiers during the Japanese invasion. 72 moves = his age.',
    beltKo: '5단',
    beltEn: '5th Dan',
  ),
  ItfPattern(
    name: 'Se-Jong',
    slug: 'se_jong',
    korean: '세종',
    moves: 24,
    meaningKo: '한글을 창제한 조선 4대 세종대왕. 24동작은 한글의 24자모.',
    meaningEn:
        'Named after the greatest Korean King Sejong who invented the Korean alphabet (Hangul) in 1443. 24 moves = 24 letters.',
    beltKo: '6단',
    beltEn: '6th Dan',
  ),
  ItfPattern(
    name: 'Tong-Il',
    slug: 'tong_il',
    korean: '통일',
    moves: 56,
    meaningKo: '한반도의 통일을 염원하는 품새. 56동작은 각각 그 의미를 지님.',
    meaningEn:
        'Expresses the hope for the reunification of Korea, divided since 1945. The final pattern in the ITF syllabus.',
    beltKo: '7단',
    beltEn: '7th Dan',
  ),
];
