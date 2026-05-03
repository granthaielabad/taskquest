import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'firebase_options.dart';
import 'core/theme/app_theme.dart';
import 'core/providers/theme_provider.dart';
import 'features/auth/providers/auth_provider.dart';
import 'features/auth/screens/splash_screen.dart';
import 'features/auth/screens/auth_success_screen.dart';
import 'features/shared/widgets/main_scaffold.dart';
import 'features/settings/services/notification_service.dart';
import 'core/services/database_seed_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialize Notifications
  await NotificationService().init();

  // Seed database with new quests and badges
  // You can comment this out after the first run if you don't want to re-seed every time.
  await DatabaseSeedService().seedAll();

  // Initialize Google Sign-In as required by the package
  try {
    const clientId =
        '910396668792-5qatv8m0g9i1um66pso655qfvud90vr8.apps.googleusercontent.com';
    await GoogleSignIn.instance.initialize(
      serverClientId: clientId,
      clientId: kIsWeb ? clientId : null,
    );
  } catch (e) {
    debugPrint('Google Sign-In initialization note: $e');
  }

  runApp(const ProviderScope(child: TaskQuestApp()));
}

class TaskQuestApp extends ConsumerWidget {
  const TaskQuestApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final isTransitioning = ref.watch(authTransitionProvider);
    final themeMode = ref.watch(themeProvider);
    final textScale = ref.watch(textScaleProvider);
    final fontStyle = ref.watch(fontStyleProvider);
    final themePreset = ref.watch(themePresetProvider);

    return MaterialApp(
      key: ValueKey(authState.value?.uid ?? 'unauthenticated'),
      title: 'TaskQuest',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.createTheme(
        brightness: Brightness.light,
        fontStyle: fontStyle,
        preset: themePreset,
      ),
      darkTheme: AppTheme.createTheme(
        brightness: Brightness.dark,
        fontStyle: fontStyle,
        preset: themePreset,
      ),
      themeMode: themeMode,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(textScale)),
          child: child!,
        );
      },
      home: authState.when(
        data: (user) {
          if (user != null) {
            if (isTransitioning) return const AuthSuccessScreen();
            return const MainScaffold();
          }
          return const SplashScreen();
        },
        loading: () => const SplashScreen(),
        error: (e, s) => const SplashScreen(),
      ),
    );
  }
}
