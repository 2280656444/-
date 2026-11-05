import 'package:flutter/material.dart';
import '../models/almanac_info.dart';
import '../models/history_item.dart';
import '../services/almanac_service.dart';
import '../services/history_service.dart';
import '../services/settings_manager.dart';

class AlmanacDetailPage extends StatelessWidget {
  final DateTime date;
  const AlmanacDetailPage({super.key, required this.date});

  @override
  Widget build(BuildContext context) {
    final a = AlmanacService.of(date);
    final s = SettingsManager();

    return Scaffold(
      appBar: AppBar(title: Text('${date.year}年${date.month}月${date.day}日')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Center(
            child: Column(
              children: [
                Text(a.lunarLabel,
                    style: const TextStyle(
                        fontSize: 26, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(
                    '${a.ganYear}年 ${a.ganMonth}月 ${a.ganDay}日 · 生肖${a.zodiac}',
                    style: TextStyle(color: Colors.grey.shade700)),
                if (a.hasTerm || a.hasFestival)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Wrap(
                      spacing: 6,
                      children: [
                        if (a.hasTerm) _chip(_termLabel(a.term!), Colors.green.shade600),
                        ...a.festivals.map((e) => _chip(e, Colors.red.shade600)),
                        ...a.lunarFestivals
                            .map((e) => _chip(e, Colors.red.shade600)),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (s.get<bool>('showYi', true))
            _block('宜', a.yi, Colors.green.shade700),
          if (s.get<bool>('showJi', true))
            _block('忌', a.ji, Colors.red.shade700),
          const SizedBox(height: 8),
          if (s.get<bool>('showChong', true))
            _card([
              _row('冲煞', '${a.chong}（${a.chongDir}）'),
              _row('值神', a.zhiShen),
              _row('星宿', a.xiu),
              _row('胎神', a.taiShen),
            ]),
          if (s.get<bool>('showShen', true))
            _card([
              _row('吉神宜趋', a.jiShen.isEmpty ? '—' : a.jiShen),
              _row('凶神宜忌', a.xiongSha.isEmpty ? '—' : a.xiongSha),
            ]),
          const SizedBox(height: 8),
          _historyCard(date),
        ],
      ),
    );
  }

  Widget _historyCard(DateTime date) {
    return FutureBuilder<List<HistoryItem>>(
      future: HistoryService.of(date),
      builder: (ctx, snap) {
        if (!snap.hasData || snap.data!.isEmpty) return const SizedBox.shrink();
        final items = snap.data!;
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('历史上的今天 · ${date.month}月${date.day}日',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(height: 8),
                ...items.take(10).map((it) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 44,
                            child: Text('${it.year}',
                                style: const TextStyle(
                                    color: Colors.brown, fontSize: 13)),
                          ),
                          Container(
                            margin: const EdgeInsets.only(right: 6, top: 2),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 5, vertical: 1),
                            decoration: BoxDecoration(
                              color: it.category == '出生'
                                  ? Colors.purple.shade100
                                  : it.category == '逝世'
                                      ? Colors.grey.shade300
                                      : Colors.brown.shade100,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(it.category,
                                style: const TextStyle(fontSize: 10)),
                          ),
                          Expanded(
                            child: Text('${it.title}（${it.month}月${it.day}日）',
                                style: const TextStyle(fontSize: 13)),
                          ),
                        ],
                      ),
                    )),
                const SizedBox(height: 6),
                const Text('数据来源：维基百科中文版 (CC BY-SA 3.0)',
                    style: TextStyle(fontSize: 10, color: Colors.grey)),
              ],
            ),
          ),
        );
      },
    );
  }

  static String _termLabel(String t) => t.contains('·') ? '距$t' : t;

  Widget _chip(String text, Color c) => Chip(
        label:
            Text(text, style: const TextStyle(color: Colors.white, fontSize: 12)),
        backgroundColor: c,
        padding: EdgeInsets.zero,
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      );

  Widget _block(String tag, List<String> items, Color c) {
    if (items.isEmpty) return const SizedBox.shrink();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 28,
              height: 28,
              alignment: Alignment.center,
              decoration:
                  BoxDecoration(color: c, borderRadius: BorderRadius.circular(6)),
              child: Text(tag,
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Wrap(
                spacing: 10,
                runSpacing: 6,
                children: items
                    .map((e) => Text(e, style: TextStyle(color: c, fontSize: 14)))
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _card(List<Widget> rows) => Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
          child: Column(children: rows),
        ),
      );

  Widget _row(String k, String v) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
                width: 72,
                child: Text(k,
                    style: TextStyle(color: Colors.grey.shade700, fontSize: 13))),
            Expanded(child: Text(v, style: const TextStyle(fontSize: 14))),
          ],
        ),
      );
}
