import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import '../providers/language_provider.dart';
import '../utils/app_colors.dart';
import '../utils/translations.dart';

import 'schemes_screen.dart';
import 'voice_help_screen.dart';
import 'buy_sell_screen.dart';
import 'crops_screen.dart';
import 'weather_screen.dart';
import 'market_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Map<String, dynamic>? _farmerData;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final mobile = prefs.getString('current_mobile');

      if (mobile != null) {
        if (!kIsWeb) {
          final directory = await getApplicationDocumentsDirectory();
          final file = File('${directory.path}/farmer_$mobile.json');

          if (await file.exists()) {
            final content = await file.readAsString();
            setState(() {
              _farmerData = jsonDecode(content);
            });
          }
        } else {
          // Web Fallback: Load from browser memory
          final profileStr = prefs.getString('profile_$mobile');
          if (profileStr != null) {
            setState(() {
              _farmerData = jsonDecode(profileStr);
            });
          }
        }
      }
    } catch (e) {
      debugPrint("Error loading profile: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    
    // Extracted Dynamic Data
    final String farmerName = _farmerData?['name']?.toString().split(' ').first ?? "Farmer";
    final String location = _farmerData?['mandal'] ?? (lang.isTelugu ? 'గుంటూరు మండలం' : 'Guntur Mandal');

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // Elegant Custom App Bar
          SliverAppBar(
            backgroundColor: AppColors.primary,
            expandedHeight: 150.0,
            floating: false,
            pinned: true,
            elevation: 0,
            shape: const ContinuousRectangleBorder(
              borderRadius: BorderRadius.only(bottomLeft: Radius.circular(60), bottomRight: Radius.circular(60)),
            ),
            title: Row(
              children: [
                const Icon(Icons.location_on, size: 20, color: AppColors.surface),
                const SizedBox(width: 8),
                Expanded(child: Text(location, style: const TextStyle(fontSize: 16, color: AppColors.surface, fontWeight: FontWeight.w500), maxLines: 1, overflow: TextOverflow.ellipsis)),
              ],
            ),
            actions: [
              IconButton(icon: const Icon(Icons.notifications_outlined, color: AppColors.surface), onPressed: () {}),
              IconButton(icon: const Icon(Icons.public, color: AppColors.surface), onPressed: () => lang.toggleLanguage()),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primary, AppColors.primary.withValues(alpha: 0.8)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: const BorderRadius.vertical(bottom: Radius.circular(30)),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(left: 24, bottom: 20, top: 40),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        '${lang.translate(T.strings['home_greeting']!)} $farmerName! 👋',
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.surface),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        lang.isTelugu ? 'మంచి పంటకాలాన్ని ఆశిస్తున్నాం!' : 'Wishing you a great harvest!',
                        style: TextStyle(fontSize: 14, color: AppColors.surface.withValues(alpha: 0.85), fontWeight: FontWeight.w400),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Main Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Weather Quick Card
                  Transform.translate(
                    offset: const Offset(0, -10),
                    child: Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                      color: AppColors.surface,
                      elevation: 8,
                      shadowColor: AppColors.primary.withValues(alpha: 0.15),
                      child: InkWell(
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const WeatherScreen())),
                        borderRadius: BorderRadius.circular(24),
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(color: Colors.orange.withValues(alpha: 0.15), shape: BoxShape.circle),
                                child: const Icon(Icons.wb_sunny_rounded, color: Colors.orange, size: 36),
                              ),
                              const SizedBox(width: 20),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: Text('32°C', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                                    ),
                                    Text(
                                      lang.translate(T.strings['partly_cloudy']!), 
                                      style: const TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w500),
                                      maxLines: 1, overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              const Spacer(),
                              const Icon(Icons.chevron_right_rounded, color: Colors.grey),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Alert Banner
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.orange.shade200, width: 1.5),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(color: Colors.orange.shade100, shape: BoxShape.circle),
                          child: Icon(Icons.notifications_active_rounded, color: Colors.orange.shade800, size: 20),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            lang.translate(T.strings['rain_warning']!),
                            style: TextStyle(fontWeight: FontWeight.w600, color: Colors.orange.shade900, fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),
                  Text(
                    lang.isTelugu ? 'ముఖ్య సేవలు' : 'Essential Services',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 16),

                  // Services Grid
                  GridView.count(
                    crossAxisCount: 3,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    childAspectRatio: 0.78,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    padding: const EdgeInsets.only(bottom: 120),
                    children: [
                      _GridItem(
                        icon: Icons.eco_rounded, 
                        label: lang.translate(T.strings['crop_info']!), 
                        color: Colors.green.shade600,
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CropsScreen())),
                      ),
                      _GridItem(
                        icon: Icons.cloud_rounded, 
                        label: lang.translate(T.strings['weather']!), 
                        color: Colors.blue.shade500,
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const WeatherScreen())),
                      ),
                      _GridItem(
                        icon: Icons.store_rounded, 
                        label: lang.translate(T.strings['market']!), 
                        color: Colors.purple.shade500,
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MarketScreen())),
                      ),
                      _GridItem(
                        icon: Icons.account_balance_rounded, 
                        label: lang.translate(T.strings['schemes']!), 
                        color: Colors.orange.shade600,
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SchemesScreen())),
                      ),
                      _GridItem(
                        icon: Icons.mic_rounded, 
                        label: lang.translate(T.strings['voice_help']!), 
                        color: Colors.red.shade400,
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const VoiceHelpScreen())),
                      ),
                      _GridItem(
                        icon: Icons.shopping_cart_rounded, 
                        label: lang.translate(T.strings['buy_sell']!), 
                        color: Colors.teal.shade500,
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BuySellScreen())),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GridItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _GridItem({required this.icon, required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(color: AppColors.primary.withValues(alpha: 0.06), blurRadius: 15, offset: const Offset(0, 8), spreadRadius: 0)
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 28, color: color),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary, height: 1.1),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
