import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PalabraOrtografia {
  final String correcta;
  final String incorrecta;
  final int tipoError;

  PalabraOrtografia({
    required this.correcta,
    required this.incorrecta,
    required this.tipoError,
  });

  factory PalabraOrtografia.fromCsv(String line) {
    final parts = line.split(',');
    return PalabraOrtografia(
      correcta: parts[0].trim(),
      incorrecta: parts[1].trim(),
      tipoError: int.tryParse(parts[2].trim()) ?? 0,
    );
  }
}

class CommGame1Page extends StatefulWidget {
  const CommGame1Page({Key? key}) : super(key: key);

  @override
  State<CommGame1Page> createState() => _CommGame1PageState();
}

class _CommGame1PageState extends State<CommGame1Page> {
  List<PalabraOrtografia> palabras = [];
  PalabraOrtografia? palabraActual;
  List<String> opciones = [];
  late DateTime inicioEjercicio;
  late DateTime inicioJuego;

  int ejerciciosRealizados = 0;
  int respuestasCorrectas = 0;
  int respuestasIncorrectas = 0;

  @override
  void initState() {
    super.initState();
    cargarCSV();
  }

  Future<void> cargarCSV() async {
    final csvString = await rootBundle.loadString('assets/Imagenes/Juegos/files/palabrasJuegoOrtografia.csv');
    final lines = csvString.split('\n');
    final data = lines
        .skip(1)
        .where((line) => line.trim().isNotEmpty && line.contains(','))
        .map(PalabraOrtografia.fromCsv)
        .toList();

    palabras = data;
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
    setState(() {
      palabraActual = (palabras..shuffle()).first;
      opciones = [palabraActual!.correcta, palabraActual!.incorrecta]..shuffle();
      inicioEjercicio = DateTime.now();
    });
  }

  void verificarRespuesta(String seleccion) {
    final esCorrecta = seleccion == palabraActual!.correcta;
    final ahora = DateTime.now();
    final duracion = ahora.difference(inicioEjercicio).inSeconds;

    final registro = {
      'juego': 'ortografia',
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

    mostrarResultado(
      esCorrecta: esCorrecta,
      respuestaCorrecta: palabraActual!.correcta,
    );
  }

  void mostrarResultado({
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
              if (ejerciciosRealizados >= 10) {
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

    final jsonFinal = {
      'juego': 'ortografia',
      'fecha_hora_inicio': inicioJuego.toIso8601String(),
      'fecha_hora_fin': finJuego.toIso8601String(),
      'duracion_total_segundos': duracionTotal,
      'correctas': respuestasCorrectas,
      'incorrectas': respuestasIncorrectas,
    };

    print(jsonEncode(jsonFinal));

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
          '✅ Correctas: $respuestasCorrectas\n❌ Incorrectas: $respuestasIncorrectas\n⏱️ Duración: ${duracionTotal}s',
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
    if (palabraActual == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final rutaImagen = 'assets/Imagenes/Juegos/JuegosComu/Juego1/${palabraActual!.correcta}.png';

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
                    'Juego de Ortografía',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFBD0000),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Palabras correctas e incorrectas',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF123523),
                    ),
                  ),
                  const SizedBox(height: 30),
                  Image.asset(
                    rutaImagen,
                    height: MediaQuery.of(context).size.height * 0.3,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return const Text('Imagen no encontrada');
                    },
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Selecciona la palabra correcta:',
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
                        child: Text(opcion, style: const TextStyle(fontSize: 20)),
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