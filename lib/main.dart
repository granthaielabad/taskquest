import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'firebase_options.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/providers/auth_provider.dart';
import 'features/auth/screens/splash_screen.dart';
import 'features/shared/widgets/main_scaffold.dart';
import 'features/auth/screens/auth_success_screen.dart';
import 'features/auth/screens/onboarding_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await GoogleSignIn.instance.initialize();
  
  runApp(
    const ProviderScope(
      child: TaskQuestApp(),
    ),
  );
}

class TaskQuestApp extends ConsumerWidget {
  const TaskQuestApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final isTransitioning = ref.watch(authTransitionProvider);

    return MaterialApp(
      title: 'TaskQuest',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: authState.when(
        data: (user) {
          if (user != null) {
            if (isTransitioning) return const AuthSuccessScreen();
            return const MainScaffold();
          }
          // If no user, we start with the Splash which then shows Onboarding
          return const SplashScreen();
        },
        loading: () => const SplashScreen(),
        error: (e, s) => const SplashScreen(),
      ),
    );
  }
}
