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

    // Animación de zoom del logo
    _logoController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    )..repeat(reverse: true);

    _logoAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeInOut),
    );

    // Animación de entrada para el texto
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
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          'Aprendizaje ABJ 🕹️',
          style: TextStyle(
            fontSize: (screenWidth * 0.03).clamp(16.0, 24.0),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        actions: [
          TextButton(
            onPressed: () => Navigator.pushNamed(context, '/register'),
            child: Text(
              'Registrarse',
              style: TextStyle(
                color: Colors.blue,
                fontSize: (screenWidth * 0.03).clamp(14.0, 18.0),
              ),
            ),
          ),
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
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(screenWidth * 0.06),
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 600),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: screenHeight * 0.05),

                  // Logo animado
                  ScaleTransition(
                    scale: _logoAnimation,
                    child: Image.asset(
                      '../assets/Imagenes/imagenes_bienvenida/logo.png',
                      width: screenWidth * 0.6,
                      height: screenWidth * 0.6,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.03),

                  // Texto animado de bienvenida
                  SlideTransition(
                    position: _textOffsetAnimation,
                    child: Text(
                      '🎉 Bienvenido a la APP ABJ 🎮',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: (screenWidth * 0.05).clamp(20.0, 28.0),
                        fontWeight: FontWeight.bold,
                        color: Colors.teal,
                      ),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.015),

                  Text(
                    '¡Aprende y diviértete!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: (screenWidth * 0.035).clamp(14.0, 20.0),
                      color: Colors.grey[700],
                    ),
                  ),

                  SizedBox(height: screenHeight * 0.05),
                ],
              ),
            ),
          ),
        ),
      ),
      backgroundColor: Colors.white,
    );
  }
}