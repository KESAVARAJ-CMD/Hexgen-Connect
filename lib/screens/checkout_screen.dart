import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../core/network/api_service.dart';
import '../core/theme/app_theme.dart';
import '../core/widgets/cyber_controls.dart';
import '../core/widgets/cyber_glass_backdrop.dart';
import 'booking_success_screen.dart';

class CheckoutScreen extends StatefulWidget {
  final String venueId;
  final String venueName;
  final String date;
  final List<String> selectedTimeSlots;
  final double totalAmount;

  const CheckoutScreen({
    super.key,
    this.venueId = 'v1',
    this.venueName = 'Hexgen Sports Arena',
    this.date = 'Tomorrow',
    this.selectedTimeSlots = const ['09:00 AM - 10:00 AM'],
    this.totalAmount = 1830.0,
  });

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  int _selectedPaymentMethod = 0; // 0: UPI, 1: Card, 2: NetBanking
  String _selectedUpiApp = 'GPay';
  String _selectedBank = 'HDFC Bank';
  bool _saveCard = true;
  bool _isProcessingPayment = false;

  final TextEditingController _upiIdController =
      TextEditingController(text: 'rahulkumar@okaxis');
  final TextEditingController _cardNumberController =
      TextEditingController(text: '4532  8921  7741  1234');
  final TextEditingController _nameOnCardController =
      TextEditingController(text: 'Rahul Kumar');
  final TextEditingController _expiryController =
      TextEditingController(text: '06 / 28');
  final TextEditingController _cvvController =
      TextEditingController(text: '884');

  @override
  void dispose() {
    _upiIdController.dispose();
    _cardNumberController.dispose();
    _nameOnCardController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    super.dispose();
  }

