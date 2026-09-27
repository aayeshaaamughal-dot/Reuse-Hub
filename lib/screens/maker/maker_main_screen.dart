import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import 'maker_home_screen.dart';
import 'explore_screen.dart';
import 'requests_screen.dart';
import '../profile/profile_screen.dart';

class MakerMainScreen extends StatefulWidget {
  const MakerMainScreen({super.key});

  @override
  State<MakerMainScreen> createState() => _MakerMainScreenState();
}

class _MakerMainScreenState extends State<MakerMainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    MakerHomeScreen(),
    ExploreScreen(),
    MakerRequestsScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        selectedItemColor: AppTheme.primaryColor,
        unselectedItemColor: AppTheme.textSecondaryColor,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.explore_outlined),
            activeIcon: Icon(Icons.explore),
            label: 'Explore',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long_outlined),
            activeIcon: Icon(Icons.receipt_long),
            label: 'Requests',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
