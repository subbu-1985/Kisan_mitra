enum VoiceIntent {
  weather,
  marketPrice,
  schemes,
  cropAdvice,
  unknown
}

class VoiceIntentService {
  static VoiceIntent determineIntent(String text) {
    final lowerText = text.toLowerCase();
    
    // Weather Intent Keywords
    if (_matches(lowerText, [
      'weather', 'rain', 'sun', 'temperature', 'forecast', 'climate', 'hot', 'cold', 'cloud', 'storm',
      'వాతావరణం', 'వర్షం', 'ఎండ', 'ఉష్ణోగ్రత', 'మబ్బులు', 'గాలి'
    ])) {
      return VoiceIntent.weather;
    }
    
    // Market Price Intent Keywords
    if (_matches(lowerText, [
      'price', 'cost', 'rate', 'value', 'mandi', 'market', 'sell', 'buy', 'bhav',
      'ధర', 'రేటు', 'ఖరీదు', 'బజార్', 'మార్కెట్', 'అమ్మకం'
    ])) {
      return VoiceIntent.marketPrice;
    }
    
    // Schemes/Subsidies Intent Keywords
    if (_matches(lowerText, [
      'scheme', 'subsidy', 'loan', 'bank', 'pm kisan', 'money', 'benefit', 'government', 'help',
      'పథకం', 'సబ్సిడీ', 'ఋణం', 'లోన్', 'డబ్బులు', 'సహాయం', 'ప్రభుత్వం'
    ])) {
      return VoiceIntent.schemes;
    }

    // Crop Advice
    if (_matches(lowerText, [
      'pest', 'disease', 'insect', 'spray', 'fertilizer', 'urea', 'growth', 'problem',
      'పురుగు', 'తెగులు', 'మందు', 'ఎరువు', 'యూరియా', 'సమస్య'
    ])) {
      return VoiceIntent.cropAdvice;
    }

    return VoiceIntent.unknown;
  }

  static bool _matches(String text, List<String> keywords) {
    for (var k in keywords) {
      if (text.contains(k)) return true;
    }
    return false;
  }

  static String extractCrop(String text) {
    final crops = {
      'rice': ['rice', 'paddy', 'వరి', 'బియ్యం'],
      'cotton': ['cotton', 'పత్తి'],
      'chilli': ['chilli', 'mirchi', 'మిర్చి', 'మిరప'],
      'tomato': ['tomato', 'టమాటా'],
      'maize': ['maize', 'corn', 'మొక్కజొన్న'],
      'onion': ['onion', 'ఉల్లి'],
    };

    final lower = text.toLowerCase();
    for (var entry in crops.entries) {
      for (var k in entry.value) {
        if (lower.contains(k)) return entry.key;
      }
    }
    return '';
  }
}
