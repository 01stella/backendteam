import 'package:flutter/material.dart';
import '../widgets/historycard.dart';
import '../widgets/custom_bottom_navbar.dart'; // Make sure this path is correct!

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const bgColor = Color(0xFFF6F6E9);
    
    return Scaffold(
      backgroundColor: bgColor,
      // --- MENU-STYLE NAVBAR & FLOATING QR BUTTON ---
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: _buildScanQRButton(bgColor),
      bottomNavigationBar: const CustomBottomNavBar(selectedIndex: 2), // 2 for History
      // ----------------------------------------------
      body: SafeArea(
        child: Column(
          children: [
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF6F6E9),
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: Center(
                      child: Text(
                        'LQ',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: Color(0xFFB98068),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'HISTORY',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      letterSpacing: 1.5,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: const Text(
                'MY ORDER',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Color(0xFFB98068),
                  letterSpacing: 1.2,
                ),
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  HistoryCard(
                    title: 'JIC TOWER',
                    dateTime: '19/05/2026 09.19',
                    status: 'Ongoing',
                    statusColor: const Color(0xFFB98068),
                    price: '100.000',
                    itemCount: 2,
                    items: const [
                      OrderItem(
                        imageUrl: 'https://i.imgur.com/1bX5QH6.png',
                        name: 'Lemon Tea',
                        description: null,
                        price: null,
                      ),
                      OrderItem(
                        imageUrl: 'https://i.imgur.com/2nCt3Sbl.png',
                        name: 'Croissant',
                        description: null,
                        price: null,
                      ),
                    ],
                    detailsText: 'Click for details',
                  ),
                  HistoryCard(
                    title: 'JIC TOWER',
                    dateTime: '23/05/2026 13.00',
                    status: 'Success',
                    statusColor: const Color(0xFF7CB518),
                    price: '300.000',
                    itemCount: 3,
                    items: const [
                      OrderItem(
                        imageUrl: 'https://i.imgur.com/3y1bX5Q.png',
                        name: 'Lemon Tea',
                        description: 'Description',
                        price: '10,000',
                      ),
                      OrderItem(
                        imageUrl: 'https://i.imgur.com/1bX5QH6.png',
                        name: 'Croissant',
                        description: 'Description',
                        price: '15,000',
                      ),
                      OrderItem(
                        imageUrl: 'https://i.imgur.com/2nCt3Sbl.png',
                        name: 'Latte + Tumbler',
                        description: '30 Shots',
                        price: '275,000',
                      ),
                    ],
                    actionButton: SizedBox(
                      width: 110,
                      height: 28,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFD9CBA3),
                          foregroundColor: const Color(0xFF1A1A1A),
                          padding: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                          elevation: 0,
                        ),
                        onPressed: null,
                        child: const Text('Order Again', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    detailsText: 'Click to Reduce',
                  ),
                  HistoryCard(
                    title: 'JIC TOWER',
                    dateTime: '23/05/2026 13.00',
                    status: 'Cancelled',
                    statusColor: const Color(0xFFD7263D),
                    price: '340.000',
                    itemCount: 4,
                    items: const [
                      OrderItem(
                        imageUrl: 'https://i.imgur.com/3y1bX5Q.png',
                        name: '',
                        description: null,
                        price: null,
                      ),
                      OrderItem(
                        imageUrl: 'https://i.imgur.com/1bX5QH6.png',
                        name: '',
                        description: null,
                        price: null,
                      ),
                    ],
                    detailsText: '2 more...\nClick for details',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Helper for the Floating SCAN QR Button ---
  Widget _buildScanQRButton(Color bgColor) {
    return Container(
      height: 64,
      width: 64,
      margin: const EdgeInsets.only(top: 24), 
      decoration: BoxDecoration(
        color: const Color(0xFF8C9862), 
        shape: BoxShape.circle,
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