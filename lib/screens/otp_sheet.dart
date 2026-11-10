// DEPRECATED / UNUSED: OTP verification flow bypassed per user specification.
// Users now receive instant auto-generated Player ID and direct login access upon entering mobile number.
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../core/network/api_service.dart';
import '../core/theme/app_theme.dart';
import 'complete_profile_screen.dart';

@Deprecated('OTP verification bypassed. Direct mobile login is now used.')
class OtpBottomSheet extends StatefulWidget {
  final String phoneNumber;
  const OtpBottomSheet({super.key, this.phoneNumber = '9886519422'});

  static void show(BuildContext context, {String phoneNumber = '9886519422'}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.4),
      builder: (context) => BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: OtpBottomSheet(phoneNumber: phoneNumber),
      ),
    );
  }

  @override
  State<OtpBottomSheet> createState() => _OtpBottomSheetState();
}

class _OtpBottomSheetState extends State<OtpBottomSheet> {
  final List<TextEditingController> _otpControllers =
      List.generate(6, (_) => TextEditingController(text: ''));
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  bool _isVerifying = false;
  String? _errorMessage;

  @override
  void dispose() {
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  Future<void> _onVerify() async {
    final enteredOtp = _otpControllers.map((c) => c.text).join();
    if (enteredOtp.length < 6) {
      setState(() => _errorMessage = 'Please enter all 6 digits of the OTP');
      return;
    }

    setState(() {
      _isVerifying = true;
      _errorMessage = null;
    });

    final res = await ApiService().verifyOtp(widget.phoneNumber, enteredOtp);

    if (!mounted) return;

    if (res['success'] == true) {
      Navigator.pop(context); // Close OTP sheet
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const CompleteProfileScreen(),
        ),
      );
    } else {
      setState(() {
        _isVerifying = false;
        _errorMessage = res['message'] ?? 'Invalid OTP. Please try 123456';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.pureWhite,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.only(
        top: 20,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header Bar: You're almost there + Close X ────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "You're almost there",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: AppTheme.navyBlue,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded,
                    color: AppTheme.navyBlue, size: 22),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),

          const SizedBox(height: 18),

          // ── Enter OTP Label ──────────────────────────────────────────────
          const Text(
            'Enter 6-Digit OTP',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppTheme.slateBlue,
            ),
          ),

          const SizedBox(height: 12),

          // ── 6-Digit OTP Box Grid ──────────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(
              6,
              (index) {
                final isFocused = _focusNodes[index].hasFocus;
                final isFilled = _otpControllers[index].text.isNotEmpty;

                return Container(
                  width: 46,
                  height: 52,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isFocused || isFilled
                          ? AppTheme.electricBlue
                          : AppTheme.skyBlue,
                      width: isFocused || isFilled ? 1.8 : 1.2,
                    ),
                    boxShadow: isFocused || isFilled
                        ? [
                            BoxShadow(
                              color: AppTheme.electricBlue.withAlpha(20),
                              blurRadius: 6,
                            ),
                          ]
                        : [],
                  ),
                  child: TextField(
                    controller: _otpControllers[index],
                    focusNode: _focusNodes[index],
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    maxLength: 1,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: AppTheme.navyBlue,
                    ),
                    decoration: const InputDecoration(
                      counterText: '',
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                    onChanged: (val) {
                      setState(() {});
                      if (val.isNotEmpty && index < 5) {
                        _focusNodes[index + 1].requestFocus();
                      } else if (val.isEmpty && index > 0) {
                        _focusNodes[index - 1].requestFocus();
                      }
                      if (_otpControllers.every((c) => c.text.isNotEmpty)) {
                        _onVerify();
                      }
                    },
                  ),
                );
              },
            ),
          ),

          if (_errorMessage != null) ...[
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Center(
                child: Text(
                  _errorMessage!,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.redAccent,
                  ),
                ),
              ),
            ),
          ],

          const SizedBox(height: 22),

          // ── Verify CTA Button ─────────────────────────────────────────────
          GestureDetector(
            onTap: _isVerifying ? null : _onVerify,
            child: Container(
              width: double.infinity,
              height: 52,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(26),
                gradient: AppTheme.primaryCtaGradient,
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.electricBlue.withAlpha(80),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: _isVerifying
                  ? const Center(
                      child: SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      ),
                    )
                  : const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Verify & Continue',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 18),
                      ],
                    ),
            ),
          ),

          const SizedBox(height: 18),

          // ── Resend Timer ──────────────────────────────────────────────────
          const Center(
            child: Text(
              'Resend OTP in 00:30',
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.bold,
                color: AppTheme.slateBlue,
              ),
            ),
          ),

          const SizedBox(height: 10),

          // ── Didn't receive OTP? Resend OTP or Send to mail ────────────────
          const Center(
            child: Text(
              "Didn't receive OTP?",
              style: TextStyle(
                fontSize: 12,
                color: AppTheme.slateBlue,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () {},
                child: const Text(
                  'Resend OTP',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.electricBlue,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
              const Text(
                '  or  ',
                style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.slateBlue,
                ),
              ),
              GestureDetector(
                onTap: () {},
                child: const Text(
                  'Send to mail',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.electricBlue,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),
        ],
      ),
    );
  }
}
