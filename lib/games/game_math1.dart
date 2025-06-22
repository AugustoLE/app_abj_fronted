import 'dart:math';
import 'package:flutter/material.dart';
import 'dart:convert';

class MathGame1Page extends StatefulWidget {
  const MathGame1Page({super.key});

  @override
  State<MathGame1Page> createState() => _MathGame1PageState();
}

class _MathGame1PageState extends State<MathGame1Page> {
  final TextEditingController _controller = TextEditingController();
  late int num1, num2, resultado;
  late String operador;
  int? indiceOculto;

  final Random _random = Random();

  late DateTime inicioJuego;
  late DateTime inicioEjercicio;

  int contadorEjercicios = 0;
  int correctas = 0;
  int incorrectas = 0;

  final List<Map<String, dynamic>> registros = [];

  @override
  void initState() {
    super.initState();
    inicioJuego = DateTime.now();
    generarOperacion();
  }

  void generarOperacion() {
    final operadores = ['+', '-', '×', '÷'];
    operador = operadores[_random.nextInt(4)];
    indiceOculto = _random.nextInt(3);
    inicioEjercicio = DateTime.now();

    switch (operador) {
      case '+':
        num1 = _random.nextInt(20) + 1;
        num2 = _random.nextInt(20) + 1;
        resultado = num1 + num2;
        break;
      case '-':
        num1 = _random.nextInt(20) + 1;
        num2 = _random.nextInt(20) + 1;
        if (num2 > num1) {
          final temp = num1;
          num1 = num2;
          num2 = temp;
        }
        resultado = num1 - num2;
        break;
      case '×':
        num1 = _random.nextInt(5) + 1;
        num2 = _random.nextInt(5) + 1;
        resultado = num1 * num2;
        break;
      case '÷':
        num2 = _random.nextInt(5) + 1;
        resultado = _random.nextInt(5) + 1;
        num1 = num2 * resultado;
        break;
    }

    _controller.clear();
    setState(() {});
  }

  void verificarRespuesta() {
    int? respuesta = int.tryParse(_controller.text);
    int valorCorrecto;

    switch (indiceOculto) {
      case 0:
        valorCorrecto = num1;
        break;
      case 1:
        valorCorrecto = num2;
        break;
      default:
        valorCorrecto = resultado;
    }

    final esCorrecto = respuesta == valorCorrecto;
    final ahora = DateTime.now();
    final duracion = ahora.difference(inicioEjercicio).inSeconds;

    registros.add({
      'respuesta': respuesta,
      'es_correcta': esCorrecto,
      'tiempo_segundos': duracion,
      'fecha_hora': ahora.toIso8601String()
    });

    if (esCorrecto) {
      correctas++;
    } else {
      incorrectas++;
    }

    contadorEjercicios++;

    mostrarResultadoDialogo(
      esCorrecto: esCorrecto,
      respuestaCorrecta: valorCorrecto.toString(),
    );
  }

  void mostrarResultadoDialogo({
    required bool esCorrecto,
    required String respuestaCorrecta,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: Colors.white,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            border: Border.all(
              color: esCorrecto ? Colors.green.shade600 : Colors.red.shade600,
              width: 3,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                esCorrecto ? Icons.check_circle_outline : Icons.cancel_outlined,
                size: 48,
                color: esCorrecto ? Colors.green : Colors.red,
              ),
              const SizedBox(height: 12),
              Text(
                esCorrecto ? '¡Correcto!' : 'Incorrecto',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: esCorrecto ? Colors.green.shade800 : Colors.red.shade800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                esCorrecto
                    ? '¡Muy bien! Sigue así.'
                    : 'La respuesta correcta era: $respuestaCorrecta',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  if (contadorEjercicios >= 10) {
                    mostrarResumenFinal();
                  } else {
                    generarOperacion();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF54ACAC),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Continuar'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void mostrarResumenFinal() {
    final finJuego = DateTime.now();
    final duracionTotal = finJuego.difference(inicioJuego).inSeconds;

    final resumenJson = {
      'juego': 'operaciones',
      'fecha_inicio': inicioJuego.toIso8601String(),
      'fecha_fin': finJuego.toIso8601String(),
      'duracion_total_segundos': duracionTotal,
      'correctas': correctas,
      'incorrectas': incorrectas,
    };

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: Colors.white,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFF54ACAC), width: 3),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.emoji_events, size: 48, color: Color(0xFFBD0000)),
              const SizedBox(height: 12),
              const Text(
                '¡Juego Finalizado!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF123523),
                ),
              ),
              const SizedBox(height: 16),
              Text('Correctas: $correctas', style: const TextStyle(fontSize: 16)),
              Text('Incorrectas: $incorrectas', style: const TextStyle(fontSize: 16)),
              Text('Duración total: $duracionTotal segundos',
                  style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context); // cerrar diálogo
                      Navigator.pop(context); // ir al menú principal
                    },
                    icon: const Icon(Icons.home),
                    label: const Text('Menú'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFBD0000),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        contadorEjercicios = 0;
                        correctas = 0;
                        incorrectas = 0;
                        registros.clear();
                        inicioJuego = DateTime.now();
                      });
                      Navigator.pop(context);
                      generarOperacion();
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Reintentar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF54ACAC),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String hint, bool oculto, String? valor) {
    return SizedBox(
      width: 100,
      height: 60,
      child: oculto
          ? TextField(
        controller: _controller,
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(fontSize: 28, color: Colors.grey),
          border: const OutlineInputBorder(),
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
        ),
        style: const TextStyle(fontSize: 28),
        textInputAction: TextInputAction.done,
      )
          : Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          valor ?? '',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 28),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Center(
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    const Text(
                      'Juego Matemático',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFBD0000),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Operaciones matemáticas',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF123523),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 40),
                    screenWidth > 600
                        ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildTextField(' ?', indiceOculto == 0, '$num1'),
                        const SizedBox(width: 10),
                        Text(operador, style: const TextStyle(fontSize: 24)),
                        const SizedBox(width: 10),
                        _buildTextField(' ?', indiceOculto == 1, '$num2'),
                        const SizedBox(width: 10),
                        const Text('=', style: TextStyle(fontSize: 24)),
                        const SizedBox(width: 10),
                        _buildTextField(' ?', indiceOculto == 2, '$resultado'),
                      ],
                    )
                        : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildTextField(' ?', indiceOculto == 0, '$num1'),
                        const SizedBox(height: 8),
                        Text(operador, style: const TextStyle(fontSize: 24)),
                        const SizedBox(height: 8),
                        _buildTextField(' ?', indiceOculto == 1, '$num2'),
                        const SizedBox(height: 8),
                        const Text('=', style: TextStyle(fontSize: 24)),
                        const SizedBox(height: 8),
                        _buildTextField(' ?', indiceOculto == 2, '$resultado'),
                      ],
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: verificarRespuesta,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF54ACAC),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                        textStyle: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: const BorderSide(color: Color(0xFF223030), width: 1),
                        ),
                        elevation: 4,
                      ),
                      child: const Text('Comprobar'),
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),

            // Botón de regreso al menú
            Positioned(
              top: 16,
              left: 16,
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: Colors.teal.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.home, size: 32, color: Colors.teal),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
