import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/language_provider.dart';
import '../utils/app_colors.dart';
import '../utils/translations.dart';

class SchemesScreen extends StatefulWidget {
  const SchemesScreen({super.key});

  @override
  State<SchemesScreen> createState() => _SchemesScreenState();
}

class _SchemesScreenState extends State<SchemesScreen> {
  String _filter = 'All';

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);

    final List<Map<String, dynamic>> schemes = [
      {'en': 'PM-KISAN', 'te': 'పీఎం-కిసాన్', 'desc': '₹6,000/year direct benefit', 'type': 'Central', 'btn': 'check_status', 'icon': Icons.account_balance},
      {'en': 'eNAM', 'te': 'eNAM (ఈ-నామ్)', 'desc': 'Online crop selling platform', 'type': 'Central', 'btn': 'register', 'icon': Icons.storefront},
      {'en': 'PMFBY', 'te': 'పీఎంఎఫ్‌బీవై', 'desc': 'Crop insurance scheme', 'type': 'Central', 'btn': 'apply', 'icon': Icons.health_and_safety},
      {'en': 'Rythu Bandhu', 'te': 'రైతు బంధు', 'desc': '₹5,000/acre investment support', 'type': 'State AP', 'btn': 'check_eligibility', 'icon': Icons.grass},
      {'en': 'Kisan Credit Card', 'te': 'కిసాన్ క్రెడిట్ కార్డ్', 'desc': 'Low-interest farm loans', 'type': 'Central', 'btn': 'apply', 'icon': Icons.credit_card},
      {'en': 'Soil Health Card', 'te': 'సాయిల్ హెల్త్ కార్డ్', 'desc': 'Free soil testing', 'type': 'State AP', 'btn': 'book_slot', 'icon': Icons.science},
    ];

    return Scaffold(
      appBar: AppBar(title: Text(lang.translate(T.strings['schemes']!))),
      body: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.all(12),
            child: Row(
              children: ['All', 'Central', 'State AP'].map((f) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Text(f),
                  selected: _filter == f,
                  onSelected: (val) => setState(() => _filter = f),
                ),
              )).toList(),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: schemes.length,
              itemBuilder: (context, i) {
                final s = schemes[i];
                if (_filter != 'All' && s['type'] != _filter) return const SizedBox.shrink();
                
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(backgroundColor: AppColors.primary.withValues(alpha: 0.1), child: Icon(s['icon'], color: AppColors.primary)),
                            const SizedBox(width: 12),
                            Expanded(child: Text(lang.isTelugu ? s['te'] : s['en'], style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
                            IconButton(icon: const Icon(Icons.share, color: Colors.green), onPressed: () {}), // WhatsApp Share Placeholder
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(s['desc'], style: const TextStyle(color: AppColors.textSecondary)),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Expanded(child: Text('Eligibility: Farmers', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              onPressed: () {},
                              style: ElevatedButton.styleFrom(backgroundColor: AppColors.secondary),
                              child: Text(lang.translate(T.strings[s['btn']]!), style: const TextStyle(color: AppColors.surface)),
                            ),
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