  Future<void> _onProceedToPay() async {
    if (_isProcessingPayment) return;

    setState(() => _isProcessingPayment = true);

    final paymentName = _selectedPaymentMethod == 0
        ? 'UPI ($_selectedUpiApp)'
        : _selectedPaymentMethod == 1
            ? 'Credit/Debit Card'
            : 'Net Banking ($_selectedBank)';

    // ── Real UPI Intent Integration ──────────────────────────────────────────
    if (_selectedPaymentMethod == 0) {
      // Hexgen Business UPI VPA (or dynamic Merchant ID)
      const merchantVpa = 'hexgen.sports@okaxis';
      const merchantName = 'Hexgen Sports Arena';
      final txnRef = 'HEX${DateTime.now().millisecondsSinceEpoch}';
      final amount = widget.totalAmount.toStringAsFixed(2);
      final note = 'Booking Lane at ${widget.venueName}';

      final upiUri = Uri.parse(
        'upi://pay?pa=$merchantVpa&pn=${Uri.encodeComponent(merchantName)}&mc=5941&tr=$txnRef&tn=${Uri.encodeComponent(note)}&am=$amount&cu=INR',
      );

      try {
        final canLaunch = await canLaunchUrl(upiUri);
        if (canLaunch) {
          await launchUrl(upiUri, mode: LaunchMode.externalApplication);
          // Allow user brief moment in UPI app before verifying with server
          await Future.delayed(const Duration(seconds: 2));
        } else {
          debugPrint('UPI app cannot be launched directly, proceeding with server checkout.');
        }
      } catch (e) {
        debugPrint('UPI intent trigger exception: $e');
      }
    }

    final res = await ApiService().createBooking(
      venueId: widget.venueId,
      date: widget.date,
      timeSlots: widget.selectedTimeSlots,
      totalAmount: widget.totalAmount,
      paymentMethod: paymentName,
    );

    if (!mounted) return;
    setState(() => _isProcessingPayment = false);

    final bookingData = res['booking'] ?? {};
    final bookingId = bookingData['bookingId'] ?? 'HEX-BK77492';
    final venueName = bookingData['venueName'] ?? widget.venueName;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => BookingSuccessScreen(
          bookingId: bookingId,
          venueName: venueName,
          laneInfo: 'Right-Hand Lane 1 • Synthetic Turf',
          dateTime: '${widget.date} • ${widget.selectedTimeSlots.join(', ')}',
          totalAmount: '₹ ${widget.totalAmount.toInt()}',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: CyberGlassBackdrop(
        showOrbs: true,
        showPattern: true,
        child: SafeArea(
          child: Column(
            children: [
              // ── 1. Top Decorative App Bar ─────────────────────────────────
              _buildTopBar(context),

              // ── Main Scrollable Content ──────────────────────────────────
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── 2. Stadium Ticket Pass Card (with perforation notches)
                      _buildTicketPassCard(),

                      const SizedBox(height: 12),

                      // ── 3. Decorative Promo / Member Perk Banner ───────────
                      _buildPromoBanner(),

                      const SizedBox(height: 14),

                      // ── 4. Athlete Profile Card ───────────────────────────
                      _buildAthleteProfileCard(),

                      const SizedBox(height: 14),

                      // ── 5. Decorative Payment Options Section ──────────────
                      _buildPaymentSection(),

                      const SizedBox(height: 14),

                      // ── 6. Itemized Receipt & Billing Breakdown ────────────
                      _buildReceiptCard(),

                      const SizedBox(height: 14),

                      // ── 7. Trust & Security Badge ─────────────────────────
                      _buildSecurityBadge(),

                      const SizedBox(height: 18),
                    ],
                  ),
                ),
              ),

              // ── 8. Bottom Sticky Payment Action Bar ───────────────────────
              _buildBottomPaymentBar(),
            ],
          ),
        ),
      ),
    );
  }

  // ── 1. Top Decorative App Bar ─────────────────────────────────────────────
  Widget _buildTopBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFFDCEBFE),
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.electricBlue.withAlpha(20),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: AppTheme.navyBlue,
                size: 16,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      'CHECKOUT & PASS',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: AppTheme.navyBlue,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: Color(0xFF00D4FF),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                const Text(
                  'Hexgen Sports Arena • Booking ID: HEX-BK77492',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.slateBlue,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFE0F2FE), Color(0xFFF0FDF4)],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF86EFAC), width: 1),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: Color(0xFF16A34A),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 5),
                const Text(
                  'SECURE 256-BIT',
                  style: TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF15803D),
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── 2. Stadium Ticket Pass Card (with Perforated Notches) ───────────────────
  Widget _buildTicketPassCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFD6E4FF),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.electricBlue.withAlpha(16),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Glowing Sport Icon Box
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF0052FF), Color(0xFF00D4FF)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF0066FF).withValues(alpha: 0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.sports_cricket_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Hexgen Sports Arena',
                            style: TextStyle(
                              fontSize: 15.5,
                              fontWeight: FontWeight.w900,
                              color: AppTheme.navyBlue,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEFF6FF),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: const Color(0xFFBFDBFE)),
                            ),
                            child: const Text(
                              'LANE 01',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF0052FF),
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      const Text(
                        'Shanthinagar, Bangalore • Synthetic Turf Pitch',
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.slateBlue,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Perforated Ticket Notches & Dashed Divider Line
          Row(
            children: [
              // Left Circular Notch Cutout
              Container(
                width: 10,
                height: 20,
                decoration: const BoxDecoration(
                  color: Color(0xFFE8F1FC),
                  borderRadius: BorderRadius.horizontal(right: Radius.circular(10)),
                ),
              ),
              const Expanded(
                child: _DashedLine(color: Color(0xFFCBD5E1), height: 1),
              ),
              // Right Circular Notch Cutout
              Container(
                width: 10,
                height: 20,
                decoration: const BoxDecoration(
                  color: Color(0xFFE8F1FC),
                  borderRadius: BorderRadius.horizontal(left: Radius.circular(10)),
                ),
              ),
            ],
          ),

          // Lower Ticket Pass Details
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
            child: Row(
              children: [
                _buildPassDetailBadge(
                  icon: Icons.calendar_today_rounded,
                  label: 'Tomorrow',
                  sub: '09:00 - 10:00 AM',
                ),
                Container(width: 1, height: 30, color: const Color(0xFFE2E8F0)),
                _buildPassDetailBadge(
                  icon: Icons.timelapse_rounded,
                  label: 'Duration',
                  sub: '60 Mins • 6 Overs',
                ),
                Container(width: 1, height: 30, color: const Color(0xFFE2E8F0)),
                _buildPassDetailBadge(
                  icon: Icons.videocam_outlined,
                  label: 'AI Radar',
                  sub: 'Telemetry Ready',
                  accentColor: const Color(0xFF16A34A),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPassDetailBadge({
    required IconData icon,
    required String label,
    required String sub,
    Color? accentColor,
  }) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6),
        child: Row(
          children: [
            Icon(
              icon,
              size: 15,
              color: accentColor ?? AppTheme.electricBlue,
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w600,
                      color: accentColor ?? AppTheme.slateBlue,
                    ),
                  ),
                  Text(
                    sub,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w800,
                      color: accentColor ?? AppTheme.navyBlue,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── 3. Decorative Promo / Member Perk Banner ──────────────────────────────
  Widget _buildPromoBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF0FDF4),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF86EFAC), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF16A34A).withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: const Color(0xFF16A34A).withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.local_offer_rounded,
              color: Color(0xFF16A34A),
              size: 16,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'COUPON "HEXGEN10" APPLIED',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF15803D),
                    letterSpacing: 0.5,
                  ),
                ),
                SizedBox(height: 1),
                Text(
                  '₹ 200 Athlete Member discount included in fee',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF166534),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: const Color(0xFF15803D),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              'SAVED ₹200',
              style: TextStyle(
                fontSize: 9.5,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                letterSpacing: 0.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── 4. Athlete Profile Card ───────────────────────────────────────────────
  Widget _buildAthleteProfileCard() {
    return _buildDecorativeCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'ATHLETE PROFILE',
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w900,
                  color: AppTheme.navyBlue,
                  letterSpacing: 0.5,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFDCFCE7),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: const Color(0xFF86EFAC)),
                ),
                child: const Text(
                  'ID: HEX-99481',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF15803D),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              // Avatar with glowing gradient ring
              Container(
                width: 44,
                height: 44,
                padding: const EdgeInsets.all(2),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: AppTheme.primaryCtaGradient,
                ),
                child: Container(
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                  ),
                  child: const Center(
                    child: Text(
                      'RK',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                        color: AppTheme.electricBlue,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Rahul Kumar',
                      style: TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.navyBlue,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: const [
                        Icon(Icons.phone_iphone_rounded, size: 12, color: AppTheme.electricBlue),
                        SizedBox(width: 4),
                        Text(
                          '+91 88654 94221',
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w500,
                            color: AppTheme.slateBlue,
                          ),
                        ),
                        SizedBox(width: 10),
                        Icon(Icons.mail_outline_rounded, size: 12, color: Color(0xFF00D4FF)),
                        SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            'rahulkumar1@gmail.com',
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w500,
                              color: AppTheme.slateBlue,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── 5. Payment Options Section ────────────────────────────────────────────
  Widget _buildPaymentSection() {
    return _buildDecorativeCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'PAYMENT METHOD',
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w900,
                  color: AppTheme.navyBlue,
                  letterSpacing: 0.5,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'ENCRYPTED',
                  style: TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0052FF),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // 1. UPI Option
          _buildPaymentOptionTile(
            index: 0,
            title: 'UPI (Instant & Recommended)',
            subtitle: 'GPay, PhonePe, Paytm, BHIM or any UPI ID',
            icon: Icons.qr_code_scanner_rounded,
            iconColors: const [Color(0xFF0052FF), Color(0xFF00D4FF)],
          ),

          if (_selectedPaymentMethod == 0) ...[
            const SizedBox(height: 10),
            _buildUpiSelector(),
          ],

          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Divider(height: 1, color: Color(0xFFF1F5F9)),
          ),

          // 2. Credit/Debit Card Option
          _buildPaymentOptionTile(
            index: 1,
            title: 'Credit / Debit Card',
            subtitle: 'Visa, MasterCard, RuPay (Instant OTP)',
            icon: Icons.credit_card_rounded,
            iconColors: const [Color(0xFF0284C7), Color(0xFF38BDF8)],
          ),

          if (_selectedPaymentMethod == 1) ...[
            const SizedBox(height: 12),
            _buildCardForm(),
          ],

          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Divider(height: 1, color: Color(0xFFF1F5F9)),
          ),

          // 3. Net Banking
          _buildPaymentOptionTile(
            index: 2,
            title: 'Net Banking',
            subtitle: 'HDFC, ICICI, SBI, Axis & all major banks',
            icon: Icons.account_balance_rounded,
            iconColors: const [Color(0xFF475569), Color(0xFF64748B)],
          ),

          if (_selectedPaymentMethod == 2) ...[
            const SizedBox(height: 10),
            _buildBankSelector(),
          ],
        ],
      ),
    );
  }

  Widget _buildPaymentOptionTile({
    required int index,
    required String title,
    required String subtitle,
    required IconData icon,
    required List<Color> iconColors,
  }) {
    final isSelected = _selectedPaymentMethod == index;

    return InkWell(
      onTap: () => setState(() => _selectedPaymentMethod = index),
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFF0F7FF) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: isSelected
              ? Border.all(color: const Color(0xFF0066FF).withValues(alpha: 0.35))
              : null,
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: iconColors,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: Colors.white, size: 19),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: isSelected ? FontWeight.w800 : FontWeight.w700,
                      color: AppTheme.navyBlue,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.slateBlue,
                    ),
                  ),
                ],
              ),
            ),
            CyberGradientRadio(
              isSelected: isSelected,
              onTap: () => setState(() => _selectedPaymentMethod = index),
            ),
          ],
        ),
      ),
    );
  }

  // ── UPI Apps Selector ─────────────────────────────────────────────────────
  Widget _buildUpiSelector() {
    final apps = [
      {'name': 'GPay', 'color': Color(0xFF4285F4)},
      {'name': 'PhonePe', 'color': Color(0xFF5F259F)},
      {'name': 'Paytm', 'color': Color(0xFF00B9F5)},
      {'name': 'UPI ID', 'color': Color(0xFF0052FF)},
    ];

    return Column(
      children: [
        Row(
          children: apps.map((app) {
            final isAppSelected = _selectedUpiApp == app['name'];
            final appColor = app['color'] as Color;

            return Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _selectedUpiApp = app['name'] as String),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: isAppSelected ? Colors.white : const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isAppSelected ? appColor : const Color(0xFFE2E8F0),
                      width: isAppSelected ? 1.5 : 1,
                    ),
                    boxShadow: isAppSelected
                        ? [
                            BoxShadow(
                              color: appColor.withValues(alpha: 0.2),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: Center(
                    child: Text(
                      app['name'] as String,
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.bold,
                        color: isAppSelected ? appColor : AppTheme.navyBlue,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        if (_selectedUpiApp == 'UPI ID') ...[
          const SizedBox(height: 10),
          _buildDecorativeInput(
            controller: _upiIdController,
            label: 'Enter UPI ID / VPA',
            hintText: 'e.g. mobile@upi',
            prefixIcon: Icons.alternate_email_rounded,
          ),
        ],
      ],
    );
  }

  // ── Card Form ─────────────────────────────────────────────────────────────
  Widget _buildCardForm() {
    return Column(
      children: [
        _buildDecorativeInput(
          controller: _cardNumberController,
          label: 'Card Number',
          hintText: '4532  8921  7741  1234',
          prefixIcon: Icons.credit_card_rounded,
          suffixWidget: Container(
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: const Color(0xFF0052FF).withAlpha(15),
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Text(
              'VISA',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w900,
                color: Color(0xFF0052FF),
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _buildDecorativeInput(
                controller: _expiryController,
                label: 'Expiry',
                hintText: 'MM/YY',
                prefixIcon: Icons.calendar_today_outlined,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildDecorativeInput(
                controller: _cvvController,
                label: 'CVV',
                hintText: '•••',
                prefixIcon: Icons.lock_outline_rounded,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        _buildDecorativeInput(
          controller: _nameOnCardController,
          label: 'Name on Card',
          hintText: 'Rahul Kumar',
          prefixIcon: Icons.person_outline_rounded,
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: Checkbox(
                value: _saveCard,
                onChanged: (val) => setState(() => _saveCard = val ?? true),
                activeColor: AppTheme.electricBlue,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              'Save this card securely for future sessions',
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w500,
                color: AppTheme.slateBlue,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ── Net Banking Selector ──────────────────────────────────────────────────
  Widget _buildBankSelector() {
    final banks = ['HDFC Bank', 'ICICI Bank', 'SBI', 'Axis Bank'];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: banks.map((bank) {
        final isSelected = _selectedBank == bank;
        return GestureDetector(
          onTap: () => setState(() => _selectedBank = bank),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: isSelected ? Colors.white : const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isSelected ? AppTheme.electricBlue : const Color(0xFFE2E8F0),
                width: isSelected ? 1.5 : 1,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: AppTheme.electricBlue.withAlpha(20),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: Text(
              bank,
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.bold,
                color: isSelected ? AppTheme.electricBlue : AppTheme.navyBlue,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // ── 6. Itemized Receipt & Billing Breakdown Card ──────────────────────────
  Widget _buildReceiptCard() {
    return _buildDecorativeCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                'ORDER & BILLING SUMMARY',
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w900,
                  color: AppTheme.navyBlue,
                  letterSpacing: 0.5,
                ),
              ),
              Text(
                'Instant Lock',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF16A34A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          _buildReceiptRow('Lane 1 Turf Pitch (1 Hour)', '₹ 1,800'),
          const SizedBox(height: 6),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '60FPS AI Telemetry & Video',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.slateBlue,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                decoration: BoxDecoration(
                  color: const Color(0xFFDCFCE7),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'COMPLIMENTARY',
                  style: TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF15803D),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),

          _buildReceiptRow('Taxes & Convenience Fee (18% GST)', '₹ 30'),

          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: _DashedLine(color: Color(0xFFE2E8F0), height: 1),
          ),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'TOTAL PAYABLE',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      color: AppTheme.navyBlue,
                      letterSpacing: 0.5,
                    ),
                  ),
                  SizedBox(height: 1),
                  Text(
                    'Includes all applicable taxes',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.slateBlue,
                    ),
                  ),
                ],
              ),
              ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [Color(0xFF0052FF), Color(0xFF0099FF)],
                ).createShader(bounds),
                child: const Text(
                  '₹ 1,830',
                  style: TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReceiptRow(String title, String amount) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppTheme.slateBlue,
          ),
        ),
        Text(
          amount,
          style: const TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w700,
            color: AppTheme.navyBlue,
          ),
        ),
      ],
    );
  }

  // ── 7. Trust & Security Badge ─────────────────────────────────────────────
  Widget _buildSecurityBadge() {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE2EEFF)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.shield_rounded, size: 14, color: Color(0xFF16A34A)),
            SizedBox(width: 6),
            Text(
              '100% Safe & Secure 256-Bit SSL Encrypted Checkout',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Color(0xFF475569),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── 8. Bottom Sticky Payment Action Bar ───────────────────────────────────
  Widget _buildBottomPaymentBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(
          top: BorderSide(
            color: Color(0xFFE2EEFF),
            width: 1.2,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.navyBlue.withAlpha(12),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: const [
              Text(
                'AMOUNT TO PAY',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.slateBlue,
                  letterSpacing: 0.6,
                ),
              ),
              SizedBox(height: 2),
              Text(
                '₹ 1,830',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: AppTheme.navyBlue,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
          const SizedBox(width: 18),
          Expanded(
            child: GestureDetector(
              onTap: _onProceedToPay,
              child: Container(
                height: 52,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: AppTheme.primaryCtaGradient,
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.electricBlue.withAlpha(85),
                      blurRadius: 14,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: _isProcessingPayment
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
                          Icon(
                            Icons.lock_rounded,
                            color: Colors.white,
                            size: 16,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Pay & Confirm Slot',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 0.3,
                            ),
                          ),
                          SizedBox(width: 6),
                          Icon(
                            Icons.arrow_forward_rounded,
                            color: Colors.white,
                            size: 16,
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Reusable Component: Decorative Card ───────────────────────────────────
  Widget _buildDecorativeCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFE2EEFF),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.electricBlue.withAlpha(10),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: child,
    );
  }

  // ── Reusable Component: Decorative Input ──────────────────────────────────
  Widget _buildDecorativeInput({
    required TextEditingController controller,
    required String label,
    required String hintText,
    required IconData prefixIcon,
    Widget? suffixWidget,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: AppTheme.slateBlue,
          ),
        ),
        const SizedBox(height: 5),
        Container(
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: const Color(0xFFDCEBFE),
              width: 1.2,
            ),
          ),
          child: Row(
            children: [
              Icon(prefixIcon, size: 16, color: AppTheme.slateBlue),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: controller,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.navyBlue,
                  ),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                    hintText: hintText,
                    hintStyle: const TextStyle(
                      color: Color(0xFF94A3B8),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              ?suffixWidget,
            ],
          ),
        ),
      ],
    );
  }
}

// ── Decorative Dashed Line Component ─────────────────────────────────────────
class _DashedLine extends StatelessWidget {
  final Color color;
  final double height;

  const _DashedLine({
    required this.color,
    this.height = 1,
  });

  @override
  Widget build(BuildContext context) {
    const dashWidth = 5.0;
    const dashSpace = 4.0;
    return LayoutBuilder(
      builder: (context, constraints) {
        final boxWidth = constraints.constrainWidth();
        final dashCount = (boxWidth / (dashWidth + dashSpace)).floor();
        return Flex(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          direction: Axis.horizontal,
          children: List.generate(dashCount, (_) {
            return SizedBox(
              width: dashWidth,
              height: height,
              child: DecoratedBox(
                decoration: BoxDecoration(color: color),
              ),
            );
          }),
        );
      },
    );
  }
}
