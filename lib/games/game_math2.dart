import 'dart:math';
import 'package:flutter/material.dart';
import 'dart:convert';
import '../services/api_service.dart';
import '../models/score_model.dart';
import '../models/user_model.dart';

class MathGame2Page extends StatefulWidget {
  final UserModel user; // Añadido para recibir el usuario
  const MathGame2Page({super.key, required this.user});

  @override
  State<MathGame2Page> createState() => _MathGame2PageState();
}

class _MathGame2PageState extends State<MathGame2Page> {
  final Map<String, String> tipoImagenes = {
    'A - B': 'A-B.png',
    'B - A': 'B-A.png',
    'A ∩ B': 'A∩B.png',
    'A ∪ B': 'AUB.png',
    'A Δ B': 'AΔB.png',
  };

  late String tipoCorrecto;
  late List<String> opciones;
  String? seleccion;
  late DateTime inicioEjercicio;
  late DateTime inicioJuego;

  int ejerciciosRealizados = 0;
  int respuestasCorrectas = 0;
  int respuestasIncorrectas = 0;

  @override
  void initState() {
    super.initState();
    reiniciarJuego();
  }

  void reiniciarJuego() {
    ejerciciosRealizados = 0;
    respuestasCorrectas = 0;
    respuestasIncorrectas = 0;
    inicioJuego = DateTime.now();
    generarNuevoEjercicio();
  }

  void generarNuevoEjercicio() {
    inicioEjercicio = DateTime.now();
    final tipos = tipoImagenes.keys.toList();
    tipoCorrecto = tipos[Random().nextInt(tipos.length)];
    opciones = [tipoCorrecto];

    while (opciones.length < 3) {
      final opcion = tipos[Random().nextInt(tipos.length)];
      if (!opciones.contains(opcion)) {
        opciones.add(opcion);
      }
    }

    opciones.shuffle();
    seleccion = null;
    setState(() {});
  }

  String calcularNivel(int aciertos, int fallos) {
    final tasaAciertos = aciertos / (aciertos + fallos);
    if (tasaAciertos >= 0.8) return 'Avanzado';
    if (tasaAciertos >= 0.5) return 'Intermedio';
    return 'Principiante';
  }

  Future<void> _registrarPuntaje(ScoreModel score) async {
    try {
      final api = ApiService();
      await api.registerScore(widget.user.parentEmail, score);
      print('✅ Puntaje registrado con éxito');
    } catch (e) {
      print('❌ Error al registrar puntaje: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al registrar puntaje')),
      );
    }
  }

  void mostrarNotificacionResultado({
    required bool esCorrecta,
    required String respuestaCorrecta,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFFF2FDFD),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(
              esCorrecta ? Icons.check_circle : Icons.cancel,
              color: esCorrecta ? Color(0xFF123523) : Color(0xFFBD0000),
              size: 28,
            ),
            const SizedBox(width: 8),
            Text(
              esCorrecta ? '¡Respuesta Correcta!' : '¡Respuesta Incorrecta!',
              style: TextStyle(
                color: esCorrecta ? Color(0xFF123523) : Color(0xFFBD0000),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Text(
          esCorrecta ? '¡Muy bien hecho!' : 'La respuesta correcta era: $respuestaCorrecta',
          style: const TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            style: TextButton.styleFrom(foregroundColor: const Color(0xFF54ACAC)),
            child: const Text('Siguiente'),
            onPressed: () {
              Navigator.pop(context);
              if (ejerciciosRealizados >= 10) {
                mostrarNotificacionFinal();
              } else {
                generarNuevoEjercicio();
              }
            },
          ),
        ],
      ),
    );
  }

  void mostrarNotificacionFinal() {
    final finJuego = DateTime.now();
    final duracionTotal = finJuego.difference(inicioJuego).inSeconds;

    final score = ScoreModel(
      nombreJuego: 'conjuntos',
      aciertos: respuestasCorrectas,
      fallos: respuestasIncorrectas,
      tiempo: duracionTotal.toDouble(),
      nivel: calcularNivel(respuestasCorrectas, respuestasIncorrectas),
      fecha: finJuego,
    );

    _registrarPuntaje(score);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFFF2FDFD),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: const [
            Icon(Icons.bar_chart, color: Color(0xFF123523), size: 28),
            SizedBox(width: 8),
            Text(
              'Resumen del Juego',
              style: TextStyle(
                color: Color(0xFF123523),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Text(
          '✅ Correctas: $respuestasCorrectas\n❌ Incorrectas: $respuestasIncorrectas\n⏱️ Duración: ${duracionTotal}s\n📊 Nivel: ${calcularNivel(respuestasCorrectas, respuestasIncorrectas)}',
          style: const TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              reiniciarJuego();
            },
            child: const Text(
              'Volver a intentar',
              style: TextStyle(color: Color(0xFF123523)),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text(
              'Menú',
              style: TextStyle(color: Color(0xFFBD0000)),
            ),
          ),
        ],
      ),
    );
  }

  void verificarRespuesta() {
    if (seleccion == null) return;

    final esCorrecta = seleccion == tipoCorrecto;
    final ahora = DateTime.now();
    final duracion = ahora.difference(inicioEjercicio).inSeconds;

    final registro = {
      'juego': 'conjuntos',
      'respuesta': seleccion,
      'es_correcta': esCorrecta,
      'tiempo_segundos': duracion,
      'fecha_hora': ahora.toIso8601String(),
    };

    print(jsonEncode(registro));

    ejerciciosRealizados++;
    if (esCorrecta) {
      respuestasCorrectas++;
    } else {
      respuestasIncorrectas++;
    }

    mostrarNotificacionResultado(
      esCorrecta: esCorrecta,
      respuestaCorrecta: tipoCorrecto,
    );
  }

  Widget construirOpcion(String texto) {
    return GestureDetector(
      onTap: () => setState(() => seleccion = texto),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Radio<String>(
            value: texto,
            groupValue: seleccion,
            activeColor: const Color(0xFF54ACAC),
            fillColor: MaterialStateProperty.all(const Color(0xFF54ACAC)),
            onChanged: (valor) => setState(() => seleccion = valor),
          ),
          Text(texto, style: const TextStyle(fontSize: 18)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final nombreImagen = tipoImagenes[tipoCorrecto]!;
    final size = MediaQuery.of(context).size;
    final imagenAncho = size.width * 0.7;
    final imagenAlto = size.height * 0.35;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Juego Matemático',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFBD0000),
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Tipo de conjuntos',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF123523),
                  ),
                ),
                const SizedBox(height: 50),
                Image.asset(
                  'assets/Imagenes/Juegos/JuegosMate/Juego2/graphics/$nombreImagen',
                  width: imagenAncho,
                  height: imagenAlto,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 20),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 20,
                  children: opciones.map((o) => construirOpcion(o)).toList(),
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: seleccion != null ? verificarRespuesta : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF54ACAC),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 20,
                    ),
                    textStyle: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: const BorderSide(
                        color: Color(0xFF223030),
                        width: 1,
                      ),
                    ),
                    elevation: 4,
                  ),
                  child: const Text('Comprobar'),
                ),
              ],
            ),
          ),
          Positioned(
            top: 40,
            left: 20,
            child: Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: Colors.teal.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.home, size: 36, color: Colors.teal),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),
        ],
      ),
    );
  }
}