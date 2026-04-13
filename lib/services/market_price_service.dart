import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

class CropPrice {
  final String commodity;
  final String commodityTelugu;
  final String market;
  final String state;
  final double minPrice;
  final double maxPrice;
  final double modalPrice;
  final String variety;
  final String arrivalDate;

  CropPrice({
    required this.commodity,
    required this.commodityTelugu,
    required this.market,
    required this.state,
    required this.minPrice,
    required this.maxPrice,
    required this.modalPrice,
    required this.variety,
    required this.arrivalDate,
  });

  factory CropPrice.fromJson(Map<String, dynamic> json) {
    final name = (json['commodity'] ?? '').toString();
    return CropPrice(
      commodity: name,
      commodityTelugu: _teluguName(name),
      market: json['market'] ?? '',
      state: json['state'] ?? '',
      minPrice: double.tryParse(json['min_price']?.toString() ?? '0') ?? 0,
      maxPrice: double.tryParse(json['max_price']?.toString() ?? '0') ?? 0,
      modalPrice: double.tryParse(json['modal_price']?.toString() ?? '0') ?? 0,
      variety: json['variety'] ?? '',
      arrivalDate: json['arrival_date'] ?? '',
    );
  }

  static String _teluguName(String english) {
    const map = {
      'Rice': 'వరి',
      'Paddy': 'వరి',
      'Wheat': 'గోధుమ',
      'Maize': 'మొక్కజొన్న',
      'Cotton': 'పత్తి',
      'Tomato': 'టమాటా',
      'Onion': 'ఉల్లిపాయ',
      'Potato': 'బంగాళదుంప',
      'Chilli': 'మిరపకాయ',
      'Groundnut': 'వేరుశెనగ',
      'Soyabean': 'సోయాబీన్',
      'Turmeric': 'పసుపు',
      'Jowar': 'జొన్న',
      'Bajra': 'సజ్జ',
      'Sunflower': 'పొద్దుతిరుగుడు',
      'Sugarcane': 'చెరకు',
      'Banana': 'అరటి',
      'Mango': 'మామిడి',
      'Brinjal': 'వంకాయ',
      'Cabbage': 'క్యాబేజీ',
      'Cauliflower': 'కాలీఫ్లవర్',
      'Bitter gourd': 'కాకరకాయ',
      'Bottle gourd': 'సొరకాయ',
      'Lady finger': 'బెండకాయ',
      'Lemon': 'నిమ్మకాయ',
      'Garlic': 'వెల్లుల్లి',
      'Ginger': 'అల్లం',
      'Green gram': 'పెసలు',
      'Black gram': 'మినుమ',
      'Red gram': 'కందిపప్పు',
    };
    for (final entry in map.entries) {
      if (english.toLowerCase().contains(entry.key.toLowerCase())) {
        return entry.value;
      }
    }
    return english;
  }

  String get unit {
    final veggies = ['tomato', 'onion', 'potato', 'chilli', 'brinjal',
      'cabbage', 'cauliflower', 'bitter', 'bottle', 'lady', 'lemon', 'banana'];
    final isVeggie = veggies.any((v) => commodity.toLowerCase().contains(v));
    return isVeggie ? '/kg' : '/q';
  }

  double get displayPrice {
    final isVeggie = unit == '/kg';
    return isVeggie ? modalPrice / 100 : modalPrice;
  }
}


  static Future<List<CropPrice>> fetchPrices({
    String state = 'Andhra Pradesh',
    String? market,
    String? commodity,
    int limit = 10,
  }) async {
    final params = <String, String>{
      'api-key': apiKey,
      'format': 'json',
      'limit': limit.toString(),
      'filters[State]': state,
      if (market != null && market.isNotEmpty) 'filters[Market]': market,
      if (commodity != null && commodity.isNotEmpty)
        'filters[Commodity]': commodity,
    };

    final uri = Uri.parse(baseUrl).replace(queryParameters: params);

    try {
      final response = await http.get(uri).timeout(const Duration(seconds: 12));
      if (response.statusCode != 200) {
        throw Exception('HTTP ${response.statusCode}');
      }
      final decoded = jsonDecode(response.body) as Map<String, dynamic>;
      final records = decoded['records'] as List<dynamic>? ?? [];
      return records
          .map((r) => CropPrice.fromJson(r as Map<String, dynamic>))
          .toList();
    } on TimeoutException {
      throw Exception('Request timed out — check your connection');
    } catch (e) {
      throw Exception('Failed to fetch prices: $e');
    }
  }

  static List<String> get availableStates => [
        'Andhra Pradesh',
        'Telangana',
        'Karnataka',
        'Tamil Nadu',
        'Maharashtra',
      ];

  static List<String> marketsForState(String state) {
    final map = {
      'Andhra Pradesh': ['Guntur', 'Vijayawada', 'Kurnool', 'Tirupati', 'Nellore'],
      'Telangana': ['Hyderabad', 'Warangal', 'Nizamabad', 'Karimnagar', 'Khammam'],
      'Karnataka': ['Bangalore', 'Mysore', 'Hubli', 'Belgaum'],
      'Tamil Nadu': ['Chennai', 'Coimbatore', 'Madurai', 'Salem'],
      'Maharashtra': ['Mumbai', 'Pune', 'Nagpur', 'Nashik'],
    };
    return map[state] ?? [];
  }
}
