import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  final Widget nextScreen;

  const SplashScreen({super.key, required this.nextScreen});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _imageFade;
  late Animation<double> _titleFade;
  late Animation<Offset> _titleSlide;
  late Animation<double> _subtitleFade;
  late Animation<Offset> _subtitleSlide;

  @override
  void initState() {
    super.initState();

    // Controller untuk gambar (muncul duluan)
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    // Controller untuk teks (muncul setelah gambar)
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    // Animasi gambar: fade in
    _imageFade = CurvedAnimation(parent: _fadeController, curve: Curves.easeIn);

    // Animasi judul: fade + slide dari bawah
    _titleFade = CurvedAnimation(
      parent: _slideController,
      curve: const Interval(0.0, 0.7, curve: Curves.easeOut),
    );
    _titleSlide = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _slideController,
            curve: const Interval(0.0, 0.7, curve: Curves.easeOut),
          ),
        );

    // Animasi subtitle: fade + slide, sedikit delay
    _subtitleFade = CurvedAnimation(
      parent: _slideController,
      curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
    );
    _subtitleSlide =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _slideController,
            curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
          ),
        );

    _startAnimation();
  }

  Future<void> _startAnimation() async {
    // Mulai fade gambar
    await _fadeController.forward();

    // Setelah gambar muncul, animasikan teks
    await Future.delayed(const Duration(milliseconds: 200));
    await _slideController.forward();

    // Tunggu sebentar lalu navigate ke halaman berikutnya
    await Future.delayed(const Duration(milliseconds: 1500));
    _navigateToNext();
  }

  void _navigateToNext() {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => widget.nextScreen,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 600),
      ),
    );
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ── Background image dengan fade in ──
          FadeTransition(
            opacity: _imageFade,
            child: Image.asset(
              'assets/images/splash_bg.png', // ganti path sesuai asset kamu
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFF1A0A00), Color(0xFF000000)],
                  ),
                ),
              ),
            ),
          ),

          // ── Gradient overlay bawah agar teks terbaca ──
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: [0.45, 0.75, 1.0],
                colors: [Colors.transparent, Color(0xCC000000), Colors.black],
              ),
            ),
          ),

          // ── Teks bagian bawah ──
          Positioned(
            left: 24,
            right: 24,
            bottom: 80,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Judul
                SlideTransition(
                  position: _titleSlide,
                  child: FadeTransition(
                    opacity: _titleFade,
                    child: const Text(
                      'Fall in Love with\nCoffee in Blissful\nDelight!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        height: 1.2,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Subtitle
                SlideTransition(
                  position: _subtitleSlide,
                  child: FadeTransition(
                    opacity: _subtitleFade,
                    child: const Text(
                      'Welcome to our cozy Seven Coffee corner, where\nevery cup is a delightful for you.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFFAAAAAA),
                        height: 1.5,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
