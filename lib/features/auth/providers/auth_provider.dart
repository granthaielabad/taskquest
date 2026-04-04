import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:taskquest/features/shared/services/auth_service.dart';

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(authServiceProvider).authStateChanges;
});

final currentUserProvider = Provider<User?>((ref) {
  return ref.watch(authServiceProvider).currentUser;
});

// Using a Notifier for better compatibility
class AuthTransitionNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void setTransitioning(bool value) => state = value;
}

final authTransitionProvider = NotifierProvider<AuthTransitionNotifier, bool>(() {
  return AuthTransitionNotifier();
});
