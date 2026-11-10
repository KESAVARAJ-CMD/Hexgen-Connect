import 'package:flutter/material.dart';
import '../features/dashboard/player_dashboard_screen.dart';

class HomeDashboardScreen extends StatelessWidget {
  const HomeDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlayerDashboardScreen(playerName: 'Rahul Kumar', playerId: 'HEX-99481');
  }
}
