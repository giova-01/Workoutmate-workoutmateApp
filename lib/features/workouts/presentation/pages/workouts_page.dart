import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../config/providers/app_providers.dart';
import '../../../auth/presentation/auth_state.dart';

class WorkoutsPage extends ConsumerWidget {
  const WorkoutsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);

    if (authState is! AuthAuthenticated) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final user = authState.user.id;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.black),
          onPressed: () {
            // TODO: Implementar drawer/menú lateral
          },
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 55,
              height: 55,
              child: Padding(
                padding: const EdgeInsets.all(2.0),
                child: Center(child: Image.asset('assets/images/logo.png')),
              ),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Mis Rutinas',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),

              Center(
                child: ElevatedButton(
                  onPressed: () {
                    //TODO
                  },
                  child: Container(
                    width: 200,
                    height: 200,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(image: AssetImage('assets/images/add.png'))
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
