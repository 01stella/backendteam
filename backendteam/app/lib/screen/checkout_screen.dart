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
  
  String? _selectedPaymentMethod; 
  String _userPhone = "Loading..."; // Will fetch from memory

  // --- NEW: Fulfillment State Variables ---
  late String _fulfillmentType;
  TimeOfDay? _pickupTime;
  final TextEditingController _floorController = TextEditingController();
  final TextEditingController _roomController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fulfillmentType = CartService().fulfillmentType;
    _fetchData();
  }

  @override
  void dispose() {
    _floorController.dispose();
    _roomController.dispose();
    super.dispose();
  }

  Future<void> _fetchData() async {
    // 1. Fetch User Data for Contact Section
    final user = await AuthService.getUser();
    if (user != null) {
      setState(() {
        // Fallback just in case phone_number wasn't added to the login response yet
        _userPhone = user['phone_number'] ?? "Phone not set"; 
      });
    }

    // 2. Fetch Calculations
    final itemsPayload = widget.cartItems.map((i) => {
      "item_type": i.itemType,
      "menu_id": i.menuId,
      "bundle_id": i.bundleId,
      "quantity": i.quantity,
      "ice_level": i.iceLevel,
      "sugar_level": i.sugarLevel,
      "coffee_strength": i.coffeeStrength,
      "bundle_items": i.bundleItems.map((b) => b.toJson()).toList(),
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

  // --- NEW: MySQL Time Formatter ---
  String? _getFormattedMySQLTime() {
    if (_pickupTime == null) return null;
    final hour = _pickupTime!.hour.toString().padLeft(2, '0');
    final minute = _pickupTime!.minute.toString().padLeft(2, '0');
    return "$hour:$minute:00"; // Perfect format for MySQL TIME column
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
                    _buildFulfillmentTabs(),
                    _fulfillmentType == 'pickup' ? _buildPickUpSection() : _buildDeliverySection(),
                    Container(height: 8, color: thickDividerColor),
                    _buildOrderSummary(),
                    Container(height: 8, color: thickDividerColor),
                    _buildStampCollection(),
                    Container(height: 8, color: thickDividerColor),
                    _buildPaymentDetails(),
                    Container(height: 8, color: thickDividerColor),
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

  Widget _buildFulfillmentTabs() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Row(
        children: [
          Expanded(
            child: _buildFulfillmentTab(
              label: 'Pick Up',
              icon: Icons.coffee,
              value: 'pickup',
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _buildFulfillmentTab(
              label: 'Delivery',
              icon: Icons.delivery_dining,
              value: 'delivery',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFulfillmentTab({
    required String label,
    required IconData icon,
    required String value,
  }) {
    const Color activeGreen = Color(0xFF8C9862);
    const Color inactiveBorder = Color(0xFFC3A358);
    final bool isSelected = _fulfillmentType == value;

    return GestureDetector(
      onTap: () {
        setState(() {
          _fulfillmentType = value;
          CartService().fulfillmentType = value;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? activeGreen : Colors.transparent,
          border: Border.all(
            color: isSelected ? activeGreen : inactiveBorder,
            width: 1.2,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? Colors.white : const Color(0xFF1E1E1E),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                color: isSelected ? Colors.white : const Color(0xFF1E1E1E),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- REBUILT: Pick Up Section with TimePicker ---
  Widget _buildPickUpSection() {
    const Color activeGreen = Color(0xFF8C9862);
    String timeDisplay = _pickupTime != null ? _pickupTime!.format(context) : 'Select Time';

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
              GestureDetector(
                onTap: () async {
                  final TimeOfDay? picked = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.now(),
                    builder: (context, child) {
                      return Theme(
                        data: Theme.of(context).copyWith(
                          colorScheme: const ColorScheme.light(primary: activeGreen),
                        ),
                        child: child!,
                      );
                    },
                  );
                  if (picked != null) {
                    setState(() {
                      _pickupTime = picked;
                    });
                  }
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(timeDisplay, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: _pickupTime == null ? activeGreen : const Color(0xFF1E1E1E), decoration: _pickupTime == null ? TextDecoration.underline : TextDecoration.none)),
                    const SizedBox(height: 4),
                    const Text('Tap to set time', style: TextStyle(fontSize: 12, color: Colors.black54)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- NEW: Delivery Section ---
  Widget _buildDeliverySection() {
    const Color activeGreen = Color(0xFF8C9862);
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('DELIVERY', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: activeGreen, letterSpacing: 1.2)),
          const SizedBox(height: 4),
          Container(height: 2, width: double.infinity, color: activeGreen),
          const SizedBox(height: 12),
          
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: const Color(0xFFFFF4E5), borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.orange.shade200)),
            child: const Row(
              children: [
                Icon(Icons.info_outline, color: Colors.orange, size: 20),
                SizedBox(width: 8),
                Expanded(child: Text('Location must be within the UNIJI Tower.', style: TextStyle(fontSize: 12, color: Colors.orange))),
              ],
            ),
          ),
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _floorController,
                  decoration: InputDecoration(
                    labelText: 'Floor',
                    labelStyle: const TextStyle(fontSize: 12),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: activeGreen)),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextField(
                  controller: _roomController,
                  decoration: InputDecoration(
                    labelText: 'Room',
                    labelStyle: const TextStyle(fontSize: 12),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: activeGreen)),
                  ),
                ),
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
              const Text('ORDER SUMMARY', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1.2, color: Color(0xFF1E1E1E))),
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
                imgUrl: item.imgUrl,
              )).toList(),
        ],
      ),
    );
  }

 Widget _buildOrderItemCard({required String name, required String description, required String price, required String qty, required String? imgUrl}) {
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
            SizedBox(
              width: 70, height: 70,
              child: imgUrl != null && imgUrl.isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(imgUrl, fit: BoxFit.contain, errorBuilder: (context, error, stackTrace) => Container(decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(8)), child: Icon(Icons.fastfood, color: Colors.grey.shade400, size: 24))),
                    )
                  : Container(decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(8)), child: Icon(Icons.fastfood, color: Colors.grey.shade400, size: 24)),
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

  // --- REBUILT: Dynamic Stamp Collection ---
  Widget _buildStampCollection() {
    // Check if total hits the 50k threshold
    int earnedStamps = _total >= 50000 ? 1 : 0;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('Stamp Collection', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1E1E1E))),
          Text(
            earnedStamps > 0 ? 'Will get $earnedStamps Stamp' : 'No Stamps (Min. Rp 50.000)', 
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: earnedStamps > 0 ? const Color(0xFF8C9862) : Colors.grey),
          ), 
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

  Widget _buildPaymentMethodsAndContacts() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Payment Methods', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1E1E1E))),
          const SizedBox(height: 12),
          _buildPaymentOptionCard(title: 'Pay at Cashier', value: 'cashier', icon: Icons.point_of_sale),
          const SizedBox(height: 10),
          _buildPaymentOptionCard(title: 'Pay via App (Static QR)', value: 'app_qr', icon: Icons.qr_code_scanner),
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
              // DYNAMIC PHONE NUMBER HERE
              Text(_userPhone, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF1E1E1E))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentOptionCard({required String title, required String value, required IconData icon}) {
    bool isSelected = _selectedPaymentMethod == value;
    const Color activeGreen = Color(0xFF8C9862);

    return GestureDetector(
      onTap: () => setState(() => _selectedPaymentMethod = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? activeGreen.withOpacity(0.1) : Colors.white,
          border: Border.all(color: isSelected ? activeGreen : Colors.grey.shade300, width: isSelected ? 1.5 : 1.0),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? activeGreen : Colors.grey.shade500, size: 22),
            const SizedBox(width: 14),
            Text(title, style: TextStyle(fontSize: 14, fontWeight: isSelected ? FontWeight.bold : FontWeight.w600, color: isSelected ? activeGreen : const Color(0xFF1E1E1E))),
            const Spacer(),
            if (isSelected) const Icon(Icons.check_circle, color: activeGreen, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomPayButton(BuildContext context) {
    const Color activeGreen = Color(0xFF8C9862);
    bool isButtonDisabled = _selectedPaymentMethod == null;

    return Container(
      color: const Color(0xFFF3EFE6), 
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min, 
        children: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: isButtonDisabled ? null : () async {
                // --- NEW: FORM VALIDATION ---
                if (_fulfillmentType == 'pickup' && _pickupTime == null) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a pick up time')));
                  return;
                }
                if (_fulfillmentType == 'delivery' && (_floorController.text.isEmpty || _roomController.text.isEmpty)) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill out the Floor and Room')));
                  return;
                }

                final user = await AuthService.getUser();
                int realCustomerId = user!['id']; 

                final itemsPayload = widget.cartItems.map((i) => {
                  "item_type": i.itemType,
                  "menu_id": i.menuId,
                  "bundle_id": i.bundleId,
                  "quantity": i.quantity,
                  "ice_level": i.iceLevel,
                  "sugar_level": i.sugarLevel,
                  "coffee_strength": i.coffeeStrength,
                  "bundle_items": i.bundleItems.map((b) => b.toJson()).toList(),
                }).toList();
                
                // SENDING THE NEW VARIABLES
                final result = await ApiService.createOrder(
                  customerId: realCustomerId, 
                  paymentMethod: _selectedPaymentMethod,
                  items: itemsPayload,
                  fulfillmentType: _fulfillmentType,
                  pickupTime: _getFormattedMySQLTime(),
                  deliveryFloor: _floorController.text.isNotEmpty ? _floorController.text : null,
                  deliveryRoom: _roomController.text.isNotEmpty ? _roomController.text : null,
                );

                if (result != null && result['success'] == true) {
                  if (!context.mounted) return; 
                  
                  if (_selectedPaymentMethod == 'app_qr') {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => PaymentScreen(totalAmount: _total, orderId: result['order_id'])));
                  } else {
                    CartService().clearCart();
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Order sent to kitchen! Please pay at the cashier.'), backgroundColor: activeGreen));
                    Navigator.pushNamedAndRemoveUntil(context, '/menu', (route) => false);
                  }
                } else {
                   if (!context.mounted) return;
                   ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Order failed. Please check backend connection.')));
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: activeGreen, disabledBackgroundColor: Colors.grey.shade400, elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 18), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(
                isButtonDisabled ? 'SELECT PAYMENT METHOD' : 'PAY ${_formatPrice(_total)}', 
                style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.0),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16), side: const BorderSide(color: Color(0xFF6E562A), width: 1.5), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              child: const Text('CANCEL', style: TextStyle(color: Color(0xFF4A3C1D), fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
            ),
          ),
        ],
      ),
    );
  }
}
