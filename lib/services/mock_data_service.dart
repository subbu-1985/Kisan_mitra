

class MockFarmer {
  final String name;
  final String mobile;
  final String district;
  final String mandal;
  final String farmSize;
  final List<String> crops;

  MockFarmer({
    required this.name,
    required this.mobile,
    required this.district,
    required this.mandal,
    required this.farmSize,
    required this.crops,
  });

  Map<String, dynamic> toJson() => {
    'uid': 'farmer_${mobile}_mock',
    'name': name,
    'mobile': mobile,
    'state': 'Andhra Pradesh',
    'district': district,
    'mandal': mandal,
    'village': '$mandal Village',
    'farmSize': farmSize,
    'crops': crops,
    'registeredAt': '2026-01-01T10:00:00.000',
  };
}

class MockDataService {
  static List<MockFarmer> get farmers => [
    MockFarmer(name: 'Rama', mobile: '9000000001', district: 'Guntur', mandal: 'Krosuru', farmSize: '5.5', crops: ['Rice', 'Chilli']),
    MockFarmer(name: 'Baji', mobile: '9000000002', district: 'Krishna', mandal: 'Vijayawada', farmSize: '3.2', crops: ['Maize', 'Mango']),
    MockFarmer(name: 'Subbu', mobile: '9000000003', district: 'Kurnool', mandal: 'Nandyal', farmSize: '12.0', crops: ['Cotton', 'Groundnut']),
    MockFarmer(name: 'Nitish', mobile: '9000000004', district: 'Nellore', mandal: 'Kavali', farmSize: '2.5', crops: ['Paddy', 'Tobacco']),
    MockFarmer(name: 'Naveen', mobile: '9000000005', district: 'Prakasam', mandal: 'Ongole', farmSize: '8.0', crops: ['Chilli', 'Cotton']),
    MockFarmer(name: 'Sameer', mobile: '9000000006', district: 'Chittoor', mandal: 'Tirupati', farmSize: '4.5', crops: ['Tomato', 'Sugarcane']),
    MockFarmer(name: 'Yash', mobile: '9000000007', district: 'Ananthapuramu', mandal: 'Dharmavaram', farmSize: '15.0', crops: ['Groundnut', 'Banana']),
    MockFarmer(name: 'Manish', mobile: '9000000008', district: 'Visakhapatnam', mandal: 'Anakapalli', farmSize: '6.0', crops: ['Finger Millet', 'Maize']),
    MockFarmer(name: 'Noel', mobile: '9000000009', district: 'YSR Kadapa', mandal: 'Proddatur', farmSize: '2.0', crops: ['Turmeric', 'Onion']),
    MockFarmer(name: 'Chetan', mobile: '9000000010', district: 'East Godavari', mandal: 'Kakinada', farmSize: '10.5', crops: ['Paddy', 'Coconut']),
  ];
}
