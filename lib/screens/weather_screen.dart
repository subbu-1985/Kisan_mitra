import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lottie/lottie.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import '../providers/language_provider.dart';
import '../utils/app_colors.dart';
import '../utils/translations.dart';
import '../services/weather_service.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  final WeatherService _weatherService = WeatherService();
  Map<String, dynamic>? _weatherData;
  bool _isLoading = true;
  String _errorMessage = '';

  String _location = '';

  @override
  void initState() {
    super.initState();
    _loadProfileAndWeather();
  }

  Future<void> _loadProfileAndWeather() async {
    await _loadProfile();
    await _fetchWeather();
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
            final data = jsonDecode(content);
            setState(() {
              _location = "${data['mandal']}, ${data['district']}";
            });
          }
        } else {
          // Web Fallback: Load from browser memory
          final profileStr = prefs.getString('profile_$mobile');
          if (profileStr != null) {
            final data = jsonDecode(profileStr);
            setState(() {
              _location = "${data['mandal']}, ${data['district']}";
            });
          }
        }
      }
    } catch (e) {
      debugPrint("Error loading profile for weather: $e");
    }
  }

  Future<void> _fetchWeather() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    try {
      final data = await _weatherService.fetchWeatherData();
      setState(() {
        _weatherData = data;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  // WMO Condition mapping with Lottie URLs
  Map<String, dynamic> _getWeatherInfo(int wmoCode) {
    if (wmoCode <= 3) return {'code': 'weather_desc_sunny', 'icon': Icons.wb_sunny, 'lottie': 'https://storage.googleapis.com/cms-storage-bucket/305a41767b0aa93f7da2.json', 'color': Colors.orange};
    if (wmoCode >= 45 && wmoCode <= 48) return {'code': 'weather_desc_fog', 'icon': Icons.foggy, 'lottie': 'https://assets5.lottiefiles.com/temp/lf20_kOsjGE.json', 'color': Colors.grey};
    if (wmoCode >= 51 && wmoCode <= 67) return {'code': 'weather_desc_rainy', 'icon': Icons.water_drop, 'lottie': 'https://assets7.lottiefiles.com/packages/lf20_b7nnuzb2.json', 'color': Colors.blue};
    if (wmoCode >= 95) return {'code': 'weather_desc_rainy', 'icon': Icons.flash_on, 'lottie': 'https://assets7.lottiefiles.com/packages/lf20_b7nnuzb2.json', 'color': Colors.deepPurple};
    return {'code': 'weather_desc_cloudy', 'icon': Icons.cloud, 'lottie': 'https://assets8.lottiefiles.com/packages/lf20_kcaa0glq.json', 'color': Colors.blueGrey};
  }

  Map<String, String> _getFarmingAlert(Map<String, dynamic> currentData) {
    if (currentData['weather_code'] >= 51) {
      return {'code': 'alert_rain', 'color': 'red', 'icon': 'warning'};
    }
    if (currentData['temperature_2m'] > 35) {
      return {'code': 'alert_heat', 'color': 'orange', 'icon': 'local_fire_department'};
    }
    if (currentData['relative_humidity_2m'] > 85) {
      return {'code': 'alert_humidity', 'color': 'orange', 'icon': 'bug_report'};
    }
    return {'code': 'alert_good', 'color': 'green', 'icon': 'check_circle'};
  }

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(lang.translate(T.strings['weather']!), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            if (_location.isNotEmpty)
              Text(_location, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w400)),
          ],
        ),
        actions: [
          IconButton(icon: const Icon(Icons.language), onPressed: () => lang.toggleLanguage()),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _fetchWeather,
        color: AppColors.primary,
        child: _isLoading 
            ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
            : _errorMessage.isNotEmpty && _weatherData == null
                ? ListView(
                    children: [
                      SizedBox(height: MediaQuery.of(context).size.height * 0.3),
                      const Icon(Icons.signal_wifi_off, size: 60, color: Colors.grey),
                      const SizedBox(height: 16),
                      Text("You are offline. Please reconnect.", textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey)),
                    ],
                  )
                : ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      _buildCurrentWeatherCard(lang),
                      const SizedBox(height: 16),
                      _buildFarmingAlertCard(lang),
                      const SizedBox(height: 24),
                      Text(
                        lang.translate(T.strings['7_day_forecast']!),
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary),
                      ),
                      const SizedBox(height: 16),
                      _build7DayForecast(lang),
                    ],
                  ),
      ),
    );
  }

  Widget _buildCurrentWeatherCard(LanguageProvider lang) {
    final current = _weatherData!['current'];
    final info = _getWeatherInfo(current['weather_code']);
    
    return Container(
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: AppColors.primary.withValues(alpha: 0.3), blurRadius: 10, offset: const Offset(0, 5))
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          SizedBox(
            height: 120,
            child: Lottie.network(
              info['lottie'],
              errorBuilder: (context, error, stackTrace) => Icon(info['icon'], size: 100, color: AppColors.secondary),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '${current['temperature_2m']}°C',
            style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: AppColors.surface, height: 1.0),
          ),
          Text(
            lang.translate(T.strings[info['code']]!),
            style: const TextStyle(fontSize: 20, color: AppColors.surface),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(child: _buildMetric(Icons.water_drop, '${current['relative_humidity_2m']}%', lang.translate(T.strings['humidity']!))),
              Expanded(child: _buildMetric(Icons.air, '${current['wind_speed_10m']} km/h', lang.translate(T.strings['wind_speed']!))),
              Expanded(child: _buildMetric(Icons.thermostat, '${current['apparent_temperature']}°C', lang.translate(T.strings['feels_like']!))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetric(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: AppColors.secondary, size: 24),
        const SizedBox(height: 8),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(value, style: const TextStyle(color: AppColors.surface, fontWeight: FontWeight.bold)),
        ),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(label, style: TextStyle(color: AppColors.surface.withValues(alpha: 0.8), fontSize: 12)),
        ),
      ],
    );
  }

  Widget _buildFarmingAlertCard(LanguageProvider lang) {
    final alertData = _getFarmingAlert(_weatherData!['current']);
    
    Color alertColor;
    IconData icon;
    if (alertData['color'] == 'red') {
      alertColor = Colors.red.shade600; icon = Icons.warning_amber_rounded;
    } else if (alertData['color'] == 'orange') {
      alertColor = Colors.orange.shade700; icon = Icons.local_fire_department;
    } else {
      alertColor = AppColors.primary; icon = Icons.check_circle_outline;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: alertColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: alertColor.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          Icon(icon, color: alertColor, size: 30),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              lang.translate(T.strings[alertData['code']]!),
              style: TextStyle(color: alertColor, fontWeight: FontWeight.w600, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _build7DayForecast(LanguageProvider lang) {
    final daily = _weatherData!['daily'];
    final timeList = daily['time'] as List;
    final maxTemp = daily['temperature_2m_max'] as List;
    final minTemp = daily['temperature_2m_min'] as List;
    final weatherCodes = daily['weather_code'] as List;

    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: timeList.length,
      itemBuilder: (context, index) {
        final date = DateTime.parse(timeList[index]);
        final dayName = DateFormat('EEEE').format(date);
        final info = _getWeatherInfo(weatherCodes[index]);

        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          elevation: 1,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            leading: Icon(info['icon'], color: info['color'], size: 30),
            title: Text(
              dayName,
              style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary),
            ),
            subtitle: Text(
              lang.translate(T.strings[info['code']]!),
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
            ),
            trailing: Text(
              '${minTemp[index].round()}° / ${maxTemp[index].round()}°C',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textPrimary),
            ),
          ),
        );
      },
    );
  }
}
