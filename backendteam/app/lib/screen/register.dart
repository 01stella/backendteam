import 'package:flutter/material.dart';
import '../widgets/custom_bottom_navbar.dart';
import '../widgets/welcome_bottom_sheet.dart';
import '../services/auth_service.dart'; // <--- Added the auth service import!
import '../services/api_service.dart';
import '../widgets/cafe_logo_button.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with WidgetsBindingObserver {
  // --- STATE ---
  String? _loggedInUserName; // Null means not logged in!
  int _stampCount = 0;
  int _voucherCount = 0;

  // --- NEW: Check storage when the screen loads ---
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkSavedSession();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkSavedSession();
    }
  }

  Future<void> _checkSavedSession() async {
    final user = await AuthService.getUser();
    if (user != null) {
      final stamps = await ApiService.fetchCustomerStamps(user['id']);
      final vouchers = await ApiService.fetchCustomerVouchers(user['id']);
      if (!mounted) return;
      setState(() {
        _loggedInUserName = user['full_name'];
        _stampCount = stamps;
        _voucherCount = vouchers.length;
      });
    }
  }

  Future<void> _showCustomerDetailsModal() async {
    final user = await AuthService.getUser();
    if (!mounted) return;

    if (user == null) {
      _showWelcomePopup(context);
      return;
    }

    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.38),
      builder: (context) {
        return FutureBuilder<Map<String, dynamic>?>(
          future: ApiService.fetchCustomerById(user['id']),
          builder: (context, snapshot) {
            final isLoading =
                snapshot.connectionState == ConnectionState.waiting;
            final details = snapshot.data;
            final name = details?['full_name']?.toString() ?? user['full_name'];
            final email = details?['email']?.toString() ?? 'Email not set';
            final phone =
                details?['phone_number']?.toString().isNotEmpty == true
                ? details!['phone_number'].toString()
                : 'Phone not set';
            final birthday = details?['birthday']?.toString().isNotEmpty == true
                ? details!['birthday'].toString().split('T').first
                : 'Birthday not set';
            final initial = name.toString().isNotEmpty
                ? name.toString()[0].toUpperCase()
                : 'C';

            return Dialog(
              backgroundColor: Colors.transparent,
              insetPadding: const EdgeInsets.symmetric(horizontal: 28),
              child: Container(
                padding: const EdgeInsets.fromLTRB(22, 24, 22, 18),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3EFE6),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFE5D5AE)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.18),
                      blurRadius: 28,
                      offset: const Offset(0, 14),
                    ),
                  ],
                ),
                child: isLoading
                    ? const Padding(
                        padding: EdgeInsets.symmetric(vertical: 34),
                        child: Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFFC3A358),
                          ),
                        ),
                      )
                    : Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 68,
                            height: 68,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color(0xFFC3A358),
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: Center(
                              child: Text(
                                initial,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),
                          Text(
                            name,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Color(0xFF1E1E1E),
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Customer Details',
                            style: TextStyle(
                              color: Colors.black54,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 18),
                          _buildCustomerDetailRow(
                            Icons.person_outline,
                            'Name',
                            name,
                          ),
                          const SizedBox(height: 10),
                          _buildCustomerDetailRow(
                            Icons.mail_outline,
                            'Email',
                            email,
                          ),
                          const SizedBox(height: 10),
                          _buildCustomerDetailRow(
                            Icons.phone_outlined,
                            'Phone',
                            phone,
                          ),
                          const SizedBox(height: 10),
                          _buildCustomerDetailRow(
                            Icons.cake_outlined,
                            'Birthday',
                            birthday,
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () => Navigator.pop(context),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF8C9862),
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 13,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text(
                                'CLOSE',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.1,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _redeemStampVoucher() async {
    final user = await AuthService.getUser();
    if (!mounted) return;

    if (user == null) {
      _showWelcomePopup(context);
      return;
    }

    final result = await ApiService.redeemStampVoucher(user['id']);
    if (!mounted) return;

    if (result['success'] == true) {
      final stamps = await ApiService.fetchCustomerStamps(user['id']);
      final vouchers = await ApiService.fetchCustomerVouchers(user['id']);
      if (!mounted) return;

      setState(() {
        _stampCount = stamps;
        _voucherCount = vouchers.length;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Redeemed 10 stamps for a 10% voucher.'),
          backgroundColor: Color(0xFF8C9862),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'Unable to redeem voucher.'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  void _showWelcomePopup(BuildContext context) async {
    // Wait for the bottom sheet to close and see if it hands back user data
    final userData = await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: true,
      enableDrag: true,
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: const WelcomeBottomSheet(),
        );
      },
    );

    // If we got data back (meaning a successful login), update the UI!
    if (userData != null && userData['full_name'] != null) {
      final stamps = await ApiService.fetchCustomerStamps(userData['id']);
      final vouchers = await ApiService.fetchCustomerVouchers(userData['id']);
      if (!mounted) return;
      setState(() {
        _loggedInUserName = userData['full_name'];
        _stampCount = stamps;
        _voucherCount = vouchers.length;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Login Successful! Welcome back.'),
          backgroundColor: const Color(0xFF8C9862),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.only(bottom: 20, left: 20, right: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const bgColor = Color(0xFFF3EFE6);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: bgColor,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: _buildScanQRButton(bgColor),
      bottomNavigationBar: const CustomBottomNavBar(selectedIndex: 3),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              const SizedBox(height: 30),
              _buildCustomerCard(),
              const SizedBox(height: 30),
              _buildSectionTitle('MY ACCOUNT'),
              const SizedBox(height: 16),
              _buildMyAccountCards(),
              const SizedBox(height: 30),
              _buildLoyaltyStamps(),
              const SizedBox(height: 30),
              _buildSectionTitle('FAQ', hasArrow: true),
              const SizedBox(height: 16),
              _buildFAQItem(
                '1. How do I earn points?',
                'You can earn points by ordering through the app. Points can be redeemed for discounts or special rewards.',
              ),
              const SizedBox(height: 16),
              _buildFAQItem(
                '2. What are your opening hours?',
                'We\'re open every day from 8:00 AM to 10:00 PM. Opening hours may change during holidays or special events.',
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  // --- DYNAMIC HEADER ---
  Widget _buildHeader(BuildContext context) {
    final textColor = const Color(0xFF1E1E1E);
    final goldDark = const Color(0xFFC3A358);

    // Check if we have a name. If yes, grab the first initial!
    String? initial = _loggedInUserName != null
        ? _loggedInUserName![0].toUpperCase()
        : null;
    String displayText = _loggedInUserName != null
        ? 'Hi, $_loggedInUserName'
        : 'LOGIN';

    return GestureDetector(
      // Only allow tapping to open the popup if they are NOT logged in
      onTap: _loggedInUserName == null
          ? () => _showWelcomePopup(context)
          : null,
      behavior: HitTestBehavior.opaque,
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: goldDark, width: 1.5),
            ),
            child: initial == null
                ? const CafeLogoButton(padding: 8)
                : Center(
                    child: Text(
                      initial,
                      style: TextStyle(
                        fontSize: 24,
                        color: goldDark,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  ),
          ),
          const SizedBox(width: 12),
          Text(
            displayText, // Shows their name instead of LOGIN
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerCard() {
    final goldDark = const Color(0xFFC3A358);
    final goldLight = const Color(0xFFE5D5AE);
    final textColor = const Color(0xFF1E1E1E);
    String initial = _loggedInUserName != null
        ? _loggedInUserName![0].toUpperCase()
        : 'G';

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: _showCustomerDetailsModal,
        borderRadius: BorderRadius.circular(12),
        splashColor: goldDark.withValues(alpha: 0.12),
        hoverColor: goldDark.withValues(alpha: 0.06),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: goldDark,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(12),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'CUSTOMER',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                            color: textColor,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          height: 2,
                          width: 80,
                          color: textColor.withOpacity(0.5),
                        ),
                      ],
                    ),
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.3),
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: Center(
                        child: Text(
                          initial,
                          style: const TextStyle(
                            fontSize: 24,
                            color: Colors.white,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 20,
                ),
                decoration: BoxDecoration(
                  color: goldLight,
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(12),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // --- NEW: LOGOUT BUTTON ---
                    if (_loggedInUserName != null)
                      GestureDetector(
                        onTap: () async {
                          await AuthService.logout();
                          setState(() {
                            _loggedInUserName = null;
                            _stampCount = 0;
                            _voucherCount = 0;
                          });
                        },
                        child: const Text(
                          'Log Out',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.redAccent,
                          ),
                        ),
                      )
                    else
                      const SizedBox(), // Empty space if not logged in

                    const Text(
                      'View My Benefits',
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCustomerDetailRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: const Color(0xFFE5D5AE),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: const Color(0xFFC3A358), size: 18),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 10, color: Colors.black45),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  color: Color(0xFF1E1E1E),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title, {bool hasArrow = false}) {
    final textColor = const Color(0xFF1E1E1E);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
            color: textColor,
          ),
        ),
        if (hasArrow)
          Icon(
            Icons.chevron_right,
            color: textColor.withOpacity(0.6),
            size: 20,
          ),
      ],
    );
  }

  Widget _buildMyAccountCards() {
    final cardGreen = const Color(0xFFE1E2C9);
    final textColor = const Color(0xFF1E1E1E);
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 24),
            decoration: BoxDecoration(
              color: cardGreen,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(
                    0.15,
                  ), // Shadow color and opacity
                  spreadRadius: 1, // Expands the shadow
                  blurRadius: 8, // Softens the shadow
                  offset: Offset(0, 4), // Moves the shadow (x, y)
                ),
              ],
            ),
            child: Column(
              children: [
                const Text(
                  'Voucher',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.confirmation_num_outlined,
                      size: 20,
                      color: textColor,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '$_voucherCount',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 12),
            decoration: BoxDecoration(
              color: cardGreen,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(
                    0.15,
                  ), // Shadow color and opacity
                  spreadRadius: 1, // Expands the shadow
                  blurRadius: 8, // Softens the shadow
                  offset: Offset(0, 4), // Moves the shadow (x, y)
                ),
              ],
            ),
            child: Column(
              children: [
                const Text(
                  'Gift a Coffee',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  'Invite and earn\npoints',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 10,
                    color: textColor.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoyaltyStamps() {
    final cardGreen = const Color(0xFFE1E2C9);
    final textColor = const Color(0xFF1E1E1E);
    final visibleStampCount = _stampCount.clamp(0, 10);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardGreen,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'LOYALTY STAMPS',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                  color: textColor,
                ),
              ),
              Text(
                '$visibleStampCount/10',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: textColor.withOpacity(0.5),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Free drinks at 10 stamps. Get 10% off every stamp.',
            style: TextStyle(fontSize: 10, color: textColor.withOpacity(0.7)),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(
              5,
              (index) => _buildStamp(index < visibleStampCount),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(
              5,
              (index) => _buildStamp(index + 5 < visibleStampCount),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _stampCount >= 10 ? _redeemStampVoucher : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8C9862),
                disabledBackgroundColor: Colors.grey.shade400,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                _stampCount >= 10
                    ? 'REDEEM 10 STAMPS'
                    : 'NEED ${10 - visibleStampCount} MORE STAMPS',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.1,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStamp(bool isFilled) {
    final stampFilled = const Color(0xFF9E9E82);
    final stampEmpty = const Color(0xFFEBEBD3);
    return Container(
      width: 45,
      height: 45,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isFilled ? stampFilled : stampEmpty,
      ),
      child: isFilled
          ? const Icon(Icons.check, color: Colors.white, size: 24)
          : null,
    );
  }

  Widget _buildFAQItem(String question, String answer) {
    final textColor = const Color(0xFF1E1E1E);
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: const Color(0xFFE2C991),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    question,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  size: 16,
                  color: textColor.withOpacity(0.6),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            color: const Color(0xFFE4DFCC),
            child: Text(
              answer,
              style: TextStyle(
                fontSize: 11,
                height: 1.4,
                color: textColor.withOpacity(0.8),
              ),
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
