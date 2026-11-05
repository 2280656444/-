import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;

class NotifyService {
  static final _n = FlutterLocalNotificationsPlugin();
  static bool _init = false;

  static Future<void> init() async {
    if (_init) return;
    _init = true;

    tz_data.initializeTimeZones();

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    await _n.initialize(const InitializationSettings(android: android));

    await _n.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(
          const AndroidNotificationChannel(
            'rili',
            '日厤提醒',
            description: '日程与纪念日提醒',
            importance: Importance.high,
          ),
        );
  }

  static Future<void> schedule(
    int id,
    String title,
    String body,
    DateTime when,
  ) async {
    final tzTime = tz.TZDateTime.from(when, tz.local);

    await _n.zonedSchedule(
      id,
      title,
      body,
      tzTime,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'rili',
          '日厤提醒',
          channelDescription: '日程与纪念日提醒',
          importance: Importance.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  static Future<void> cancel(int id) async {
    await _n.cancel(id);
  }
}
