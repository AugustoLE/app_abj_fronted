import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/score_model.dart';
import '../models/user_model.dart';

class Suma {
  final int numero1;
  final int numero2;
  final int resultadoCorrecto;

  Suma({
    required this.numero1,
    required this.numero2,
    required this.resultadoCorrecto,
  });
}

class MathGame1Page extends StatefulWidget {
  final UserModel user;
  const MathGame1Page({Key? key, required this.user}) : super(key: key);

  @override
  State<MathGame1Page> createState() => _MathGame1PageState();
}

class _MathGame1PageState extends State<MathGame1Page> {
  Suma? sumaActual;
  List<int> opciones = [];
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
    final random = Random();
    final numero1 = random.nextInt(50) + 1;
    final numero2 = random.nextInt(50) + 1;
    final resultadoCorrecto = numero1 + numero2;

    sumaActual = Suma(
      numero1: numero1,
      numero2: numero2,
      resultadoCorrecto: resultadoCorrecto,
    );

    opciones = [
      resultadoCorrecto,
      resultadoCorrecto + random.nextInt(10) + 1,
      resultadoCorrecto - random.nextInt(10) - 1,
      resultadoCorrecto + random.nextInt(20) - 10,
    ]..shuffle();

    setState(() {
      inicioEjercicio = DateTime.now();
    });
  }

  String calcularNivel(int aciertos, int fallos) {
    final total = aciertos + fallos;
    final tasaAciertos = total > 0 ? aciertos / total : 0.0;
    if (tasaAciertos >= 0.8) return 'Avanzado';
    if (tasaAciertos >= 0.5) return 'Intermedio';
    return 'Principiante';
  }

  Future<void> _registrarPuntaje(ScoreModel score) async {
    try {
      final api = ApiService();
      print('📤 Enviando puntaje al backend: ${jsonEncode(score.toJson())}');
      await api.registerScore(widget.user.parentEmail, score);
      print('✅ Puntaje registrado con éxito para ${widget.user.parentEmail}');
    } catch (e, stackTrace) {
      print('❌ Error al registrar puntaje: $e\n$stackTrace');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al registrar puntaje: $e')),
      );
    }
  }

  void verificarRespuesta(int seleccion) {
    print('📝 Entrando en verificarRespuesta con selección: $seleccion');
    final esCorrecta = seleccion == sumaActual!.resultadoCorrecto;
    final ahora = DateTime.now();
    final duracion = ahora.difference(inicioEjercicio).inSeconds;

    final registro = {
      'juego': 'sumas',
      'respuesta': '$seleccion',
      'es_correcta': esCorrecta,
      'tiempo_segundos': duracion,
      'fecha_hora': ahora.toIso8601String(),
    };

    print('📝 Registro de respuesta: ${jsonEncode(registro)}');

    ejerciciosRealizados++;
    if (esCorrecta) {
      respuestasCorrectas++;
    } else {
      respuestasIncorrectas++;
    }

    mostrarResultado(
      esCorrecta: esCorrecta,
      respuestaCorrecta: sumaActual!.resultadoCorrecto.toString(),
    );
  }

  void mostrarResultado({
    required bool esCorrecta,
    required String respuestaCorrecta,
  }) {
    print('📊 Mostrando resultado: esCorrecta=$esCorrecta, ejerciciosRealizados=$ejerciciosRealizados');
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
              esCorrecta ? '¡Correcto!' : 'Respuesta Incorrecta',
              style: TextStyle(
                color: esCorrecta ? Color(0xFF123523) : Color(0xFFBD0000),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Text(
          esCorrecta
              ? '¡Muy bien hecho!'
              : 'La respuesta correcta era: $respuestaCorrecta',
          style: const TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            style: TextButton.styleFrom(foregroundColor: const Color(0xFF54ACAC)),
            child: const Text('Siguiente'),
            onPressed: () {
              Navigator.pop(context);
              print('🔄 Completado ejercicio $ejerciciosRealizados');
              if (ejerciciosRealizados >= 10) {
                print('🏁 Finalizando juego');
                mostrarResumenFinal();
              } else {
                generarNuevoEjercicio();
              }
            },
          ),
        ],
      ),
    );
  }

  void mostrarResumenFinal() {
    final finJuego = DateTime.now();
    final duracionTotal = finJuego.difference(inicioJuego).inSeconds;

    final score = ScoreModel(
      nombreJuego: 'sumas',
      aciertos: respuestasCorrectas,
      fallos: respuestasIncorrectas,
      tiempo: duracionTotal.toDouble(),
      nivel: calcularNivel(respuestasCorrectas, respuestasIncorrectas),
      fecha: finJuego,
    );

    print('📊 Generando resumen final: aciertos=$respuestasCorrectas, fallos=$respuestasIncorrectas');
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

  @override
  Widget build(BuildContext context) {
    if (sumaActual == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Juego de Sumas',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFBD0000),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Resuelve la suma',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF123523),
                    ),
                  ),
                  const SizedBox(height: 30),
                  Text(
                    '${sumaActual!.numero1} + ${sumaActual!.numero2} = ?',
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Selecciona la respuesta correcta:',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 30),
                  for (var opcion in opciones)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: ElevatedButton(
                        onPressed: () => verificarRespuesta(opcion),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF54ACAC),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text('$opcion', style: const TextStyle(fontSize: 20)),
                      ),
                    ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 40,
            left: 20,
            child: Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.home, size: 36, color: Colors.deepOrange),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),
        ],
      ),
    );
  }
}