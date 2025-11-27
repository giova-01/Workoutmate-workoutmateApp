import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

const double kNavIconSize = 40;

class HomeShellPage extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const HomeShellPage({
    super.key,
    required this.navigationShell,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: navigationShell.currentIndex,
        onTap: (index) => _onTap(context, index),
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined, size: kNavIconSize),
            activeIcon: Icon(Icons.home, size: kNavIconSize),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.fitness_center_outlined, size: kNavIconSize),
            activeIcon: Icon(Icons.fitness_center, size: kNavIconSize),
            label: 'Rutinas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add, size: 50),
            activeIcon: Icon(Icons.add_circle, size: 50),
            label: 'Crear',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.qr_code_scanner_outlined, size: kNavIconSize),
            activeIcon: Icon(Icons.qr_code_scanner, size: kNavIconSize),
            label: 'Escanear',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart_outlined, size: kNavIconSize),
            activeIcon: Icon(Icons.bar_chart, size: kNavIconSize),
            label: 'Progreso',
          ),
        ],
      ),
    );
  }

  void _onTap(BuildContext context, int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }
}
