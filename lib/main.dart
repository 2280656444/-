import 'package:flutter/material.dart';
import 'services/settings_manager.dart';
import 'services/notify_service.dart';
import 'pages/calendar_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SettingsManager().init();
  await NotifyService.init();
  runApp(const RiliApp());
}

class RiliApp extends StatelessWidget {
  const RiliApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '日厤',
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.brown),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.brown,
        brightness: Brightness.dark,
      ),
      home: const CalendarPage(),
    );
  }
}
