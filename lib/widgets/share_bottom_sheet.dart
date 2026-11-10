import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/theme/app_theme.dart';

class ShareBottomSheet extends StatelessWidget {
  const ShareBottomSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => const ShareBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: AppTheme.pureWhite,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 20,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.cardBorderColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.iceBlue,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppTheme.lightBlue),
                ),
                child: const Icon(
                  Icons.ios_share_rounded,
                  color: AppTheme.electricBlue,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Share Venue',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: AppTheme.navyBlue,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Invite friends or teammates to Hexgen Sports Arena',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.slateBlue,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded, color: AppTheme.slateBlue),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Share Options
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildShareOption(
                context,
                icon: Icons.chat_bubble_rounded,
                color: const Color(0xFF25D366),
                label: 'WhatsApp',
                onTap: () {
                  Navigator.pop(context);
                  _showToast(context, 'Sharing via WhatsApp...');
                },
              ),
              _buildShareOption(
                context,
                icon: Icons.camera_alt_rounded,
                color: const Color(0xFFE4405F),
                label: 'Instagram',
                onTap: () {
                  Navigator.pop(context);
                  _showToast(context, 'Sharing to Instagram Story...');
                },
              ),
              _buildShareOption(
                context,
                icon: Icons.copy_rounded,
                color: AppTheme.electricBlue,
                label: 'Copy Link',
                onTap: () {
                  Clipboard.setData(
                    const ClipboardData(
                      text: 'https://hexgenbooking.com/venue/hexgen-arena',
                    ),
                  );
                  Navigator.pop(context);
                  _showToast(context, 'Venue link copied to clipboard!');
                },
              ),
              _buildShareOption(
                context,
                icon: Icons.qr_code_rounded,
                color: AppTheme.navyBlue,
                label: 'QR Code',
                onTap: () {
                  Navigator.pop(context);
                  _showToast(context, 'Generating venue QR code...');
                },
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Direct Link Field
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: AppTheme.iceBlue,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppTheme.cardBorderColor),
            ),
            child: Row(
              children: [
                const Icon(Icons.link_rounded, color: AppTheme.electricBlue, size: 20),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'hexgenbooking.com/hexgen-arena',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.navyBlue,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Clipboard.setData(
                      const ClipboardData(
                        text: 'https://hexgenbooking.com/venue/hexgen-arena',
                      ),
                    );
                    Navigator.pop(context);
                    _showToast(context, 'Link copied!');
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.electricBlue,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Copy',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildShareOption(
    BuildContext context, {
    required IconData icon,
    required Color color,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: color.withAlpha(20),
              shape: BoxShape.circle,
              border: Border.all(color: color.withAlpha(60)),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppTheme.navyBlue,
            ),
          ),
        ],
      ),
    );
  }

  void _showToast(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppTheme.navyBlue,
      ),
    );
  }
}
