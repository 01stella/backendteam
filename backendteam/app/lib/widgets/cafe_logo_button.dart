import 'package:flutter/material.dart';

const String cafeLocationTitle = 'UNIJI TOWER';
const String cafeLocationDetail = 'Jakarta International';
const String cafePhoneNumber = '+62 812-3456-7890';
const String cafeEmail = 'lumiora.cafe@gmail.com';

class CafeLogoButton extends StatelessWidget {
  final double padding;

  const CafeLogoButton({super.key, this.padding = 7});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => showCafeInfoModal(context),
        customBorder: const CircleBorder(),
        child: Padding(
          padding: EdgeInsets.all(padding),
          child: ClipOval(
            child: Image.asset('assets/cafelogo.png', fit: BoxFit.cover),
          ),
        ),
      ),
    );
  }
}

Future<void> showCafeInfoModal(BuildContext context) {
  const Color primaryGreen = Color(0xFF7B8C2A);
  const Color warmBrown = Color(0xFF947B44);
  const Color surface = Color(0xFFFFFCF5);
  const Color textDark = Color(0xFF252821);

  return showDialog<void>(
    context: context,
    barrierColor: Colors.black.withValues(alpha: 0.38),
    builder: (context) {
      return Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 28),
        child: Container(
          padding: const EdgeInsets.fromLTRB(22, 24, 22, 18),
          decoration: BoxDecoration(
            color: surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE8DDCA)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.18),
                blurRadius: 28,
                offset: const Offset(0, 14),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: warmBrown, width: 1.5),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: ClipOval(
                    child: Image.asset(
                      'assets/cafelogo.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                cafeLocationTitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: textDark,
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.1,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                cafeLocationDetail,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.black54, fontSize: 13),
              ),
              const SizedBox(height: 18),
              _CafeInfoRow(
                icon: Icons.location_on_outlined,
                label: 'Location',
                value: '$cafeLocationTitle, $cafeLocationDetail',
              ),
              const SizedBox(height: 10),
              const _CafeInfoRow(
                icon: Icons.phone_outlined,
                label: 'Phone',
                value: cafePhoneNumber,
              ),
              const SizedBox(height: 10),
              const _CafeInfoRow(
                icon: Icons.mail_outline,
                label: 'Email',
                value: cafeEmail,
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryGreen,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 13),
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
}

class _CafeInfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _CafeInfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: const Color(0xFFE8DDCA),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: const Color(0xFF947B44), size: 18),
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
                  color: Color(0xFF252821),
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
}
