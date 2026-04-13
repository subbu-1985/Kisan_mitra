import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/language_provider.dart';
import '../utils/app_colors.dart';
import '../utils/translations.dart';

class CropsScreen extends StatefulWidget {
  const CropsScreen({super.key});

  @override
  State<CropsScreen> createState() => _CropsScreenState();
}

class _CropsScreenState extends State<CropsScreen> {
  String _selectedFilter = 'all';

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);

    final List<Map<String, dynamic>> crops = [
      {'en': 'Rice', 'te': 'వరి', 'duration': '120-140', 'water': 'High', 'season': 'Kharif', 'type': 'cereal', 'img': 'images/rice.jpeg'},
      {'en': 'Wheat', 'te': 'గోధుమ', 'duration': '110-130', 'water': 'Medium', 'season': 'Rabi', 'type': 'cereal', 'img': 'images/wheat.jpeg'},
      {'en': 'Maize', 'te': 'మొక్కజొన్న', 'duration': '80-110', 'water': 'Medium', 'season': 'Kharif', 'type': 'cereal', 'img': 'images/maize.jpeg'},
      {'en': 'Cotton', 'te': 'పత్తి', 'duration': '150-180', 'water': 'Medium', 'season': 'Kharif', 'type': 'cash', 'img': 'images/cotton.jpeg'},
      {'en': 'Tomato', 'te': 'టమాటా', 'duration': '60-85', 'water': 'High', 'season': 'All', 'type': 'vegetables', 'img': 'images/tomato.jpg'},
      {'en': 'Chilli', 'te': 'మిరపకాయ', 'duration': '90-120', 'water': 'Medium', 'season': 'Kharif', 'type': 'spices', 'img': 'images/chilli.jpg'},
      {'en': 'Onion', 'te': 'ఉల్లిపాయ', 'duration': '100-120', 'water': 'Medium', 'season': 'Rabi', 'type': 'vegetables', 'img': 'images/onion.jpeg'},
      {'en': 'Potato', 'te': 'బంగాళదుంప', 'duration': '90-110', 'water': 'Medium', 'season': 'Rabi', 'type': 'vegetables', 'img': 'images/potato.jpeg'},
      {'en': 'Mango', 'te': 'మామిడి', 'duration': 'Perennial', 'water': 'Medium', 'season': 'Summer', 'type': 'fruits', 'img': 'images/mango.jpeg'},
      {'en': 'Turmeric', 'te': 'పసుపు', 'duration': '240-300', 'water': 'High', 'season': 'Kharif', 'type': 'spices', 'img': 'images/turmeric.jpeg'},
    ];

    final filters = ['all', 'kharif', 'rabi', 'vegetables', 'fruits', 'spices'];

    final filteredCrops = crops.where((c) {
      if (_selectedFilter == 'all') return true;
      if (_selectedFilter == 'kharif') return (c['season'] as String).toLowerCase() == 'kharif';
      if (_selectedFilter == 'rabi') return (c['season'] as String).toLowerCase() == 'rabi';
      if (_selectedFilter == 'vegetables') return c['type'] == 'vegetables';
      if (_selectedFilter == 'fruits') return c['type'] == 'fruits';
      if (_selectedFilter == 'spices') return c['type'] == 'spices';
      return false;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(lang.translate(T.strings['crop_info']!)),
        actions: [
          IconButton(icon: const Icon(Icons.language), onPressed: () => lang.toggleLanguage()),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              decoration: InputDecoration(
                hintText: lang.translate(T.strings['search_crops']!),
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: filters.map((f) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Text(lang.translate(T.strings[f] ?? {'en': f, 'te': f})),
                  selected: _selectedFilter == f,
                  onSelected: (val) => setState(() => _selectedFilter = f),
                ),
              )).toList(),
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(12),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.75,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: filteredCrops.length,
              itemBuilder: (context, i) {
                final c = filteredCrops[i];
                return GestureDetector(
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => CropDetailScreen(crop: c))),
                  child: Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    clipBehavior: Clip.antiAlias,
                    elevation: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: c['img'].toString().startsWith('http')
                              ? Image.network(c['img'], fit: BoxFit.cover, width: double.infinity)
                              : Image.asset(c['img'], fit: BoxFit.cover, width: double.infinity),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(lang.isTelugu ? c['te'] : c['en'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              Text('${c['duration']} days | ${c['season']}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                              Container(
                                margin: const EdgeInsets.only(top: 4),
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(4)),
                                child: Text('Water: ${c['water']}', style: const TextStyle(fontSize: 10, color: AppColors.primary, fontWeight: FontWeight.bold)),
                              )
                            ],
                          ),
                        )
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

class CropDetailScreen extends StatelessWidget {
  final Map<String, dynamic> crop;
  const CropDetailScreen({super.key, required this.crop});

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);

    return Scaffold(
      appBar: AppBar(title: Text(lang.isTelugu ? crop['te'] : crop['en'])),
      body: SingleChildScrollView(
        child: Column(
          children: [
            crop['img'].toString().startsWith('http')
                ? Image.network(crop['img'], height: 200, width: double.infinity, fit: BoxFit.cover)
                : Image.asset(crop['img'], height: 200, width: double.infinity, fit: BoxFit.cover),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    lang.isTelugu ? crop['te'] : crop['en'],
                    style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.primary),
                  ),
                  const SizedBox(height: 10),
                  Text(lang.isTelugu 
                    ? 'ఇది చాలా ముఖ్యమైన పంట. అనుకూలమైన నేల మరియు ఎరువుల వివరణ ఇక్కడ ఉంటుంది.'
                    : 'This is a very important crop. Favorable soil and fertilizer details go here.'),
                  const SizedBox(height: 20),
                  const Text('Soil Type: Loamy, Clay', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  const Text('MSP: ₹2,100 / quintal', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.secondary)),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.add),
                      label: Text(lang.translate(T.strings['add_my_crops']!)),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Added to my crops')));
                      },
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
