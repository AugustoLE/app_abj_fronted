import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/api_service.dart';
import '../models/score_model.dart';
import '../models/user_model.dart';

class Animal {
  final String nombre;
  final String tipoNacimiento;
  final String tipoEsqueleto;

  Animal({
    required this.nombre,
    required this.tipoNacimiento,
    required this.tipoEsqueleto,
  });

  factory Animal.fromCsv(String line) {
    final parts = line.split(',');
    return Animal(
      nombre: parts[0].trim(),
      tipoNacimiento: parts[1].trim().toLowerCase(),
      tipoEsqueleto: parts[2].trim().toLowerCase(),
    );
  }
}

class SciGame2Page extends StatefulWidget {
  final UserModel user; // Añadido para recibir el usuario
  const SciGame2Page({super.key, required this.user});

  @override
  State<SciGame2Page> createState() => _SciGame2PageState();
}

class _SciGame2PageState extends State<SciGame2Page> {
  List<Animal> animales = [];
  List<Animal> animalesFiltrados = [];
  List<String> tablero = [];
  List<bool> revelados = [];
  String tipoJuego = '';
  int? primerIndice;
  int errores = 0;
  bool bloqueado = false;
  late DateTime inicio;

  @override
  void initState() {
    super.initState();
    cargarAnimales();
  }

  Future<void> cargarAnimales() async {
    final csvString = await rootBundle.loadString('assets/Imagenes/Juegos/files/animalesTiposCien.csv');
    final lines = csvString.split('\n');
    final data = lines
        .skip(1)
        .where((line) => line.trim().isNotEmpty && line.contains(','))
        .map(Animal.fromCsv)
        .toList();

    setState(() {
      animales = data;
      iniciarJuego();
    });
  }

  void iniciarJuego() {
    final opciones = ['ovíparo', 'mamífero', 'vertebrado', 'invertebrado'];
    tipoJuego = opciones[Random().nextInt(opciones.length)];

    if (tipoJuego == 'ovíparo' || tipoJuego == 'mamífero') {
      animalesFiltrados = animales.where((a) => a.tipoNacimiento == tipoJuego).toList();
    } else {
      animalesFiltrados = animales.where((a) => a.tipoEsqueleto == tipoJuego).toList();
    }

    animalesFiltrados.shuffle();
    final seleccionados = animalesFiltrados.take(8).toList();
    tablero = [...seleccionados, ...seleccionados].map((a) => a.nombre).toList()..shuffle();
    revelados = List.filled(16, false);
    errores = 0;
    inicio = DateTime.now();
    primerIndice = null;
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

  void manejarSeleccion(int index) {
    if (bloqueado || revelados[index]) return;

    setState(() {
      revelados[index] = true;
    });

    if (primerIndice == null) {
      primerIndice = index;
    } else {
      final segundoIndice = index;
      final match = tablero[primerIndice!] == tablero[segundoIndice];
      if (!match) {
        errores++;
        bloqueado = true;
        Future.delayed(const Duration(seconds: 1), () {
          setState(() {
            revelados[primerIndice!] = false;
            revelados[segundoIndice] = false;
            primerIndice = null;
            bloqueado = false;
          });
        });
      } else {
        primerIndice = null;
      }
    }

    if (revelados.every((r) => r)) {
      final duracion = DateTime.now().difference(inicio).inSeconds;
      final score = ScoreModel(
        nombreJuego: 'memoria_animales',
        aciertos: 8, // 8 pares correctos
        fallos: errores,
        tiempo: duracion.toDouble(),
        nivel: calcularNivel(8, errores),
        fecha: DateTime.now(),
      );
      _registrarPuntaje(score);
      mostrarResultado(duracion);
    }
  }

  void mostrarResultado(int duracion) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¡Juego completado!'),
        content: Text(
          'Tiempo: $duracion segundos\nTipo: $tipoJuego\nErrores: $errores\nNivel: ${calcularNivel(8, errores)}',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() => iniciarJuego());
            },
            child: const Text('Reintentar'),
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

  @override
  Widget build(BuildContext context) {
    if (tablero.isEmpty) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final anchoDisponible = constraints.maxWidth - 40;
              final altoDisponible = constraints.maxHeight - 40;
              final tamanoCuadroAncho = anchoDisponible / 4;
              final tamanoCuadroAlto = altoDisponible / 5.5;
              final tamanoCuadro = tamanoCuadroAncho < tamanoCuadroAlto
                  ? tamanoCuadroAncho
                  : tamanoCuadroAlto;

              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Memoria de Animales ${tipoJuego[0].toUpperCase()}${tipoJuego.substring(1)}',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF006600),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: tamanoCuadro * 4 + 24,
                      height: tamanoCuadro * 4 + 24,
                      child: GridView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: 16,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4,
                          mainAxisSpacing: 8,
                          crossAxisSpacing: 8,
                          childAspectRatio: 1,
                        ),
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            onTap: () => manejarSeleccion(index),
                            child: Container(
                              width: tamanoCuadro,
                              height: tamanoCuadro,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                color: Colors.blue.shade100,
                                image: revelados[index]
                                    ? DecorationImage(
                                  image: AssetImage(
                                    'assets/Imagenes/Juegos/JuegosCien/Juego2/${tablero[index]}.png',
                                  ),
                                  fit: BoxFit.fitWidth,
                                )
                                    : const DecorationImage(
                                  image: AssetImage('assets/Imagenes/Juegos/JuegosCien/Juego2/reverso.png'),
                                  fit: BoxFit.fitWidth,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
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