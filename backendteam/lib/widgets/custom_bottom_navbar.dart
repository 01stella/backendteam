import 'package:flutter/material.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int selectedIndex;
  const CustomBottomNavBar({Key? key, required this.selectedIndex}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFD9CBA3), width: 2)),
      ),
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _NavBarIcon(
            icon: Icons.home,
            label: 'Home',
            selected: selectedIndex == 0,
            onTap: () {},
          ),
          _NavBarIcon(
            icon: Icons.menu_book,
            label: 'Menu',
            selected: selectedIndex == 1,
            onTap: () {},
          ),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFD9CBA3),
              borderRadius: BorderRadius.circular(32),
            ),
            padding: const EdgeInsets.all(8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.qr_code_scanner, color: Color(0xFF1A1A1A)),
                SizedBox(height: 2),
                Text('SCAN QR', style: TextStyle(fontSize: 10, color: Color(0xFF1A1A1A))),
              ],
            ),
          ),
          _NavBarIcon(
            icon: Icons.history,
            label: 'History',
            selected: selectedIndex == 2,
            onTap: () {
              if (selectedIndex != 2) {
                Navigator.pushReplacementNamed(context, '/history');
              }
            },
          ),
          _NavBarIcon(
            icon: Icons.person,
            label: 'Profile',
            selected: selectedIndex == 3,
            onTap: () {
              if (selectedIndex != 3) {
                Navigator.pushReplacementNamed(context, '/register');
              }
            },
          ),
        ],
      ),
    );
  }
}

class _NavBarIcon extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _NavBarIcon({required this.icon, required this.label, required this.selected, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: selected ? Color(0xFFB98068) : Color(0xFFB0B0B0)),
          const SizedBox(height: 2),
          Text(label, style: TextStyle(fontSize: 10, color: selected ? Color(0xFFB98068) : Color(0xFFB0B0B0))),
        ],
      ),
    );
  }
}
