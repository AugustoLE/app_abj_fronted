import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/api_service.dart';
import '../models/score_model.dart';
import '../models/user_model.dart';

class ParteCuerpo {
  final String parte;
  final String ubicacion;
  final String descripcion;

  ParteCuerpo({
    required this.parte,
    required this.ubicacion,
    required this.descripcion,
  });

  factory ParteCuerpo.fromCsv(String line) {
    final parts = line.split(',');
    return ParteCuerpo(
      parte: parts[0].trim(),
      ubicacion: parts[1].trim(),
      descripcion: parts[2].trim(),
    );
  }
}

class SciGame1Page extends StatefulWidget {
  final UserModel user; // Añadido para recibir el usuario
  const SciGame1Page({super.key, required this.user});
  @override
  State<SciGame1Page> createState() => _SciGame1PageState();
}

class _SciGame1PageState extends State<SciGame1Page> {
  List<ParteCuerpo> partes = [];
  ParteCuerpo? parteActual;
  List<String> opciones = [];
  int aciertos = 0;
  int errores = 0;
  int ejerciciosRealizados = 0;
  final int totalEjercicios = 10;
  late DateTime inicioJuego;
  late DateTime inicioEjercicio;

  @override
  void initState() {
    super.initState();
    cargarCSV();
  }

  Future<void> cargarCSV() async {
    final csvString = await rootBundle.loadString('assets/Imagenes/Juegos/files/partesDelCuerpoCien.csv');
    final lines = csvString.split('\n');
    final data = lines
        .skip(1)
        .where((line) => line.trim().isNotEmpty && line.contains(','))
        .map(ParteCuerpo.fromCsv)
        .toList();

    setState(() {
      partes = data;
      inicioJuego = DateTime.now();
      generarNuevoEjercicio();
    });
  }

  void generarNuevoEjercicio() {
    if (ejerciciosRealizados >= totalEjercicios) {
      mostrarResumenFinal();
      return;
    }

    final aleatorio = Random();
    parteActual = (partes..shuffle()).first;

    final otrasOpciones = partes
        .where((p) => p.parte != parteActual!.parte)
        .toList()
      ..shuffle();

    opciones = [
      parteActual!.parte,
      otrasOpciones[0].parte,
      otrasOpciones[1].parte
    ]..shuffle();

    inicioEjercicio = DateTime.now();
    setState(() {});
  }

  void verificarRespuesta(String seleccion) {
    final esCorrecta = seleccion == parteActual!.parte;
    final ahora = DateTime.now();
    final duracion = ahora.difference(inicioEjercicio).inSeconds;

    if (esCorrecta) {
      aciertos++;
    } else {
      errores++;
    }

    ejerciciosRealizados++;

    final registro = {
      'juego': 'anatomia',
      'respuesta': seleccion,
      'correcta': parteActual!.parte,
      'es_correcta': esCorrecta,
      'tiempo_segundos': duracion,
      'fecha_hora': ahora.toIso8601String(),
    };

    print(jsonEncode(registro));

    mostrarResultado(esCorrecta);
  }

  void mostrarResultado(bool esCorrecta) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          esCorrecta ? '¡Correcto!' : 'Incorrecto',
          style: TextStyle(
            color: esCorrecta ? Colors.green : Colors.red,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Parte: ${parteActual!.parte}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text('Ubicación: ${parteActual!.ubicacion}'),
            const SizedBox(height: 4),
            Text('Descripción: ${parteActual!.descripcion}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              generarNuevoEjercicio();
            },
            child: const Text('Siguiente'),
          ),
        ],
      ),
    );
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

  void mostrarResumenFinal() {
    final finJuego = DateTime.now();
    final duracionTotal = finJuego.difference(inicioJuego).inSeconds;
    String nivel;

    final resumen = {
      'juego': 'anatomia',
      'inicio': inicioJuego.toIso8601String(),
      'fin': finJuego.toIso8601String(),
      'duracion_segundos': duracionTotal,
      'aciertos': aciertos,
      'errores': errores,
    };

    final score = ScoreModel(
      nombreJuego: 'ParteCuerpo',
      aciertos: aciertos,
      fallos: errores,
      tiempo: duracionTotal.toDouble(),
      nivel: calcularNivel(aciertos, errores),
      fecha: DateTime.now(),
    );
    _registrarPuntaje(score);

    print(jsonEncode(resumen));

    nivel = score.nivel.toString();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text(
          '¡Juego Finalizado!',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF006600),
          ),
        ),
        content: Text(
          'Aciertos: $aciertos\n''Errores: $errores\n''Nivel alcanzado: $nivel', // 👈 mostramos el nivel aquí
        ),
        actions: [
          TextButton(
            onPressed: reiniciarJuego,
            child: const Text('Volver a intentar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Menú'),
          ),
        ],
      ),
    );
  }

  void reiniciarJuego() {
    setState(() {
      aciertos = 0;
      errores = 0;
      ejerciciosRealizados = 0;
      inicioJuego = DateTime.now();
      generarNuevoEjercicio();
      Navigator.of(context).pop(); // Cierra el diálogo final
    });
  }

  @override
  Widget build(BuildContext context) {
    if (parteActual == null) {
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
                    'Juego Partes del Cuerpo Humano',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF006600),
                    ),
                  ),
                  const SizedBox(height: 30),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Image.asset(
                      'assets/Imagenes/Juegos/JuegosCien/Juego1/${parteActual!.parte}.png',
                      fit: BoxFit.contain,
                      height: MediaQuery.of(context).size.height * 0.35,
                    ),
                  ),
                  const SizedBox(height: 30),
                  for (var opcion in opciones)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10.0),
                      child: ElevatedButton(
                        onPressed: () => verificarRespuesta(opcion),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 40,
                            vertical: 16,
                          ),
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
                color: Colors.green.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.home, size: 36, color: Colors.green),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),
        ],
      ),
    );
  }
}