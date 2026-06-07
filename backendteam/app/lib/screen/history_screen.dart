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

  String _formatPrice(dynamic value) {
    final amount = num.tryParse(value?.toString() ?? '') ?? 0;
    return 'Rp ${amount.toInt()}';
  }

  String _formatDate(dynamic value) {
    final rawDate = value?.toString() ?? '';
    return rawDate.length > 16
        ? rawDate.substring(0, 16).replaceFirst('T', ' ')
        : rawDate;
  }

  String _formatMethod(dynamic value) {
    switch (value?.toString()) {
      case 'app_qr':
        return 'Pay via App';
      case 'cashier':
        return 'Pay at Cashier';
      default:
        return _capitalize(value?.toString() ?? 'Unknown');
    }
  }

  String _fulfillmentTitle(Map<String, dynamic> order) {
    final type = order['fulfillment_type']?.toString() ?? 'pickup';
    if (type == 'delivery') {
      final floor = order['delivery_floor']?.toString() ?? '-';
      final room = order['delivery_room']?.toString() ?? '-';
      return 'Delivery - Floor $floor, Room $room';
    }

    final pickupTime = order['pickup_time']?.toString();
    return pickupTime == null || pickupTime.isEmpty
        ? 'Pick Up - UNIJI Lobby'
        : 'Pick Up - $pickupTime';
  }

  void _showReceipt(Map<String, dynamic> order) {
    final items = order['items'] as List<dynamic>? ?? [];
    final status = _capitalize(order['order_status']?.toString() ?? 'Unknown');
    final paymentStatus = _capitalize(order['payment_status']?.toString() ?? 'Unknown');
    final orderId = order['id']?.toString() ?? '-';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.78,
          minChildSize: 0.45,
          maxChildSize: 0.92,
          builder: (context, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: Color(0xFFFFFCF5),
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
                children: [
                  Center(
                    child: Container(
                      width: 44,
                      height: 5,
                      decoration: BoxDecoration(
                        color: const Color(0xFFD7CBB8),
                        borderRadius: BorderRadius.circular(99),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  const Center(
                    child: Text(
                      'LUMIORA RECEIPT',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.4,
                        color: Color(0xFF1E1E1E),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Center(
                    child: Text(
                      'Order #$orderId',
                      style: const TextStyle(fontSize: 12, color: Colors.black54),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildReceiptInfoRow('Date', _formatDate(order['created_at'])),
                  _buildReceiptInfoRow('Status', status),
                  _buildReceiptInfoRow('Payment', _formatMethod(order['payment_method'])),
                  _buildReceiptInfoRow('Payment Status', paymentStatus),
                  _buildReceiptInfoRow('Fulfillment', _fulfillmentTitle(order)),
                  const SizedBox(height: 16),
                  const Divider(color: Color(0xFFE4D9C8)),
                  const SizedBox(height: 10),
                  const Text(
                    'Items',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E1E1E),
                    ),
                  ),
                  const SizedBox(height: 10),
                  ...items.map((item) => _buildReceiptItem(item)),
                  const SizedBox(height: 12),
                  const Divider(color: Color(0xFFE4D9C8)),
                  const SizedBox(height: 12),
                  _buildReceiptInfoRow(
                    'Total',
                    _formatPrice(order['total']),
                    isTotal: true,
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildReceiptInfoRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: isTotal ? 15 : 12,
                fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
                color: Colors.black54,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: isTotal ? 18 : 12,
                fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
                color: isTotal ? const Color(0xFF8C9862) : const Color(0xFF1E1E1E),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReceiptItem(dynamic item) {
    final quantity = int.tryParse(item['quantity']?.toString() ?? '') ?? 0;
    final itemPrice = num.tryParse(item['item_price']?.toString() ?? '') ?? 0;
    final menuPrice = num.tryParse(item['price']?.toString() ?? '') ?? 0;
    final unitPrice = itemPrice > 0 ? itemPrice : menuPrice;
    final lineTotal = quantity * unitPrice;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${quantity}x',
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              item['item_name']?.toString() ?? 'Item',
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            _formatPrice(lineTotal),
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
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
                  letterSpacing: 1.0,
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
                        
                        
                        final orderMap = Map<String, dynamic>.from(order as Map);
                        final formattedDate = _formatDate(order['created_at']);
                        
                        return GestureDetector(
                          onTap: () => _showReceipt(orderMap),
                          behavior: HitTestBehavior.opaque,
                          child: HistoryCard(
                            title: _fulfillmentTitle(orderMap),
                            dateTime: formattedDate,
                            status: _capitalize(order['order_status'] ?? 'Unknown'),
                            statusColor: _getStatusColor(order['order_status'] ?? ''),
                            price: order['total'].toString(),
                            itemCount: items.length,
                            // Map the database items into your custom OrderItem class!
                            items: items.map((item) => OrderItem(
                              imageUrl: item['image_url'] ?? '', 
                              name: item['item_name'] ?? 'Item',
                              description: 'Qty: ${item['quantity']}',
                              price: item['price'] != null ? item['price'].toString() : null,
                            )).toList(),
                            detailsText: 'Tap for receipt',
                          ),
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
