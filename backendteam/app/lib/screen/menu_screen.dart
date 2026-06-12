import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../widgets/cafe_logo_button.dart';
import '../widgets/welcome_bottom_sheet.dart';
import '../widgets/custom_bottom_navbar.dart';
import '../services/api_service.dart';
import '../services/cart_service.dart';
import '../model/cart_item.dart';
import '../model/bundle_model.dart';
import '../services/bundle_service.dart';

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
    'Pastry & Bakery',
    'Skewers',
  ];

  final List<GlobalKey> _categoryKeys = List.generate(
    8,
    (index) => GlobalKey(),
  );

  late Future<Map<String, List<dynamic>>> _menuFuture;

  @override
  void initState() {
    super.initState();
    _menuFuture = _fetchAndGroupMenu();
  }

  // Fetch from API and group by category_name
  Future<Map<String, List<dynamic>>> _fetchAndGroupMenu() async {
    final rawData = await ApiService.fetchMenu();
    Map<String, List<dynamic>> grouped = {};

    for (var item in rawData) {
      String catName = item['category_name'];
      if (!grouped.containsKey(catName)) {
        grouped[catName] = [];
      }
      grouped[catName]!.add(item);
    }
    return grouped;
  }

  // Helper to format price
  String _formatPrice(int price) {
    final String priceStr = price.toString();
    if (priceStr.length > 3) {
      return 'Rp ${priceStr.substring(0, priceStr.length - 3)}.${priceStr.substring(priceStr.length - 3)}';
    }
    return 'Rp $priceStr';
  }

  // Trigger the popup
  void _showItemDetails(
    BuildContext context,
    String itemType,
    String categoryName,
    int? menuId,
    int? bundleId,
    String name,
    String description,
    int basePrice,
    String? imgUrl,
    List<BundleIncludedItem> bundleItems,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: ItemDetailsBottomSheet(
            itemType: itemType,
            categoryName: categoryName,
            menuId: menuId,
            bundleId: bundleId,
            bundleItems: bundleItems,
            itemName: name,
            itemDescription: description,
            basePrice: basePrice,
            imgUrl: imgUrl,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color bgColor = Color(0xFFF3EFE6);
    const Color goldColor = Color(0xFFC3A358);

    return Scaffold(
      backgroundColor: bgColor,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: _buildScanQRButton(bgColor),
      bottomNavigationBar: const CustomBottomNavBar(selectedIndex: 1),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(goldColor),
            Container(height: 1.5, color: goldColor.withOpacity(0.5)),
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
            child: const CafeLogoButton(),
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
      width: 100,
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
              final keyContext = _categoryKeys[index].currentContext;
              if (keyContext != null) {
                Scrollable.ensureVisible(
                  keyContext,
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeInOut,
                  alignment: 0.05,
                );
              }
            },
            behavior: HitTestBehavior.opaque,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              decoration: BoxDecoration(
                border: Border(
                  right: BorderSide(
                    color: isSelected
                        ? activeGreen
                        : const Color.fromARGB(255, 87, 9, 9).withOpacity(0.3),
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
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.w500,
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
    return FutureBuilder<Map<String, List<dynamic>>>(
      future: _menuFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFF8C9862)),
          );
        }
        if (snapshot.hasError || !snapshot.hasData) {
          return const Center(child: Text('Failed to load menu'));
        }

        final groupedMenu = snapshot.data!;

        return Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 80, 20, 60),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: _categories.asMap().entries.map((entry) {
                  int index = entry.key;
                  String catName = entry.value;

                  // ==========================================
                  // 1. INJECT THE BUNDLES HERE
                  // ==========================================
                  // ==========================================
                  // 1. INJECT THE BUNDLES HERE
                  // ==========================================
                  if (catName == 'Special Bundle') {
                    return Container(
                      key: _categoryKeys[index],
                      margin: const EdgeInsets.only(bottom: 16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(bottom: 12.0, left: 4.0),
                            child: Text(
                              'Special Bundle',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF1E1E1E),
                              ),
                            ),
                          ),

                          FutureBuilder<List<Bundle>>(
                            future: fetchBundles(),
                            builder: (context, bundleSnapshot) {
                              if (bundleSnapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Center(
                                  child: CircularProgressIndicator(
                                    color: Color(0xFF8C9862),
                                  ),
                                );
                              }
                              if (bundleSnapshot.hasError ||
                                  !bundleSnapshot.hasData ||
                                  bundleSnapshot.data!.isEmpty) {
                                return const Padding(
                                  padding: EdgeInsets.only(left: 4.0),
                                  child: Text(
                                    'No promos available right now.',
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 12,
                                    ),
                                  ),
                                );
                              }

                              final bundles = bundleSnapshot.data!;
                              return Column(
                                children: bundles.map((bundle) {
                                  // Reuse your beautifully designed card and pass the bundle data!
                                  return _buildItemCard(
                                    itemType: 'bundle',
                                    categoryName: 'Special Bundle',
                                    menuId: null,
                                    bundleId: bundle.id,
                                    name: bundle.name,
                                    description: bundle.includedItems
                                        .map((i) => i.name)
                                        .join(" + "),
                                    price: bundle.price,
                                    imgUrl: bundle.imageUrl,
                                    bundleItems: bundle.includedItems,
                                  );
                                }).toList(),
                              );
                            },
                          ),
                        ],
                      ),
                    );
                  }

                  // ==========================================
                  // 2. YOUR EXISTING REGULAR MENU LOGIC
                  // ==========================================
                  List<dynamic> itemsInCat = groupedMenu[catName] ?? [];

                  // Only render the category section if it has items in the DB
                  if (itemsInCat.isEmpty) return const SizedBox.shrink();

                  return _buildCategorySection(
                    key: _categoryKeys[index],
                    title: catName,
                    items: itemsInCat
                        .map<Widget>(
                          (item) => _buildItemCard(
                            itemType: 'menu',
                            categoryName: catName,
                            menuId: item['menu_id'],
                            bundleId: null,
                            bundleItems: const [],
                            name: item['item_name'],
                            description: item['description'] ?? '',
                            price: int.parse(
                              item['price'].toString().split('.')[0],
                            ),
                            imgUrl: item['image_url'],
                          ),
                        )
                        .toList(),
                  );
                }).toList(),
              ),
            ),

            Positioned(
              top: 16,
              right: 20,
              child: Container(
                width: 50,
                height: 50,
                decoration: const BoxDecoration(
                  color: Color(0xFF8C9862),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(
                    Icons.shopping_cart_outlined,
                    color: Colors.white,
                    size: 24,
                  ),
                  onPressed: () {
                    Navigator.pushNamed(context, '/cart');
                  },
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCategorySection({
    required GlobalKey key,
    required String title,
    required List<Widget> items,
  }) {
    return Container(
      key: key,
      margin: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 12.0, left: 4.0),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1E1E1E),
              ),
            ),
          ),
          ...items,
        ],
      ),
    );
  }

  Widget _buildItemCard({
    required String name,
    required String description,
    required int price,
    required String? imgUrl,
    required String itemType, // 'menu' or 'bundle'
    required String categoryName,
    required int? menuId,
    required int? bundleId,
    required List<BundleIncludedItem> bundleItems,
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
            color: Colors.black.withOpacity(0.08),
            blurRadius: 6,
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
              child: imgUrl != null && imgUrl.isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        imgUrl,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) =>
                            _buildPlaceholderImage(),
                      ),
                    )
                  : _buildPlaceholderImage(),
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
                    _formatPrice(price),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: activeGreen,
                    ),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () => _showItemDetails(
                context,
                itemType,
                categoryName,
                menuId,
                bundleId,
                name,
                description,
                price,
                imgUrl,
                bundleItems,
              ),
              behavior: HitTestBehavior.opaque,
              child: Container(
                alignment: Alignment.topRight,
                padding: const EdgeInsets.only(bottom: 30, left: 20),
                child: const Icon(
                  Icons.add,
                  size: 20,
                  color: Color(0xFF1E1E1E),
                ),
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
            Text(
              'SCAN QR',
              style: TextStyle(
                color: Colors.white,
                fontSize: 8,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ------------------------------------------------------------------------
// Detailed Item Bottom Sheet (3/4 Screen Size)
// ------------------------------------------------------------------------
class ItemDetailsBottomSheet extends StatefulWidget {
  final String itemType;
  final String categoryName;
  final int? menuId;
  final int? bundleId;
  final String itemName;
  final String itemDescription;
  final int basePrice;
  final String? imgUrl;
  final List<BundleIncludedItem> bundleItems;

  const ItemDetailsBottomSheet({
    Key? key,
    required this.itemType,
    required this.categoryName,
    required this.menuId,
    required this.bundleId,
    required this.itemName,
    required this.itemDescription,
    required this.basePrice,
    required this.imgUrl,
    required this.bundleItems,
  }) : super(key: key);

  @override
  State<ItemDetailsBottomSheet> createState() => _ItemDetailsBottomSheetState();
}

class _ItemDetailsBottomSheetState extends State<ItemDetailsBottomSheet> {
  String _selectedIce = 'Hot';
  String _selectedSugar = 'Less Sugar';
  String _selectedStrength = 'Normal';
  int _quantity = 1;
  int _selectedBundleIndex = 0;
  late List<BundleCartCustomization> _bundleCustomizations;

  final Color _activeGreen = const Color(0xFF8C9862);
  final Color _inactiveBorder = const Color(0xFFC3A358);

  bool get _isBundle => widget.itemType == 'bundle';
  bool get _needsCustomization =>
      _isBundle || widget.categoryName != 'Pastry & Bakery';

  @override
  void initState() {
    super.initState();
    _bundleCustomizations = widget.bundleItems
        .map(
          (item) => BundleCartCustomization(
            menuId: item.menuId,
            name: item.name,
            iceLevel: _selectedIce,
            sugarLevel: _selectedSugar,
            coffeeStrength: _selectedStrength,
          ),
        )
        .toList();
  }

  String _formatPrice(int price) {
    final String priceStr = price.toString();
    if (priceStr.length > 3) {
      return 'Rp ${priceStr.substring(0, priceStr.length - 3)}.${priceStr.substring(priceStr.length - 3)}';
    }
    return 'Rp $priceStr';
  }

  void _selectBundleItem(int index) {
    final customization = _bundleCustomizations[index];
    setState(() {
      _selectedBundleIndex = index;
      _selectedIce = customization.iceLevel;
      _selectedSugar = customization.sugarLevel;
      _selectedStrength = customization.coffeeStrength;
    });
  }

  void _updateSelectedCustomization({
    String? iceLevel,
    String? sugarLevel,
    String? coffeeStrength,
  }) {
    if (!_isBundle || _bundleCustomizations.isEmpty) return;

    final current = _bundleCustomizations[_selectedBundleIndex];
    _bundleCustomizations[_selectedBundleIndex] = BundleCartCustomization(
      menuId: current.menuId,
      name: current.name,
      iceLevel: iceLevel ?? current.iceLevel,
      sugarLevel: sugarLevel ?? current.sugarLevel,
      coffeeStrength: coffeeStrength ?? current.coffeeStrength,
    );
  }

  // --- NEW: THE GATEKEEPER FUNCTION ---
  // This wraps your 'Add to Cart' logic inside an auth check
  Future<void> _handleProtectedAction(bool goToCheckout) async {
    // 1. Check if logged in
    var user = await AuthService.getUser();

    // 2. Not logged in? Show the WelcomeBottomSheet!
    if (user == null) {
      if (!mounted) return;

      // We await the bottom sheet to see if they logged in successfully
      final loginResult = await showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (BuildContext context) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            // YOU MUST IMPORT THIS WIDGET AT THE TOP OF MENU_SCREEN.DART
            // import '../widgets/welcome_bottom_sheet.dart';
            child: const WelcomeBottomSheet(),
          );
        },
      );

      // If they closed the sheet without logging in, stop here.
      if (loginResult == null) return;

      // If we reach here, they logged in! Proceed with adding to cart.
    }

    // 3. Add item to cart
    CartService().addItem(
      CartItem(
        itemType: widget.itemType,
        menuId: widget.menuId,
        bundleId: widget.bundleId,
        name: widget.itemName,
        description: widget.itemDescription,
        price: widget.basePrice,
        imgUrl: widget.imgUrl,
        quantity: _quantity,
        bundleItems: _isBundle ? _bundleCustomizations : const [],
        iceLevel: _selectedIce,
        sugarLevel: _selectedSugar,
        coffeeStrength: _selectedStrength,
      ),
    );

    if (!mounted) return;

    // 4. Navigate based on which button they pressed
    if (goToCheckout) {
      Navigator.pop(context); // Close the item details sheet
      Navigator.pushNamed(context, '/cart'); // Go to cart
    } else {
      final messenger = ScaffoldMessenger.of(context);
      final media = MediaQuery.of(context);
      final bottomMargin = (media.size.height - media.padding.top - 96).clamp(
        20.0,
        media.size.height,
      );

      Navigator.pop(context); // Close the item details sheet
      messenger.hideCurrentSnackBar();
      messenger.showSnackBar(
        SnackBar(
          content: const Text('Added to Cart!'),
          backgroundColor: const Color(0xFF8C9862),
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.fromLTRB(20, 0, 20, bottomMargin),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final double popupHeight = MediaQuery.of(context).size.height * 0.75;

    return Container(
      height: popupHeight,
      decoration: const BoxDecoration(
        color: Color(0xFFF3EFE6),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24.0),
          topRight: Radius.circular(24.0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            height: 48,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(24.0),
                topRight: Radius.circular(24.0),
              ),
            ),
            alignment: Alignment.center,
            child: Container(
              height: 6,
              width: 48,
              decoration: BoxDecoration(
                color: Colors.grey.shade400,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.itemName,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.itemDescription,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.black.withOpacity(0.6),
                    ),
                  ),
                  const SizedBox(height: 24),

                  if (_needsCustomization) ...[
                    if (_isBundle && _bundleCustomizations.isNotEmpty) ...[
                      _buildSectionTitle('Customize Item'),
                      _buildBundleSelector(),
                    ],
                    _buildSectionTitle('Ice Level'),
                    _buildOptionsRow(
                      options: ['Hot', 'Less Ice', 'Normal Ice'],
                      selectedValue: _selectedIce,
                      onSelect: (val) => setState(() {
                        _selectedIce = val;
                        _updateSelectedCustomization(iceLevel: val);
                      }),
                    ),
                    _buildSectionTitle('Sugar Level'),
                    _buildOptionsRow(
                      options: ['No Sugar', 'Less Sugar', 'Normal Sugar'],
                      selectedValue: _selectedSugar,
                      onSelect: (val) => setState(() {
                        _selectedSugar = val;
                        _updateSelectedCustomization(sugarLevel: val);
                      }),
                    ),
                    _buildSectionTitle('Coffee Strength'),
                    _buildOptionsRow(
                      options: ['Normal', 'Strong'],
                      selectedValue: _selectedStrength,
                      onSelect: (val) => setState(() {
                        _selectedStrength = val;
                        _updateSelectedCustomization(coffeeStrength: val);
                      }),
                    ),
                    const SizedBox(height: 8),
                    const Divider(),
                    const SizedBox(height: 16),
                  ],

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _formatPrice(widget.basePrice * _quantity),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: _activeGreen,
                        ),
                      ),
                      Row(
                        children: [
                          _buildQtyButton(Icons.remove, () {
                            if (_quantity > 1) setState(() => _quantity--);
                          }),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              '$_quantity',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          _buildQtyButton(Icons.add, () {
                            setState(() => _quantity++);
                          }),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  Row(
                    children: [
                      // --- UPDATED ADD TO CART BUTTON ---
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => _handleProtectedAction(false),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            side: BorderSide(color: _activeGreen, width: 1.5),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            'ADD TO CART',
                            style: TextStyle(
                              color: _activeGreen,
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),

                      // --- UPDATED CHECK OUT BUTTON ---
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => _handleProtectedAction(true),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF947B44),
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'CHECK OUT',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildOptionsRow({
    required List<String> options,
    required String selectedValue,
    required ValueChanged<String> onSelect,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Wrap(
        spacing: 8,
        runSpacing: 10,
        children: options.map((option) {
          bool isSelected = option == selectedValue;
          return GestureDetector(
            onTap: () => onSelect(option),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? _activeGreen : Colors.transparent,
                border: Border.all(
                  color: isSelected ? _activeGreen : _inactiveBorder,
                  width: 1.0,
                ),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                option,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected ? Colors.white : Colors.black87,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildBundleSelector() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Wrap(
        spacing: 8,
        runSpacing: 10,
        children: List.generate(_bundleCustomizations.length, (index) {
          final item = _bundleCustomizations[index];
          final isSelected = index == _selectedBundleIndex;

          return GestureDetector(
            onTap: () => _selectBundleItem(index),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? _activeGreen : Colors.transparent,
                border: Border.all(
                  color: isSelected ? _activeGreen : _inactiveBorder,
                  width: 1.0,
                ),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                item.name,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected ? Colors.white : Colors.black87,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildQtyButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: _activeGreen,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Icon(icon, color: Colors.white, size: 16),
      ),
    );
  }
}
