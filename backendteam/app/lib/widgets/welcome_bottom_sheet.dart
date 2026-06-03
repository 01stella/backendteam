import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart'; 
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../services/api_service.dart'; 

class WelcomeBottomSheet extends StatefulWidget {
  const WelcomeBottomSheet({super.key});

  @override
  State<WelcomeBottomSheet> createState() => _WelcomeBottomSheetState();
}

class _WelcomeBottomSheetState extends State<WelcomeBottomSheet> {
  // --- STATE ---
  bool _isLogin = true; 
  bool _isLoading = false; 
  
  bool _isMarketingChecked = false;
  bool _isTermsChecked = false;

  // We now store the actual DateTime object to easily send to MySQL
  DateTime? _selectedDate; 

  // Controllers
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _birthdayController = TextEditingController();

  // --- COLORS (Matched to Figma) ---
  static const Color primaryPopupColor = Color(0xFFEFECE5); 
  static const Color fieldColor = Color(0xFFE2DED4); 
  static const Color customGreen = Color(0xFFBFC67C); 
  static const Color darkOliveButton = Color(0xFF4C4C36); 
  static const Color darkTextGrey = Color(0xFF8A8574);
  static const Color lightGrey = Color(0xFFDFDAD1); 
  
  final TextStyle headerTextStyle = const TextStyle(
    color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1.0,
  );

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _birthdayController.dispose();
    super.dispose();
  }

  void _toggleAuthMode() {
    setState(() {
      _isLogin = !_isLogin;
    });
  }

  // --- THE DATE PICKER POPUP ---
  void _presentDatePicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: primaryPopupColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext builder) {
        return SizedBox(
          height: 300,
          child: Column(
            children: [
              // Done Button Header
              Container(
                decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: lightGrey, width: 1)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    CupertinoButton(
                      child: const Text('Done', style: TextStyle(color: darkOliveButton, fontWeight: FontWeight.bold)),
                      onPressed: () => Navigator.of(context).pop(),
                    )
                  ],
                ),
              ),
              // The Spinning Wheels
              Expanded(
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.date,
                  initialDateTime: _selectedDate ?? DateTime(2000, 1, 1),
                  maximumDate: DateTime.now(),
                  minimumYear: 1940,
                  onDateTimeChanged: (DateTime newDate) {
                    setState(() {
                      _selectedDate = newDate;
                      // Update the text field to look pretty for the user
                      _birthdayController.text = "${newDate.day.toString().padLeft(2, '0')} / ${newDate.month.toString().padLeft(2, '0')} / ${newDate.year}";
                    });
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
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
                  Container(width: 40, height: 1.5, color: customGreen),
                ],
              ),
              const SizedBox(height: 28), 

              AnimatedSize(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: _isLogin ? _buildLoginForm() : _buildRegisterForm(),
                ),
              ),
              const SizedBox(height: 24),

              // --- MAIN BUTTON (UPDATED LOGIC) ---
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : () async {
                    setState(() => _isLoading = true);

                    Map<String, dynamic> response;

                    if (_isLogin) {
                      response = await ApiService.loginCustomer(
                        email: _emailController.text.trim(),
                        password: _passwordController.text,
                      );
                    } else {
                      String formattedDate = '';
                      if (_selectedDate != null) {
                        formattedDate = "${_selectedDate!.year}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}";
                      }

                      response = await ApiService.registerCustomer(
                        fullName: _nameController.text.trim(),
                        email: _emailController.text.trim(),
                        password: _passwordController.text,
                        phone: '0${_phoneController.text.trim()}', 
                        birthday: formattedDate,
                      );
                    }

                    if (!mounted) return;
                    setState(() => _isLoading = false);

                    // --- NEW SUCCESS/FAIL LOGIC ---
                    if (response['success'] == true) {
                      
                      if (_isLogin) {
                        // Pass the 'data' object back to the main screen!
                        Navigator.pop(context, response['data']); 
                        
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Login Successful! Welcome back.'), 
                            backgroundColor: Color(0xFF8C9862) 
                          ),
                        );
                      } else {
                        // 2. REGISTER SUCCESS: Don't close! Just flip back to Login.
                        setState(() {
                          _isLogin = true; 
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Registration Successful! Please log in.'), 
                            backgroundColor: Color(0xFF8C9862) 
                          ),
                        );
                      }

                    } else {
                      // 3. FAIL: Show the error message from the backend
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(response['message'] ?? 'An error occurred. Please try again.'), 
                          backgroundColor: Colors.redAccent
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: darkOliveButton,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)), 
                    padding: const EdgeInsets.symmetric(vertical: 16), 
                  ),
                  child: _isLoading 
                    ? const SizedBox(
                        height: 20, 
                        width: 20, 
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                      )
                    : Text(
                        _isLogin ? 'LOGIN' : 'CONTINUE',
                        style: const TextStyle(
                          color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600, letterSpacing: 1.5, 
                        ),
                      ),
                ),
              ),
              const SizedBox(height: 16),

              Center(
                child: GestureDetector(
                  onTap: _toggleAuthMode,
                  behavior: HitTestBehavior.opaque,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text.rich(
                      TextSpan(
                        text: _isLogin ? "Don't have an account? " : "Already have an account? ",
                        style: const TextStyle(color: darkTextGrey, fontSize: 11),
                        children: [
                          TextSpan(
                            text: _isLogin ? 'REGISTER' : 'LOG IN',
                            style: const TextStyle(
                              color: Colors.black, 
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

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
                    onChanged: (val) => setState(() => _isMarketingChecked = val!),
                    titleText: 'Marketing Communications',
                    description: const TextSpan(
                      text: 'I wish to receive marketing communications via WhatsApp, email, text messaging and/or phonecall.',
                    ),
                  ),
                  const SizedBox(height: 16), 
                  _customConsentCheckbox(
                    value: _isTermsChecked,
                    onChanged: (val) => setState(() => _isTermsChecked = val!),
                    titleText: 'Terms and Conditions',
                    description: TextSpan(
                      text: 'I confirm I have read and accept the ',
                      children: [
                        TextSpan(
                          text: 'Terms of Use',
                          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                          recognizer: TapGestureRecognizer()..onTap = () {},
                        ),
                        const TextSpan(text: ' and '),
                        TextSpan(
                          text: 'Privacy Policy',
                          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
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

  Widget _buildLoginForm() {
    return Column(
      key: const ValueKey('login_form'),
      children: [
        _buildTextField(hint: 'Email', controller: _emailController),
        const SizedBox(height: 16),
        _buildTextField(hint: 'Password', controller: _passwordController, isPassword: true),
      ],
    );
  }

  Widget _buildRegisterForm() {
    return Column(
      key: const ValueKey('register_form'),
      children: [
        _buildTextField(hint: 'Enter Name', controller: _nameController),
        const SizedBox(height: 16),
        _buildTextField(hint: 'Email', controller: _emailController),
        const SizedBox(height: 16),
        _buildTextField(hint: 'Password', controller: _passwordController, isPassword: true),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Phone No.', style: TextStyle(fontSize: 10, color: darkTextGrey)),
                  const SizedBox(height: 6),
                  _buildTextField(hint: '+62 | ', controller: _phoneController, isNumber: true),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Birthday', style: TextStyle(fontSize: 10, color: darkTextGrey)),
                  const SizedBox(height: 6),
                  _buildTextField(
                    hint: 'DD / MM / YYYY', 
                    controller: _birthdayController,
                    readOnly: true,
                    onTap: _presentDatePicker,
                  ),
                ],
              ),
            ),
          ],
        )
      ],
    );
  }

  Widget _buildTextField({
    required String hint, 
    required TextEditingController controller, 
    bool isPassword = false,
    bool isNumber = false,
    bool readOnly = false, 
    VoidCallback? onTap,   
  }) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      keyboardType: isNumber ? TextInputType.phone : TextInputType.text,
      readOnly: readOnly,
      onTap: onTap,
      cursorColor: Colors.black,
      style: const TextStyle(color: Colors.black, fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: darkTextGrey, fontSize: 14),
        filled: true,
        fillColor: fieldColor,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _socialButton(IconData icon) {
    return Container(
      width: 44, height: 44,
      decoration: const BoxDecoration(color: lightGrey, shape: BoxShape.circle),
      child: Center(child: FaIcon(icon, size: 20, color: darkTextGrey)),
    );
  }

  Widget _customConsentCheckbox({
    required bool value,
    required ValueChanged<bool?> onChanged,
    required String titleText,
    required InlineSpan description,
  }) {
    return InkWell(
      onTap: () => onChanged(!value),
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 2, right: 10), 
            width: 12, height: 12,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: value ? darkTextGrey : lightGrey, 
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(titleText, style: const TextStyle(color: Colors.black, fontSize: 11, fontWeight: FontWeight.bold)),
                const SizedBox(height: 2),
                Text.rich(description, style: const TextStyle(color: darkTextGrey, fontSize: 10, height: 1.3)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}