import 'package:flutter/material.dart';
import '../models/almanac_info.dart';
import '../services/settings_manager.dart';

class DayCell extends StatelessWidget {
  final int day;
  final AlmanacInfo? info;
  final bool isToday;
  final bool isSelected;
  final bool isRest;
  final bool isWork;
  final VoidCallback? onTap;

  const DayCell({
    super.key,
    required this.day,
    this.info,
    this.isToday = false,
    this.isSelected = false,
    this.isRest = false,
    this.isWork = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final s = SettingsManager();
    final showLunar = s.get<bool>('showLunar', true);
    final showTerm = s.get<bool>('showTerm', true);
    final showFestival = s.get<bool>('showFestival', true);

    String? badge;
    Color? badgeColor;
    if (showFestival && info != null) {
      final f = info!.festivals.isNotEmpty
          ? info!.festivals.first
          : (info!.lunarFestivals.isNotEmpty ? info!.lunarFestivals.first : null);
      if (f != null) {
        badge = f;
        badgeColor = Colors.red;
      }
    }
    if (badge == null && showTerm && info?.hasTerm == true) {
      // 节气只在“当天就是节气”时显示，补位内容（含日期）太长不放角标
      final t = info!.term!;
      badge = t.contains('·') ? null : t;
      badgeColor = Colors.green;
    }

    final dayColor =
        isWork ? Colors.grey : (isRest ? Colors.red.shade400 : null);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color:
              isSelected ? Colors.brown.withOpacity(0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: isToday ? Border.all(color: Colors.brown, width: 1.4) : null,
        ),
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Text(
                  '$day',
                  style: TextStyle(
                    fontSize: 16,
                    color: dayColor,
                    fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                if (isWork)
                  const Positioned(
                    right: -8,
                    top: 0,
                    child: Text('班',
                        style: TextStyle(fontSize: 8, color: Colors.grey)),
                  ),
                if (isRest && !isWork)
                  Positioned(
                    right: -8,
                    top: 0,
                    child: Text('休',
                        style: TextStyle(
                            fontSize: 8, color: Colors.red.shade400)),
                  ),
              ],
            ),
            if (badge != null)
              Text(badge,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 9, color: badgeColor))
            else if (showLunar && info != null)
              Text(info!.lunarLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      fontSize: 9,
                      color: info!.hasTerm
                          ? Colors.green
                          : Colors.grey.shade600)),
          ],
        ),
      ),
    );
  }
}
