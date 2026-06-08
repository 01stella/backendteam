import 'package:flutter/material.dart';
import '../model/bundle_model.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../services/bundle_service.dart';
import '../services/cart_service.dart';
import '../widgets/custom_bottom_navbar.dart';

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
  final Color textDark = const Color(0xFF252821);
  final Color surface = const Color(0xFFFFFCF5);

  String _userName = 'Guest';
  int _stampCount = 0;
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
      setState(() {
        _userName = user['full_name'].split(' ')[0];
        _stampCount = stamps;
        _isLoading = false;
      });
      return;
    }

    if (mounted) {
      setState(() {
        _userName = 'Guest';
        _stampCount = 0;
        _isLoading = false;
      });
    }
  }

  String _formatPrice(num price) {
    return 'Rp ${price.toInt()}';
  }

  Future<void> _goToMenu(String fulfillmentType) async {
    CartService().fulfillmentType = fulfillmentType;
    await Navigator.pushNamed(context, '/menu');
    if (mounted) _loadUserData();
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
              _buildHero(),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildActionButtons(),
                    const SizedBox(height: 20),
                    _buildBonusBanner(),
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
              color: Colors.black.withOpacity(0.14),
              blurRadius: 12,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: const Icon(Icons.qr_code_scanner, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: const CustomBottomNavBar(selectedIndex: 0),
    );
  }

  Widget _buildHero() {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Column(
          children: [
            SizedBox(
              height: 255,
              width: double.infinity,
              child: FutureBuilder<List<dynamic>>(
                future: _menuFuture,
                builder: (context, snapshot) {
                  final imageUrl = _firstImageUrl(snapshot.data);

                  return imageUrl == null
                      ? _buildHeroFallback()
                      : Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              _buildHeroFallback(),
                        );
                },
              ),
            ),
            Container(
              width: double.infinity,
              color: primaryGreen,
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hello, $_userName!',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      _buildStatBadge(Icons.stars, '$_stampCount', 'Stamps'),
                      _buildStatBadge(Icons.local_offer, '1', 'Vouchers'),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        Positioned(
          right: 20,
          top: 212,
          child: Container(
            width: 112,
            height: 112,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: primaryGreen, width: 5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.16),
                  blurRadius: 16,
                  offset: const Offset(0, 7),
                ),
              ],
            ),
            padding: const EdgeInsets.all(10),
            child: ClipOval(
              child: Image.asset(
                'assets/lumioralogo.png',
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
      ],
    );
  }

  String? _firstImageUrl(List<dynamic>? items) {
    if (items == null) return null;
    for (final item in items) {
      final url = item['image_url']?.toString();
      if (url != null && url.isNotEmpty) return url;
    }
    return null;
  }

  Widget _buildHeroFallback() {
    return Container(
      color: const Color(0xFFE8DCC4),
      child: Stack(
        children: [
          Positioned(
            right: 22,
            bottom: 28,
            child: Icon(Icons.local_cafe, size: 110, color: primaryGreen),
          ),
          Positioned(
            left: 22,
            bottom: 34,
            child: SizedBox(
              width: 190,
              child: Text(
                'Fresh coffee, bundles, and quick bites.',
                style: TextStyle(
                  color: textDark,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  height: 1.15,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatBadge(IconData icon, String value, String label) {
    return Container(
      constraints: const BoxConstraints(minWidth: 108),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
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

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: _buildFulfillmentCard(
            label: 'Pick Up',
            icon: Icons.coffee,
            isPrimary: true,
            onTap: () => _goToMenu('pickup'),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: _buildFulfillmentCard(
            label: 'Delivery',
            icon: Icons.delivery_dining,
            isPrimary: false,
            onTap: () => _goToMenu('delivery'),
          ),
        ),
      ],
    );
  }

  Widget _buildFulfillmentCard({
    required String label,
    required IconData icon,
    required bool isPrimary,
    required VoidCallback onTap,
  }) {
    final bg = isPrimary ? Colors.white : darkGreen;
    final fg = isPrimary ? primaryGreen : Colors.white;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 122,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(8),
          border: isPrimary ? Border.all(color: primaryGreen, width: 2) : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 42, color: fg),
            const SizedBox(height: 10),
            Text(
              label,
              style: TextStyle(
                color: isPrimary ? textDark : Colors.white,
                fontSize: 19,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBonusBanner() {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, '/menu'),
      child: Container(
        height: 82,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: primaryGreen,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'New Bonus Unlock',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Earn stamps with every verified order.',
                    style: TextStyle(color: Colors.white70, fontSize: 11),
                  ),
                ],
              ),
            ),
            Container(
              width: 96,
              height: 54,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.18),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.local_activity, color: Colors.white, size: 30),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBundlesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Bundle Picks', 'View menu'),
        const SizedBox(height: 12),
        SizedBox(
          height: 190,
          child: FutureBuilder<List<Bundle>>(
            future: _bundlesFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator(color: primaryGreen));
              }

              final bundles = (snapshot.data ?? []).take(5).toList();
              if (bundles.isEmpty) {
                return _buildEmptyStrip('Bundles will appear here once available.');
              }

              return ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: bundles.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, index) => _buildBundleCard(bundles[index]),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBundleCard(Bundle bundle) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, '/menu'),
      child: Container(
        width: 152,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFE8DDCA)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Center(
                child: bundle.imageUrl.isEmpty
                    ? Icon(Icons.bakery_dining, size: 48, color: primaryGreen)
                    : Image.network(
                        bundle.imageUrl,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) =>
                            Icon(Icons.bakery_dining, size: 48, color: primaryGreen),
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
            const SizedBox(height: 4),
            Text(
              _formatPrice(bundle.price),
              style: TextStyle(
                color: primaryGreen,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMostOrderedSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Most Ordered', 'Explore'),
        const SizedBox(height: 12),
        FutureBuilder<List<dynamic>>(
          future: _menuFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator(color: primaryGreen));
            }

            final items = (snapshot.data ?? []).take(4).toList();
            if (items.isEmpty) {
              return _buildEmptyStrip('Popular menu items will appear here soon.');
            }

            return Column(
              children: items
                  .map((item) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _buildPopularItem(item),
                      ))
                  .toList(),
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

    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, '/menu'),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFE8DDCA)),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 58,
              height: 58,
              child: imageUrl.isEmpty
                  ? _buildImageFallback()
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        imageUrl,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) =>
                            _buildImageFallback(),
                      ),
                    ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: textDark,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    category,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 11, color: Colors.black54),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Text(
              _formatPrice(price),
              style: TextStyle(
                color: primaryGreen,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageFallback() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFE9E1D3),
        borderRadius: BorderRadius.circular(8),
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

  Widget _buildEmptyStrip(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE8DDCA)),
      ),
      child: Text(
        text,
        style: const TextStyle(color: Colors.black54, fontSize: 12),
      ),
    );
  }
}
