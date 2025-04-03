import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:smarttimer/screens/timer_screen.dart';
import 'package:smarttimer/utils/custom_text_style.dart';

import '../constants/colors.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late PersistentTabController _controller;

  @override
  void initState() {
    super.initState();
    _controller = PersistentTabController(initialIndex: 0);
  }

  List<Widget> screens() {
    return [
      TimerScreen(),
      const Center(child: Text("Search Screen")),
      const Center(child: Text("Profile Screen")),
    ];
  }

  List<PersistentBottomNavBarItem> _navBarsItems() {
    return [
      PersistentBottomNavBarItem(
        icon: const Icon(Icons.timer),
        title: "Timer",
        textStyle: myTextStyle18(fontWeight: FontWeight.bold),
        inactiveColorPrimary: Colors.grey,
        activeColorPrimary: AppColors.primary,
        activeColorSecondary: Colors.white,
      ),
      PersistentBottomNavBarItem(
        icon: const Icon(Icons.search),
        title: "Search",
        textStyle: myTextStyle18(),
        inactiveColorPrimary: Colors.grey,
      ),
      PersistentBottomNavBarItem(
        icon: const Icon(Icons.person),
        title: "Profile",
        textStyle: myTextStyle18(),
        activeColorPrimary: Colors.orange,
        inactiveColorPrimary: Colors.grey,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return PersistentTabView(
      context,
      controller: _controller,
      screens: screens(),
      items: _navBarsItems(),
      handleAndroidBackButtonPress: true,
      resizeToAvoidBottomInset: true,
      stateManagement: true,
      hideNavigationBarWhenKeyboardAppears: true,
      padding: const EdgeInsets.all(2),
      backgroundColor: AppColors.background,
      isVisible: true,
      animationSettings: const NavBarAnimationSettings(
        navBarItemAnimation: ItemAnimationSettings(
          duration: Duration(milliseconds: 400),
          curve: Curves.ease,
        ),
        screenTransitionAnimation: ScreenTransitionAnimationSettings(
          animateTabTransition: true,
          duration: Duration(milliseconds: 200),
          screenTransitionAnimationType: ScreenTransitionAnimationType.fadeIn,
        ),
      ),
      confineToSafeArea: true,
      margin: EdgeInsets.all(16),
      decoration: NavBarDecoration(
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.white12,
            spreadRadius: 1,
            blurRadius: 5,
            offset: Offset(-3, -3),
          ),
          BoxShadow(
            color: Colors.white12,
            spreadRadius: 1,
            blurRadius: 5,
            offset: Offset(3, 3),
          ),
          BoxShadow(
            color: Colors.white12,
            spreadRadius: 1,
            blurRadius: 5,
            offset: Offset(-3, 3),
          ),

        ],
      ),
      navBarHeight: kBottomNavigationBarHeight,

      /// here define style number
      navBarStyle: NavBarStyle.style10,
    );
  }
}
