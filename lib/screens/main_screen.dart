import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/language_provider.dart';
import '../utils/app_colors.dart';
import '../utils/translations.dart';

import 'home_screen.dart';
import 'crops_screen.dart';
import 'weather_screen.dart';
import 'market_screen.dart';
import 'profile_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const CropsScreen(),
    const WeatherScreen(),
    const MarketScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);

    return Scaffold(
      extendBody: true, // This makes the body flow smoothly under the floating navbar
      body: _screens[_currentIndex],
      bottomNavigationBar: Container(
        margin: const EdgeInsets.only(bottom: 24, left: 16, right: 16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.15),
              blurRadius: 20,
              spreadRadius: 5,
              offset: const Offset(0, 5),
            )
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            backgroundColor: AppColors.surface,
            selectedItemColor: AppColors.primary,
            unselectedItemColor: AppColors.textSecondary.withValues(alpha: 0.6),
            selectedFontSize: 10,
            unselectedFontSize: 9,
            showUnselectedLabels: true,
            type: BottomNavigationBarType.fixed,
            elevation: 0,
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            items: [
              BottomNavigationBarItem(
                icon: const Padding(padding: EdgeInsets.only(bottom: 4), child: Icon(Icons.home_rounded)),
                activeIcon: const Padding(padding: EdgeInsets.only(bottom: 2), child: Icon(Icons.home_rounded, size: 24)),
                label: lang.translate(T.strings['home']!),
              ),
              BottomNavigationBarItem(
                icon: const Padding(padding: EdgeInsets.only(bottom: 4), child: Icon(Icons.eco_rounded)),
                activeIcon: const Padding(padding: EdgeInsets.only(bottom: 2), child: Icon(Icons.eco_rounded, size: 24)),
                label: lang.translate(T.strings['crop_info']!),
              ),
              BottomNavigationBarItem(
                icon: const Padding(padding: EdgeInsets.only(bottom: 4), child: Icon(Icons.cloud_rounded)),
                activeIcon: const Padding(padding: EdgeInsets.only(bottom: 2), child: Icon(Icons.cloud_rounded, size: 24)),
                label: lang.translate(T.strings['weather']!),
              ),
              BottomNavigationBarItem(
                icon: const Padding(padding: EdgeInsets.only(bottom: 4), child: Icon(Icons.store_rounded)),
                activeIcon: const Padding(padding: EdgeInsets.only(bottom: 2), child: Icon(Icons.store_rounded, size: 24)),
                label: lang.translate(T.strings['market']!),
              ),
              BottomNavigationBarItem(
                icon: const Padding(padding: EdgeInsets.only(bottom: 4), child: Icon(Icons.person_rounded)),
                activeIcon: const Padding(padding: EdgeInsets.only(bottom: 4), child: Icon(Icons.person_rounded, size: 28)),
                label: lang.translate(T.strings['profile']!),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
