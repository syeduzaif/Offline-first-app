import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:iconsax/iconsax.dart';
import 'package:offline_first_app/core/constants/app_colors.dart';
import 'package:offline_first_app/core/constants/app_layout.dart';
import 'package:offline_first_app/shared/widgets/offline_banner_widget.dart';

class MainShell extends StatelessWidget {
  const MainShell({super.key, required this.child});

  final Widget child;

  static const _tabs = [
    '/home',
    '/students',
    '/attendance',
    '/timetable',
    '/lms',
  ];

  int _currentIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    final index = _tabs.indexWhere((t) => location.startsWith(t));
    return index == -1 ? 0 : index;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: OfflineBannerWrapper(child: child),
      bottomNavigationBar: Container(
        color: AppColors.white,
        padding: EdgeInsets.symmetric(
          horizontal: AppLayout.width16,
          vertical: AppLayout.height12,
        ),
        child: GNav(
          backgroundColor: AppColors.white,
          color: AppColors.grayMedium,
          activeColor: AppColors.primary,
          tabBackgroundColor: AppColors.primaryLighter,
          gap: 8,
          padding: EdgeInsets.symmetric(
            horizontal: AppLayout.width12,
            vertical: AppLayout.height10,
          ),
          selectedIndex: _currentIndex(context),
          onTabChange: (index) => context.go(_tabs[index]),
          tabs: const [
            GButton(icon: Iconsax.home,       text: 'Home'),
            GButton(icon: Iconsax.people,     text: 'Students'),
            GButton(icon: Iconsax.calendar_1, text: 'Attendance'),
            GButton(icon: Iconsax.timer_1,    text: 'Timetable'),
            GButton(icon: Iconsax.book_1,     text: 'LMS'),
          ],
        ),
      ),
    );
  }
}
