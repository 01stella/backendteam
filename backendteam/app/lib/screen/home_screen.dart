import 'package:flutter/material.dart';
import '../model/bundle_model.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../services/bundle_service.dart';
import '../services/cart_service.dart';
import '../widgets/cafe_logo_button.dart';
import '../widgets/custom_bottom_navbar.dart';
import '../widgets/welcome_bottom_sheet.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Lumiora Home',
      theme: ThemeData(
        fontFamily: 'Sans-Serif',
        scaffoldBackgroundColor: const Color(0xFFF6F1EA),
        primaryColor: const Color(0xFF7B8C2A),
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  final Color primaryGreen = const Color(0xFF7B8C2A);
  final Color darkGreen = const Color(0xFF4C4C36);
  final Color warmBrown = const Color(0xFF947B44);
  final Color softBrown = const Color(0xFFE8DDCA);
  final Color textDark = const Color(0xFF252821);
  final Color surface = const Color(0xFFFFFCF5);
  final TextEditingController _searchController = TextEditingController();

  String _userName = 'Guest';
  String _userEmail = '';
  String _selectedFulfillmentType = 'pickup';
  String _selectedCategory = 'All';
  String _searchQuery = '';
  int _stampCount = 0;
  int _voucherCount = 0;
  bool _isLoading = true;
  late Future<List<Bundle>> _bundlesFuture;
  late Future<List<dynamic>> _menuFuture;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _bundlesFuture = fetchBundles();
    _menuFuture = ApiService.fetchMenu();
    _loadUserData();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _searchController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _loadUserData();
    }
  }

  Future<void> _loadUserData() async {
    final user = await AuthService.getUser();

    if (user != null && mounted) {
      final stamps = await ApiService.fetchCustomerStamps(user['id']);
      final vouchers = await ApiService.fetchCustomerVouchers(user['id']);
      setState(() {
        _userName = user['full_name'].split(' ')[0];
        _userEmail = user['email']?.toString() ?? 'Email not available';
        _stampCount = stamps;
        _voucherCount = vouchers.length;
        _isLoading = false;
      });
      return;
    }

    if (mounted) {
      setState(() {
        _userName = 'Guest';
        _userEmail = 'Sign in to see your email';
        _stampCount = 0;
        _voucherCount = 0;
        _isLoading = false;
      });
    }
  }

  String _formatPrice(num price) {
    return 'Rp ${price.toInt()}';
  }

  List<BoxShadow> _softShadow({double opacity = 0.08, double y = 8}) {
    return [
      BoxShadow(
        color: Colors.black.withValues(alpha: opacity),
        blurRadius: 24,
        offset: Offset(0, y),
      ),
      BoxShadow(
        color: Colors.white.withValues(alpha: 0.72),
        blurRadius: 10,
        offset: const Offset(-3, -3),
      ),
    ];
  }

  List<BoxShadow> _coloredGlow(Color color, {double opacity = 0.22}) {
    return [
      BoxShadow(
        color: color.withValues(alpha: opacity),
        blurRadius: 22,
        spreadRadius: -4,
        offset: const Offset(0, 10),
      ),
    ];
  }

  List<dynamic> _filteredMenuItems(List<dynamic> items) {
    final query = _searchQuery.trim().toLowerCase();

    return items.where((item) {
      final name = item['item_name']?.toString().toLowerCase() ?? '';
      final category = item['category_name']?.toString() ?? '';
      final description = item['description']?.toString().toLowerCase() ?? '';
      final matchesCategory =
          _selectedCategory == 'All' || category == _selectedCategory;
      final matchesSearch =
          query.isEmpty ||
          name.contains(query) ||
          category.toLowerCase().contains(query) ||
          description.contains(query);

      return matchesCategory && matchesSearch;
    }).toList();
  }

  Future<void> _showSignInModal() async {
    final result = await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: true,
      enableDrag: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: const WelcomeBottomSheet(),
        );
      },
    );

    if (result != null && mounted) {
      await _loadUserData();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: const Color(0xFFF6F1EA),
        body: Center(child: CircularProgressIndicator(color: primaryGreen)),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF6F1EA),
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 112),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHomeHeader(),
                    const SizedBox(height: 16),
                    _buildCustomerSummary(),
                    const SizedBox(height: 18),
                    _buildFulfillmentTabs(),
                    const SizedBox(height: 14),
                    _buildSearchBar(),
                    const SizedBox(height: 22),
                    _buildCategoriesSection(),
                    const SizedBox(height: 22),
                    _buildBundlesSection(),
                    const SizedBox(height: 22),
                    _buildMostOrderedSection(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: Container(
        height: 64,
        width: 64,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: primaryGreen,
          boxShadow: [
            BoxShadow(
              color: primaryGreen.withValues(alpha: 0.38),
              blurRadius: 24,
              spreadRadius: 2,
              offset: const Offset(0, 8),
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.18),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: const Icon(Icons.qr_code_scanner, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: const CustomBottomNavBar(selectedIndex: 0),
    );
  }

  Widget _buildHomeHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: primaryGreen,
            border: Border.all(color: const Color(0xFFD2B36A), width: 1.5),
            boxShadow: _coloredGlow(primaryGreen, opacity: 0.24),
          ),
          child: const CafeLogoButton(),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hello, $_userName',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: textDark,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 3),
              _userName == 'Guest'
                  ? GestureDetector(
                      onTap: _showSignInModal,
                      behavior: HitTestBehavior.opaque,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Text(
                          'Sign in to account',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            color: warmBrown,
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline,
                            decorationColor: warmBrown,
                          ),
                        ),
                      ),
                    )
                  : Text(
                      _userEmail,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black54,
                      ),
                    ),
            ],
          ),
        ),
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: warmBrown,
            shape: BoxShape.circle,
            boxShadow: _coloredGlow(warmBrown, opacity: 0.26),
          ),
          child: IconButton(
            icon: const Icon(
              Icons.shopping_cart_outlined,
              color: Colors.white,
              size: 21,
            ),
            onPressed: () => Navigator.pushNamed(context, '/cart'),
          ),
        ),
      ],
    );
  }

  Widget _buildCustomerSummary() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: primaryGreen,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: warmBrown.withValues(alpha: 0.45),
          width: 1.2,
        ),
        boxShadow: [
          ..._coloredGlow(primaryGreen, opacity: 0.24),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.10),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildStatBadge(Icons.stars, '$_stampCount', 'Stamps'),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _buildStatBadge(
              Icons.local_offer,
              '$_voucherCount',
              'Vouchers',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFulfillmentTabs() {
    return Row(
      children: [
        Expanded(
          child: _buildFulfillmentTab('pickup', 'Pick Up', Icons.coffee),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildFulfillmentTab(
            'delivery',
            'Delivery',
            Icons.delivery_dining,
          ),
        ),
      ],
    );
  }

  Widget _buildFulfillmentTab(String value, String label, IconData icon) {
    final isSelected = _selectedFulfillmentType == value;
    final activeColor = value == 'pickup' ? primaryGreen : warmBrown;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: () {
          setState(() => _selectedFulfillmentType = value);
          CartService().fulfillmentType = value;
        },
        borderRadius: BorderRadius.circular(8),
        hoverColor: activeColor.withValues(alpha: 0.08),
        splashColor: activeColor.withValues(alpha: 0.12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          height: 92,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: isSelected ? activeColor : surface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? activeColor : softBrown,
              width: 1.3,
            ),
            boxShadow: isSelected
                ? _coloredGlow(activeColor, opacity: 0.22)
                : _softShadow(opacity: 0.06, y: 6),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 30,
                color: isSelected ? Colors.white : activeColor,
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : textDark,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        boxShadow: _softShadow(opacity: 0.07, y: 8),
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (value) => setState(() => _searchQuery = value),
        cursorColor: primaryGreen,
        decoration: InputDecoration(
          hintText: 'Search your coffee',
          hintStyle: const TextStyle(color: Colors.black45, fontSize: 13),
          prefixIcon: Icon(Icons.search, color: textDark, size: 22),
          suffixIcon: _searchQuery.isEmpty
              ? Container(
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: softBrown,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(Icons.tune, color: warmBrown, size: 18),
                )
              : IconButton(
                  icon: Icon(Icons.close, color: darkGreen, size: 20),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _searchQuery = '');
                  },
                ),
          filled: true,
          fillColor: surface,
          contentPadding: const EdgeInsets.symmetric(vertical: 0),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(
              color: softBrown.withValues(alpha: 0.72),
              width: 1,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: primaryGreen, width: 1.6),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoriesSection() {
    return FutureBuilder<List<dynamic>>(
      future: _menuFuture,
      builder: (context, snapshot) {
        final rawCategories = (snapshot.data ?? [])
            .map((item) => item['category_name']?.toString() ?? '')
            .where((category) => category.isNotEmpty)
            .toSet()
            .toList();
        final categories = ['All', ...rawCategories];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('Categories', 'See all'),
            const SizedBox(height: 12),
            SizedBox(
              height: 88,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: categories.length,
                separatorBuilder: (context, index) => const SizedBox(width: 10),
                itemBuilder: (context, index) {
                  final category = categories[index];
                  return _buildCategoryChip(category);
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCategoryChip(String category) {
    final isSelected = _selectedCategory == category;
    final activeColor = category == 'All' ? primaryGreen : warmBrown;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: () => setState(() => _selectedCategory = category),
        borderRadius: BorderRadius.circular(8),
        hoverColor: activeColor.withValues(alpha: 0.08),
        splashColor: activeColor.withValues(alpha: 0.12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: 88,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 9),
          decoration: BoxDecoration(
            color: isSelected ? activeColor : surface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected
                  ? Colors.white.withValues(alpha: 0.32)
                  : softBrown,
            ),
            boxShadow: isSelected
                ? _coloredGlow(activeColor, opacity: 0.22)
                : _softShadow(opacity: 0.06, y: 6),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _categoryIcon(category),
                color: isSelected ? Colors.white : activeColor,
                size: 24,
              ),
              const SizedBox(height: 7),
              Text(
                category,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isSelected ? Colors.white : textDark,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _categoryIcon(String category) {
    final lower = category.toLowerCase();
    if (lower.contains('latte')) return Icons.local_cafe;
    if (lower.contains('classic')) return Icons.coffee;
    if (lower.contains('non')) return Icons.icecream;
    if (lower.contains('pastry') || lower.contains('bakery')) {
      return Icons.bakery_dining;
    }
    if (lower.contains('skewer')) return Icons.restaurant;
    return Icons.apps;
  }

  Widget _buildStatBadge(IconData icon, String value, String label) {
    return Container(
      constraints: const BoxConstraints(minWidth: 108),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withValues(alpha: 0.72)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: textDark),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: textDark,
                  height: 1,
                ),
              ),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  color: Colors.black54,
                  height: 1.1,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBundlesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Bundle Picks', 'View menu'),
        const SizedBox(height: 12),
        FutureBuilder<List<Bundle>>(
          future: _bundlesFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return SizedBox(
                height: 176,
                child: Center(
                  child: CircularProgressIndicator(color: primaryGreen),
                ),
              );
            }

            final bundles = (snapshot.data ?? []).take(6).toList();
            if (bundles.isEmpty) {
              return _buildEmptyState('No bundles available yet.');
            }

            return SizedBox(
              height: 176,
              child: ListView.separated(
                clipBehavior: Clip.none,
                scrollDirection: Axis.horizontal,
                itemCount: bundles.length,
                separatorBuilder: (context, index) => const SizedBox(width: 12),
                itemBuilder: (context, index) =>
                    _buildBundlePreviewCard(bundles[index]),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildBundlePreviewCard(Bundle bundle) {
    final description = bundle.includedItems.isEmpty
        ? 'Lumiora bundle'
        : bundle.includedItems.map((item) => item.name).join(' + ');

    return SizedBox(
      width: 160,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: () => Navigator.pushNamed(context, '/menu'),
          borderRadius: BorderRadius.circular(8),
          hoverColor: warmBrown.withValues(alpha: 0.07),
          splashColor: warmBrown.withValues(alpha: 0.12),
          child: Ink(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: softBrown),
              boxShadow: _softShadow(opacity: 0.08, y: 8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Center(
                    child: bundle.imageUrl.isEmpty
                        ? _buildImageFallback()
                        : ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              bundle.imageUrl,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) =>
                                  _buildImageFallback(),
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  bundle.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: textDark,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  description,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 10, color: Colors.black54),
                ),
                const SizedBox(height: 7),
                Text(
                  _formatPrice(bundle.price),
                  style: TextStyle(
                    color: warmBrown,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMostOrderedSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Most Popular Menu', 'Explore'),
        const SizedBox(height: 12),
        FutureBuilder<List<dynamic>>(
          future: _menuFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(color: primaryGreen),
              );
            }

            final items = snapshot.data ?? [];
            if (items.isEmpty) {
              return _buildEmptyState('No menu items available yet.');
            }

            final filteredItems = _filteredMenuItems(items).take(6).toList();
            if (filteredItems.isEmpty) {
              return _buildEmptyState('No menu matched your search.');
            }

            return SizedBox(
              height: 214,
              child: ListView.separated(
                clipBehavior: Clip.none,
                scrollDirection: Axis.horizontal,
                itemCount: filteredItems.length,
                separatorBuilder: (context, index) => const SizedBox(width: 12),
                itemBuilder: (context, index) => SizedBox(
                  width: 154,
                  child: _buildPopularItem(filteredItems[index]),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildPopularItem(dynamic item) {
    final name = item['item_name']?.toString() ?? 'Menu item';
    final category = item['category_name']?.toString() ?? 'Lumiora favorite';
    final imageUrl = item['image_url']?.toString() ?? '';
    final price = num.tryParse(item['price']?.toString() ?? '') ?? 0;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: () => Navigator.pushNamed(context, '/menu'),
        borderRadius: BorderRadius.circular(8),
        hoverColor: warmBrown.withValues(alpha: 0.07),
        splashColor: warmBrown.withValues(alpha: 0.12),
        child: Ink(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: surface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.white.withValues(alpha: 0.78)),
            boxShadow: _softShadow(opacity: 0.09, y: 9),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Center(
                  child: imageUrl.isEmpty
                      ? _buildImageFallback()
                      : Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: warmBrown.withValues(alpha: 0.10),
                                blurRadius: 18,
                                spreadRadius: -8,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              imageUrl,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) =>
                                  _buildImageFallback(),
                            ),
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: textDark,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                category,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 10, color: Colors.black54),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _formatPrice(price),
                      style: TextStyle(
                        color: primaryGreen,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: warmBrown,
                      shape: BoxShape.circle,
                      boxShadow: _coloredGlow(warmBrown, opacity: 0.26),
                    ),
                    child: const Icon(
                      Icons.arrow_forward,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageFallback() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFE9E1D3),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Icon(Icons.local_cafe, color: primaryGreen),
    );
  }

  Widget _buildSectionHeader(String title, String actionLabel) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            color: textDark,
            fontSize: 17,
            fontWeight: FontWeight.bold,
          ),
        ),
        GestureDetector(
          onTap: () => Navigator.pushNamed(context, '/menu'),
          child: Text(
            actionLabel,
            style: TextStyle(
              color: primaryGreen,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withValues(alpha: 0.78)),
        boxShadow: _softShadow(opacity: 0.06, y: 6),
      ),
      child: Text(
        message,
        style: const TextStyle(color: Colors.black54, fontSize: 12),
      ),
    );
  }
}
