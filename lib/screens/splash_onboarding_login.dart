import 'dart:convert';
import 'package:flutter/material.dart';
import 'dart:math';
import 'package:provider/provider.dart';
import '../providers/language_provider.dart';
import '../utils/app_colors.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
// Rebuild trigger
import 'dart:io';
import 'main_screen.dart';
import 'registration_screen.dart';
import '../services/mock_data_service.dart';

// ══════════════════════════════════════════════════════════════
//  SPLASH SCREEN  — mirrors the screenshot layout exactly
// ══════════════════════════════════════════════════════════════
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeCtrl;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200));
    _fade = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeIn);
    _fadeCtrl.forward();

    _handleStartupNavigation();
  }

  Future<void> _handleStartupNavigation() async {
    await Future.delayed(const Duration(seconds: 4));
    if (!mounted) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final mobile = prefs.getString('current_mobile');

      if (mobile != null && !kIsWeb) {
        final directory = await getApplicationDocumentsDirectory();
        final file = File('${directory.path}/farmer_$mobile.json');

        if (await file.exists()) {
          // Profile exists, skip login
          if (mounted) {
            Navigator.pushReplacement(
              context, 
              MaterialPageRoute(builder: (_) => const MainScreen())
            );
            return;
          }
        }
      }
    } catch (e) {
      debugPrint("Startup check error: $e");
    }

    // Default to Login Screen if no profile
    if (mounted) {
      Navigator.pushReplacement(
        context, 
        MaterialPageRoute(builder: (_) => const LoginScreen())
      );
    }
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1B5E20), Color(0xFF2E7D32), Color(0xFF33691E)],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fade,
            child: Stack(
              children: [
                // ── Main animated scene (fills the whole screen) ──────
                const NagaliSceneWidget(),

                // ── Logo badge top-left ────────────────────────────────
                Positioned(
                  top: 20,
                  left: 20,
                  child: Container(
                    width: 110,
                    height: 110,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF1B5E20),
                      border: Border.all(
                          color: const Color(0xFFD4AF37), width: 2.5),
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        'images/app_logo.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),

                // ── Tagline bottom-left ────────────────────────────────
                const Positioned(
                  bottom: 110,
                  left: 20,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Continuous Growth',
                          style: TextStyle(
                            color: Color(0xFF8BC34A),
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          )),
                      Text('నిరంతర అభివృద్ధి',
                          style: TextStyle(
                            color: Color(0xFF8BC34A),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          )),
                    ],
                  ),
                ),

                // ── Sparkle bottom-right ──────────────────────────────
                const Positioned(
                  bottom: 90,
                  right: 20,
                  child: Text('✦',
                      style: TextStyle(
                          color: Colors.white54, fontSize: 22)),
                ),

              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
//  SCENE WIDGET — owns all animation controllers
// ══════════════════════════════════════════════════════════════
class NagaliSceneWidget extends StatefulWidget {
  const NagaliSceneWidget({super.key});
  @override
  State<NagaliSceneWidget> createState() => _NagaliSceneWidgetState();
}

