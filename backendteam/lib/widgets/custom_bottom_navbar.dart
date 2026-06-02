import 'package:flutter/material.dart';

// --- 1. The Bottom Navigation Bar ---
class CustomBottomNavBar extends StatelessWidget {
  final int selectedIndex;

  const CustomBottomNavBar({Key? key, required this.selectedIndex}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      color: Colors.white,
      elevation: 10,
      notchMargin: 0,
      padding: EdgeInsets.zero,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavButton(context, Icons.home_outlined, 'Home', 0, '/home'), 
            _buildNavButton(context, Icons.coffee, 'Menu', 1, '/menu'), 
            const SizedBox(width: 48), // The empty gap for the floating QR Button
            _buildNavButton(context, Icons.receipt_long_outlined, 'History', 2, '/history'),
            _buildNavButton(context, Icons.person_outline, 'Profile', 3, '/register'), 
          ],
        ),
      ),
    );
  }

  Widget _buildNavButton(BuildContext context, IconData icon, String label, int index, String route) {
    bool isSelected = selectedIndex == index;
    // Uses the premium Olive Green color from the Menu screen
    final activeColor = const Color(0xFF8C9862); 
    final inactiveColor = const Color(0xFFB0B0B0);

    return GestureDetector(
      onTap: () {
        if (!isSelected) {
          Navigator.pushReplacementNamed(context, route);
        }
      },
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: isSelected ? activeColor : inactiveColor),
          const SizedBox(height: 2),
          Text(
            label, 
            style: TextStyle(
              fontSize: 10, 
              color: isSelected ? activeColor : inactiveColor
            )
          ),
        ],
      ),
    );
  }
}

// --- 2. The Floating Scan QR Button ---
class ScanQRButton extends StatelessWidget {
  final Color bgColor;

  const ScanQRButton({Key? key, required this.bgColor}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      width: 64,
      margin: const EdgeInsets.only(top: 24), 
      decoration: BoxDecoration(
        color: const Color(0xFF8C9862), 
        shape: BoxShape.circle,
        // The border perfectly matches the background of the screen it's on
        border: Border.all(color: bgColor, width: 4), 
      ),
      child: InkWell(
        onTap: () {
          print("Scan QR Clicked");
        },
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.qr_code_scanner, color: Colors.white, size: 24),
            SizedBox(height: 2),
            Text('SCAN QR', style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}