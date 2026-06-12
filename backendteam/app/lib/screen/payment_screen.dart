import '../services/cart_service.dart';
import '../services/api_service.dart';
import '../widgets/cafe_logo_button.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class PaymentScreen extends StatefulWidget {
  final int totalAmount; // Receives the calculated total
  final int orderId;

  const PaymentScreen({
    Key? key,
    required this.totalAmount,
    required this.orderId,
  }) : super(key: key);

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Proof of payment uploaded successfully!'),
              backgroundColor: Color(0xFF8C9862),
            ),
          );
        }
      }
    } catch (e) {
      debugPrint("Error picking image: $e");
    }
  }

  // >>> THIS IS THE BUILD METHOD THAT WAS MISSING <<<
  @override
  Widget build(BuildContext context) {
    const Color bgColor = Color(0xFFF3EFE6);
    const Color goldColor = Color(0xFFC3A358);
    const Color thickDividerColor = Color(0xFFDAD6CC);
    const Color buttonColor = Color(0xFF967A3B);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(goldColor),
            Container(height: 1.5, color: goldColor.withOpacity(0.5)),

            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildPaymentDetails(),
                    Container(height: 12, color: thickDividerColor),

                    const SizedBox(height: 24),
                    _buildQRCodeSection(buttonColor),

                    // Show the new beautiful card if an image is selected!
                    if (_selectedImage != null) _buildFileUploadedCard(),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      // Put the bottom controls down here!
      bottomNavigationBar: _buildBottomControls(buttonColor, context),
    );
  }

  Widget _buildFileUploadedCard() {
    // Extract the name of the file from the path
    String fileName = _selectedImage!.path.split('/').last;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
            color: const Color(0xFF8C9862).withOpacity(0.5),
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            // Small Image Icon
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFF3EFE6),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.image,
                color: Color(0xFF8C9862),
                size: 24,
              ),
            ),
            const SizedBox(width: 16),

            // File Name and Status
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Proof Attached',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    fileName,
                    style: const TextStyle(fontSize: 12, color: Colors.black54),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // Success Checkmark
            const Icon(Icons.check_circle, color: Color(0xFF8C9862), size: 24),
          ],
        ),
      ),
    );
  }

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
            'PAYMENT',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
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
              const Text(
                'Payment Details',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.info_outline,
                size: 14,
                color: Colors.black.withOpacity(0.5),
              ),
            ],
          ),
          const SizedBox(height: 16),

          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              const Text(
                'Total :',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 16),
              Text(
                'Rp ${widget.totalAmount}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQRCodeSection(Color textColor) {
    return Column(
      children: [
        Text(
          'Payment Method: QR Code',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.black.withOpacity(0.6),
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'FLAME N FOAM EATERY AND COFFEE',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 4),
        const Text('NMID: ID1025415828231', style: TextStyle(fontSize: 11)),
        const SizedBox(height: 24),

        Container(
          width: 260,
          height: 260,
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.grey.shade300, width: 1),
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.all(8),
          child: Image.asset(
            'assets/cafeqrcode.png',
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) => const Center(
              child: Icon(Icons.qr_code, size: 100, color: Colors.grey),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomControls(Color buttonColor, BuildContext context) {
    const Color activeGreen = Color(0xFF8C9862);

    return Container(
      color: const Color(0xFFF3EFE6),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // If no image is selected, show UPLOAD button
          if (_selectedImage == null)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _pickImage,
                style: ElevatedButton.styleFrom(
                  backgroundColor: activeGreen,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'UPLOAD PROOF',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
            )
          // If image IS selected, show ONLY the FINISH button
          else
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  // 1. Tell the backend to update the status to 'pending_verification'
                  bool success = await ApiService.markPaymentPending(
                    widget.orderId,
                  );

                  if (success && context.mounted) {
                    // 2. Clear the cart memory since the order is paid
                    CartService().clearCart();

                    // 3. Pop everything and go back to the Menu route
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      '/menu',
                      (route) => false,
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Failed to submit proof. Try again.'),
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: buttonColor,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'FINISH & RETURN',
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
    );
  }
}
