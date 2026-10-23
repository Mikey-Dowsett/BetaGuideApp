import 'package:flutter/material.dart';

import 'analytics_page.dart';
import 'camera_test_page.dart';

void main() {
  runApp(const BetaGuideApp());
}

class BetaGuideApp extends StatefulWidget {
  const BetaGuideApp({super.key});

  @override
  State<BetaGuideApp> createState() => _BetaGuideAppState();
}

class _BetaGuideAppState extends State<BetaGuideApp> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BetaGuide',
      theme:
          ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal)),
      home: Scaffold(
        body: IndexedStack(
          index: _tab,
          children: [
            const CameraTestPage(),
            AnalyticsPage(stats: globalStats),
          ],
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _tab,
          onDestinationSelected: (i) => setState(() => _tab = i),
          destinations: const [
            NavigationDestination(
                icon: Icon(Icons.videocam), label: 'Camera'),
            NavigationDestination(
                icon: Icon(Icons.analytics), label: 'Analytics'),
          ],
        ),
      ),
    );
  }
}
