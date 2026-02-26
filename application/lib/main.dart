import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/search_screen.dart';
import 'screens/settings_screen.dart';

void main() => runApp(const VocabApp());

class VocabApp extends StatelessWidget {
  const VocabApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Vocab Rehearse",
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
      ),
      home: const AppShell(),
    );
  }
}

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;

  final _pages = const [
    HomeScreen(),
    SearchScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.dashboard), label: "Home"),
          NavigationDestination(icon: Icon(Icons.search), label: "Search"),
          NavigationDestination(icon: Icon(Icons.settings), label: "Settings"),
        ],
      ),
    );
  }
}