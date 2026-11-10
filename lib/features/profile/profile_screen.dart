import 'package:flutter/material.dart';
import '../../screens/profile_screen.dart' as screens;

class ProfileScreen extends StatelessWidget {
  final String? name;
  final String? id;
  final bool? isSubscribed;
  final bool showTopBar;
  final bool showBottomNavBar;

  const ProfileScreen({
    super.key,
    this.name,
    this.id,
    this.isSubscribed,
    this.showTopBar = false,
    this.showBottomNavBar = false,
  });

  @override
  Widget build(BuildContext context) {
    return screens.ProfileScreen(
      showTopBar: showTopBar,
      showBottomNavBar: showBottomNavBar,
      name: name,
      id: id,
    );
  }
}
