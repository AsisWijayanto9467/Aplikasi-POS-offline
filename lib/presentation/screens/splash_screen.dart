import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import 'main_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnim;
  late Animation<double> _scaleAnim;
  late Animation<double> _slideAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );

    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.4, curve: Curves.easeOut)),
    );
    _scaleAnim = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.6, curve: Curves.elasticOut)),
    );
    _slideAnim = Tween<double>(begin: 50.0, end: 0.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.2, 0.6, curve: Curves.easeOutCubic)),
    );

    _controller.forward();

    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => const MainScreen(),
            transitionsBuilder: (_, animation, __, child) {
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: const Duration(milliseconds: 600),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF7C3AED), Color(0xFF8B5CF6), Color(0xFFA78BFA)],
              ),
            ),
            child: Stack(
              children: [
                Positioned(
                  top: -100, right: -100,
                  child: Opacity(
                    opacity: 0.1,
                    child: Container(
                      width: 300, height: 300,
                      decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white),
                    ),
                  ),
                ),
                Positioned(
                  bottom: -50, left: -50,
                  child: Opacity(
                    opacity: 0.1,
                    child: Container(
                      width: 200, height: 200,
                      decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white),
                    ),
                  ),
                ),
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Opacity(
                        opacity: _fadeAnim.value,
                        child: Transform.scale(
                          scale: _scaleAnim.value,
                          child: Container(
                            width: 120, height: 120,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(30),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 30,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: const Icon(Icons.spa_rounded, size: 60, color: Color(0xFF7C3AED)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                      Opacity(
                        opacity: _fadeAnim.value,
                        child: Transform.translate(
                          offset: Offset(0, _slideAnim.value),
                          child: const Column(
                            children: [
                              Text('SalonDesk', style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1.5)),
                              SizedBox(height: 8),
                              Text('Modern POS for Your Salon', style: TextStyle(fontSize: 14, color: Colors.white70, letterSpacing: 1)),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 60),
                      Opacity(
                        opacity: _fadeAnim.value,
                        child: SizedBox(
                          width: 40, height: 40,
                          child: CircularProgressIndicator(
                            strokeWidth: 3,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white.withOpacity(0.8)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  bottom: 40, left: 0, right: 0,
                  child: Opacity(
                    opacity: _fadeAnim.value,
                    child: const Text('v1.0.0', textAlign: TextAlign.center, style: TextStyle(color: Colors.white54, fontSize: 12)),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}