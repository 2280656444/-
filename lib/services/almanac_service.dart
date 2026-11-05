import 'package:lunar/lunar.dart';
import '../models/almanac_info.dart';

class AlmanacService {
  /// 取某天完整黄历
  static AlmanacInfo of(DateTime date) {
    final solar = Solar.fromYmd(date.year, date.month, date.day);
    final lunar = solar.getLunar();

    final lunarLabel =
        '${lunar.getMonthInChinese()}月${lunar.getDayInChinese()}';

    final ganYear = lunar.getYearInGanZhi();
    final ganMonth = lunar.getMonthInGanZhi();
    final ganDay = lunar.getDayInGanZhi();
    final zodiac = lunar.getYearShengXiao();

    final yi = lunar.getDayYi().toList();
    final ji = lunar.getDayJi().toList();

    final chongZhi = lunar.getDayChong();
    final chongGan = lunar.getDayChongGan();
    final chong = '冲$chongGan$chongZhi';
    final sha = lunar.getDaySha();
    final chongDir = '煞$sha';

    final zhiShen = lunar.getDayTianShen();
    final xiu = '${lunar.getXiu()}${lunar.getZheng()}${lunar.getAnimal()}';
    // 胎神方位（lunar 包里叫 getDayPositionTai，返回 String）
    final taiShen = lunar.getDayPositionTai();
    // 吉神宜趋 / 凶煞宜忌：没有的日期包里返回 ['无']
    final jiShen = lunar.getDayJiShen().join('、');
    final xiongSha = lunar.getDayXiongSha().join('、');

    // 当天没有节气时 getJieQi 为空，用前一个节气补位
    var termName = lunar.getJieQi();
    if (termName.isEmpty) {
      final prev = lunar.getPrevJieQi(true);
      termName = prev.getName();
    }

    final festivals = solar.getFestivals().toList(); // 公历节日
    final lunarFestivals = lunar.getFestivals().toList(); // 农历节日

    return AlmanacInfo(
      lunarLabel: lunarLabel,
      ganYear: ganYear,
      ganMonth: ganMonth,
      ganDay: ganDay,
      zodiac: zodiac,
      yi: yi,
      ji: ji,
      chong: chong,
      chongDir: chongDir,
      sha: sha,
      zhiShen: zhiShen,
      xiu: xiu,
      taiShen: taiShen,
      jiShen: jiShen,
      xiongSha: xiongSha,
      term: termName.isEmpty ? null : termName,
      festivals: festivals,
      lunarFestivals: lunarFestivals,
    );
  }

  /// 批量取整月（日历页用）
  static Map<int, AlmanacInfo> month(int year, int month) {
    final days = DateTime(year, month + 1, 0).day;
    final map = <int, AlmanacInfo>{};
    for (int d = 1; d <= days; d++) {
      map[d] = of(DateTime(year, month, d));
    }
    return map;
  }
}
