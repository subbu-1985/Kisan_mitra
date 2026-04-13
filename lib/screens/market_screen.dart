import 'dart:async';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../services/market_price_service.dart';
import '../providers/language_provider.dart';
import '../utils/app_colors.dart';
import '../utils/translations.dart';

class MarketScreen extends StatefulWidget {
  const MarketScreen({super.key});
  @override
  State<MarketScreen> createState() => _MarketScreenState();
}

class _MarketScreenState extends State<MarketScreen> {
  // ── State ────────────────────────────────────────────────────────
  List<CropPrice> _prices = [];
  bool _loading = true;
  bool _refreshing = false;
  String? _error;
  String _selectedState  = 'Andhra Pradesh';
  String _selectedMarket = '';
  Timer? _autoRefresh;
  DateTime? _lastUpdated;

  // Previous prices for change calculation (simulated delta)
  final Map<String, double> _previousPrices = {};

  final List<Map<String, dynamic>> _mockPrices = [
    {'commodity': 'Rice', 'te': 'వరి', 'market': 'Guntur', 'price': 2250, 'unit': '/q', 'trend': '+1.2%'},
    {'commodity': 'Paddy', 'te': 'వరి', 'market': 'Nellore', 'price': 2100, 'unit': '/q', 'trend': '+0.5%'},
    {'commodity': 'Maize', 'te': 'మొక్కజొన్న', 'market': 'Kurnool', 'price': 1950, 'unit': '/q', 'trend': '-0.8%'},
    {'commodity': 'Cotton', 'te': 'పత్తి', 'market': 'Adoni', 'price': 7200, 'unit': '/q', 'trend': '+2.5%'},
    {'commodity': 'Tomato', 'te': 'టమాటా', 'market': 'Madanapalle', 'price': 25, 'unit': '/kg', 'trend': '-15%'},
    {'commodity': 'Chilli', 'te': 'మిరపకాయ', 'market': 'Guntur', 'price': 18500, 'unit': '/q', 'trend': '+5.0%'},
    {'commodity': 'Onion', 'te': 'ఉల్లిపాయ', 'market': 'Kurnool', 'price': 30, 'unit': '/kg', 'trend': '+2.0%'},
    {'commodity': 'Potato', 'te': 'బంగాళదుంప', 'market': 'Vijayawada', 'price': 35, 'unit': '/kg', 'trend': '+0.0%'},
    {'commodity': 'Turmeric', 'te': 'పసుపు', 'market': 'Duggirala', 'price': 14500, 'unit': '/q', 'trend': '+3.2%'},
    {'commodity': 'Groundnut', 'te': 'వేరుశెనగ', 'market': 'Anantapur', 'price': 6500, 'unit': '/q', 'trend': '-1.5%'},
    {'commodity': 'Banana', 'te': 'అరటి', 'market': 'Kadapa', 'price': 40, 'unit': '/kg', 'trend': '+1.0%'},
    {'commodity': 'Mango', 'te': 'మామిడి', 'market': 'Nuzvid', 'price': 60, 'unit': '/kg', 'trend': '+4.5%'},
  ];

  @override
  void initState() {
    super.initState();
    _loadPrices();
    // Auto-refresh every 30 min
    _autoRefresh = Timer.periodic(
      const Duration(minutes: 30),
      (_) => _loadPrices(silent: true),
    );
  }

  @override
  void dispose() {
    _autoRefresh?.cancel();
    super.dispose();
  }

