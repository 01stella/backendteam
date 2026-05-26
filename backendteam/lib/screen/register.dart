import 'package:flutter/material.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3EFE6),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
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
              const SizedBox(height: 40), // Bottom padding
            ],
          ),
        ),
      ),
    );
  }

  // --- Widget Builders ---

  Widget _buildHeader() {
    final textColor = const Color(0xFF1E1E1E);
    final goldDark = const Color(0xFFC3A358);
    return Row(
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
          // Top Gold Section
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
          // Bottom Light Beige Section
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
    final stampFilled = const Color(0xFF9E9E82);
    final stampEmpty = const Color(0xFFEBEBD3);
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
          // Stamps Grid
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
          // Question Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: const Color(0xFFE2C991), // Muted gold for FAQ headers
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
          // Answer Body
          Container(
            padding: const EdgeInsets.all(16),
            color: const Color(0xFFE4DFCC), // Beige for FAQ body
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
}