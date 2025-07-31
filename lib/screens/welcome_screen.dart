import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'signup_screen.dart';
import 'login_screen.dart';

class WelcomeScreen extends StatefulWidget {
  static const routeName = '/Welcome';
  const WelcomeScreen({super.key});

  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _textController;
  late AnimationController _buttonController;
  late AnimationController _particleController;
  late AnimationController _pulseController;

  late Animation<double> _logoFadeAnimation;
  late Animation<double> _logoScaleAnimation;
  late Animation<double> _glowAnimation;
  late Animation<Offset> _textSlideAnimation;
  late Animation<double> _textFadeAnimation;
  late Animation<double> _buttonSlideAnimation;
  late Animation<double> _pulseAnimation;

  String _displayedText = '';
  final String _fullText = 'ShieldUp';
  bool _showButtons = false;

  @override
  void initState() {
    super.initState();

    _logoController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _textController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _buttonController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _particleController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    // Logo animations
    _logoFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeInOut),
      ),
    );

    _logoScaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.0, 0.8, curve: Curves.elasticOut),
      ),
    );

    _glowAnimation = Tween<double>(begin: 0.0, end: 15.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.4, 1.0, curve: Curves.easeInOut),
      ),
    );

    // Text animations
    _textSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.8),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeOutCubic),
    );

    _textFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeInOut),
    );

    // Button animation - changed to fade and scale instead of slide
    _buttonSlideAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _buttonController, curve: Curves.easeOutCubic),
    );

    // Pulse animation
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _startAnimationSequence();
    _particleController.repeat();
    _pulseController.repeat(reverse: true);
  }

  void _startAnimationSequence() async {
    // Start logo animation
    await _logoController.forward();

    // Start text animation
    _textController.forward();
    await _startTextTypewriter();

    // Show buttons
    setState(() => _showButtons = true);
    _buttonController.forward();
  }

  Future<void> _startTextTypewriter() async {
    // FIXED: Slower typewriter animation - increased delay from 120ms to 250ms
    for (int i = 0; i <= _fullText.length; i++) {
      await Future.delayed(const Duration(milliseconds: 250));
      if (mounted) {
        setState(() {
          _displayedText = _fullText.substring(0, i);
        });
      }
    }
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    _buttonController.dispose();
    _particleController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1A2E23), Color(0xFF004D40), Color(0xFF00695C)],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              _buildParticleBackground(size),
              _buildFloatingElements(size),
              Center(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Logo section
                        _buildAnimatedLogo(),
                        const SizedBox(height: 50),

                        // Title section
                        _buildAnimatedTitle(),
                        const SizedBox(height: 32),

                        // Description
                        _buildDescription(),
                        const SizedBox(height: 80),

                        // Action buttons
                        _buildActionButtons(),
                      ],
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

  Widget _buildAnimatedLogo() {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _logoFadeAnimation,
        _logoScaleAnimation,
        _glowAnimation,
        _pulseAnimation,
      ]),
      builder: (context, child) {
        return FadeTransition(
          opacity: _logoFadeAnimation,
          child: ScaleTransition(
            scale: _logoScaleAnimation,
            child: Transform.scale(
              scale: _pulseAnimation.value,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      blurRadius: _glowAnimation.value,
                      color: Colors.tealAccent.withOpacity(0.6),
                      spreadRadius: 5,
                    ),
                    BoxShadow(
                      blurRadius: _glowAnimation.value * 2,
                      color: Colors.teal.withOpacity(0.3),
                      spreadRadius: 10,
                    ),
                  ],
                ),
                child: ClipOval(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          Colors.teal.shade400.withOpacity(0.2),
                          Colors.transparent,
                        ],
                      ),
                    ),
                    child: Image.asset(
                      'assets/images/icon3.png',
                      height: 180,
                      width: 180,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAnimatedTitle() {
    return SlideTransition(
      position: _textSlideAnimation,
      child: FadeTransition(
        opacity: _textFadeAnimation,
        child: ShaderMask(
          shaderCallback:
              (bounds) => const LinearGradient(
                colors: [Colors.white, Colors.tealAccent, Colors.white],
                stops: [0.0, 0.5, 1.0],
              ).createShader(bounds),
          child: Text(
            _displayedText,
            style: GoogleFonts.orbitron(
              fontSize: 52,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: 4.0,
              shadows: [
                Shadow(
                  blurRadius: 20.0,
                  color: Colors.tealAccent.withOpacity(0.8),
                  offset: const Offset(0, 4),
                ),
                Shadow(
                  blurRadius: 40.0,
                  color: Colors.teal.withOpacity(0.5),
                  offset: const Offset(0, 8),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDescription() {
    return FadeTransition(
      opacity: _textFadeAnimation,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Text(
          "Secure Your Future with Confidence",
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            fontSize: 22,
            color: Colors.white.withOpacity(0.9),
            fontWeight: FontWeight.w500,
            letterSpacing: 1.2,
            height: 1.4,
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    if (!_showButtons) return const SizedBox(height: 60);

    return AnimatedBuilder(
      animation: _buttonSlideAnimation,
      builder: (context, child) {
        return FadeTransition(
          opacity: _buttonSlideAnimation,
          child: Transform.scale(
            scale:
                0.8 +
                (_buttonSlideAnimation.value * 0.2), // Scale from 0.8 to 1.0
            child: Column(
              children: [
                // Primary button
                Container(
                  width: double.infinity,
                  height: 60,
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    gradient: LinearGradient(
                      colors: [Colors.teal.shade400, Colors.teal.shade600],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.teal.withOpacity(
                          0.4 * _buttonSlideAnimation.value,
                        ),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        PageRouteBuilder(
                          pageBuilder:
                              (context, animation, secondaryAnimation) =>
                                  const SignupScreen(),
                          transitionsBuilder: (
                            context,
                            animation,
                            secondaryAnimation,
                            child,
                          ) {
                            return FadeTransition(
                              opacity: animation,
                              child: SlideTransition(
                                position: Tween<Offset>(
                                  begin: const Offset(0.0, 0.1),
                                  end: Offset.zero,
                                ).animate(
                                  CurvedAnimation(
                                    parent: animation,
                                    curve: Curves.easeOutCubic,
                                  ),
                                ),
                                child: child,
                              ),
                            );
                          },
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Image.asset(
                            'assets/images/icon3.png',
                            height: 32,
                            width: 32,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Text(
                          "Get Started",
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                            letterSpacing: 1.0,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Icon(
                          Icons.arrow_forward_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Secondary button
                Container(
                  width: double.infinity,
                  height: 60,
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        PageRouteBuilder(
                          pageBuilder:
                              (context, animation, secondaryAnimation) =>
                                  const LoginScreen(),
                          transitionsBuilder: (
                            context,
                            animation,
                            secondaryAnimation,
                            child,
                          ) {
                            return FadeTransition(
                              opacity: animation,
                              child: SlideTransition(
                                position: Tween<Offset>(
                                  begin: const Offset(0.0, -0.1),
                                  end: Offset.zero,
                                ).animate(
                                  CurvedAnimation(
                                    parent: animation,
                                    curve: Curves.easeOutCubic,
                                  ),
                                ),
                                child: child,
                              ),
                            );
                          },
                        ),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                        color: Colors.tealAccent.shade100.withOpacity(
                          _buttonSlideAnimation.value,
                        ),
                        width: 2,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: Text(
                      "I Already Have an Account",
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: Colors.tealAccent.shade100.withOpacity(
                          _buttonSlideAnimation.value,
                        ),
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildParticleBackground(Size size) {
    return AnimatedBuilder(
      animation: _particleController,
      builder: (context, child) {
        return Stack(
          children: [
            CustomPaint(
              painter: ParticlePainter(
                _particleController.value,
                count: 30,
                color: Colors.teal.withOpacity(0.1),
                speed: 0.5,
              ),
              size: size,
            ),
            CustomPaint(
              painter: ParticlePainter(
                _particleController.value,
                count: 20,
                color: Colors.tealAccent.withOpacity(0.08),
                speed: 0.3,
              ),
              size: size,
            ),
          ],
        );
      },
    );
  }

  Widget _buildFloatingElements(Size size) {
    return AnimatedBuilder(
      animation: _particleController,
      builder: (context, child) {
        return Stack(
          children: List.generate(8, (index) {
            final random = Random(index);
            final x = random.nextDouble() * size.width;
            final y = random.nextDouble() * size.height;
            final offset = sin(_particleController.value * 2 * pi + index) * 20;

            return Positioned(
              left: x + offset,
              top: y + offset * 0.5,
              child: Container(
                width: 4 + random.nextDouble() * 8,
                height: 4 + random.nextDouble() * 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.tealAccent.withOpacity(0.3),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.tealAccent.withOpacity(0.5),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
              ),
            );
          }),
        );
      },
    );
  }
}

class ParticlePainter extends CustomPainter {
  final double animationValue;
  final int count;
  final Color color;
  final double speed;

  ParticlePainter(
    this.animationValue, {
    required this.count,
    required this.color,
    this.speed = 1.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = color
          ..style = PaintingStyle.fill;

    final random = Random(42);

    for (int i = 0; i < count; i++) {
      double baseX = random.nextDouble() * size.width;
      double baseY = random.nextDouble() * size.height;

      double x = baseX + sin(animationValue * 2 * pi * speed + i) * 30;
      double y = baseY + cos(animationValue * 2 * pi * speed + i) * 20;

      double radius = 1.0 + random.nextDouble() * 3.0;

      // Keep particles within bounds
      x = x.clamp(0, size.width);
      y = y.clamp(0, size.width);

      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
