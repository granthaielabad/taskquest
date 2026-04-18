import 'package:flutter/material.dart';
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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Safely initialize Google Sign-In for Web compatibility
  try {
    await GoogleSignIn.instance.initialize();
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

    return MaterialApp(
      key: ValueKey(authState.value?.uid ?? 'unauthenticated'),
      title: 'TaskQuest',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(textScale),
          ),
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