class _NagaliSceneWidgetState extends State<NagaliSceneWidget>
    with TickerProviderStateMixin {
  late AnimationController _ploughCtrl;
  late AnimationController _wheatCtrl;
  late AnimationController _soilCtrl;
  late AnimationController _rainCtrl;
  late AnimationController _glowCtrl;

  late Animation<double> _ploughX;
  late Animation<double> _ploughBob;
  late Animation<double> _wheatSway;
  late Animation<double> _soilT;
  late Animation<double> _rainT;
  late Animation<double> _glowT;

  @override
  void initState() {
    super.initState();

    _ploughCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 4200))
      ..repeat(reverse: true);

    _wheatCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 2000))
      ..repeat(reverse: true);

    _soilCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800))
      ..repeat();

    _rainCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500))
      ..repeat();

    _glowCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 2500))
      ..repeat(reverse: true);

    _ploughX = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _ploughCtrl, curve: Curves.easeInOut));

    _ploughBob = Tween<double>(begin: -2.5, end: 2.5).animate(
        CurvedAnimation(parent: _ploughCtrl, curve: Curves.easeInOut));

    _wheatSway = Tween<double>(begin: -1.0, end: 1.0).animate(
        CurvedAnimation(parent: _wheatCtrl, curve: Curves.easeInOut));

    _soilT = CurvedAnimation(parent: _soilCtrl, curve: Curves.easeOut);
    _rainT = CurvedAnimation(parent: _rainCtrl, curve: Curves.linear);
    _glowT = Tween<double>(begin: 0.7, end: 1.0).animate(
        CurvedAnimation(parent: _glowCtrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ploughCtrl.dispose();
    _wheatCtrl.dispose();
    _soilCtrl.dispose();
    _rainCtrl.dispose();
    _glowCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge(
          [_ploughCtrl, _wheatCtrl, _soilCtrl, _rainCtrl, _glowCtrl]),
      builder: (ctx, _) => CustomPaint(
        painter: NagaliScenePainter(
          ploughT: _ploughX.value,
          ploughBob: _ploughBob.value,
          wheatSway: _wheatSway.value,
          soilT: _soilT.value,
          rainT: _rainT.value,
          glowT: _glowT.value,
        ),
        child: const SizedBox.expand(),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
//  PAINTER — draws the full Kisan Mitra scene
// ══════════════════════════════════════════════════════════════
class NagaliScenePainter extends CustomPainter {
  final double ploughT;
  final double ploughBob;
  final double wheatSway;
  final double soilT;
  final double rainT;
  final double glowT;

  NagaliScenePainter({
    required this.ploughT,
    required this.ploughBob,
    required this.wheatSway,
    required this.soilT,
    required this.rainT,
    required this.glowT,
  });

  // Colours matched to the reference screenshot
  static const Color wood1 = Color(0xFF6B3410);
  static const Color wood2 = Color(0xFF8B4513);
  static const Color wood3 = Color(0xFFAD6020);
  static const Color wood4 = Color(0xFFCD8B3A);
  static const Color soilA = Color(0xFFB5651D);
  static const Color soilB = Color(0xFF8B4513);
  static const Color soilC = Color(0xFF6B3410);
  static const Color soilD = Color(0xFF4A2208);
  static const Color soilE = Color(0xFF3A1A06);
  static const Color metalA = Color(0xFF546E7A);
  static const Color metalB = Color(0xFF78909C);
  static const Color metalC = Color(0xFF90A4AE);
  static const Color grassG = Color(0xFF33691E);
  static const Color wheatG = Color(0xFF2E7D32);
  static const Color wheatL = Color(0xFF43A047);
  static const Color wheatY = Color(0xFFCDC42A);
  static const Color sunY = Color(0xFFFDD835);
  static const Color sunO = Color(0xFFFF8F00);
  static const Color cloudC = Color(0xFFBBDEFB);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // ground surface is at 58% height
    final groundY = h * 0.58;

    _drawSoilLayers(canvas, w, h, groundY);
    _drawWeatherElements(canvas, w, h);
    _drawWheatField(canvas, w, groundY);

    // Plough x: travels from 70% → 28% of width
    final px = w * 0.70 - ploughT * w * 0.42;
    final py = groundY + ploughBob;

    _drawFurrow(canvas, px, w, groundY);
    _drawSoilBurst(canvas, px, py);
    _drawNagali(canvas, px, py, ploughT > 0.5);
  }

  // ── Layered soil cross-section ────────────────────────────────────────
  void _drawSoilLayers(Canvas canvas, double w, double h, double groundY) {
    // Grass strip
    final grassPath = Path()
      ..moveTo(0, groundY - 8)
      ..quadraticBezierTo(w * 0.3, groundY - 16, w * 0.55, groundY - 6)
      ..quadraticBezierTo(w * 0.8, groundY + 4, w, groundY - 4)
      ..lineTo(w, groundY + 10)
      ..lineTo(0, groundY + 10)
      ..close();
    canvas.drawPath(grassPath, Paint()..color = grassG);

    // Layer 1 — reddish-brown topsoil
    final l1 = Path()
      ..moveTo(0, groundY + 8)
      ..lineTo(w, groundY + 4)
      ..lineTo(w, groundY + h * 0.12)
      ..lineTo(0, groundY + h * 0.12)
      ..close();
    canvas.drawPath(
      l1,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [soilA, soilB],
        ).createShader(Rect.fromLTWH(0, groundY, w, h * 0.12)),
    );

    // Layer 2 — darker
    final l2 = Path()
      ..moveTo(0, groundY + h * 0.12)
      ..lineTo(w, groundY + h * 0.12 - 3)
      ..lineTo(w, groundY + h * 0.24)
      ..lineTo(0, groundY + h * 0.24)
      ..close();
    canvas.drawPath(l2, Paint()..color = soilC);

    // Layer 3 — darkest
    final l3 = Path()
      ..moveTo(0, groundY + h * 0.24)
      ..lineTo(w, groundY + h * 0.24 - 2)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(l3, Paint()..color = soilD);
  }

  // ── Furrow line left by the blade ────────────────────────────────────
  void _drawFurrow(Canvas canvas, double px, double w, double groundY) {
    final trailLen = ploughT * w * 0.42;
    if (trailLen < 4) return;
    final bladeX = px - 18; // blade tip is offset left

    canvas.drawLine(
      Offset(bladeX - trailLen * 0.82, groundY + 14),
      Offset(bladeX, groundY + 14),
      Paint()
        ..color = soilE
        ..strokeWidth = 5
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawLine(
      Offset(bladeX - trailLen * 0.82, groundY + 14),
      Offset(bladeX, groundY + 14),
      Paint()
        ..color = soilD.withValues(alpha: 0.5)
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round,
    );
  }

  // ── Sun + Cloud + rain ────────────────────────────────────────────────
  void _drawWeatherElements(Canvas canvas, double w, double h) {
    // Sun (centre-right sky)
    final sunX = w * 0.46;
    final sunY = h * 0.16;
    _drawSun(canvas, sunX, sunY);

    // Cloud (right)
    final cloudX = w * 0.76;
    final cloudY = h * 0.13;
    _drawCloud(canvas, cloudX, cloudY);

    // Arrow loop between sun and cloud
    final arcPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.55)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Arrow: sun → cloud (top arc)
    final topArc = Path()
      ..moveTo(sunX + 18, sunY - 6)
      ..quadraticBezierTo(
          (sunX + cloudX) / 2, h * 0.05, cloudX - 22, cloudY - 4);
    canvas.drawPath(topArc, arcPaint);
    _drawArrowHead(canvas, cloudX - 22, cloudY - 4,
        cloudX - 26, cloudY + 2, arcPaint);

    // Arrow: cloud → sun (bottom arc)
    final botArc = Path()
      ..moveTo(cloudX - 14, cloudY + 14)
      ..quadraticBezierTo(
          (sunX + cloudX) / 2, h * 0.36, sunX + 12, sunY + 14);
    canvas.drawPath(botArc, arcPaint);
    _drawArrowHead(
        canvas, sunX + 12, sunY + 14, sunX + 6, sunY + 10, arcPaint);

    // Rain drops
    _drawRain(canvas, cloudX, cloudY);
  }

  void _drawSun(Canvas canvas, double cx, double cy) {
    // Outer glow
    canvas.drawCircle(Offset(cx, cy), 28 * glowT,
        Paint()..color = sunY.withValues(alpha: 0.15));
    // Body
    canvas.drawCircle(Offset(cx, cy), 20, Paint()..color = sunY);
    // Rays
    final r = Paint()
      ..color = sunY
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round;
    for (int i = 0; i < 8; i++) {
      final a = i * pi / 4;
      canvas.drawLine(Offset(cx + cos(a) * 23, cy + sin(a) * 23),
          Offset(cx + cos(a) * 30, cy + sin(a) * 30), r);
    }
    // Smiley
    final face = Paint()
      ..color = sunO
      ..strokeWidth = 1.8
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(Rect.fromCenter(center: Offset(cx, cy + 3), width: 14, height: 9),
        0, pi, false, face);
    canvas.drawCircle(Offset(cx - 5, cy - 3), 2, Paint()..color = sunO);
    canvas.drawCircle(Offset(cx + 5, cy - 3), 2, Paint()..color = sunO);
  }

  void _drawCloud(Canvas canvas, double cx, double cy) {
    final p = Paint()..color = cloudC;
    canvas.drawOval(Rect.fromCenter(center: Offset(cx, cy + 8), width: 58, height: 24), p);
    canvas.drawOval(Rect.fromCenter(center: Offset(cx - 14, cy + 2), width: 34, height: 26), p);
    canvas.drawOval(Rect.fromCenter(center: Offset(cx + 10, cy - 2), width: 38, height: 28), p);
    // highlight
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx + 6, cy - 7), width: 22, height: 11),
      Paint()..color = Colors.white.withValues(alpha: 0.4),
    );
  }

  void _drawRain(Canvas canvas, double cx, double cy) {
    final p = Paint()
      ..color = const Color(0xFF64B5F6).withValues(alpha: 0.9)
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round;
    final drops = [
      [cx - 14.0, cy + 18.0],
      [cx - 2.0,  cy + 22.0],
      [cx + 10.0, cy + 18.0],
      [cx - 8.0,  cy + 32.0],
      [cx + 4.0,  cy + 32.0],
    ];
    final offset = (rainT * 18) % 18;
    for (final d in drops) {
      canvas.drawLine(
        Offset(d[0], d[1] + offset),
        Offset(d[0] - 2.5, d[1] + 10 + offset),
        p,
      );
    }
  }

  void _drawArrowHead(Canvas canvas, double tx, double ty,
      double fromX, double fromY, Paint p) {
    final angle = atan2(ty - fromY, tx - fromX);
    final p1 = Offset(tx - cos(angle - 0.4) * 8, ty - sin(angle - 0.4) * 8);
    final p2 = Offset(tx - cos(angle + 0.4) * 8, ty - sin(angle + 0.4) * 8);
    canvas.drawLine(Offset(tx, ty), p1, p);
    canvas.drawLine(Offset(tx, ty), p2, p);
  }

  // ── Wheat field (right side) ──────────────────────────────────────────
  void _drawWheatField(Canvas canvas, double w, double groundY) {
    final positions = [
      w * 0.68, w * 0.73, w * 0.78, w * 0.83, w * 0.88, w * 0.93, w * 0.98
    ];
    final heights = [
        groundY * 0.42, groundY * 0.38, groundY * 0.44, groundY * 0.36,
        groundY * 0.42, groundY * 0.38, groundY * 0.34];

    for (int i = 0; i < positions.length; i++) {
      final sway = wheatSway * (2.5 + i * 0.6);
      _drawWheatStalk(canvas, positions[i], groundY + 6, heights[i], sway, i.isEven);
    }
  }

  void _drawWheatStalk(Canvas canvas, double bx, double by,
      double stalkH, double sway, bool leafRight) {
    final tx = bx + sway;
    final ty = by - stalkH;

    // Stalk
    final stalk = Path()
      ..moveTo(bx, by)
      ..quadraticBezierTo(bx + sway * 0.5, by - stalkH * 0.55, tx, ty);
    canvas.drawPath(stalk, Paint()
      ..color = wheatG
      ..strokeWidth = 2.2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round);

    // Leaf
    final lx = bx + sway * 0.35;
    final ly = by - stalkH * 0.4;
    final leafD = leafRight ? 26.0 : -26.0;
    final leaf = Path()
      ..moveTo(lx, ly)
      ..quadraticBezierTo(lx + leafD, ly - 10, lx + leafD * 1.2, ly)
      ..quadraticBezierTo(lx + leafD * 0.6, ly + 4, lx, ly);
    canvas.drawPath(leaf, Paint()..color = wheatL);

    _drawWheatHead(canvas, tx, ty);
  }

  void _drawWheatHead(Canvas canvas, double cx, double cy) {
    canvas.drawLine(Offset(cx, cy), Offset(cx, cy + 26),
        Paint()..color = wheatY..strokeWidth = 1.5..strokeCap = StrokeCap.round);

    final g = Paint()..color = wheatY;
    for (int i = 0; i < 6; i++) {
      final y = cy + i * 4.2;
      // left grain
      final lp = Path()
        ..moveTo(cx, y)
        ..quadraticBezierTo(cx - 7, y + 1.5, cx - 9, y + 3.5)
        ..quadraticBezierTo(cx - 4, y + 3, cx, y + 4.5);
      canvas.drawPath(lp, g);
      // right grain
      final rp = Path()
        ..moveTo(cx, y)
        ..quadraticBezierTo(cx + 7, y + 1.5, cx + 9, y + 3.5)
        ..quadraticBezierTo(cx + 4, y + 3, cx, y + 4.5);
      canvas.drawPath(rp, g);
      // awns
      final awn = Paint()..color = wheatY..strokeWidth = 0.9..strokeCap = StrokeCap.round;
      canvas.drawLine(Offset(cx - 9, y + 3.5), Offset(cx - 15, y - 2), awn);
      canvas.drawLine(Offset(cx + 9, y + 3.5), Offset(cx + 15, y - 2), awn);
    }
  }

  // ── Soil burst at blade tip ───────────────────────────────────────────
  void _drawSoilBurst(Canvas canvas, double px, double py) {
    final bx = px - 18;
    final by = py + 26;
    final particles = [
      [bx - 22.0, by - 25.0, 5.0, 0.0],
      [bx - 32.0, by - 14.0, 4.0, 0.07],
      [bx - 12.0, by - 34.0, 3.5, 0.13],
      [bx +  4.0, by - 20.0, 3.0, 0.18],
      [bx - 18.0, by -  8.0, 2.5, 0.05],
      [bx - 38.0, by -  6.0, 2.0, 0.22],
    ];
    for (final s in particles) {
      final t = ((soilT - s[3]).clamp(0.0, 1.0));
      if (t <= 0) continue;
      final op = (1 - t) * 0.88;
      canvas.drawCircle(
        Offset(s[0] + (s[0] - bx) * t * 0.3, s[1] + (s[1] - by) * t * 0.4),
        s[2],
        Paint()..color = soilA.withValues(alpha: op),
      );
    }
  }

  // ══════════════════════════════════════════════════════════════
  //  NAGALI — closely matches the reference image:
  //  • long diagonal wooden pole, upper-right to lower-left
  //  • curved vertical shank bending into the ground
  //  • wide flat metal blade pointing down-left into soil
  //  • wooden crosspiece / brace connecting pole & shank
  // ══════════════════════════════════════════════════════════════
  void _drawNagali(Canvas canvas, double cx, double cy, bool goingLeft) {
    canvas.save();
    // Place origin at the plough body junction (where pole meets shank)
    canvas.translate(cx, cy);
    // When moving left flip horizontally so blade is always at the front
    if (goingLeft) canvas.scale(-1.0, 1.0);

    // Ground shadow
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(-10, 30), width: 100, height: 10),
      Paint()..color = Colors.black.withValues(alpha: 0.15),
    );

    _drawLongPole(canvas);
    _drawShank(canvas);
    _drawBrace(canvas);
    _drawBlade(canvas);

    canvas.restore();
  }

  // Long diagonal pole — from top-right down to junction at (0,0)
  void _drawLongPole(Canvas canvas) {
    final path = Path()
      ..moveTo(82, -130)  // top-right handle end
      ..lineTo(95, -118)
      ..lineTo(12, 10)    // lower junction end
      ..lineTo(-2, -2)
      ..close();

    canvas.drawPath(path, _woodShader(wood1, wood2, wood4,
        const Rect.fromLTWH(-4, -135, 102, 148)));

    // Highlight strip
    canvas.drawLine(const Offset(86, -124), const Offset(6, 6),
        Paint()..color = wood4.withValues(alpha: 0.5)..strokeWidth = 2.5
          ..strokeCap = StrokeCap.round);

    // Wood grain marks
    final grain = Paint()..color = wood1.withValues(alpha: 0.3)
      ..strokeWidth = 1..strokeCap = StrokeCap.round;
    for (int i = 0; i < 5; i++) {
      final t = 0.15 + i * 0.16;
      final x1 = 82 - t * 82;
      final y1 = -130 + t * 140;
      canvas.drawLine(Offset(x1, y1), Offset(x1 - 6, y1 + 8), grain);
    }

    // Handle grip at top
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: const Offset(86, -124), width: 18, height: 10),
        const Radius.circular(3),
      ),
      Paint()..color = wood1,
    );
    // grip wraps
    final wrap = Paint()..color = wood4.withValues(alpha: 0.6)..strokeWidth = 1.5;
    for (int i = 0; i < 3; i++) {
      canvas.drawLine(Offset(78 + i * 4.0, -128), Offset(78 + i * 4.0, -120), wrap);
    }
  }

  // Curved shank — bends from junction (0,0) down into soil
  void _drawShank(Canvas canvas) {
    final path = Path()
      ..moveTo(-2, -2)    // top join
      ..lineTo(12, 10)
      ..quadraticBezierTo(16, 30, -4, 55)   // curves downward-left
      ..lineTo(-18, 48)
      ..quadraticBezierTo(-12, 22, -14, 2)
      ..close();

    canvas.drawPath(path, _woodShader(wood2, wood3, wood1,
        const Rect.fromLTWH(-20, -4, 36, 62)));

    // Highlight
    canvas.drawLine(const Offset(8, 12), const Offset(-6, 52),
        Paint()..color = wood4.withValues(alpha: 0.45)..strokeWidth = 2
          ..strokeCap = StrokeCap.round);

    // Grain
    final grain = Paint()..color = wood1.withValues(alpha: 0.25)..strokeWidth = 1;
    canvas.drawLine(const Offset(4, 16), const Offset(-2, 28), grain);
    canvas.drawLine(const Offset(0, 30), const Offset(-8, 42), grain);
  }

  // Brace / crosspiece connecting pole to shank
  void _drawBrace(Canvas canvas) {
    // The rectangular wooden block visible in the reference image
    final braceRect = RRect.fromRectAndRadius(
        const Rect.fromLTWH(-16, -4, 32, 18), const Radius.circular(3));
    canvas.drawRRect(braceRect,
        Paint()..color = wood1);
    canvas.drawRRect(braceRect,
        Paint()..color = wood3.withValues(alpha: 0.4)
          ..style = PaintingStyle.stroke..strokeWidth = 1.5);

    // Face texture
    canvas.drawLine(const Offset(-14, 2), const Offset(14, 2),
        Paint()..color = wood4.withValues(alpha: 0.3)..strokeWidth = 1);
    canvas.drawLine(const Offset(-14, 8), const Offset(14, 8),
        Paint()..color = wood4.withValues(alpha: 0.2)..strokeWidth = 1);

    // Bolt
    canvas.drawCircle(const Offset(0, 7), 5, Paint()..color = wood2);
    canvas.drawCircle(const Offset(0, 7), 3, Paint()..color = wood4);
    canvas.drawCircle(const Offset(0, 7), 1.2, Paint()..color = wood1);
  }

  // Wide flat triangular metal blade — goes into the ground
  void _drawBlade(Canvas canvas) {
    // In the reference image the blade is a wide flat wedge, dark metal,
    // pointing down and slightly left, embedded in soil.
    final bladePath = Path()
      ..moveTo(-18, 48)   // top-left (shank bottom-left)
      ..lineTo(-4, 55)    // top-right (shank bottom-right)
      ..lineTo(20, 70)    // right shoulder
      ..lineTo(-2, 84)    // tip — into the ground
      ..lineTo(-30, 68)   // left shoulder
      ..close();

    // Blade shadow
    canvas.drawPath(bladePath.shift(const Offset(3, 4)),
        Paint()..color = Colors.black.withValues(alpha: 0.2));

    // Blade body — dark steel gradient
    canvas.drawPath(bladePath, Paint()
      ..shader = const LinearGradient(
        colors: [metalA, metalC, metalA, metalB],
        stops: [0.0, 0.35, 0.65, 1.0],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(const Rect.fromLTWH(-32, 48, 56, 40)));

    // Cutting edge highlight (bottom edge)
    canvas.drawLine(const Offset(-30, 68), const Offset(-2, 84),
        Paint()..color = Colors.white.withValues(alpha: 0.45)..strokeWidth = 1.5
          ..strokeCap = StrokeCap.round);
    canvas.drawLine(const Offset(-2, 84), const Offset(20, 70),
        Paint()..color = Colors.white.withValues(alpha: 0.25)..strokeWidth = 1.2
          ..strokeCap = StrokeCap.round);

    // Outline
    canvas.drawPath(bladePath, Paint()
      ..color = const Color(0xFF263238)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2);
  }

  Paint _woodShader(Color a, Color b, Color c, Rect rect) => Paint()
    ..shader = LinearGradient(
      colors: [a, b, c, b, a],
      stops: const [0.0, 0.22, 0.5, 0.78, 1.0],
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
    ).createShader(rect);

  @override
  bool shouldRepaint(NagaliScenePainter old) => true;
}


