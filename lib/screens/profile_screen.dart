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

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? _farmerData;
  bool _isLoading = true;

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
              _isLoading = false;
            });
            return;
          }
        } else {
          // Web Fallback: Load from SharedPreferences
          final profileStr = prefs.getString('profile_$mobile');
          if (profileStr != null) {
            setState(() {
              _farmerData = jsonDecode(profileStr);
              _isLoading = false;
            });
            return;
          }
        }
      }
    } catch (e) {
      debugPrint("Error loading profile: $e");
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    }

    // Default static data if none found
    final String name = _farmerData?['name'] ?? "Guest Farmer";
    final String location = _farmerData != null 
        ? "${_farmerData!['district']}, ${_farmerData!['state']}" 
        : "Location Not Set";
    final String mobile = _farmerData?['mobile'] ?? (lang.isTelugu ? 'మొబైల్ లేదు' : "No Mobile");
    final String primaryCrop = (_farmerData?['crops'] as List?)?.firstOrNull ?? "Not Set";
    final String landSize = "${_farmerData?['farmSize'] ?? '0'} ${_farmerData?['farmUnit'] ?? 'Acres'}";

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.only(top: 40, bottom: 20, left: 20, right: 20),
              decoration: const BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: AppColors.surface,
                        child: Text(
                          name.characters.take(2).toString().toUpperCase(), 
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.primary)
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.surface)),
                            Text(location, style: const TextStyle(color: Colors.white70)),
                            Text("+91 $mobile", style: const TextStyle(color: Colors.white70)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(child: _StatColumn(lang.isTelugu ? 'పంటలు' : "Crops", "${(_farmerData?['crops'] as List?)?.length ?? 0}")),
                      Expanded(child: _StatColumn(lang.isTelugu ? 'పథకాలు' : "Schemes", "0")),
                      Expanded(child: _StatColumn(lang.isTelugu ? 'భూమి' : "Land", landSize)),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    lang.isTelugu ? 'ఖాతా వివరాలు' : "Account Details", 
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)
                  ),
                  const SizedBox(height: 10),
                  _DetailRow(label: lang.isTelugu ? 'ఇమెయిల్' : "Email", value: _farmerData?['email'] ?? "---"),
                  _DetailRow(label: lang.isTelugu ? 'ప్రధాన పంట' : "Primary Crop", value: primaryCrop),
                  _DetailRow(label: lang.isTelugu ? 'భూమి పరిమాణం' : "Land Size", value: landSize),
                  _DetailRow(label: lang.isTelugu ? 'వర్గం' : "Category", value: _farmerData?['farmerCategory'] ?? "---"),
                  
                  const SizedBox(height: 20),
                  Text(
                    lang.isTelugu ? 'మరింత సమాచారం' : "More Info", 
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)
                  ),
                  const SizedBox(height: 10),
                  
                  ListTile(
                    leading: const Icon(Icons.edit, color: AppColors.primary),
                    title: Text(lang.translate(T.strings['edit_profile']!)),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {},
                  ),
                  ListTile(
                    leading: const Icon(Icons.settings, color: AppColors.primary),
                    title: Text(lang.translate(T.strings['settings']!)),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {},
                  ),
                  ListTile(
                    leading: const Icon(Icons.language, color: AppColors.primary),
                    title: Text(lang.isTelugu ? 'English కి మార్చండి' : 'Change to Telugu (తెలుగు)'),
                    trailing: Switch(
                      value: lang.isTelugu,
                      onChanged: (v) => lang.toggleLanguage(),
                      activeThumbColor: AppColors.primary,
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.logout, color: AppColors.error),
                    title: Text(lang.translate(T.strings['logout']!), style: const TextStyle(color: AppColors.error)),
                    onTap: () async {
                      final navigator = Navigator.of(context);
                      final p = await SharedPreferences.getInstance();
                      await p.clear();
                      if (!mounted) return;
                      navigator.pushNamedAndRemoveUntil('/', (route) => false);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatColumn extends StatelessWidget {
  final String label;
  final String value;
  const _StatColumn(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.surface)),
        Text(label, style: const TextStyle(fontSize: 14, color: Colors.white70)),
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 16)),
          Expanded(
            child: Text(
              value, 
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              textAlign: TextAlign.right,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
