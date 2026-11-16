import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import 'view_coach_profile_screen.dart';

class CoachChatMessage {
  final String id;
  final String text;
  final bool isFromPlayer;
  final DateTime time;
  final String? audioDuration;
  final String? attachedSessionTitle;
  final String? attachedSessionDetail;

  CoachChatMessage({
    required this.id,
    required this.text,
    required this.isFromPlayer,
    required this.time,
    this.audioDuration,
    this.attachedSessionTitle,
    this.attachedSessionDetail,
  });
}

class CoachChatScreen extends StatefulWidget {
  final Map<String, dynamic> coach;
  final String? initialAttachedSession;

  const CoachChatScreen({
    super.key,
    required this.coach,
    this.initialAttachedSession,
  });

  static Future<void> open(
    BuildContext context, {
    required Map<String, dynamic> coach,
    String? initialAttachedSession,
  }) {
    return Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CoachChatScreen(
          coach: coach,
          initialAttachedSession: initialAttachedSession,
        ),
      ),
    );
  }

  @override
  State<CoachChatScreen> createState() => _CoachChatScreenState();
}

class _CoachChatScreenState extends State<CoachChatScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<CoachChatMessage> _messages = [];
  bool _isTyping = false;
  final bool _isCoachOnline = true;
  String? _currentlyAttachedSession;

  @override
  void initState() {
    super.initState();
    _currentlyAttachedSession = widget.initialAttachedSession;
    _initDefaultConversation();
  }

  void _initDefaultConversation() {
    final coachName = widget.coach['name'] ?? 'Coach';
    final role = widget.coach['role'] ?? 'Cricket Specialist';

    _messages.addAll([
      CoachChatMessage(
        id: '1',
        text: 'Hello Mahesh! 🏏 Welcome to $coachName DM. I am your $role at Hexgen Turf.',
        isFromPlayer: false,
        time: DateTime.now().subtract(const Duration(minutes: 25)),
      ),
      CoachChatMessage(
        id: '2',
        text: 'I reviewed your recent practice session. Your bat speed is solid at 142.4 km/h! Keep your top elbow pointing towards mid-off during the follow-through.',
        isFromPlayer: false,
        time: DateTime.now().subtract(const Duration(minutes: 24)),
      ),
      CoachChatMessage(
        id: '3',
        text: '',
        isFromPlayer: false,
        time: DateTime.now().subtract(const Duration(minutes: 22)),
        audioDuration: '0:18',
      ),
      CoachChatMessage(
        id: '4',
        text: 'Thanks Coach! I was noticing a slight edge on out-swingers. Will focus on the high elbow.',
        isFromPlayer: true,
        time: DateTime.now().subtract(const Duration(minutes: 10)),
      ),
    ]);
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage({String? customText, String? sessionTitle, String? sessionDetail}) {
    final textToSend = (customText ?? _textController.text).trim();
    if (textToSend.isEmpty && sessionTitle == null) return;

    final newMsg = CoachChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: textToSend,
      isFromPlayer: true,
      time: DateTime.now(),
      attachedSessionTitle: sessionTitle ?? _currentlyAttachedSession,
      attachedSessionDetail: sessionDetail,
    );

    setState(() {
      _messages.add(newMsg);
      if (customText == null) _textController.clear();
      _currentlyAttachedSession = null;
    });

    _scrollToBottom();
    _triggerSimulatedCoachReply(textToSend);
  }

  void _triggerSimulatedCoachReply(String playerQuery) {
    // 1. Show "typing..." after 800ms
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) setState(() => _isTyping = true);
    });

    // 2. Add realistic coach response after 2.2s
    Future.delayed(const Duration(milliseconds: 2300), () {
      if (!mounted) return;

      String replyText;
      final q = playerQuery.toLowerCase();

      if (q.contains('cover drive') || q.contains('elbow')) {
        replyText = 'Spot on! On the cover drive, ensure your head leads into the line before the bat swings down. Try 20 dry shadow swings focusing only on the high elbow.';
      } else if (q.contains('edge') || q.contains('slip') || q.contains('swing')) {
        replyText = 'For the out-swing edge, soften your bottom hand grip right before contact. Let the top hand dominate the trajectory.';
      } else if (q.contains('slot') || q.contains('session') || q.contains('book')) {
        replyText = 'I have a slot open tomorrow at Hexgen Turf Lane 2 (05:30 PM). Would you like to reserve that for video analysis?';
      } else if (q.contains('speed') || q.contains('pace') || q.contains('140')) {
        replyText = 'Against 140+ pace, your trigger movement should be completed before release. Shorten your backlift by 2 inches for quicker bat swing.';
      } else {
        replyText = 'Got it! I am analyzing this technique against your session telemetry. Keep practicing with intent and upload your next 3-over drill video.';
      }

      setState(() {
        _isTyping = false;
        _messages.add(
          CoachChatMessage(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            text: replyText,
            isFromPlayer: false,
            time: DateTime.now(),
          ),
        );
      });

      _scrollToBottom();
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent + 80,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _showAttachmentBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Share with Coach',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: AppTheme.navyBlue,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildAttachOption(
                      icon: Icons.videocam_rounded,
                      color: const Color(0xFF0052FF),
                      label: 'Session Video',
                      onTap: () {
                        Navigator.pop(ctx);
                        _sendMessage(
                          sessionTitle: 'Session 3 • Cover Drive Video',
                          sessionDetail: '3 Overs • 142.4 km/h • High Elbow Drill',
                          customText: 'Coach, please review my front foot drive video from Session 3.',
                        );
                      },
                    ),
                    _buildAttachOption(
                      icon: Icons.analytics_rounded,
                      color: const Color(0xFF10B981),
                      label: 'Telemetry',
                      onTap: () {
                        Navigator.pop(ctx);
                        _sendMessage(
                          sessionTitle: 'Hexgen AI Telemetry Report',
                          sessionDetail: 'Bat Speed: 142 km/h • Impact: 92% Sweet Spot',
                          customText: 'Here is my AI telemetry breakdown from the machine.',
                        );
                      },
                    ),
                    _buildAttachOption(
                      icon: Icons.sports_cricket_rounded,
                      color: const Color(0xFFF59E0B),
                      label: 'Book Slot',
                      onTap: () {
                        Navigator.pop(ctx);
                        _sendMessage(
                          customText: 'Hi Coach, I want to book a 1-on-1 net practice slot with you this week.',
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAttachOption({
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
              color: color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 26),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppTheme.navyBlue,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCoachAvatar({double size = 40}) {
    final assetPath = widget.coach['assetImage'] as String?;
    final name = widget.coach['name'] ?? 'Coach';
    final initial = name.replaceAll('Coach ', '').substring(0, 1).toUpperCase();

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipOval(
        child: assetPath != null
            ? Image.asset(
                assetPath,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => _buildFallbackAvatar(initial),
              )
            : _buildFallbackAvatar(initial),
      ),
    );
  }

  Widget _buildFallbackAvatar(String initial) {
    return Container(
      color: AppTheme.electricBlue,
      alignment: Alignment.center,
      child: Text(
        initial,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w900,
          fontSize: 16,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final coachName = widget.coach['name'] ?? 'Coach';

    return Scaffold(
      backgroundColor: const Color(0xFFECE5DD), // Classic WhatsApp / Cricket Turf Tone
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        titleSpacing: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppTheme.navyBlue),
          onPressed: () => Navigator.pop(context),
        ),
        title: GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ViewCoachProfileScreen(coach: widget.coach),
              ),
            );
          },
          child: Row(
            children: [
              Stack(
                children: [
                  _buildCoachAvatar(size: 38),
                  if (_isCoachOnline)
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 1.5),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            coachName,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w900,
                              color: AppTheme.navyBlue,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.verified_rounded,
                          color: Color(0xFF0052FF),
                          size: 14,
                        ),
                      ],
                    ),
                    Text(
                      _isTyping
                          ? 'typing...'
                          : (_isCoachOnline ? 'online • BCCI Certified' : 'offline'),
                      style: TextStyle(
                        fontSize: 11,
                        color: _isTyping ? const Color(0xFF0052FF) : const Color(0xFF64748B),
                        fontWeight: _isTyping ? FontWeight.w800 : FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.call_outlined, color: AppTheme.navyBlue, size: 21),
            tooltip: 'Audio Call',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('📞 Requesting 1-on-1 audio consultation with $coachName...'),
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: AppTheme.navyBlue,
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.videocam_outlined, color: AppTheme.navyBlue, size: 23),
            tooltip: 'Video Review Call',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('📹 Starting remote video telemetry sync with $coachName...'),
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: AppTheme.navyBlue,
                ),
              );
            },
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert_rounded, color: AppTheme.navyBlue),
            onSelected: (val) {
              if (val == 'profile') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ViewCoachProfileScreen(coach: widget.coach),
                  ),
                );
              } else if (val == 'clear') {
                setState(() => _messages.clear());
              }
            },
            itemBuilder: (_) => [
              const PopupMenuItem(value: 'profile', child: Text('View Full Profile')),
              const PopupMenuItem(value: 'clear', child: Text('Clear Chat')),
            ],
          ),
        ],
      ),
      body: Stack(
        children: [
          // Background cricket pitch watermark pattern
          Positioned.fill(
            child: Opacity(
              opacity: 0.035,
              child: Image.asset(
                'assets/logo.png',
                repeat: ImageRepeat.repeat,
                scale: 6,
                errorBuilder: (context, error, stackTrace) => const SizedBox(),
              ),
            ),
          ),

          Column(
            children: [
              // Chat Security / Encrypted Banner
              Container(
                margin: const EdgeInsets.symmetric(vertical: 8),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF9C4),
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.lock_rounded, size: 11, color: Color(0xFF78350F)),
                    SizedBox(width: 5),
                    Text(
                      '🔒 End-to-end encrypted cricket telemetry & chat',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF78350F),
                      ),
                    ),
                  ],
                ),
              ),

              // Messages List
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  itemCount: _messages.length,
                  itemBuilder: (context, index) {
                    final msg = _messages[index];
                    return _buildMessageBubble(msg);
                  },
                ),
              ),

              // Quick Doubt Chips Bar (Instagram/WhatsApp quick reply bar)
              Container(
                height: 38,
                margin: const EdgeInsets.only(bottom: 4),
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  children: [
                    _buildQuickChip('🏏 Fix Cover Drive Elbow'),
                    _buildQuickChip('📹 Review Latest Session'),
                    _buildQuickChip('📅 Book 1-on-1 Net Slot'),
                    _buildQuickChip('⚡ How to handle 140+ pace?'),
                  ],
                ),
              ),

              // Bottom Input Bar
              _buildBottomInputBar(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickChip(String label) {
    return Container(
      margin: const EdgeInsets.only(right: 6),
      child: ActionChip(
        backgroundColor: Colors.white,
        elevation: 0.5,
        side: const BorderSide(color: Color(0xFFCBD5E1), width: 0.8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 0),
        label: Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: AppTheme.navyBlue,
          ),
        ),
        onPressed: () => _sendMessage(customText: label),
      ),
    );
  }

  Widget _buildMessageBubble(CoachChatMessage msg) {
    final isMe = msg.isFromPlayer;
    final timeStr = '${msg.time.hour.toString().padLeft(2, '0')}:${msg.time.minute.toString().padLeft(2, '0')}';

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 3.5),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.78,
        ),
        decoration: BoxDecoration(
          color: isMe ? const Color(0xFFE7FFDB) : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(14),
            topRight: const Radius.circular(14),
            bottomLeft: isMe ? const Radius.circular(14) : const Radius.circular(3),
            bottomRight: isMe ? const Radius.circular(3) : const Radius.circular(14),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 3,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Attached Session Banner inside bubble
            if (msg.attachedSessionTitle != null) ...[
              Container(
                margin: const EdgeInsets.only(bottom: 6),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isMe ? const Color(0xFFD4F7C5) : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isMe ? const Color(0xFFB4EAA0) : const Color(0xFFE2E8F0),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppTheme.electricBlue,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Icon(Icons.play_circle_fill_rounded, color: Colors.white, size: 18),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            msg.attachedSessionTitle!,
                            style: const TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w900,
                              color: AppTheme.navyBlue,
                            ),
                          ),
                          if (msg.attachedSessionDetail != null)
                            Text(
                              msg.attachedSessionDetail!,
                              style: const TextStyle(
                                fontSize: 10,
                                color: Color(0xFF64748B),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Voice Note Simulation
            if (msg.audioDuration != null) ...[
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: const BoxDecoration(
                      color: AppTheme.electricBlue,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 8),
                  const Text('ılılllıllıılllıllı', style: TextStyle(color: Color(0xFF0052FF), fontSize: 13)),
                  const SizedBox(width: 8),
                  Text(
                    msg.audioDuration!,
                    style: const TextStyle(fontSize: 11, color: Color(0xFF64748B), fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 3),
            ] else if (msg.text.isNotEmpty) ...[
              Text(
                msg.text,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF1E293B),
                  height: 1.35,
                ),
              ),
            ],

            // Timestamp and Double Tick
            const SizedBox(height: 2),
            Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Spacer(),
                Text(
                  timeStr,
                  style: const TextStyle(
                    fontSize: 10,
                    color: Color(0xFF94A3B8),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (isMe) ...[
                  const SizedBox(width: 4),
                  // WhatsApp Blue Double Tick
                  const Icon(
                    Icons.done_all_rounded,
                    size: 14,
                    color: Color(0xFF0052FF),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomInputBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 6, 8, 8),
      color: Colors.white,
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            // Attachment Icon (+)
            IconButton(
              icon: const Icon(Icons.add_circle_outline_rounded, color: AppTheme.electricBlue, size: 26),
              onPressed: _showAttachmentBottomSheet,
              tooltip: 'Attach Practice Video / Session',
            ),

            // Text Input Box
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: TextField(
                  controller: _textController,
                  maxLines: 4,
                  minLines: 1,
                  textCapitalization: TextCapitalization.sentences,
                  style: const TextStyle(fontSize: 14, color: AppTheme.navyBlue),
                  decoration: const InputDecoration(
                    hintText: 'Message coach...',
                    hintStyle: TextStyle(fontSize: 13.5, color: Color(0xFF94A3B8)),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(vertical: 9),
                  ),
                  onSubmitted: (val) => _sendMessage(),
                ),
              ),
            ),

            const SizedBox(width: 6),

            // Send Button
            GestureDetector(
              onTap: () => _sendMessage(),
              child: Container(
                width: 42,
                height: 42,
                decoration: const BoxDecoration(
                  gradient: AppTheme.primaryCtaGradient,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xFF0052FF),
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.send_rounded,
                  color: Colors.white,
                  size: 19,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
