import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({Key? key}) : super(key: key);

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  // Add state variables for the image picker
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  // Function to handle the image selection
  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery, // Opens the device gallery
        imageQuality: 80, // Compresses the image slightly to save data
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
                    
                    // Show a preview if an image is selected
                    if (_selectedImage != null) _buildImagePreview(),
                    
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
            
            _buildUploadButton(buttonColor, context),
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
            'PAYMENT',
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
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1E1E1E)),
              ),
              const SizedBox(width: 4),
              Icon(Icons.info_outline, size: 14, color: Colors.black.withOpacity(0.5)),
            ],
          ),
          const SizedBox(height: 16),
          
          _buildDetailRow('Total Discount', '-Rp 15.000', isBold: true),
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: _buildDetailRow('Voucher Applied', '-Rp 15.000', isGrey: true),
          ),
          _buildDetailRow('PB1 10.00%', 'Rp 12.000', isBold: true),
          _buildDetailRow('VAT 11%', 'Rp. 10.000', isBold: true),
          
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              const Text(
                'Total :',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1E1E1E)),
              ),
              const SizedBox(width: 16),
              const Text(
                'Rp 120.000',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E1E1E)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isBold = false, bool isGrey = false}) {
    final color = isGrey ? Colors.black.withOpacity(0.5) : const Color(0xFF1E1E1E);
    final weight = isBold ? FontWeight.bold : FontWeight.w500;
    final fontSize = isGrey ? 10.0 : 12.0;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: fontSize, fontWeight: weight, color: color)),
          Text(value, style: TextStyle(fontSize: fontSize, fontWeight: weight, color: color)),
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
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF1E1E1E), letterSpacing: 0.5),
        ),
        const SizedBox(height: 4),
        const Text(
          'NMID: ID1025415828231',
          style: TextStyle(fontSize: 11, color: Color(0xFF1E1E1E)),
        ),
        const SizedBox(height: 4),
        const Text(
          'A01',
          style: TextStyle(fontSize: 11, color: Color(0xFF1E1E1E)),
        ),
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
        
        const SizedBox(height: 24),
        Text(
          'SCAN QR CODE',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.0,
            color: textColor, 
          ),
        ),
      ],
    );
  }

  // New UI to show the user they successfully attached an image
  Widget _buildImagePreview() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
      child: Column(
        children: [
          const Text(
            'Proof Attached:',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black54),
          ),
          const SizedBox(height: 8),
          Container(
            height: 100,
            width: 80,
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFF967A3B), width: 2),
              borderRadius: BorderRadius.circular(8),
              image: DecorationImage(
                image: FileImage(_selectedImage!),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUploadButton(Color buttonColor, BuildContext context) {
    return Container(
      color: const Color(0xFFF3EFE6), 
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: _pickImage, // Triggers the image picker
          style: ElevatedButton.styleFrom(
            backgroundColor: _selectedImage == null ? buttonColor : const Color(0xFF8C9862), // Changes color if image is picked
            elevation: 0,
            padding: const EdgeInsets.symmetric(vertical: 18),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(
            _selectedImage == null ? 'UPLOAD PROOF' : 'CHANGE PROOF', // Updates text dynamically
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.0,
            ),
          ),
        ),
      ),
    );
  }
}