import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../widgets/custom_bottom_navbar.dart'; // Make sure this path is correct!

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  void _showWelcomePopup(BuildContext context) {
    showModalBottomSheet(
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
  }

  @override
  Widget build(BuildContext context) {
    const bgColor = Color(0xFFF3EFE6);
    
    return Scaffold(
      backgroundColor: bgColor,
      // --- MENU-STYLE NAVBAR & FLOATING QR BUTTON ---
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: _buildScanQRButton(bgColor),
      bottomNavigationBar: const CustomBottomNavBar(selectedIndex: 3), // 3 for Profile
      // ----------------------------------------------
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

  Widget _buildHeader(BuildContext context) {
    final textColor = const Color(0xFF1E1E1E);
    final goldDark = const Color(0xFFC3A358);
    
    return GestureDetector(
      onTap: () => _showWelcomePopup(context),
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
            child: Center(
              child: Text(
                'L',
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
            'LOGIN',
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
    return Container(
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
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
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
                  child: const Center(
                    child: Text(
                      'L',
                      style: TextStyle(
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
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
            decoration: BoxDecoration(
              color: goldLight,
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
            ),
            child: const Text(
              'View My Benefits',
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
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
          Icon(Icons.chevron_right, color: textColor.withOpacity(0.6), size: 20),
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
                    Icon(Icons.confirmation_num_outlined, size: 20, color: textColor),
                    const SizedBox(width: 6),
                    Text(
                      '0',
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
                '4/10',
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
            style: TextStyle(
              fontSize: 10,
              color: textColor.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(5, (index) => _buildStamp(index < 4)),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(5, (index) => _buildStamp(false)),
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
                Icon(Icons.chevron_right, size: 16, color: textColor.withOpacity(0.6)),
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

  // --- Helper for the Floating SCAN QR Button ---
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

// ------------------------------------------------------------------------
// The Modal Bottom Sheet
// ------------------------------------------------------------------------
class WelcomeBottomSheet extends StatefulWidget {
  const WelcomeBottomSheet({super.key});

  @override
  State<WelcomeBottomSheet> createState() => _WelcomeBottomSheetState();
}

class _WelcomeBottomSheetState extends State<WelcomeBottomSheet> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _referralController = TextEditingController();
  bool _isMarketingChecked = false;
  bool _isTermsChecked = false;

  static const Color primaryPopupColor = Color(0xFFE6E1D1);
  static const Color customGreen = Color(0xFFBFC67C);
  static const Color darkTextGrey = Color(0xFF8A8574);
  static const Color lightGrey = Color(0xFFDFDAD1);
  static const Color hintGrey = Color(0xFFAFAFA0); 
  static const Color buttonColor = Color(0xFFCDC9B6);
  static const Color buttonTextGrey = Color(0xFF8A8574);

  final TextStyle headerTextStyle = const TextStyle(
    color: Colors.black, 
    fontSize: 18, 
    fontWeight: FontWeight.bold,
    letterSpacing: 1.0,
  );

  final TextStyle inputTextStyle = const TextStyle(
    color: Colors.black,
    fontSize: 16, 
  );

  final TextStyle hintTextStyle = const TextStyle(
    color: hintGrey,
    fontSize: 16, 
    fontStyle: FontStyle.normal, 
  );

  final TextStyle boldConsentTextStyle = const TextStyle(
    color: Colors.black,
    fontSize: 11, 
    fontWeight: FontWeight.bold,
  );

  final TextStyle consentTextStyle = const TextStyle(
    color: darkTextGrey,
    fontSize: 10, 
    height: 1.2,
  );

  @override
  void dispose() {
    _phoneController.dispose();
    _referralController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: primaryPopupColor,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.0), 
          topRight: Radius.circular(20.0),
        ),
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(32, 28, 32, 32), 
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('WELCOME', style: headerTextStyle),
                  const SizedBox(height: 8), 
                  Container(
                    width: 40, 
                    height: 1.5,
                    color: customGreen,
                  ),
                ],
              ),
              const SizedBox(height: 36), 

              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.only(bottom: 4, right: 8),
                        decoration: const BoxDecoration(
                          border: Border(
                            bottom: BorderSide(color: lightGrey, width: 1),
                          ),
                        ),
                        child: Text('+62', style: inputTextStyle),
                      ),
                      const SizedBox(height: 7), 
                    ],
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      cursorColor: Colors.black,
                      style: inputTextStyle,
                      decoration: InputDecoration(
                        hintText: 'Phone Number...',
                        hintStyle: hintTextStyle,
                        isDense: true,
                        contentPadding: const EdgeInsets.only(bottom: 8, top: 4), 
                        enabledBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(color: lightGrey),
                        ),
                        focusedBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.black, width: 1.2),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24), 

              TextField(
                controller: _referralController,
                cursorColor: Colors.black,
                style: inputTextStyle,
                decoration: InputDecoration(
                  hintText: 'Referral Code (Optional)',
                  hintStyle: hintTextStyle,
                  isDense: true,
                  contentPadding: const EdgeInsets.only(bottom: 8, top: 4),
                  enabledBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: lightGrey),
                  ),
                  focusedBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.black, width: 1.2),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    print('Continue pressed.');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: buttonColor,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2.0)), 
                    padding: const EdgeInsets.symmetric(vertical: 14), 
                  ),
                  child: const Text(
                    'CONTINUE',
                    style: TextStyle(
                      color: buttonTextGrey,
                      fontSize: 14, 
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5, 
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _socialButton(FontAwesomeIcons.solidEnvelope),
                  const SizedBox(width: 16),
                  _socialButton(FontAwesomeIcons.apple),
                  const SizedBox(width: 16),
                  _socialButton(FontAwesomeIcons.whatsapp),
                ],
              ),
              const SizedBox(height: 32),

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _customConsentCheckbox(
                    value: _isMarketingChecked,
                    onChanged: (newValue) {
                      setState(() {
                        _isMarketingChecked = newValue!;
                      });
                    },
                    titleText: 'Marketing Communications',
                    description: const TextSpan(
                      text: 'I wish to receive marketing communications via WhatsApp, email, text messaging and/ or phonecall.',
                    ),
                  ),
                  const SizedBox(height: 16), 
                  _customConsentCheckbox(
                    value: _isTermsChecked,
                    onChanged: (newValue) {
                      setState(() {
                        _isTermsChecked = newValue!;
                      });
                    },
                    titleText: 'Terms and Conditions',
                    description: TextSpan(
                      text: 'I confirm I have read and accept the ',
                      children: <TextSpan>[
                        TextSpan(
                          text: 'Terms of Use',
                          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black, decoration: TextDecoration.none),
                          recognizer: TapGestureRecognizer()..onTap = () {},
                        ),
                        const TextSpan(text: ' and '),
                        TextSpan(
                          text: 'Privacy Policy',
                          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black, decoration: TextDecoration.none),
                          recognizer: TapGestureRecognizer()..onTap = () {},
                        ),
                        const TextSpan(text: '.'),
                      ],
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

  Widget _socialButton(IconData icon) {
    return Container(
      width: 40, 
      height: 40,
      decoration: const BoxDecoration(
        color: Color(0xFFDFDAD1), 
        shape: BoxShape.circle,
      ),
      child: Center(
        child: FaIcon(icon, size: 16, color: darkTextGrey), 
      ),
    );
  }

  Widget _customConsentCheckbox({
    required bool value,
    required ValueChanged<bool?> onChanged,
    required String titleText,
    required InlineSpan description,
  }) {
    return InkWell(
      onTap: () {
        onChanged(!value);
      },
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 2, right: 10), 
            width: 12, 
            height: 12,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: value ? darkTextGrey : lightGrey, 
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(titleText, style: boldConsentTextStyle),
                const SizedBox(height: 2),
                Text.rich(
                  description,
                  style: consentTextStyle,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}