import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/constants/app_constants.dart';
import '../../services/firestore_service.dart';
import '../../widgets/ReUse_logo.dart';
import '../../widgets/reusehub_loading_sign.dart';
import '../onboarding/onboarding_screen.dart';
import '../auth/login_screen.dart';
import '../maker/maker_main_screen.dart';
import '../supplier/supplier_main_screen.dart';
import '../auth/role_selection_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  // Entrance animation (logo)
  late final AnimationController _entranceController;
  late final Animation<double> _logoScale;
  late final Animation<double> _logoFade;
  late final Animation<double> _logoRotation;

  // Staggered text/tagline reveal
  late final Animation<double> _textFade;
  late final Animation<Offset> _textSlide;

  // Underline draw-in
  late final Animation<double> _underlineWidth;

  // Continuous glow pulse behind the logo
  late final AnimationController _glowController;
  late final Animation<double> _glowScale;
  late final Animation<double> _glowOpacity;

  // Slow background gradient shift
  late final AnimationController _bgController;
  late final Animation<double> _bgShift;

  @override
  void initState() {
    super.initState();

    // ---- Logo entrance: scale + fade + a tiny playful rotation ----
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );

    _logoScale = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _entranceController, curve: const Interval(0.0, 0.7, curve: Curves.elasticOut)),
    );

    _logoFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _entranceController, curve: const Interval(0.0, 0.4, curve: Curves.easeOut)),
    );

    _logoRotation = Tween<double>(begin: -0.15, end: 0.0).animate(
      CurvedAnimation(parent: _entranceController, curve: const Interval(0.0, 0.7, curve: Curves.easeOutBack)),
    );

    // ---- Text/tagline: fades + slides up shortly after the logo lands ----
    _textFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _entranceController, curve: const Interval(0.45, 0.85, curve: Curves.easeOut)),
    );

    _textSlide = Tween<Offset>(begin: const Offset(0, 0.25), end: Offset.zero).animate(
      CurvedAnimation(parent: _entranceController, curve: const Interval(0.45, 0.85, curve: Curves.easeOutCubic)),
    );

    // ---- Underline accent draws itself in last ----
    _underlineWidth = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _entranceController, curve: const Interval(0.8, 1.0, curve: Curves.easeOut)),
    );

    _entranceController.forward();

    // ---- Continuous soft glow pulse behind the logo ----
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    _glowScale = Tween<double>(begin: 0.92, end: 1.08).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    _glowOpacity = Tween<double>(begin: 0.25, end: 0.55).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    // ---- Slow ambient background gradient shift ----
    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4000),
    )..repeat(reverse: true);

    _bgShift = Tween<double>(begin: -0.3, end: 0.3).animate(
      CurvedAnimation(parent: _bgController, curve: Curves.easeInOut),
    );

    // Fast asynchronous background seed
    Future.microtask(() {
      try {
        FirestoreService().seedDemoDataIfEmpty();
      } catch (_) {}
    });

    _navigateToNext();
  }

  void _navigateToNext() async {
    await Future.delayed(const Duration(milliseconds: 2400));

    if (!mounted) return;

    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final userModel = await FirestoreService().getUserData(user.uid);
        if (!mounted) return;

        if (userModel != null) {
          if (userModel.role == AppConstants.roleSupplier) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const SupplierMainScreen()),
            );
          } else if (userModel.role == AppConstants.roleMaker) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const MakerMainScreen()),
            );
          } else {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => RoleSelectionScreen(userId: user.uid)),
            );
          }
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const LoginScreen()),
          );
        }
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const OnboardingScreen()),
        );
      }
    } catch (_) {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const OnboardingScreen()),
      );
    }
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _glowController.dispose();
    _bgController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: _bgShift,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(_bgShift.value * 0.4, -0.1 + _bgShift.value * 0.2),
                radius: 1.3,
                colors: const [
                  Color(0xFF12513A), // brighter emerald glow center
                  Color(0xFF0F3D28),
                  Color(0xFF071B12), // dark forest edge
                ],
                stops: const [0.0, 0.5, 1.0],
              ),
            ),
            child: child,
          );
        },
        child: SafeArea(
          child: Stack(
            children: [
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Pulsing glow + logo (single image — icon, wordmark
                    // and tagline are all baked into this one asset, so
                    // it is only rendered once here)
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        AnimatedBuilder(
                          animation: _glowController,
                          builder: (context, _) {
                            return Transform.scale(
                              scale: _glowScale.value,
                              child: Container(
                                width: 260,
                                height: 260,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF2DC653)
                                          .withOpacity(_glowOpacity.value * 0.5),
                                      blurRadius: 60,
                                      spreadRadius: 20,
                                    ),
                                    BoxShadow(
                                      color: const Color(0xFFF59E0B)
                                          .withOpacity(_glowOpacity.value * 0.25),
                                      blurRadius: 40,
                                      spreadRadius: 6,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                        FadeTransition(
                          opacity: _logoFade,
                          child: ScaleTransition(
                            scale: _logoScale,
                            child: AnimatedBuilder(
                              animation: _logoRotation,
                              builder: (context, child) {
                                return Transform.rotate(
                                  angle: _logoRotation.value,
                                  child: child,
                                );
                              },
                              child: SlideTransition(
                                position: _textSlide,
                                child: FadeTransition(
                                  opacity: _textFade,
                                  child: const ReUseLogo(
                                    size: 190,
                                    showText: true,
                                    showTagline: true,
                                    isDarkBackground: true,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 6),

                    // Animated underline accent that draws itself in
                    AnimatedBuilder(
                      animation: _underlineWidth,
                      builder: (context, _) {
                        return Container(
                          height: 3,
                          width: 90 * _underlineWidth.value,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4),
                            gradient: const LinearGradient(
                              colors: [Color(0xFF2DC653), Color(0xFFF59E0B)],
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),

              // Bottom Attractive Eco-Recycle Loading Sign
              Positioned(
                bottom: 36,
                left: 0,
                right: 0,
                child: Center(
                  child: FadeTransition(
                    opacity: _textFade,
                    child: const ReUseLoadingSign(
                      size: 46,
                      message: AppConstants.subtitle,
                      isDark: true,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}