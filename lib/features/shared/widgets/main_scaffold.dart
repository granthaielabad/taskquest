import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taskquest/features/home/screens/home_screen.dart';
import 'package:taskquest/features/games/screens/games_screen.dart';
import 'package:taskquest/features/explore/screens/explore_screen.dart';
import 'package:taskquest/features/games/screens/flashcard_scan_screen.dart';
import 'package:taskquest/features/auth/providers/auth_provider.dart';
import 'package:taskquest/features/auth/providers/user_provider.dart';
import 'package:taskquest/features/profile/profile_screen.dart';
import 'package:taskquest/features/shared/widgets/bottom_nav_bar.dart';

class MainScaffold extends ConsumerStatefulWidget {
  const MainScaffold({super.key});

  @override
  ConsumerState<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends ConsumerState<MainScaffold> {
  int _currentIndex = 0;
  final Set<int> _activatedTabs = {0};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _performStartupHandshake();
    });
  }

  void _performStartupHandshake() async {
    final user = ref.read(authStateProvider).value;
    if (user != null) {
      await ref
          .read(userServiceProvider)
          .checkAndCreateProfile(
            user.uid,
            user.email ?? '',
            user.displayName ?? '',
          );
    }
  }

  void _onTabTap(int index) {
    setState(() {
      _currentIndex = index;
      _activatedTabs.add(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      const HomeScreen(),
      const GamesScreen(),
      const FlashcardScanScreen(),
      const ExploreScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: List.generate(screens.length, (i) {
          if (!_activatedTabs.contains(i)) return const SizedBox.shrink();
          return Offstage(
            offstage: _currentIndex != i,
            child: TickerMode(enabled: _currentIndex == i, child: screens[i]),
          );
        }),
      ),
      bottomNavigationBar: TQBottomNav(
        currentIndex: _currentIndex,
        onTap: _onTabTap,
      ),
    );
  }
}
