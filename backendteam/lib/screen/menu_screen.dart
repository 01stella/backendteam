import 'package:flutter/material.dart';
import '../widgets/custom_bottom_navbar.dart'; // Make sure this path is correct!

class MenuScreen extends StatefulWidget {
  const MenuScreen({Key? key}) : super(key: key);

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  int _selectedCategoryIndex = 0;

  final List<String> _categories = [
    'Special Bundle',
    'Latte Series',
    'Classics Coffee',
    'Non - Coffee',
    'Bundling Duo',
    'Bundling Trio',
    'Pastry & Bakery',
    'Skewers'
  ];

  @override
  Widget build(BuildContext context) {
    const Color bgColor = Color(0xFFF3EFE6);
    const Color goldColor = Color(0xFFC3A358);

    return Scaffold(
      backgroundColor: bgColor,
      
      // --- MENU-STYLE NAVBAR & FLOATING QR BUTTON ---
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: const ScanQRButton(bgColor: bgColor),
      bottomNavigationBar: const CustomBottomNavBar(selectedIndex: 1), // 1 for Menu
      // ----------------------------------------------
      
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(goldColor),
            // Header Divider Line
            Container(height: 1.5, color: goldColor.withOpacity(0.5)),
            // Main Content Area
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSidebar(),
                  Expanded(child: _buildMainContent()),
                ],
              ),
            ),
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
            'Menu',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
              color: Color(0xFF1E1E1E),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar() {
    const Color activeGreen = Color(0xFF8C9862);

    return SizedBox(
      width: 100, // Fixed width for sidebar
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 20),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          bool isSelected = index == _selectedCategoryIndex;
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedCategoryIndex = index;
              });
            },
            behavior: HitTestBehavior.opaque,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              decoration: BoxDecoration(
                border: Border(
                  right: BorderSide(
                    color: isSelected ? activeGreen : Colors.grey.withOpacity(0.3),
                    width: 1.5,
                  ),
                ),
              ),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Center(
                    child: Text(
                      _categories[index].replaceAll(' ', '\n'), 
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        height: 1.3,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                        color: const Color(0xFF1E1E1E),
                      ),
                    ),
                  ),
                  if (isSelected)
                    Positioned(
                      right: -4.5, 
                      top: 0,
                      bottom: 0,
                      child: Center(
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: activeGreen,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMainContent() {
    return Stack(
      children: [
        // The scrollable list of items
        ListView(
          padding: const EdgeInsets.fromLTRB(16, 80, 20, 20), 
          children: [
            _buildSectionHeader('Special Bundle'),
            _buildItemCard(
              name: 'Name',
              description: 'Description',
              price: 'Rp 90.000',
              imageWidget: _buildPlaceholderImage(), 
            ),
            _buildItemCard(
              name: 'Name',
              description: 'Description',
              price: 'Rp 55.000',
              imageWidget: _buildPlaceholderImage(),
            ),
            const SizedBox(height: 12),
            
            _buildSectionHeader('Latte Series'),
            _buildItemCard(
              name: 'Latte',
              description: 'Description',
              price: 'Rp 21.000',
              imageWidget: _buildPlaceholderImage(),
            ),
            _buildItemCard(
              name: 'Aren Latte',
              description: 'Description',
              price: 'Rp 23.000',
              imageWidget: _buildPlaceholderImage(),
            ),
            const SizedBox(height: 12),

            _buildSectionHeader('Classics Coffee'),
            _buildItemCard(
              name: 'Macchiato',
              description: 'Description',
              price: 'Rp 23.000',
              imageWidget: _buildPlaceholderImage(),
            ),
            const SizedBox(height: 40), 
          ],
        ),
        
        // Fixed Cart Button overlapping the top right
        Positioned(
          top: 16,
          right: 20,
          child: Container(
            width: 50,
            height: 50,
            decoration: const BoxDecoration(
              color: Color(0xFF8C9862), // Olive green
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.shopping_cart_outlined, color: Colors.white, size: 24),
              onPressed: () {
                // Open cart action
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0, left: 4.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Color(0xFF1E1E1E),
        ),
      ),
    );
  }

  Widget _buildItemCard({
    required String name,
    required String description,
    required String price,
    required Widget imageWidget,
  }) {
    const Color activeGreen = Color(0xFF8C9862);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFFDFDFB), 
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: activeGreen.withOpacity(0.3), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            SizedBox(
              width: 60,
              height: 60,
              child: imageWidget,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E1E1E),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.black.withOpacity(0.6),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    price,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: activeGreen, 
                    ),
                  ),
                ],
              ),
            ),
            Container(
              alignment: Alignment.topRight,
              padding: const EdgeInsets.only(bottom: 30), 
              child: const Icon(
                Icons.add,
                size: 20,
                color: Color(0xFF1E1E1E),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(Icons.coffee, color: Colors.grey.shade400, size: 30),
    );
  }
}