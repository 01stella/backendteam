import 'package:flutter/material.dart';
import '../widgets/historycard.dart';
import '../widgets/custom_bottom_navbar.dart'; 
import '../services/api_service.dart';
import '../services/auth_service.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({Key? key}) : super(key: key);

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  bool _isLoading = true;
  List<dynamic> _orders = [];

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final user = await AuthService.getUser();
    if (user != null) {
      // Fetch real order history using the API service we just built!
      final orders = await ApiService.fetchOrderHistory(user['id']);
      if (orders != null && mounted) {
        setState(() {
          _orders = orders;
          _isLoading = false;
        });
        return;
      }
    }
    
    // Fallback if not logged in or API fails
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Helper to determine status color dynamically
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'processing': return const Color(0xFFB98068); 
      case 'completed': return const Color(0xFF7CB518);  
      case 'cancelled': return const Color(0xFFD7263D);  
      case 'pending': return Colors.orangeAccent;
      default: return Colors.grey;
    }
  }
  
  // Quick helper to capitalize the first letter of the status
  String _capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }

  @override
  Widget build(BuildContext context) {
    const bgColor = Color(0xFFF6F6E9);
    
    return Scaffold(
      backgroundColor: bgColor,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: _buildScanQRButton(bgColor),
      bottomNavigationBar: const CustomBottomNavBar(selectedIndex: 2), 
      body: SafeArea(
        child: Column(
          children: [
            _buildTopHeader(),
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
              child: _isLoading 
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF8C9862)))
                : _orders.isEmpty 
                  ? const Center(child: Text("No order history yet!", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)))
                  // Loop through the database orders and build your HistoryCards
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: _orders.length,
                      itemBuilder: (context, index) {
                        final order = _orders[index];
                        final items = order['items'] as List<dynamic>? ?? [];
                        
                        // Safely parse the date
                        String rawDate = order['created_at'] ?? '';
                        String formattedDate = rawDate.length > 16 
                            ? rawDate.substring(0, 16).replaceFirst('T', ' ')
                            : rawDate;
                        
                        return HistoryCard(
                          title: 'UNIJI LOBBY', // Based on your pickup location
                          dateTime: formattedDate,
                          status: _capitalize(order['order_status'] ?? 'Unknown'),
                          statusColor: _getStatusColor(order['order_status'] ?? ''),
                          price: order['total'].toString(),
                          itemCount: items.length,
                          // Map the database items into your custom OrderItem class!
                          items: items.map((item) => OrderItem(
                            // Using a fallback dummy image since we aren't pulling image URLs from the DB yet
                            imageUrl: 'https://i.imgur.com/1bX5QH6.png', 
                            name: item['item_name'] ?? 'Item',
                            description: 'Qty: ${item['quantity']}',
                            price: item['price'] != null ? item['price'].toString() : null,
                          )).toList(),
                          detailsText: 'Click for details',
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopHeader() {
    return Container(
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
            child: const Center(
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
    );
  }

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