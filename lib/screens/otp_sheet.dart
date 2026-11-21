import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/theme/app_theme.dart';
import 'continue_with_screen.dart';

class OtpBottomSheet extends StatefulWidget {
  final String phoneNumber;
  final String playerId;

  const OtpBottomSheet({
    super.key,
    this.phoneNumber = '9886519422',
    this.playerId = 'HX-9821',
  });

  static void show(
    BuildContext context, {
    String phoneNumber = '9886519422',
    String playerId = 'HX-9821',
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.4),
      builder: (context) => BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: OtpBottomSheet(
          phoneNumber: phoneNumber,
          playerId: playerId,
        ),
      ),
    );
  }

  @override
  State<OtpBottomSheet> createState() => _OtpBottomSheetState();
}

class _OtpBottomSheetState extends State<OtpBottomSheet> {
  static const int _otpLength = 6; // 6 OTP boxes
  final List<TextEditingController> _otpControllers =
      List.generate(_otpLength, (_) => TextEditingController(text: ''));
  final List<FocusNode> _focusNodes =
      List.generate(_otpLength, (_) => FocusNode());

  bool _isVerifying = false;
  String? _errorMessage;

  // 30s Countdown timer for OTP resend
  Timer? _countdownTimer;
  int _secondsRemaining = 30;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  void _startCountdown() {
    _countdownTimer?.cancel();
    setState(() => _secondsRemaining = 30);
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_secondsRemaining > 0) {
        setState(() => _secondsRemaining--);
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _onVerify() async {
    if (_isVerifying) return;
    setState(() => _isVerifying = true);

    final phone = widget.phoneNumber.trim();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('player_phone', phone);

    if (!mounted) return;
    Navigator.pop(context); // Close OTP sheet

    // Direct Flow: Mobile Number -> OTP -> Continue With Screen -> Dashboard
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ContinueWithScreen(
          phone: phone,
        ),
      ),
    );
  }

  void _resendOtp() {
    _startCountdown();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('New OTP sent to +91 ${widget.phoneNumber} (Demo: 123456)'),
        backgroundColor: AppTheme.navyBlue,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _sendToMail() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('OTP sent to registered email! (Demo: 123456)'),
        backgroundColor: AppTheme.navyBlue,
        behavior: SnackBarBehavior.floating,
      ),
    );
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
                  letterSpacing: -0.3,
                ),
              ),
              IconButton(
                icon: const Icon(
                  Icons.close_rounded,
                  color: AppTheme.navyBlue,
                  size: 22,
                ),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),

          const SizedBox(height: 18),

          // ── Enter OTP Label ──────────────────────────────────────────────
          const Text(
            'Enter OTP',
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: AppTheme.slateBlue,
            ),
          ),

          const SizedBox(height: 14),

          // ── 6 Separate Individual OTP Containers ────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(
              _otpLength,
              (index) {
                final isFocused = _focusNodes[index].hasFocus;
                final isFilled = _otpControllers[index].text.isNotEmpty;

                return AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  width: 48,
                  height: 54,
                  decoration: BoxDecoration(
                    color: isFocused
                        ? const Color(0xFFEFF6FF)
                        : const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isFocused
                          ? AppTheme.electricBlue
                          : const Color(0xFFCBD5E1), // Clean light grey outline
                      width: isFocused ? 1.8 : 1.2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: isFocused
                            ? const Color(0xFF0057FF).withValues(alpha: 0.12)
                            : Colors.black.withValues(alpha: 0.03),
                        blurRadius: isFocused ? 8 : 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        if (!isFilled && !isFocused)
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: Color(0xFF94A3B8),
                              shape: BoxShape.circle,
                            ),
                          ),
                        TextField(
                          controller: _otpControllers[index],
                          focusNode: _focusNodes[index],
                          textAlign: TextAlign.center,
                          keyboardType: TextInputType.number,
                          maxLength: 1,
                          style: const TextStyle(
                            fontSize: 20,
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
                            if (val.isNotEmpty && index < _otpLength - 1) {
                              _focusNodes[index + 1].requestFocus();
                            } else if (val.isEmpty && index > 0) {
                              _focusNodes[index - 1].requestFocus();
                            }
                            if (_otpControllers.every((c) => c.text.isNotEmpty)) {
                              _onVerify();
                            }
                          },
                        ),
                      ],
                    ),
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

          // ── Verify CTA Button (Screen 4: "Verify") ────────────────────────
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
                  : const Center(
                      child: Text(
                        'Verify',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
            ),
          ),

          const SizedBox(height: 18),

          // ── Resend Timer: "Resend OTP in 00:30" ────────────────────────────
          Center(
            child: Text(
              _secondsRemaining > 0
                  ? 'Resend OTP in 00:${_secondsRemaining.toString().padLeft(2, '0')}'
                  : 'Didn\'t receive OTP? You can now resend',
              style: const TextStyle(
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
                onTap: _secondsRemaining == 0 ? _resendOtp : null,
                child: Text(
                  'Resend OTP',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: _secondsRemaining == 0
                        ? AppTheme.electricBlue
                        : AppTheme.slateBlue.withValues(alpha: 0.6),
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
                onTap: _sendToMail,
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
