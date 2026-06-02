import 'package:flutter/material.dart';
import 'checkout_screen.dart';

// Simple model to hold our cart item data
class CartItem {
  final String name;
  final String description;
  final int price;
  int quantity;
  bool isSelected;

  CartItem({
    required this.name,
    required this.description,
    required this.price,
    this.quantity = 1,
    this.isSelected = true,
  });
}

class CartScreen extends StatefulWidget {
  const CartScreen({Key? key}) : super(key: key);

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  // Dummy data matching your Figma design
  final List<CartItem> _cartItems = [
    CartItem(name: 'Latte', description: 'Description', price: 25000),
    CartItem(name: 'Lemon Tea', description: 'Description', price: 10000),
    CartItem(name: 'Croissant', description: 'Description', price: 15000),
  ];

  // Helper to format the price nicely (e.g., 25000 -> Rp 25.000)
  String _formatPrice(int price) {
    final String priceStr = price.toString();
    if (priceStr.length > 3) {
      return 'Rp ${priceStr.substring(0, priceStr.length - 3)}.${priceStr.substring(priceStr.length - 3)}';
    }
    return 'Rp $priceStr';
  }

  // Calculate the total price of selected items
  String _calculateTotal() {
    int total = 0;
    for (var item in _cartItems) {
      if (item.isSelected) {
        total += (item.price * item.quantity);
      }
    }
    return _formatPrice(total);
  }

  @override
  Widget build(BuildContext context) {
    const Color bgColor = Color(0xFFF3EFE6);
    const Color goldColor = Color(0xFFC3A358);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            // 1. Header
            _buildHeader(goldColor),
            Container(height: 1.5, color: goldColor.withOpacity(0.5)),
            
            // 2. Scrollable Cart Items
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                itemCount: _cartItems.length,
                itemBuilder: (context, index) {
                  return _buildCartItemCard(index);
                },
              ),
            ),

            // 3. Footer (Total & Buttons)
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  // --- Widget Builders ---

  Widget _buildHeader(Color goldColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: goldColor, width: 1.5),
            ),
            child: Center(
              child: Text(
                'L',
                style: TextStyle(
                  fontSize: 20,
                  color: goldColor,
                  fontWeight: FontWeight.w300,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          const Text(
            'CART',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
              color: Color(0xFF1E1E1E),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartItemCard(int index) {
    final item = _cartItems[index];
    const Color activeGreen = Color(0xFF8C9862);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFFDFDFB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: activeGreen.withOpacity(0.2), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Checkbox
            SizedBox(
              width: 24,
              height: 24,
              child: Checkbox(
                value: item.isSelected,
                activeColor: activeGreen,
                side: const BorderSide(color: Color(0xFFC3A358)), 
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                onChanged: (bool? value) {
                  setState(() {
                    item.isSelected = value ?? false;
                  });
                },
              ),
            ),
            const SizedBox(width: 12),
            
            // Item Image (Placeholder)
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.fastfood, color: Colors.grey.shade400, size: 28),
            ),
            const SizedBox(width: 16),
            
            // Details & Controls
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.name,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E1E1E),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            item.description,
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.black.withOpacity(0.5),
                            ),
                          ),
                        ],
                      ),
                      Text(
                        _formatPrice(item.price),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E1E1E),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  
                  // Quantity Controls
                  Row(
                    children: [
                      _buildQtyButton(Icons.remove, () {
                        if (item.quantity > 1) {
                          setState(() => item.quantity--);
                        }
                      }),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          '${item.quantity}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E1E1E),
                          ),
                        ),
                      ),
                      _buildQtyButton(Icons.add, () {
                        setState(() => item.quantity++);
                      }),
                      const SizedBox(width: 12),
                      // Trash Icon
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _cartItems.removeAt(index);
                          });
                        },
                        child: const Icon(
                          Icons.delete_outline,
                          color: Color(0xFFD7263D), // Red color for trash
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQtyButton(IconData icon, VoidCallback onTap) {
    const Color activeGreen = Color(0xFF8C9862);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 24,
        height: 24,
        decoration: const BoxDecoration(
          color: activeGreen,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: 16,
        ),
      ),
    );
  }

  Widget _buildFooter() {
    const Color activeGreen = Color(0xFF8C9862);
    final String totalPrice = _calculateTotal();

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      color: Colors.transparent,
      child: Column(
        children: [
          // Divider
          Container(
            height: 1,
            color: activeGreen.withOpacity(0.4),
            margin: const EdgeInsets.only(bottom: 16),
          ),
          
          // Total Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: activeGreen,
                ),
              ),
              Text(
                totalPrice,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: activeGreen,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    // EXPLICIT ROUTING: Guarantees it goes strictly back to the Menu Screen
                    Navigator.pushReplacementNamed(context, '/menu');
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: const BorderSide(color: Color(0xFF6E562A), width: 1.5), // Dark brown/gold border
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'BACK',
                    style: TextStyle(
                      color: Color(0xFF4A3C1D),
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const CheckoutScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: activeGreen,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'CHECK OUT',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}