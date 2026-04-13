import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../providers/language_provider.dart';
import '../utils/app_colors.dart';
import '../utils/translations.dart';

class BuySellScreen extends StatelessWidget {
  const BuySellScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);

    return Scaffold(
      appBar: AppBar(title: Text(lang.translate(T.strings['buy_sell']!))),
      body: DefaultTabController(
        length: 3,
        child: Column(
          children: [
            TabBar(
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.textSecondary,
              indicatorColor: AppColors.primary,
              tabs: [
                Tab(text: lang.translate(T.strings['buy']!)),
                Tab(text: lang.translate(T.strings['sell']!)),
                Tab(text: lang.translate(T.strings['my_listings']!)),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _BuyTab(),
                  _SellTab(),
                  const Center(child: Text("No Listings yet / ఇంకా జాబితాలు లేవు", style: TextStyle(color: AppColors.textSecondary))),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BuyTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);

    // Later: Fetch this from Firestore too! Kept mock for now until requested.
    final List<Map> listings = [
      {'crop': 'Maize (మొక్కజొన్న)', 'price': '₹400/q', 'loc': 'Tenali', 'date': 'Today', 'qty': '50 q', 'img': 'images/maize.jpeg'},
      {'crop': 'Cotton (పత్తి)', 'price': '₹6100/q', 'loc': 'Guntur', 'date': 'Yesterday', 'qty': '10 q', 'img': 'images/cotton.jpeg'},
      {'crop': 'Onion (ఉల్లిపాయ)', 'price': '₹30/kg', 'loc': 'Kurnool', 'date': '2 days ago', 'qty': '100 kg', 'img': 'images/onion.jpeg'},
    ];

    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.70,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: listings.length,
      itemBuilder: (context, i) {
        final l = listings[i];
        return Card(
          elevation: 3,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: l['img'].toString().startsWith('http') 
                  ? Image.network(l['img'], fit: BoxFit.cover, width: double.infinity)
                  : Image.asset(l['img'], fit: BoxFit.cover, width: double.infinity),
              ),
              Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l['crop'], style: const TextStyle(fontWeight: FontWeight.bold), maxLines: 1),
                    Text('${l['price']} | ${l['qty']}', style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                    Row(
                      children: [
                        const Icon(Icons.location_on, size: 12, color: AppColors.textSecondary),
                        Text(l['loc'], style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                      ],
                    ),
                    Text(l['date'], style: const TextStyle(fontSize: 10, color: Colors.grey)),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      height: 30,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(padding: EdgeInsets.zero, backgroundColor: AppColors.secondary),
                        icon: const Icon(Icons.call, size: 16),
                        label: Text(lang.isTelugu ? 'కాల్' : 'Call', style: const TextStyle(fontSize: 12)),
                        onPressed: () {},
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SellTab extends StatefulWidget {
  @override
  State<_SellTab> createState() => _SellTabState();
}

class _SellTabState extends State<_SellTab> {
  String _crop = 'Rice';
  String _unit = 'Quintal';
  
  final qtyController = TextEditingController();
  final priceController = TextEditingController();
  final locController = TextEditingController();
  final phoneController = TextEditingController();

  XFile? _imageFile;
  bool _isLoading = false;

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _imageFile = picked);
    }
  }



  Future<void> _postListing() async {
    if (_imageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select an image!')));
      return;
    }

    setState(() => _isLoading = true);

    try {
      // String imageUrl = await _uploadToCloudinary();
      // (Mocking the process for 100% Offline Mode)
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Offline Mode: Listing saved locally!")));
      
      // Reset form
      setState(() {
        _imageFile = null;
        qtyController.clear();
        priceController.clear();
        locController.clear();
        phoneController.clear();
      });

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          GestureDetector(
            onTap: _pickImage,
            child: Container(
              height: 150,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey),
              ),
              child: _imageFile != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: kIsWeb 
                          ? Image.network(_imageFile!.path, fit: BoxFit.cover)
                          : Image.file(File(_imageFile!.path), fit: BoxFit.cover),
                    )
                  : const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.camera_alt, size: 50, color: Colors.grey),
                        Text('Add Photo', style: TextStyle(color: Colors.grey)),
                      ],
                    ),
            ),
          ),
          const SizedBox(height: 20),
          DropdownButtonFormField<String>(
            initialValue: _crop,
            items: ['Rice', 'Wheat', 'Cotton', 'Maize', 'Tomato'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
            onChanged: (v) => setState(() => _crop = v!),
            decoration: InputDecoration(labelText: 'Crop', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: TextField(controller: qtyController, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: 'Quantity', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))))),
              const SizedBox(width: 16),
              Expanded(child: DropdownButtonFormField<String>(
                initialValue: _unit,
                items: ['kg', 'Quintal', 'Ton'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                onChanged: (v) => setState(() => _unit = v!),
                decoration: InputDecoration(labelText: 'Unit', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
              )),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: priceController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(labelText: 'Expected Price (₹)', prefixIcon: const Icon(Icons.currency_rupee), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: locController,
            decoration: InputDecoration(labelText: 'Location', prefixIcon: const Icon(Icons.location_on), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: phoneController,
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(labelText: 'Contact Number', prefixIcon: const Icon(Icons.phone), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _postListing,
              child: _isLoading 
                ? const CircularProgressIndicator(color: Colors.white)
                : Text(lang.translate(T.strings['post_listing']!), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}