  Future<void> _loadPrices({bool silent = false}) async {
    if (!silent) {
      setState(() { _loading = true; _error = null; });
    } else {
      setState(() => _refreshing = true);
    }

    try {
      final prices = await MarketPriceService.fetchPrices(
        state: _selectedState,
        market: _selectedMarket.isEmpty ? null : _selectedMarket,
      );

      // Store previous prices before updating
      if (_prices.isNotEmpty) {
        for (final p in _prices) {
          _previousPrices[p.commodity] = p.modalPrice;
        }
      }

      setState(() {
        _prices = prices;
        _loading = false;
        _refreshing = false;
        _lastUpdated = DateTime.now();
        _error = null;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString().replaceAll('Exception: ', '');
          _loading = false;
          _refreshing = false;
        });
      }
    }
  }

  double _changePercent(CropPrice p) {
    final prev = _previousPrices[p.commodity];
    if (prev == null || prev == 0) return 0;
    return ((p.modalPrice - prev) / prev) * 100;
  }

  CropPrice? get _bestPriceCrop {
    if (_prices.isEmpty) return null;
    return _prices.reduce((a, b) => a.modalPrice > b.modalPrice ? a : b);
  }

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(lang),
      body: _loading ? _buildLoader() : _buildBody(lang),
    );
  }

  // ── AppBar ───────────────────────────────────────────────────────
  AppBar _buildAppBar(LanguageProvider lang) => AppBar(
        title: Text(
          lang.translate(T.strings['market']!),
        ),
        actions: [
          if (_refreshing)
            const Padding(
              padding: EdgeInsets.all(14),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: Colors.white),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.refresh_rounded),
              onPressed: _loadPrices,
              tooltip: 'Refresh prices',
            ),
          IconButton(
            icon: const Icon(Icons.language_rounded),
            onPressed: () => lang.toggleLanguage(),
          ),
        ],
      );

  // ── Loading ──────────────────────────────────────────────────────
  Widget _buildLoader() => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(color: AppColors.primary),
            const SizedBox(height: 16),
            const Text('ధరలు లోడ్ అవుతున్నాయి...',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
          ],
        ),
      );

  // ── Main body ────────────────────────────────────────────────────
  Widget _buildBody(LanguageProvider lang) {
    if (_prices.isEmpty && !_loading && _error == null) {
      // Fallback to Mock Prices if API returns nothing
      _prices = _mockPrices.map((m) => CropPrice(
        commodity: m['commodity'],
        commodityTelugu: m['te'],
        market: m['market'],
        state: 'Andhra Pradesh',
        minPrice: m['price'].toDouble(),
        maxPrice: m['price'].toDouble(),
        modalPrice: m['price'].toDouble(),
        variety: 'Common',
        arrivalDate: DateTime.now().toIso8601String(),
      )).toList();
    }

    return RefreshIndicator(
        color: AppColors.primary,
        onRefresh: _loadPrices,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildMarketDropdown(lang),
                    const SizedBox(height: 14),
                    _buildDateRow(),
                    const SizedBox(height: 12),
                    if (_error != null) _buildErrorBanner(),
                    if (_error == null && _bestPriceCrop != null)
                      _buildBestPriceBanner(lang),
                    const SizedBox(height: 16),
                    if (_prices.isEmpty && _error == null)
                      _buildEmptyState(lang)
                    else if (_prices.isNotEmpty)
                      _buildTableHeader(lang),
                  ],
                ),
              ),
            ),
            if (_prices.isNotEmpty)
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (ctx, i) {
                    if (i == _prices.length) return _buildFooter();
                    return _buildPriceTile(_prices[i], i, lang);
                  },
                  childCount: _prices.length + 1,
                ),
              ),
          ],
        ),
      );
  }

  // ── Market dropdown ──────────────────────────────────────────────
  Widget _buildMarketDropdown(LanguageProvider lang) {
    final markets = ['', ...MarketPriceService.marketsForState(_selectedState)];
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          // State picker
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedState,
                isExpanded: true,
                icon: const Icon(Icons.keyboard_arrow_down_rounded,
                    color: AppColors.primary),
                style: const TextStyle(
                    color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w500),
                items: MarketPriceService.availableStates
                    .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                    .toList(),
                onChanged: (v) {
                  if (v == null) return;
                  setState(() {
                    _selectedState = v;
                    _selectedMarket = '';
                  });
                  _loadPrices();
                },
              ),
            ),
          ),
          Container(width: 1, height: 28, color: AppColors.primary.withValues(alpha: 0.05)),
          const SizedBox(width: 8),
          // Market filter
          const Icon(Icons.storefront_rounded, color: AppColors.primary, size: 18),
          const SizedBox(width: 6),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: markets.contains(_selectedMarket) ? _selectedMarket : '',
                isExpanded: true,
                hint: const Text('All Markets',
                    style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                icon: const Icon(Icons.keyboard_arrow_down_rounded,
                    color: AppColors.primary),
                style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
                items: markets
                    .map((m) => DropdownMenuItem(
                          value: m,
                          child: Text(m.isEmpty ? (lang.isTelugu ? 'అన్ని మార్కెట్లు' : 'All Markets') : m),
                        ))
                    .toList(),
                onChanged: (v) {
                  setState(() => _selectedMarket = v ?? '');
                  _loadPrices();
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Date + last updated ──────────────────────────────────────────
  Widget _buildDateRow() => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            DateFormat('dd MMM yyyy').format(DateTime.now()),
            style: const TextStyle(
                fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
          ),
          if (_lastUpdated != null)
            Row(
              children: [
                const Icon(Icons.circle, color: AppColors.success, size: 8),
                const SizedBox(width: 4),
                Text(
                  'Updated ${DateFormat('hh:mm a').format(_lastUpdated!)}',
                  style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                ),
              ],
            ),
        ],
      );

  // ── Best price banner (green card) ──────────────────────────────
  Widget _buildBestPriceBanner(LanguageProvider lang) {
    final best = _bestPriceCrop!;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.trending_up_rounded,
                color: Colors.white, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(lang.isTelugu ? 'ఈరోజు ఉత్తమ ధర' : 'Today\'s Best Price',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w700)),
                const SizedBox(height: 2),
                Text(
                  '${lang.isTelugu ? best.commodityTelugu : best.commodity} — ₹${best.displayPrice.toStringAsFixed(0)}${best.unit}',
                  style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.85), fontSize: 12),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              best.market,
              style: const TextStyle(color: Colors.white, fontSize: 11),
            ),
          ),
        ],
      ),
    );
  }

  // ── Error banner ─────────────────────────────────────────────────
  Widget _buildErrorBanner() => Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.error.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.error.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            const Icon(Icons.wifi_off_rounded, color: AppColors.error, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('ధరలు లోడ్ కాలేదు',
                      style: TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 13,
                          color: AppColors.error)),
                  Text(_error ?? '',
                      style: const TextStyle(fontSize: 11, color: AppColors.error)),
                ],
              ),
            ),
            TextButton(
              onPressed: _loadPrices,
              child: const Text('Retry',
                  style: TextStyle(color: AppColors.error)),
            ),
          ],
        ),
      );

  // ── Table header ─────────────────────────────────────────────────
  Widget _buildTableHeader(LanguageProvider lang) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Row(
          children: [
            Expanded(
              flex: 3,
                child: Text(lang.isTelugu ? 'పంట' : 'Crop',
                    style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary))),
            Expanded(
              flex: 2,
              child: Text(lang.isTelugu ? 'మార్కెట్' : 'Market',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
            ),
            const SizedBox(width: 64),
            Text(lang.isTelugu ? 'మార్పు' : 'Trend',
                style: const TextStyle(
                    fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
          ],
        ),
      );

  // ── Price tile ───────────────────────────────────────────────────
  Widget _buildPriceTile(CropPrice price, int index, LanguageProvider lang) {
    final change = _changePercent(price);
    final isUp = change >= 0;
    final changeColor = change == 0
        ? AppColors.textSecondary
        : isUp
            ? AppColors.success
            : AppColors.error;
    final changeIcon = change == 0
        ? Icons.remove
        : isUp
            ? Icons.arrow_upward_rounded
            : Icons.arrow_downward_rounded;

    return Column(
      children: [
        if (index == 0)
          Divider(height: 1, color: AppColors.primary.withValues(alpha: 0.1), thickness: 1),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: InkWell(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => PriceHistoryScreen(crop: price))),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Crop name + price
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        lang.isTelugu ? price.commodityTelugu : price.commodity,
                        style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '₹${price.displayPrice.toStringAsFixed(0)}${price.unit}',
                        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                // Market name
                Expanded(
                  flex: 2,
                  child: Text(
                    price.market,
                    style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                // Change %
                SizedBox(
                  width: 64,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Icon(changeIcon, color: changeColor, size: 14),
                      const SizedBox(width: 2),
                      Text(
                        change == 0
                            ? '—'
                            : '${isUp ? '+' : ''}${change.toStringAsFixed(1)}%',
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: changeColor),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        Divider(height: 1, color: AppColors.primary.withValues(alpha: 0.1), thickness: 1),
      ],
    );
  }

  // ── Empty state ──────────────────────────────────────────────────
  Widget _buildEmptyState(LanguageProvider lang) => Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 40),
          child: Column(
            children: [
              const Icon(Icons.info_outline_rounded, size: 48, color: AppColors.textSecondary),
              const SizedBox(height: 12),
              Text(
                lang.isTelugu 
                  ? ( _selectedMarket.isEmpty ? 'ధరలు ఏవీ అందుబాటులో లేవు' : 'ఈ మార్కెట్లో ధరలు ఇంకా అప్డేట్ కాలేదు')
                  : (_selectedMarket.isEmpty ? 'No price updates available' : 'This market hasn\'t reported prices yet'),
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)
              ),
              const SizedBox(height: 8),
              if (_selectedMarket.isNotEmpty)
                Text(
                  lang.isTelugu ? 'గుంటూరు లేదా అన్ని మార్కెట్లను ప్రయత్నించండి' : 'Try "All Markets" or "Guntur" mandi',
                  style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
                ),
              const SizedBox(height: 20),
              if (_selectedMarket.isNotEmpty)
                ElevatedButton(
                  onPressed: () { setState(() => _selectedMarket = ''); _loadPrices(); },
                  child: Text(lang.isTelugu ? 'అన్ని మార్కెట్లను చూడండి' : 'Show All Markets'),
                )
            ],
          ),
        ),
      );

  // ── Footer ───────────────────────────────────────────────────────
  Widget _buildFooter() => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text(
              'డేటా: Agmarknet / data.gov.in',
              style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 4),
            Text(
              'Sample key: max 10 records. Generate your key at data.gov.in for full data.',
              style: TextStyle(fontSize: 10, color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
          ],
        ),
      );
}

