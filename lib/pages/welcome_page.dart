import 'package:flutter/material.dart';
import 'dart:math' as math;

class WelcomePage extends StatefulWidget {
  @override
  _WelcomePageState createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> with TickerProviderStateMixin {
  late AnimationController _logoController;
  late Animation<double> _logoAnimation;

  late AnimationController _textController;
  late Animation<Offset> _textOffsetAnimation;

  @override
  void initState() {
    super.initState();

    // Animación del logo
    _logoController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    )..repeat(reverse: true);

    _logoAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeInOut),
    );

    // Animación del texto
    _textController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 1),
    );

    _textOffsetAnimation = Tween<Offset>(
      begin: Offset(0.0, -1.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _textController, curve: Curves.bounceOut));

    _textController.forward();
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        title: Text(
          'ABC Games 🕹️',
          style: TextStyle(
            fontSize: (screenWidth * 0.03).clamp(16.0, 24.0),
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        elevation: 0,
        actions: [
          TextButton(
            onPressed: () => Navigator.pushNamed(context, '/login'),
            child: Text(
              'Iniciar Sesión',
              style: TextStyle(
                color: Colors.blue,
                fontSize: (screenWidth * 0.03).clamp(14.0, 18.0),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo animado
            ScaleTransition(
              scale: _logoAnimation,
              child: Image.asset(
                'assets/Imagenes/imagenes_bienvenida/logo.png',
                width: screenWidth * 0.6,
                height: screenWidth * 0.6,
              ),
            ),

            SizedBox(height: screenHeight * 0.03),

            // Texto principal animado
            SlideTransition(
              position: _textOffsetAnimation,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  'BIENVENIDO A ANIMAL COLORES "ABC"',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: (screenWidth * 0.04).clamp(20.0, 28.0),
                    fontWeight: FontWeight.bold,
                    color: Colors.teal,
                  ),
                ),
              ),
            ),

            SizedBox(height: screenHeight * 0.015),

            // Texto secundario con ancho limitado
            Container(
              padding: const EdgeInsets.only(bottom: 32.0, top: 8.0),
              constraints: BoxConstraints(maxWidth: 280),
              child: Text(
                '¡La forma divertida, efectiva y gratis de aprender!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: (screenWidth * 0.030).clamp(14.0, 20.0),
                  color: Colors.grey[700],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}