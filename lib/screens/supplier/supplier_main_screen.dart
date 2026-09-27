import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import 'supplier_dashboard.dart';
import 'my_listings_screen.dart';
import 'supplier_requests_screen.dart';
import '../profile/profile_screen.dart';

class SupplierMainScreen extends StatefulWidget {
  const SupplierMainScreen({super.key});

  @override
  State<SupplierMainScreen> createState() => _SupplierMainScreenState();
}

class _SupplierMainScreenState extends State<SupplierMainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    SupplierDashboard(),
    MyListingsScreen(),
    SupplierRequestsScreen(),
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
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory_2_outlined),
            activeIcon: Icon(Icons.inventory_2),
            label: 'Listings',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.inbox_outlined),
            activeIcon: Icon(Icons.inbox),
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