class PriceHistoryScreen extends StatelessWidget {
  final CropPrice crop;
  const PriceHistoryScreen({super.key, required this.crop});

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text('${lang.isTelugu ? crop.commodityTelugu : crop.commodity} - 7 Day History'),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              '${lang.isTelugu ? 'ధరల ధోరణి - ' : 'Price Trend for '} ${lang.isTelugu ? crop.commodityTelugu : crop.commodity}', 
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)
            ),
            const SizedBox(height: 40),
            Expanded(
              child: Container(
                padding: const EdgeInsets.only(right: 20, top: 20),
                child: LineChart(
                  LineChartData(
                    gridData: const FlGridData(show: true, drawVerticalLine: false),
                    titlesData: FlTitlesData(
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true, 
                          getTitlesWidget: (v, meta) => Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text('Day ${v.toInt()}', style: const TextStyle(fontSize: 10)),
                          )
                        ),
                      ),
                      leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    ),
                    borderData: FlBorderData(show: true, border: Border.all(color: AppColors.primary.withValues(alpha: 0.1))),
                    lineBarsData: [
                      LineChartBarData(
                        spots: const [
                          FlSpot(1, 10), FlSpot(2, 12), FlSpot(3, 11), FlSpot(4, 15), FlSpot(5, 14), FlSpot(6, 18), FlSpot(7, 20),
                        ],
                        isCurved: true,
                        color: AppColors.primary,
                        barWidth: 4,
                        isStrokeCapRound: true,
                        dotData: const FlDotData(show: true),
                        belowBarData: BarAreaData(show: true, color: AppColors.primary.withValues(alpha: 0.2)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
