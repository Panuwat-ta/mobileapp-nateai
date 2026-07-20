import 'package:flutter/material.dart';
import '../../record/screens/record_screen.dart';
import '../../notes/screens/library_screen.dart';
import '../../notes/screens/tasks_screen.dart';
import '../../notes/screens/flashcards_screen.dart';
import '../../settings/screens/settings_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 1; // Default to Record Screen

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      const LibraryScreen(),
      const RecordScreen(),
      const TasksScreen(),
      const FlashcardsScreen(),
      const SettingsScreen(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          border: Border(top: BorderSide(color: const Color(0xFFDDE2E5))),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: NavigationBar(
          height: 64, // Reduce height from default 80 to 64
          selectedIndex: _currentIndex,
          onDestinationSelected: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          backgroundColor: Colors.transparent,
          indicatorColor: Theme.of(context).colorScheme.primaryContainer,
          elevation: 0,
          destinations: [
            NavigationDestination(
              icon: Icon(Icons.inventory_2_outlined),
              selectedIcon: Icon(Icons.inventory_2, color: Theme.of(context).colorScheme.onPrimaryContainer),
              label: 'Note',
            ),
            NavigationDestination(
              icon: Icon(Icons.mic_none),
              selectedIcon: Icon(Icons.mic, color: Theme.of(context).colorScheme.onPrimaryContainer),
              label: 'Record',
            ),
            NavigationDestination(
              icon: Icon(Icons.event_note_outlined),
              selectedIcon: Icon(Icons.event_note, color: Theme.of(context).colorScheme.onPrimaryContainer),
              label: 'Tasks',
            ),
            NavigationDestination(
              icon: Icon(Icons.quiz_outlined),
              selectedIcon: Icon(Icons.quiz, color: Theme.of(context).colorScheme.onPrimaryContainer),
              label: 'Flashcards',
            ),
            NavigationDestination(
              icon: Icon(Icons.settings_outlined),
              selectedIcon: Icon(Icons.settings, color: Theme.of(context).colorScheme.onPrimaryContainer),
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }
}
