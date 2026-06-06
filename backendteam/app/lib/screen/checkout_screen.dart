import 'package:flutter/material.dart';
import '../model/cart_item.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../services/cart_service.dart';
import 'payment_screen.dart';

class CheckoutScreen extends StatefulWidget {
  final List<CartItem> cartItems;

  const CheckoutScreen({Key? key, required this.cartItems}) : super(key: key);

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  bool _isLoading = true;
  int _subtotal = 0;
  int _pb1 = 0;
  int _vat = 0;
  int _total = 0;
  
  // --- NEW: Track the selected payment method! ---
  String? _selectedPaymentMethod; 

  @override
  void initState() {
    super.initState();
    _fetchCalculations();
  }

  Future<void> _fetchCalculations() async {
    final itemsPayload = widget.cartItems.map((i) => {
      "item_type": i.itemType,
      "menu_id": i.menuId,
      "bundle_id": i.bundleId,
      "quantity": i.quantity
    }).toList();
    final result = await ApiService.calculateOrder(itemsPayload);

    if (result != null && mounted) {
      setState(() {
        _subtotal = result['subtotal'];
        _pb1 = result['pb1'];
        _vat = result['vat'];
        _total = result['total'];
        _isLoading = false;
      });
    }
  }

  String _formatPrice(num price) {
    return 'Rp ${price.toInt()}';
  }

