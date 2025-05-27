import 'package:flutter/material.dart';
import 'package:myappon/screens/auth_screen.dart';
import 'package:myappon/screens/home_screen.dart';
import 'package:myappon/services/auth_service.dart';
import 'package:myappon/services/clipboard_service.dart';
import 'package:provider/provider.dart';


class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeIn,
      ),
    );

    _controller.forward();

    // Check auth state after animation completes
    Future.delayed(const Duration(seconds: 3), () {
      final authService = context.read<AuthService>();
      
      if (!authService.isLoading) {
        _navigateToNextScreen();
      } else {
        // Wait for auth to complete
        authService.addListener(_onAuthStateChanged);
      }
    });
  }

  void _onAuthStateChanged() {
    final authService = context.read<AuthService>();
    if (!authService.isLoading) {
      authService.removeListener(_onAuthStateChanged);
      _navigateToNextScreen();
    }
  }

  void _navigateToNextScreen() {
    final authService = context.read<AuthService>();
    
    // Navigate to home if logged in, auth screen otherwise
    if (authService.isLoggedIn) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => ChangeNotifierProvider(
          create: (_) => ClipboardService(),
          child: const HomeScreen(),
        )),
      );
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const AuthScreen()),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).colorScheme.primary,
              Theme.of(context).colorScheme.secondary,
            ],
          ),
        ),
        child: Center(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.content_paste_rounded,
                  size: 100,
                  color: Colors.white,
                ),
                const SizedBox(height: 20),
                Text(
                  'Online Clipboard',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Sync clipboard across all your devices',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 40),
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}