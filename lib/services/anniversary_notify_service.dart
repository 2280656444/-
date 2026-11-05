import '../models/anniversary_model.dart';
import 'notify_service.dart';
import 'lunar_util.dart';

class AnniversaryNotifyService {
  static Future<void> schedule(AnniversaryModel a) async {
    if (a.id == null) return;
    final id = -(a.id! * 1000 + 1);

    final DateTime next;
    if (a.lunar) {
      next = LunarUtil.nextSolarDate(
        month: a.date.month,
        day: a.date.day,
      ).copyWith(hour: 9, minute: 0, second: 0, microsecond: 0);
    } else {
      final now = DateTime.now();
      var d = DateTime(now.year, a.date.month, a.date.day, 9, 0);
      if (d.isBefore(now)) {
        d = DateTime(now.year + 1, a.date.month, a.date.day, 9, 0);
      }
      next = d;
    }

    final days = next.difference(DateTime.now()).inDays;
    await NotifyService.schedule(
      id,
      '日厤纪念日',
      '${a.title} · 还有 $days 天',
      next,
    );
  }

  static Future<void> cancel(int anniversaryId) async {
    await NotifyService.cancel(-(anniversaryId * 1000 + 1));
  }
}
