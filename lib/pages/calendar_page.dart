import 'package:flutter/material.dart';
import '../models/almanac_info.dart';
import '../services/almanac_service.dart';
import '../services/holiday_table.dart';
import '../services/settings_manager.dart';
import '../widgets/day_cell.dart';
import 'almanac_detail_page.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  late DateTime _focused;
  late DateTime _selected;
  late Map<int, AlmanacInfo> _month;
  HolidayTable _holidays = HolidayTable.empty();

  @override
  void initState() {
    super.initState();
    _focused = DateTime.now();
    _selected = _focused;
    _month = AlmanacService.month(_focused.year, _focused.month);
    _loadHolidays();
  }

  Future<void> _loadHolidays() async {
    final t = await HolidayTable.load();
    if (mounted) setState(() => _holidays = t);
  }

  void _shift(int delta) {
    setState(() {
      _focused = DateTime(_focused.year, _focused.month + delta, 1);
      _selected = _focused;
      _month = AlmanacService.month(_focused.year, _focused.month);
    });
  }

  @override
  Widget build(BuildContext context) {
    final s = SettingsManager();
    final mondayFirst = s.get<bool>('weekStartMonday', true);
    final first = DateTime(_focused.year, _focused.month, 1);
    final offset = mondayFirst ? (first.weekday - 1) % 7 : first.weekday % 7;
    final total = offset + _month.length;
    final rows = (total / 7).ceil();

    return Scaffold(
      appBar: AppBar(
        title: Text('${_focused.year}年${_focused.month}月'),
        actions: [
          IconButton(
            icon: const Icon(Icons.today),
            onPressed: () => setState(() {
              _focused = DateTime.now();
              _selected = _focused;
              _month = AlmanacService.month(_focused.year, _focused.month);
            }),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              children: List.generate(7, (i) {
                final labels = mondayFirst
                    ? ['一', '二', '三', '四', '五', '六', '日']
                    : ['日', '一', '二', '三', '四', '五', '六'];
                final isWeekend = mondayFirst ? i >= 5 : (i == 0 || i == 6);
                return Expanded(
                  child: Center(
                    child: Text(labels[i],
                        style: TextStyle(
                            fontSize: 12,
                            color: isWeekend ? Colors.red.shade400 : null)),
                  ),
                );
              }),
            ),
          ),
          Expanded(
            child: SizedBox(
              height: rows * 64.0,
              child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 4),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7,
                  childAspectRatio: 0.78,
                ),
                itemCount: total,
                itemBuilder: (_, i) {
                  if (i < offset) return const SizedBox.shrink();
                  final d = i - offset + 1;
                  final date = DateTime(_focused.year, _focused.month, d);
                  final key =
                      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
                  final wd = date.weekday;
                  final baseRest =
                      wd == DateTime.saturday || wd == DateTime.sunday;
                  final isRest = _holidays.isRestDay(key, date);
                  final isWork = _holidays.isWorkday(key);
                  return DayCell(
                    day: d,
                    info: _month[d],
                    isToday: _isSame(date, DateTime.now()),
                    isSelected: _isSame(date, _selected),
                    isRest: isRest && !isWork,
                    isWork: isWork,
                    onTap: () => setState(() => _selected = date),
                  );
                },
              ),
            ),
          ),
          GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => AlmanacDetailPage(date: _selected),
              ),
            ),
            child: Container(
              margin: const EdgeInsets.all(8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.brown.withOpacity(0.06),
                borderRadius: BorderRadius.circular(12),
              ),
              child: _summary(_month[_selected.day]),
            ),
          ),
        ],
      ),
      floatingActionButton: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton.small(
            heroTag: 'prev',
            onPressed: () => _shift(-1),
            child: const Icon(Icons.chevron_left),
          ),
          const SizedBox(width: 12),
          FloatingActionButton.small(
            heroTag: 'next',
            onPressed: () => _shift(1),
            child: const Icon(Icons.chevron_right),
          ),
        ],
      ),
    );
  }

  Widget _summary(AlmanacInfo? a) {
    if (a == null) return const SizedBox.shrink();
    final s = SettingsManager();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('${_selected.month}月${_selected.day}日 · ${a.lunarLabel}',
                style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(width: 8),
            Text('${a.ganDay}日 · 属${a.zodiac}',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade700)),
          ],
        ),
        if (s.get<bool>('showYi', true) && a.yi.isNotEmpty) ...[
          const SizedBox(height: 6),
          _line('宜', a.yi.take(6).join(' · '), Colors.green.shade700),
        ],
        if (s.get<bool>('showJi', true) && a.ji.isNotEmpty) ...[
          const SizedBox(height: 4),
          _line('忌', a.ji.take(6).join(' · '), Colors.red.shade700),
        ],
        if (s.get<bool>('showChong', true))
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text('${a.chong}${a.chongDir}　值神：${a.zhiShen}',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade700)),
          ),
      ],
    );
  }

  Widget _line(String tag, String text, Color color) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
          decoration:
              BoxDecoration(color: color, borderRadius: BorderRadius.circular(4)),
          child: Text(tag,
              style: const TextStyle(color: Colors.white, fontSize: 11)),
        ),
        const SizedBox(width: 6),
        Expanded(child: Text(text, style: TextStyle(fontSize: 12, color: color))),
      ],
    );
  }

  static bool _isSame(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}
