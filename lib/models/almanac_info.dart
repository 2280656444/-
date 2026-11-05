class AlmanacInfo {
  final String lunarLabel;
  final String ganYear;
  final String ganMonth;
  final String ganDay;
  final String zodiac;
  final List<String> yi;
  final List<String> ji;
  final String chong;
  final String chongDir;
  final String sha;
  final String zhiShen;
  final String xiu;
  final String taiShen;
  final String jiShen;
  final String xiongSha;
  final String? term;
  final List<String> festivals;
  final List<String> lunarFestivals;

  const AlmanacInfo({
    required this.lunarLabel,
    required this.ganYear,
    required this.ganMonth,
    required this.ganDay,
    required this.zodiac,
    required this.yi,
    required this.ji,
    required this.chong,
    required this.chongDir,
    required this.sha,
    required this.zhiShen,
    required this.xiu,
    required this.taiShen,
    required this.jiShen,
    required this.xiongSha,
    this.term,
    this.festivals = const [],
    this.lunarFestivals = const [],
  });

  bool get hasTerm => term != null && term!.isNotEmpty;
  bool get hasFestival => festivals.isNotEmpty || lunarFestivals.isNotEmpty;
}
