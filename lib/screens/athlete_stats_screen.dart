import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../features/dashboard/tabs/stats_tab.dart';

class AthleteStatsScreen extends StatefulWidget {
  final bool isSubscribed;
  const AthleteStatsScreen({super.key, this.isSubscribed = true});

  @override
  State<AthleteStatsScreen> createState() => _AthleteStatsScreenState();
}

class _AthleteStatsScreenState extends State<AthleteStatsScreen> {
  late bool _subscribed;

  @override
  void initState() {
    super.initState();
    _subscribed = widget.isSubscribed;
  }

  void _onUnlock() {
    setState(() => _subscribed = true);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('⚡ PRO ATHLETE PASS ACTIVATED! Full Biomechanical Telemetry Unlocked.'),
        backgroundColor: AppTheme.navyBlue,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.iceBlue,
      appBar: AppBar(
        backgroundColor: AppTheme.iceBlue,
        elevation: 0,
        title: const Text(
          'BIOMECHANICS & TELEMETRY',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w900,
            color: AppTheme.navyBlue,
            letterSpacing: 0.6,
            fontFamily: 'Roboto',
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppTheme.navyBlue, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: StatsTab(
        isSubscribed: _subscribed,
        onUnlockSubscription: _onUnlock,
      ),
    );
  }
}