  @override
  Widget build(BuildContext context) {
    const Color bgColor = Color(0xFFF3EFE6);
    const Color goldColor = Color(0xFFC3A358);
    const Color thickDividerColor = Color(0xFFE8E3D7); 

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(goldColor),
            Container(height: 1.5, color: goldColor.withOpacity(0.5)),
            
            Expanded(
              child: _isLoading 
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF8C9862)))
                : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildPickUpSection(),
                    Container(height: 8, color: thickDividerColor),
                    _buildOrderSummary(),
                    Container(height: 8, color: thickDividerColor),
                    _buildStampCollection(),
                    Container(height: 8, color: thickDividerColor),
                    _buildPaymentDetails(),
                    Container(height: 8, color: thickDividerColor),
                    
                    // --- UPDATED PAYMENT SECTION ---
                    _buildPaymentMethodsAndContacts(), 
                    
                    const SizedBox(height: 40), 
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _isLoading ? const SizedBox.shrink() : _buildBottomPayButton(context),
    );
  }

  // --- Widget Builders ---

  Widget _buildHeader(Color goldColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
      child: Row(
        children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: goldColor, width: 1.5)),
            child: Center(child: Text('L', style: TextStyle(fontSize: 20, color: goldColor, fontWeight: FontWeight.w300))),
          ),
          const SizedBox(width: 16),
          const Text('CHECKOUT', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.5, color: Color(0xFF1E1E1E))),
        ],
      ),
    );
  }

  Widget _buildPickUpSection() {
    const Color activeGreen = Color(0xFF8C9862);
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('PICK UP', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: activeGreen, letterSpacing: 1.2)),
          const SizedBox(height: 4),
          Container(height: 2, width: double.infinity, color: activeGreen),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Pick up time', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1E1E1E))),
                  SizedBox(height: 4),
                  Text('UNIJI Building, Lobby Floor', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF1E1E1E))),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text('Select Time', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF1E1E1E), decoration: TextDecoration.underline)),
                  const SizedBox(height: 4),
                  Text('1.4km away from you', style: TextStyle(fontSize: 12, color: Colors.black54)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

Widget _buildOrderSummary() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'ORDER SUMMARY',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1.2, color: Color(0xFF1E1E1E)),
              ),
              const SizedBox(width: 8),
              Icon(Icons.chevron_right, size: 16, color: Colors.black.withOpacity(0.6)),
            ],
          ),
          const SizedBox(height: 16),
          ...widget.cartItems.map((item) => _buildOrderItemCard(
                name: item.name,
                description: '${item.iceLevel} • ${item.sugarLevel} • ${item.coffeeStrength}', 
                price: _formatPrice(item.price * item.quantity),
                qty: '${item.quantity}x',
                imgUrl: item.imgUrl, // <--- HERE IT IS!
              )).toList(),
        ],
      ),
    );
  }

 Widget _buildOrderItemCard({
    required String name, 
    required String description, 
    required String price, 
    required String qty,
    required String? imgUrl, // 1. Added the imgUrl parameter
  }) {
    const Color activeGreen = Color(0xFF8C9862);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFDFDFB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: activeGreen.withOpacity(0.2), width: 1),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 4))],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 2. Updated Image Section
            SizedBox(
              width: 70, 
              height: 70,
              child: imgUrl != null && imgUrl.isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        imgUrl, 
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) => Container(
                          decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(8)),
                          child: Icon(Icons.fastfood, color: Colors.grey.shade400, size: 24),
                        ),
                      ),
                    )
                  : Container(
                      decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(8)),
                      child: Icon(Icons.fastfood, color: Colors.grey.shade400, size: 24),
                    ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1E1E1E))),
                  const SizedBox(height: 2),
                  Text(description, style: TextStyle(fontSize: 11, color: Colors.black.withOpacity(0.5))),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(price, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1E1E1E))),
                const SizedBox(height: 4),
                Text(qty, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black.withOpacity(0.6))),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStampCollection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('Stamp Collection', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1E1E1E))),
          const Text('Will get 2 Stamps', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF8C9862))), 
        ],
      ),
    );
  }

  Widget _buildPaymentDetails() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('Payment Details', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1E1E1E))),
              const SizedBox(width: 4),
              Icon(Icons.info_outline, size: 14, color: Colors.black.withOpacity(0.5)),
            ],
          ),
          const SizedBox(height: 16),
          
          _buildDetailRow('Subtotal', _formatPrice(_subtotal), isBold: true),
          _buildDetailRow('PB1 10.00%', _formatPrice(_pb1), isBold: true),
          _buildDetailRow('VAT 11%', _formatPrice(_vat), isBold: true),
          
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              const Text('Total :', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF1E1E1E))),
              const SizedBox(width: 16),
              Text(_formatPrice(_total), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E1E1E))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isBold = false, bool isGrey = false}) {
    final color = isGrey ? Colors.black.withOpacity(0.5) : const Color(0xFF1E1E1E);
    final weight = isBold ? FontWeight.bold : FontWeight.normal;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 12.0, fontWeight: weight, color: color)),
          Text(value, style: TextStyle(fontSize: 12.0, fontWeight: weight, color: color)),
        ],
      ),
    );
  }

  // --- NEW: Interactive Payment Selection ---
  Widget _buildPaymentMethodsAndContacts() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Payment Methods', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1E1E1E))),
          const SizedBox(height: 12),
          
          // Option 1: Cashier
          _buildPaymentOptionCard(
            title: 'Pay at Cashier',
            value: 'cashier',
            icon: Icons.point_of_sale,
          ),
          const SizedBox(height: 10),
          
          // Option 2: App QR
          _buildPaymentOptionCard(
            title: 'Pay via App (Static QR)',
            value: 'app_qr',
            icon: Icons.qr_code_scanner,
          ),
          
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              RichText(
                text: const TextSpan(
                  text: 'CONTACTS',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF1E1E1E)),
                  children: [TextSpan(text: '*', style: TextStyle(color: Color(0xFFD7263D)))], 
                ),
              ),
              const Text('+62 8123456789', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF1E1E1E))),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Notes', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF1E1E1E))),
              Row(
                children: [
                  Text('. . .', style: TextStyle(fontSize: 16, color: Colors.black.withOpacity(0.5), letterSpacing: 2)),
                  const SizedBox(width: 8),
                  Icon(Icons.edit_square, size: 20, color: Colors.black.withOpacity(0.7)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Helper widget to draw the selectable payment cards
  Widget _buildPaymentOptionCard({required String title, required String value, required IconData icon}) {
    bool isSelected = _selectedPaymentMethod == value;
    const Color activeGreen = Color(0xFF8C9862);

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPaymentMethod = value;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? activeGreen.withOpacity(0.1) : Colors.white,
          border: Border.all(
            color: isSelected ? activeGreen : Colors.grey.shade300,
            width: isSelected ? 1.5 : 1.0,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? activeGreen : Colors.grey.shade500, size: 22),
            const SizedBox(width: 14),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                color: isSelected ? activeGreen : const Color(0xFF1E1E1E),
              ),
            ),
            const Spacer(),
            if (isSelected)
              const Icon(Icons.check_circle, color: activeGreen, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomPayButton(BuildContext context) {
    const Color activeGreen = Color(0xFF8C9862);
    
    // Check if the button should be disabled
    bool isButtonDisabled = _selectedPaymentMethod == null;

    return Container(
      color: const Color(0xFFF3EFE6), 
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min, 
        children: [
          // 1. PAY BUTTON
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              // --- DISABLE IF NULL ---
              onPressed: isButtonDisabled ? null : () async {
                // 1. Since the Cart Screen already verified they are logged in, 
                // we just grab the ID directly without the error popups.
                final user = await AuthService.getUser();
                int realCustomerId = user!['id']; // Safe to force unwrap with ! here

               final itemsPayload = widget.cartItems.map((i) => {
                "item_type": i.itemType,
                "menu_id": i.menuId,
                "bundle_id": i.bundleId,
                "quantity": i.quantity,
                "ice_level": i.iceLevel,
                "sugar_level": i.sugarLevel,
                "coffee_strength": i.coffeeStrength
              }).toList();
                
                final result = await ApiService.createOrder(
                  customerId: realCustomerId, 
                  paymentMethod: _selectedPaymentMethod,
                  items: itemsPayload
                );

                if (result != null && result['success'] == true) {
                  if (!context.mounted) return; 
                  
                  if (_selectedPaymentMethod == 'app_qr') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PaymentScreen(
                          totalAmount: _total,
                          orderId: result['order_id'], 
                        )
                      ),
                    );
                  } else {
                    CartService().clearCart();

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Order sent to kitchen! Please pay at the cashier.'),
                        backgroundColor: activeGreen,
                      ),
                    );
                    
                    Navigator.pushNamedAndRemoveUntil(context, '/menu', (route) => false);
                  }

                } else {
                   if (!context.mounted) return;
                   ScaffoldMessenger.of(context).showSnackBar(
                     const SnackBar(content: Text('Order failed. Please check backend connection.')),
                   );
                }
              },
              style: ElevatedButton.styleFrom(
                // Change color if disabled
                backgroundColor: activeGreen,
                disabledBackgroundColor: Colors.grey.shade400,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(
                isButtonDisabled ? 'SELECT PAYMENT METHOD' : 'PAY ${_formatPrice(_total)}', 
                style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.0),
              ),
            ),
          ),
          const SizedBox(height: 12),
          
          // 2. CANCEL BUTTON
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {
                Navigator.pop(context); 
              },
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                side: const BorderSide(color: Color(0xFF6E562A), width: 1.5), 
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text(
                'CANCEL', 
                style: TextStyle(color: Color(0xFF4A3C1D), fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1.2)
              ),
            ),
          ),
        ],
      ),
    );
  }
}