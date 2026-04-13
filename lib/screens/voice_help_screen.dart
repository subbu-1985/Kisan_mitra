import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../providers/language_provider.dart';
import '../utils/app_colors.dart';
import '../utils/translations.dart';
import '../services/voice_intent_service.dart';
import '../services/weather_service.dart';
import '../services/market_price_service.dart';

class VoiceHelpScreen extends StatefulWidget {
  const VoiceHelpScreen({super.key});

  @override
  State<VoiceHelpScreen> createState() => _VoiceHelpScreenState();
}

class _VoiceHelpScreenState extends State<VoiceHelpScreen> with SingleTickerProviderStateMixin {
  late FlutterTts flutterTts;
  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _transcript = '';
  late AnimationController _pulseController;
  
  final WeatherService _weatherService = WeatherService();
  List<Map<String, String>> history = [];

  @override
  void initState() {
    super.initState();
    flutterTts = FlutterTts();
    _speech = stt.SpeechToText();
    _pulseController = AnimationController(vsync: this, duration: const Duration(seconds: 1))..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    flutterTts.stop();
    super.dispose();
  }

  void _listenAndRespond(LanguageProvider lang) async {
    // Check if permissions/availability
    try {
      if (!_isListening) {
        bool available = await _speech.initialize(
          onStatus: (val) {
            if (val == 'done' || val == 'notListening') {
              setState(() => _isListening = false);
              if (_transcript.isNotEmpty && _transcript != 'Listening...' && _transcript != 'వింటున్నాను...') {
                _processCommand(_transcript, lang);
              }
            }
          },
          onError: (val) => setState(() => _isListening = false),
        );
        
        if (available) {
          setState(() {
            _isListening = true;
            _transcript = lang.isTelugu ? 'వింటున్నాను...' : 'Listening...';
          });
          _speech.listen(
            localeId: lang.isTelugu ? 'te_IN' : 'en_US',
            onResult: (val) => setState(() => _transcript = val.recognizedWords),
          );
        }
      } else {
        setState(() => _isListening = false);
        _speech.stop();
      }
    } catch (e) {
      debugPrint("Speech Error: $e");
    }
  }

  Future<void> _processCommand(String text, LanguageProvider lang) async {
    if (text.isEmpty || text == 'Listening...' || text == 'వింటున్నాను...') return;

    final intent = VoiceIntentService.determineIntent(text);
    String response = "";

    try {
      switch (intent) {
        case VoiceIntent.weather:
          final weather = await _weatherService.fetchWeatherData();
          final temp = weather['current']['temperature_2m'];
          final code = weather['current']['weather_code'];
          final condition = code == 0 ? 'Sunny' : 'Partly Cloudy';
          
          if (lang.isTelugu) {
            response = "ప్రస్తుతం ఉష్ణోగ్రత ${temp.toStringAsFixed(1)}°C గా ఉంది. వాతావరణం సాధారణంగా ఉంది.";
          } else {
            response = "The current temperature is ${temp.toStringAsFixed(1)}°C. The sky is $condition.";
          }
          break;

        case VoiceIntent.marketPrice:
          final cropName = VoiceIntentService.extractCrop(text);
          final prices = await MarketPriceService.fetchPrices(state: 'Andhra Pradesh');
          
          if (cropName.isNotEmpty && prices.isNotEmpty) {
            final match = prices.firstWhere(
              (p) => p.commodity.toLowerCase().contains(cropName), 
              orElse: () => prices.first
            );
            if (lang.isTelugu) {
              response = "${match.commodityTelugu} ధర ${match.market} లో ₹${match.modalPrice} గా ఉంది.";
            } else {
              response = "The price of ${match.commodity} in ${match.market} is ₹${match.modalPrice} per quintal.";
            }
          } else {
            response = lang.isTelugu 
              ? "మార్కెట్ ధరలు ప్రస్తుతం అందుబాటులో లేవు." 
              : "Market prices are not available at the moment.";
          }
          break;

        case VoiceIntent.schemes:
          response = lang.isTelugu
            ? "ప్రభుత్వ పథకాల గురించి సమాచారం కోసం 'కిసాన్ భరోసా' యాప్ సెక్షన్‌ని చూడవచ్చు. ప్రస్తుతానికి PM కిసాన్ చెల్లింపులు జరుగుతున్నాయి."
            : "Under PM Kisan Scheme, the next installment is being processed. Visit the schemes section for details.";
          break;

        case VoiceIntent.cropAdvice:
          response = lang.isTelugu
            ? "మీ పంటకు పురుగు తెగులు ఆశిస్తే, నిపుణుల సలహా కోసం ఫోటో తీసి 'పంట సమస్య' విభాగంలో అప్‌లోడ్ చేయండి."
            : "If your crop is facing a pest problem, please upload a photo in the 'Crop Help' section for expert advice.";
          break;

        case VoiceIntent.unknown:
          response = lang.isTelugu
            ? "క్షమించండి, నాకు అర్థం కాలేదు. వాతావరణం లేదా పంట ధరల గురించి అడగండి."
            : "I'm sorry, I didn't catch that. Try asking about weather or crop prices.";
          break;
      }
    } catch (e) {
      response = "Error processing: $e";
    }

    setState(() {
      history.insert(0, {'q': '"$text?"', 'a': response});
    });

    await flutterTts.setLanguage(lang.isTelugu ? 'te-IN' : 'en-IN');
    await flutterTts.speak(response);
  }

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);

    return Scaffold(
      appBar: AppBar(title: Text(lang.translate(T.strings['voice_help']!))),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(40),
            width: double.infinity,
            color: AppColors.background,
            child: Column(
              children: [
                Text(lang.translate(T.strings['tap_speak']!), style: const TextStyle(fontSize: 18, color: AppColors.textPrimary)),
                const SizedBox(height: 30),
                GestureDetector(
                  onTap: () => _listenAndRespond(lang),
                  child: AnimatedBuilder(
                    animation: _pulseController,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _isListening ? 1.0 + (_pulseController.value * 0.2) : 1.0,
                        child: Container(
                          padding: const EdgeInsets.all(30),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _isListening ? AppColors.error : AppColors.primary,
                            boxShadow: [
                              BoxShadow(color: (_isListening ? AppColors.error : AppColors.primary).withValues(alpha: 0.5), blurRadius: 20, spreadRadius: _isListening ? 10 : 0)
                            ]
                          ),
                          child: const Icon(Icons.mic, size: 60, color: AppColors.surface),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 30),
                Text(_transcript, style: const TextStyle(fontSize: 18, fontStyle: FontStyle.italic)),
              ],
            ),
          ),
          const Divider(thickness: 2),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: history.length,
              itemBuilder: (context, i) {
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.person, color: AppColors.secondary, size: 20),
                            const SizedBox(width: 8),
                            Expanded(child: Text(history[i]['q']!, style: const TextStyle(fontWeight: FontWeight.bold))),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.support_agent, color: AppColors.primary, size: 20),
                            const SizedBox(width: 8),
                            Expanded(child: Text(history[i]['a']!, style: const TextStyle(color: AppColors.textSecondary))),
                            IconButton(icon: const Icon(Icons.volume_up, size: 20, color: AppColors.primary), onPressed: () async {
                              await flutterTts.setLanguage(lang.isTelugu ? 'te-IN' : 'en-IN');
                              await flutterTts.speak(history[i]['a']!);
                            })
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