class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);

    final List<Map<String, String>> slides = [
      {
        'en': 'Track Crops Locally', 
        'te': 'స్థానికంగా పంటలను ట్రాక్ చేయండి', 
        'desc_en': 'Explore diverse crop information effortlessly from anywhere. Keep track of watering and seasons instantly.',
        'desc_te': 'ఎక్కడినుండైనా వివిధ పంటల సమాచారాన్ని అన్వేషించండి. నీరు ప్రవాహం, వాతావరణం మరియు సమయాలను తక్షణమే ట్రాక్ చేయండి.',
        'icon': 'eco'
      },
      {
        'en': 'Real-time Market Prices', 
        'te': 'రియల్ టైమ్ మార్కెట్ ధరలు', 
        'desc_en': 'Stay updated with the latest Mandi prices directly on your phone. Make informed decisions and sell smarter.',
        'desc_te': 'తాజా మండి ధరలతో అప్‌డేట్‌గా ఉండండి. సరైన నిర్ణయాలు తీసుకోండి మరియు తెలివిగా లాభాలు పొందండి.',
        'icon': 'trending_up'
      },
      {
        'en': 'Direct Schemes & Subsidies', 
        'te': 'ప్రత్యక్ష ప్రభుత్వ పథకాలు', 
        'desc_en': 'Discover and apply for exclusive farming subsidies and agricultural grants securely with one tap.',
        'desc_te': 'వ్యవసాయ సబ్సిడీల కోసం సులభంగా దరఖాస్తు చేసుకోండి. రైతుల సహాయాన్ని నేరుగా పొందండి.',
        'icon': 'account_balance'
      },
    ];

    IconData getIcon(String name) {
      if (name == 'eco') return Icons.eco_rounded;
      if (name == 'trending_up') return Icons.trending_up_rounded;
      return Icons.account_balance_rounded;
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                physics: const BouncingScrollPhysics(),
                onPageChanged: (i) => setState(() => _currentPage = i),
                itemCount: slides.length,
                itemBuilder: (context, i) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(40),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(getIcon(slides[i]['icon']!), size: 120, color: AppColors.primary),
                        ),
                        const SizedBox(height: 50),
                        Text(
                          lang.isTelugu ? slides[i]['te']! : slides[i]['en']!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: AppColors.primary, height: 1.2),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          lang.isTelugu ? slides[i]['desc_te']! : slides[i]['desc_en']!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 16, color: AppColors.textSecondary, height: 1.5),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                slides.length,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 5),
                  height: 10,
                  width: _currentPage == index ? 24 : 10,
                  decoration: BoxDecoration(
                    color: _currentPage == index ? AppColors.primary : AppColors.primary.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
            Padding(
              padding: const EdgeInsets.only(left: 30, right: 30, bottom: 40),
              child: SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 5,
                    shadowColor: AppColors.primary.withValues(alpha: 0.4),
                  ),
                  onPressed: () {
                    if (_currentPage == slides.length - 1) {
                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
                    } else {
                      _pageController.nextPage(duration: const Duration(milliseconds: 400), curve: Curves.easeInOut);
                    }
                  },
                  child: Text(_currentPage == slides.length - 1 
                      ? (lang.isTelugu ? 'ప్రారంభించండి' : 'Get Started') 
                      : (lang.isTelugu ? 'తదుపరి దశ' : 'Next Step'),
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  bool _otpSent = false;
  bool _isLoading = false;
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }


  Future<void> _verifyPhone() async {
    if (_phoneController.text.isEmpty || _phoneController.text.length != 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid 10-digit phone number')),
      );
      return;
    }
    
    setState(() => _isLoading = true);

    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;

    setState(() {
      _otpSent = true;
      _isLoading = false;
    });

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('OTP sent successfully (Demo Mode)'),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  Future<void> _verifyOTP() async {
    // Verify OTP (Mock 123456)
    if (_otpController.text != '123456') {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid OTP. Please use 123456 for testing.')),
      );
      return;
    }
    
    setState(() => _isLoading = true);
    final mobile = _phoneController.text.trim();
    
    // Simulate verification delay
    await Future.delayed(const Duration(seconds: 1));

    if (mounted) {
      final prefs = await SharedPreferences.getInstance();
      
      // AUTO-DISTRIBUTE PRE-BUILT PROFILES for testing
      final mocks = MockDataService.farmers;
      final selectedMock = mocks[Random().nextInt(mocks.length)];
      final Map<String, dynamic> dummyData = selectedMock.toJson();

      if (!kIsWeb) {
        final directory = await getApplicationDocumentsDirectory();
        final file = File('${directory.path}/farmer_$mobile.json');
        await file.writeAsString(jsonEncode(dummyData));
      } else {
        await prefs.setString('profile_$mobile', jsonEncode(dummyData));
      }
      
      await prefs.setString('current_mobile', mobile);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login as ${selectedMock.name} (${selectedMock.district})')),
      );
      
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MainScreen())
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Hero Banner with Logo
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primary, AppColors.primary.withValues(alpha: 0.85)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: Image.asset(
                          'images/app_logo.png',
                          height: 80,
                          width: 80,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Kisan Mitra',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: AppColors.surface,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'కిసాన్ మిత్ర',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.surface.withValues(alpha: 0.9),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Header with Language Toggle
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        lang.isTelugu ? 'లాగిన్ చేయండి' : 'Login to Your Account',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.language, color: AppColors.primary),
                      onPressed: () => lang.toggleLanguage(),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              // Subtitle with Registration Link
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Wrap(
                  alignment: WrapAlignment.start,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      lang.isTelugu ? 'ఖాతా లేనా?' : 'Don\'t have an account? ',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const RegistrationScreen()),
                      ),
                      child: Text(
                        lang.isTelugu ? 'రైతుగా నమోదు చేయండి' : 'Register as Farmer',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Phone Login Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (!_otpSent) ...[
                      Text(
                        lang.isTelugu ? 'ఫోన్ నంబర్' : 'Phone Number',
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        maxLength: 10,
                        enabled: !_isLoading,
                        onChanged: (value) => setState(() {}),
                        decoration: InputDecoration(
                          prefixText: '+91 ',
                          hintText: '98765 43210',
                          helperText: _phoneController.text.length == 10
                              ? (lang.isTelugu ? 'OTP పంపబడుతుంది' : 'OTP will be sent')
                              : null,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: AppColors.primary),
                          ),
                          prefixIcon: const Icon(Icons.phone, color: AppColors.primary),
                          counterText: '',
                        ),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _verifyPhone,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 4,
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: CircularProgressIndicator(
                                    color: AppColors.surface,
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(
                                  lang.isTelugu ? 'OTP పంపండి' : 'Send OTP',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.surface,
                                  ),
                                ),
                        ),
                      ),
                    ] else ...[
                      Text(
                        lang.isTelugu ? 'OTP నమోదు చేయండి' : 'Enter OTP',
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        lang.isTelugu 
                            ? '+91 ${_phoneController.text}కు పంపిన OTP నమోదు చేయండి'
                            : 'Enter the OTP sent to +91 ${_phoneController.text}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _otpController,
                        keyboardType: TextInputType.number,
                        maxLength: 6,
                        enabled: !_isLoading,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 24, letterSpacing: 8),
                        decoration: InputDecoration(
                          hintText: '000000',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: AppColors.primary),
                          ),
                          counterText: '',
                        ),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _verifyOTP,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 4,
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: CircularProgressIndicator(
                                    color: AppColors.surface,
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(
                                  lang.isTelugu ? 'సత్యాపించండి' : 'Verify',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.surface,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _otpSent = false;
                            _phoneController.clear();
                            _otpController.clear();
                          });
                        },
                        child: Align(
                          alignment: Alignment.center,
                          child: Text(
                            lang.isTelugu ? 'ఫోన్ నంబర్ మార్చండి' : 'Change Phone Number',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.primary,
                              decoration: TextDecoration.underline,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Footer Info
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  lang.isTelugu 
                      ? 'మీ ఖాతా సురక్షితమైనది. మేము చేసిన చర్యకు కూడా ఏ ఫీజు లేదు.'
                      : 'Your account is secure. We never share your data.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
