// Rebuild trigger
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
import 'main_screen.dart';

class RegistrationScreen extends StatefulWidget {
  final String? initialMobile;
  const RegistrationScreen({super.key, this.initialMobile});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Personal Info
  late final TextEditingController _nameController;
  late final TextEditingController _mobileController;
  final _emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _mobileController = TextEditingController(text: widget.initialMobile);
  }
  DateTime? _selectedDOB;
  
  // Location
  String _selectedState = 'Andhra Pradesh';
  String _selectedDistrict = 'Guntur';
  final _mandalController = TextEditingController();
  final _villageController = TextEditingController();
  final _pinController = TextEditingController();
  
  // Farm Details
  final _farmSizeController = TextEditingController();
  String _farmUnit = 'Acres';
  String _landType = 'Own Land';
  final List<String> _selectedCrops = [];
  String _waterSource = 'Bore Well';
  String _farmerCategory = 'Marginal';
  
  // Other Info
  String _preferredLanguage = 'English';
  bool _smsConsent = false;
  bool _whatsappConsent = false;
  
  int _currentStep = 0;
  bool _isLoading = false;

  final List<String> _allCrops = ['Rice', 'Wheat', 'Cotton', 'Maize', 'Tomato', 'Groundnut', 'Sugarcane', 'Chili'];
  final List<String> _states = ['Andhra Pradesh', 'Telangana', 'Karnataka', 'Tamil Nadu'];
  final List<String> _districts = [
    'Alluri Sitharama Raju',
    'Anakapalli',
    'Ananthapuramu',
    'Annamayya',
    'Bapatla',
    'Chittoor',
    'East Godavari',
    'Eluru',
    'Guntur',
    'Kakinada',
    'Konaseema',
    'Krishna',
    'Kurnool',
    'Nandyal',
    'NTR',
    'Palnadu',
    'Parvathipuram Manyam',
    'Prakasam',
    'SPSR Nellore',
    'Sri Sathya Sai',
    'Srikakulam',
    'Tirupati',
    'Visakhapatnam',
    'Vizianagaram',
    'West Godavari',
    'YSR Kadapa'
  ];

  Future<void> _registerFarmer(LanguageProvider lang) async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final String mobile = _mobileController.text.trim();
      final String uid = 'farmer_${mobile}_${DateTime.now().millisecondsSinceEpoch}';
      
      final Map<String, dynamic> data = {
        'uid': uid,
        // Personal Info
        'name': _nameController.text.trim(),
        'mobile': _mobileController.text.trim(),
        'email': _emailController.text.trim(),
        'dob': _selectedDOB?.toIso8601String(),
        // Location
        'state': _selectedState,
        'district': _selectedDistrict,
        'mandal': _mandalController.text.trim(),
        'village': _villageController.text.trim(),
        'pin': _pinController.text.trim(),
        // Farm Details
        'farmSize': _farmSizeController.text.trim(),
        'farmUnit': _farmUnit,
        'landType': _landType,
        'crops': _selectedCrops,
        'waterSource': _waterSource,
        'farmerCategory': _farmerCategory,
        // Other Info
        'language': _preferredLanguage,
        'smsConsent': _smsConsent,
        'whatsappConsent': _whatsappConsent,
        'registeredAt': DateTime.now().toIso8601String(),
      };

      // Cloud Sync removed for strict offline-first performance
      /*
      try {
        if (Firebase.apps.isEmpty) throw Exception('No Web Config');
        await FirebaseFirestore.instance.collection('farmers').doc(uid).set(data);
      } catch (e) {
        debugPrint("Cloud sync skipped: Offline mode active.");
      }
      */

      final mobileVal = _mobileController.text.trim();
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('current_mobile', mobileVal);

      if (!kIsWeb) {
        final directory = await getApplicationDocumentsDirectory();
        final file = File('${directory.path}/farmer_$mobileVal.json');
        await file.writeAsString(jsonEncode(data));
        debugPrint("Farmer profile saved to File: ${file.path}");
      } else {
        // Save to browser's LocalStorage for web testing
        await prefs.setString('profile_$mobileVal', jsonEncode(data));
        debugPrint("Farmer profile saved to Browser Storage.");
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(lang.isTelugu ? 'నమోదు పూర్తయింది!' : 'Registration Successful!'),
          backgroundColor: AppColors.success,
        ));
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const MainScreen()));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error),
        );
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    final steps = [
      _buildPersonalInfoStep(lang),
      _buildLocationStep(lang),
      _buildFarmDetailsStep(lang),
      _buildOtherInfoStep(lang),
    ];

    return PopScope(
      canPop: _currentStep == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (_currentStep > 0) {
          setState(() => _currentStep--);
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // Progress Bar
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: List.generate(4, (index) {
                          return Expanded(
                            child: Container(
                              height: 6,
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              decoration: BoxDecoration(
                                color: index <= _currentStep ? AppColors.primary : AppColors.primary.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        lang.isTelugu 
                          ? 'దశ ${_currentStep + 1} / 4'
                          : 'Step ${_currentStep + 1} of 4',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),

                // Step Content
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    child: steps[_currentStep],
                  ),
                ),

                // Navigation Buttons
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      if (_currentStep > 0)
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => setState(() => _currentStep--),
                            style: OutlinedButton.styleFrom(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              side: const BorderSide(color: AppColors.primary, width: 2),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: Text(
                              lang.isTelugu ? 'వెనుక' : 'Back',
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primary),
                            ),
                          ),
                        ),
                      if (_currentStep > 0) const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : () {
                            if (_currentStep < steps.length - 1) {
                              setState(() => _currentStep++);
                            } else {
                              _registerFarmer(lang);
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            elevation: 4,
                          ),
                          child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: AppColors.surface,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                _currentStep == steps.length - 1
                                  ? (lang.isTelugu ? 'నమోదు చేయండి' : 'Register')
                                  : (lang.isTelugu ? 'తదుపరి' : 'Next'),
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.surface),
                              ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPersonalInfoStep(LanguageProvider lang) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildStepTitle(lang.isTelugu ? 'వ్యక్తిగత సమాచారం' : 'Personal Information'),
        const SizedBox(height: 24),
        _buildTextField(
          controller: _nameController,
          label: lang.translate(T.strings['name']!),
          icon: Icons.person_rounded,
          validator: (val) => val?.isEmpty == true ? 'Required' : null,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _mobileController,
          label: lang.isTelugu ? 'మొబైల్ నంబర్' : 'Mobile Number',
          icon: Icons.phone,
          inputType: TextInputType.phone,
          maxLength: 10,
          validator: (val) => val?.length != 10 ? 'Enter valid 10-digit number' : null,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _emailController,
          label: lang.isTelugu ? 'ఇమెయిల్' : 'Email Address',
          icon: Icons.email,
          inputType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 16),
        GestureDetector(
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: _selectedDOB ?? DateTime(2000),
              firstDate: DateTime(1950),
              lastDate: DateTime.now(),
            );
            if (date != null) setState(() => _selectedDOB = date);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today, color: AppColors.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _selectedDOB != null
                      ? '${_selectedDOB!.day}/${_selectedDOB!.month}/${_selectedDOB!.year}'
                      : (lang.isTelugu ? 'పుట్టిన తేదీ' : 'Date of Birth'),
                    style: TextStyle(
                      color: _selectedDOB != null ? AppColors.textPrimary : AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLocationStep(LanguageProvider lang) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildStepTitle(lang.isTelugu ? 'స్థానం వివరాలు' : 'Location Details'),
        const SizedBox(height: 24),
        _buildDropdown(
          label: lang.isTelugu ? 'రాష్ట్రం' : 'State',
          value: _selectedState,
          items: _states,
          onChanged: (val) => setState(() => _selectedState = val!),
          icon: Icons.location_city,
        ),
        const SizedBox(height: 16),
        _buildDropdown(
          label: lang.isTelugu ? 'జిల్లా' : 'District',
          value: _selectedDistrict,
          items: _districts,
          onChanged: (val) => setState(() => _selectedDistrict = val!),
          icon: Icons.map,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _mandalController,
          label: lang.isTelugu ? 'మండలం' : 'Mandal/Taluk',
          icon: Icons.public,
          validator: (val) => val?.isEmpty == true ? 'Required' : null,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _villageController,
          label: lang.isTelugu ? 'గ్రామం' : 'Village/City',
          icon: Icons.home,
          validator: (val) => val?.isEmpty == true ? 'Required' : null,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _pinController,
          label: lang.isTelugu ? 'పిన్ కోడ్' : 'PIN Code',
          icon: Icons.mail,
          inputType: TextInputType.number,
          maxLength: 6,
          validator: (val) => val?.length != 6 ? 'Enter valid 6-digit PIN' : null,
        ),
      ],
    );
  }

  Widget _buildFarmDetailsStep(LanguageProvider lang) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildStepTitle(lang.isTelugu ? 'వ్యవసాయ వివరాలు' : 'Farm Details'),
        const SizedBox(height: 24),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 2,
              child: _buildTextField(
                controller: _farmSizeController,
                label: lang.isTelugu ? 'పొలం పరిమాణం' : 'Farm Size',
                icon: Icons.landscape,
                inputType: TextInputType.number,
                validator: (val) => val?.isEmpty == true ? 'Required' : null,
              ),
            ),
            const SizedBox(width: 8), // Reduced gap
            Expanded(
              flex: 1,
              child: _buildDropdown(
                label: lang.isTelugu ? 'యూనిట్' : 'Unit',
                value: _farmUnit,
                items: ['Acres', 'Hectares', 'Guntha', 'Bigha'],
                onChanged: (val) => setState(() => _farmUnit = val!),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildDropdown(
          label: lang.isTelugu ? 'భూమి రకం' : 'Land Type',
          value: _landType,
          items: ['Own Land', 'Leased Land', 'Shared'],
          onChanged: (val) => setState(() => _landType = val!),
          icon: Icons.terrain,
        ),
        const SizedBox(height: 16),
        _buildStepTitle(lang.isTelugu ? 'ప్రధాన పంటలు' : 'Primary Crops', isSubtitle: true),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _allCrops.map((crop) {
            final isSelected = _selectedCrops.contains(crop);
            return FilterChip(
              selected: isSelected,
              label: Text(crop),
              backgroundColor: AppColors.surface,
              selectedColor: AppColors.primary.withValues(alpha: 0.3),
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _selectedCrops.add(crop);
                  } else {
                    _selectedCrops.remove(crop);
                  }
                });
              },
            );
          }).toList(),
        ),
        const SizedBox(height: 24),
        _buildDropdown(
          label: lang.isTelugu ? 'నీటి వనరు' : 'Water Source',
          value: _waterSource,
          items: ['Bore Well', 'Canal', 'Tube Well', 'Rainfall'],
          onChanged: (val) => setState(() => _waterSource = val!),
          icon: Icons.water_drop,
        ),
        const SizedBox(height: 16),
        _buildDropdown(
          label: lang.isTelugu ? 'రైతు వర్గం' : 'Farmer Category',
          value: _farmerCategory,
          items: ['Marginal', 'Small', 'Medium', 'Large'],
          onChanged: (val) => setState(() => _farmerCategory = val!),
          icon: Icons.person_outline,
        ),
      ],
    );
  }

  Widget _buildOtherInfoStep(LanguageProvider lang) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildStepTitle(lang.isTelugu ? 'ఇతర సమాచారం' : 'Other Information'),
        const SizedBox(height: 24),
        _buildStepTitle(lang.isTelugu ? 'ప్రాధాన్యతలు' : 'Preferences', isSubtitle: true),
        const SizedBox(height: 12),
        _buildDropdown(
          label: lang.isTelugu ? 'ఇష్టమైన భాష' : 'Preferred Language',
          value: _preferredLanguage,
          items: ['English', 'Telugu', 'Hindi'],
          onChanged: (val) => setState(() => _preferredLanguage = val!),
          icon: Icons.language,
        ),
        const SizedBox(height: 24),
        _buildStepTitle(lang.isTelugu ? 'సమ్మతి' : 'Consent', isSubtitle: true),
        const SizedBox(height: 12),
        CheckboxListTile(
          value: _smsConsent,
          onChanged: (val) => setState(() => _smsConsent = val ?? false),
          title: Text(lang.isTelugu ? 'SMS నోటిఫికేషన్‌లను స్వీకరించండి' : 'Receive SMS notifications'),
          activeColor: AppColors.primary,
          controlAffinity: ListTileControlAffinity.leading,
        ),
        const SizedBox(height: 8),
        CheckboxListTile(
          value: _whatsappConsent,
          onChanged: (val) => setState(() => _whatsappConsent = val ?? false),
          title: Text(lang.isTelugu ? 'WhatsApp నోటిఫికేషన్‌లను స్వీకరించండి' : 'Receive WhatsApp updates'),
          activeColor: AppColors.primary,
          controlAffinity: ListTileControlAffinity.leading,
        ),
      ],
    );
  }

  Widget _buildStepTitle(String title, {bool isSubtitle = false}) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
        fontWeight: isSubtitle ? FontWeight.w600 : FontWeight.bold,
        fontSize: isSubtitle ? 14 : 18,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType inputType = TextInputType.text,
    int? maxLength,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: inputType,
        maxLength: maxLength,
        validator: validator,
        decoration: InputDecoration(
          border: InputBorder.none,
          prefixIcon: Icon(icon, color: AppColors.primary),
          labelText: label,
          contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
          counterText: '',
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String value,
    required List<String> items,
    required Function(String?) onChanged,
    IconData? icon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: DropdownButtonFormField<String>(
        initialValue: value,
        decoration: InputDecoration(
          border: InputBorder.none,
          prefixIcon: icon != null ? Icon(icon, color: AppColors.primary) : null,
          labelText: label,
          contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
        ),
        isExpanded: true,
        items: items.map((item) => DropdownMenuItem(value: item, child: Text(item, style: const TextStyle(fontSize: 14)))).toList(),
        onChanged: onChanged,
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _mobileController.dispose();
    _emailController.dispose();
    _mandalController.dispose();
    _villageController.dispose();
    _pinController.dispose();
    _farmSizeController.dispose();
    super.dispose();
  }
}
