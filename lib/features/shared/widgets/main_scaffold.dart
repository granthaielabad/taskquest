import 'package:flutter/material.dart';
import 'package:taskquest/core/theme/app_theme.dart';
import 'package:taskquest/features/home/screens/home_screen.dart';
import 'package:taskquest/features/games/screens/games_screen.dart';
import 'package:taskquest/features/badges/screens/badges_screen.dart';
import 'package:taskquest/features/explore/screens/explore_screen.dart';
// import 'package:taskquest/features/profile/screens/profile_screen.dart';

class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _currentIndex = 0;

  // Track which tabs have been visited — only build them once visited
  final Set<int> _activatedTabs = {0}; // Home is always built first

  static const List<Widget> _screens = [
    HomeScreen(),
    GamesScreen(),
    GamesScreen(),
    BadgesScreen(),
    ExploreScreen(),
  ];

  void _onTabTap(int index) {
    setState(() {
      _currentIndex = index;
      _activatedTabs.add(index); // Mark as activated — now it gets built
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      // Use a Stack instead of IndexedStack — only render activated tabs
      body: Stack(
        children: List.generate(_screens.length, (i) {
          // Only build if this tab has been visited
          if (!_activatedTabs.contains(i)) return const SizedBox.shrink();
          return Offstage(
            offstage: _currentIndex != i,
            child: TickerMode(
              enabled: _currentIndex == i,
              child: _screens[i],
            ),
          );
        }),
      ),
      bottomNavigationBar: _TQBottomNav(
        currentIndex: _currentIndex,
        onTap: _onTabTap,
      ),
    );
  }
}

// Bottom Nav
class _TQBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _TQBottomNav({
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      decoration: const BoxDecoration(
        color: AppTheme.white,
        border: Border(top: BorderSide(color: AppTheme.border)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            _NavItem(
              icon: Icons.home_outlined,
              label: 'Home',
              active: currentIndex == 0,
              onTap: () => onTap(0),
            ),
            _NavItem(
              icon: Icons.grid_view_rounded,
              label: 'Games',
              active: currentIndex == 1,
              onTap: () => onTap(1),
            ),
            // Center scan/play button
            Expanded(
              child: GestureDetector(
                onTap: () => onTap(2),
                child: Center(
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppTheme.black,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.play_arrow_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
              ),
            ),
            _NavItem(
              icon: Icons.star_border_rounded,
              label: 'Badges',
              active: currentIndex == 3,
              onTap: () => onTap(3),
            ),
            _NavItem(
              icon: Icons.explore_outlined,
              label: 'Explore',
              active: currentIndex == 4,
              onTap: () => onTap(4),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 20,
              color: active ? AppTheme.black : AppTheme.dimmed,
            ),
            const SizedBox(height: 4),
            Text(
              label.toUpperCase(),
              style: TextStyle(
                fontFamily: 'DM Mono',
                fontSize: 9,
                letterSpacing: 0.72,
                color: active ? AppTheme.black : AppTheme.dimmed,
              ),
            ),
          ],
        ),
      ),
    );
  }
}