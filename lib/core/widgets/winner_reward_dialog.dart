import 'package:flutter/material.dart';

class WinnerRewardDialog extends StatelessWidget {
  const WinnerRewardDialog({
    super.key,
    required this.reward,
    required this.onClaim,
  });

  final int reward;
  final VoidCallback onClaim;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 18),
      child: Material(
        color: Colors.white,
        elevation: 8,
        shadowColor: const Color(0x33000000),
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 22, 18, 18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                'assets/winner.png',
                width: 140,
                fit: BoxFit.contain,
                filterQuality: FilterQuality.high,
              ),
              const SizedBox(height: 10),
              const Text(
                'Well Done!',
                style: TextStyle(
                  color: Color(0xFF2A200F),
                  fontWeight: FontWeight.w700,
                  fontSize: 34,
                  height: 1.0,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'You Won $reward Points. Claim Now\nAnd Play Again.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF2A200F),
                  fontWeight: FontWeight.w600,
                  fontSize: 20,
                  height: 1.25,
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: 220,
                height: 54,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE2A321),
                    foregroundColor: const Color(0xFF2A200F),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: onClaim,
                  child: const Text(
                    'CLAIM NOW',
                    maxLines: 1,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 22,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

