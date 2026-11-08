import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../theme/app_colors.dart';
import 'home_screen.dart';
import 'library_screen.dart';
import 'offline_shelf_screen.dart';
import 'settings_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  void _onSwitchTab(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final offlineCount = appState.downloadedBooks.length;

    final screens = [
      HomeScreen(onSwitchTab: _onSwitchTab),
      LibraryScreen(onSwitchTab: _onSwitchTab),
      OfflineShelfScreen(onSwitchTab: _onSwitchTab),
      SettingsScreen(onSwitchTab: _onSwitchTab),
    ];

    return PopScope(
      canPop: _currentIndex == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && _currentIndex != 0) {
          setState(() {
            _currentIndex = 0; // Go to Home tab on system back
          });
        }
      },
      child: Scaffold(
        body: IndexedStack(
          index: _currentIndex,
          children: screens,
        ),
        bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          border: const Border(
            top: BorderSide(color: AppColors.cardBorder, width: 0.8),
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF17231D).withValues(alpha: 0.04),
              blurRadius: 12,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: NavigationBar(
            selectedIndex: _currentIndex,
            onDestinationSelected: _onSwitchTab,
            backgroundColor: Colors.transparent,
            indicatorColor: AppColors.secondaryContainer,
            elevation: 0,
            height: 64,
            labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
            destinations: [
              const NavigationDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home_rounded, color: AppColors.onSecondaryContainer),
                label: 'Home',
              ),
              NavigationDestination(
                icon: const Icon(Icons.menu_book_outlined),
                selectedIcon: const Icon(Icons.menu_book_rounded, color: AppColors.onSecondaryContainer),
                label: appState.hasSelectedClass ? 'Class ${appState.selectedClass}' : 'Library',
              ),
              NavigationDestination(
                icon: Badge(
                  isLabelVisible: offlineCount > 0,
                  label: Text('$offlineCount'),
                  backgroundColor: AppColors.primaryContainer,
                  child: const Icon(Icons.download_done_outlined),
                ),
                selectedIcon: Badge(
                  isLabelVisible: offlineCount > 0,
                  label: Text('$offlineCount'),
                  backgroundColor: AppColors.primaryContainer,
                  child: const Icon(Icons.download_done_rounded, color: AppColors.onSecondaryContainer),
                ),
                label: 'Offline',
              ),
              const NavigationDestination(
                icon: Icon(Icons.settings_outlined),
                selectedIcon: Icon(Icons.settings_rounded, color: AppColors.onSecondaryContainer),
                label: 'Settings',
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
}
