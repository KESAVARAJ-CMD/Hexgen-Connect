import 'package:flutter/material.dart';
import '../../coach/coach_connect_hub.dart';

class CoachesTab extends StatelessWidget {
  const CoachesTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const CoachConnectHub(showBackButton: false);
  }
}
