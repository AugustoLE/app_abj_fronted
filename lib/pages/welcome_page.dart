import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:fronted_abj/core/boton_audio_widget.dart';
import '../core/audio_controller.dart';
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

  final AudioPlayer _player = AudioPlayer();
  bool isMuted = false;

  @override
  void initState() {
    super.initState();

    _logoController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    )..repeat(reverse: true);

    _logoAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeInOut),
    );

    _textController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 1),
    );

    _textOffsetAnimation = Tween<Offset>(
      begin: Offset(0.0, -1.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _textController, curve: Curves.bounceOut));

    _textController.forward();
    _startMusic();
  }

  Future<void> _startMusic() async {
    await _player.setReleaseMode(ReleaseMode.loop);
    await _player.setVolume(1.0);
    await _player.play(AssetSource('audio/musica.mp3'));
  }

  void _toggleMute() {
    setState(() {
      isMuted = !isMuted;
      _player.setVolume(isMuted ? 0.0 : 1.0);
    });
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    _player.dispose();
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
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.only(bottom: 80), // deja espacio para el botón
            child: Center(
              child: Padding(
                padding: EdgeInsets.all(screenWidth * 0.06),
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: 600),
                  child: Column(
                    children: [
                      SizedBox(height: screenHeight * 0.05),

                      ScaleTransition(
                        scale: _logoAnimation,
                        child: Image.asset(
                          'assets/Imagenes/imagenes_bienvenida/logo.png',
                          width: screenWidth * 0.6,
                          height: screenWidth * 0.6,
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.03),

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
          // ✅ Botón de volumen en esquina inferior derecha
          Positioned(
            bottom: 16,
            right: 16,
            child: BotonAudioWidget(),
          ),
        ],
      ),
    );
  }
}
