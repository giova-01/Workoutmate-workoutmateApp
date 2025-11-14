import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/providers/app_providers.dart';
import '../auth_state.dart';

class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage> {
  bool _hasCheckedAuth = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {

    if (_hasCheckedAuth) {
      debugPrint('[SplashPage] Ya se verifico auth, abortando');
      return;
    }

    // Dar tiempo para que la UI se renderice
    await Future.delayed(const Duration(milliseconds: 500));

    if (!mounted) {
      return;
    }

    debugPrint('[SplashPage] Llamando checkAuthStatus');
    _hasCheckedAuth = true;
    await ref.read(authNotifierProvider.notifier).checkAuthStatus();
  }

  @override
  Widget build(BuildContext context) {

    // Escuchar cambios y navegar
    ref.listen<AuthState>(authNotifierProvider, (previous, next) {

      if (!mounted) {
        return;
      }

      if (next is AuthAuthenticated) {
        debugPrint('[SplashPage] Navegando a /home');
        context.go('/home');
      } else if (next is AuthUnauthenticated) {
        debugPrint('[SplashPage] Navegando a /login (Unauthenticated)');
        context.go('/login');
      } else if (next is AuthError) {
        debugPrint('[SplashPage] Navegando a /login (Error: ${next.message})');
        context.go('/login');
      }
    });

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.fitness_center,
                size: 80,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'WorkoutMate',
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 64),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              strokeWidth: 3,
            ),
          ],
        ),
      ),
    );
  }
}