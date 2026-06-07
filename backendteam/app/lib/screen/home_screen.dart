import 'package:flutter/material.dart';
import '../widgets/custom_bottom_navbar.dart';
// --- NEW IMPORTS ---
import '../services/auth_service.dart';
import '../services/api_service.dart';
import '../services/cart_service.dart';

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
        scaffoldBackgroundColor: const Color(0xFFF4F1E1),
        primaryColor: const Color(0xFF7B8C2A),
      ),
      // If you are using routing, ensure '/menu' is defined in your routes!
      home: const HomeScreen(),
    );
  }
}

// 1. CHANGED TO STATEFUL WIDGET
class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final Color primaryGreen = const Color(0xFF7B8C2A);
  final Color lightGreenCard = const Color(0xFFDCE2B9);
  final Color darkGrey = const Color(0xFF4A4D4A);
  final Color textDark = const Color(0xFF2C3028);

  // --- NEW STATE VARIABLES ---
  String _userName = "Guest";
  int _stampCount = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // --- FETCH USER & STAMPS ---
  Future<void> _loadUserData() async {
    final user = await AuthService.getUser();
    
    if (user != null && mounted) {
      int stamps = await ApiService.fetchCustomerStamps(user['id']);
      setState(() {
        _userName = user['full_name'].split(' ')[0]; // Gets the first name
        _stampCount = stamps;
        _isLoading = false;
      });
    } else {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show a loading spinner while fetching the name and stamps
    if (_isLoading) {
      return Scaffold(
        backgroundColor: const Color(0xFFF4F1E1),
        body: Center(child: CircularProgressIndicator(color: primaryGreen)),
      );
    }

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeroAndHeader(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  _buildActionButtons(context), // Passed context for navigation
                  const SizedBox(height: 20),
                  _buildPromoBanners(),
                  const SizedBox(height: 20),
                  _buildToggle(),
                  const SizedBox(height: 20),
                  _buildProductGrid(),
                  const SizedBox(height: 20),
                  _buildGrandFeastBanner(),
                  const SizedBox(height: 20),
                  _buildHalalFooter(),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
      // Assuming you have a ScanQRButton widget created elsewhere
      floatingActionButton: Container(
        height: 64, width: 64,
        decoration: BoxDecoration(shape: BoxShape.circle, color: primaryGreen),
        child: const Icon(Icons.qr_code_scanner, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: const CustomBottomNavBar(selectedIndex: 0),
    );
  }

  // --- Widget Builders ---

  Widget _buildHeroAndHeader() {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Column(
          children: [
            Container(
              height: 240,
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Color(0xFFE8DCC4),
                image: DecorationImage(
                  image: NetworkImage('https://via.placeholder.com/600x400/E8DCC4/888888?text=Coffee+Hero+Image'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Container(
              height: 90,
              width: double.infinity,
              color: primaryGreen,
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 2. DYNAMIC GREETING
                  Text(
                    'Hello, $_userName!', 
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      // 3. DYNAMIC STAMP COUNT
                      _buildStatBadge(Icons.stars, '$_stampCount', 'Stamps'), 
                      const SizedBox(width: 8),
                      _buildStatBadge(Icons.local_offer, '1', 'Vouchers'),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        Positioned(
          right: 16,
          top: 180,
          child: Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: primaryGreen, width: 4),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 4)),
              ],
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.coffee, color: primaryGreen, size: 24),
                  const SizedBox(height: 4),
                  Text(
                    'LUMIORA',
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: primaryGreen, letterSpacing: 1.0),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatBadge(IconData icon, String value, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.black87),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, height: 1)),
              Text(label, style: const TextStyle(fontSize: 8, color: Colors.black54, height: 1)),
            ],
          ),
        ],
      ),
    );
  }

  // 4. UPDATED ACTION BUTTONS
  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        // --- PICK UP BUTTON ---
        Expanded(
          child: GestureDetector(
            onTap: () {
              // Set memory to pickup and navigate
              CartService().fulfillmentType = 'pickup';
              Navigator.pushNamed(context, '/menu');
            },
            child: Container(
              height: 110,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: primaryGreen, width: 2),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.coffee, size: 40, color: primaryGreen),
                  const SizedBox(height: 8),
                  Text('Pick Up', style: TextStyle(fontWeight: FontWeight.bold, color: textDark)),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        // --- DELIVERY BUTTON ---
        Expanded(
          child: GestureDetector(
            onTap: () {
              // Set memory to delivery and navigate
              CartService().fulfillmentType = 'delivery';
              Navigator.pushNamed(context, '/menu');
            },
            child: Container(
              height: 110,
              decoration: BoxDecoration(
                color: darkGrey,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.delivery_dining, size: 40, color: Colors.white), // Fixed opacity
                  SizedBox(height: 8),
                  // Removed COMING SOON text
                  Text('Delivery', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)), // Fixed opacity
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ... (The rest of your widgets like _buildPromoBanners, _buildProductGrid, etc. remain exactly the same as before) ...
  Widget _buildPromoBanners() { /* Same as before */ return const SizedBox(); }
  Widget _buildToggle() { /* Same as before */ return const SizedBox(); }
  Widget _buildProductGrid() { /* Same as before */ return const SizedBox(); }
  Widget _buildGrandFeastBanner() { /* Same as before */ return const SizedBox(); }
  Widget _buildHalalFooter() { /* Same as before */ return const SizedBox(); }
}