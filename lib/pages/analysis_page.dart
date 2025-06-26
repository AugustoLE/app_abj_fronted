import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/user_model.dart';
import '../services/api_service.dart';

class AnalysisPage extends StatefulWidget {
  @override
  _AnalysisPageState createState() => _AnalysisPageState();
}

class _AnalysisPageState extends State<AnalysisPage> with TickerProviderStateMixin {
  late UserModel user;
  List<dynamic> resumen = [];
  bool isLoading = true;
  String mensaje = '';
  String? mejorJuego;
  String? juegoMasJugado;
  String? juegoAMejorar;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)!.settings.arguments;
    if (args is UserModel) {
      user = args;
      _fetchAnalysis();
    } else {
      setState(() {
        isLoading = false;
        mensaje = 'Error: No se proporcionó información del usuario';
      });
    }
  }

  Future<void> _fetchAnalysis() async {
    try {
      final api = ApiService();
      print('📡 Solicitando análisis para ${user.parentEmail}');
      final response = await http.get(Uri.parse('${api.baseUrl}/analisis/${user.parentEmail}'));
      print('📥 Respuesta del backend: ${response.statusCode} - ${response.body}');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          resumen = data['resumen'] ?? []; // Maneja caso de resumen null
          mensaje = data['message'] ?? 'No hay mensaje disponible';
          isLoading = false;
        });
        if (resumen.isNotEmpty) {
          _calcularEstadisticas();
        } else {
          setState(() {
            mensaje = 'No hay datos de análisis disponibles. Juega más partidas para generar un análisis.';
          });
        }
      } else {
        throw Exception('Error al obtener análisis: ${response.body}');
      }
    } catch (e, stackTrace) {
      print('❌ Error al cargar análisis: $e\n$stackTrace');
      setState(() {
        isLoading = false;
        mensaje = 'Error al cargar análisis: $e';
      });
    }
  }

  void _calcularEstadisticas() {
    if (resumen.isEmpty) return;

    final juegosContados = <String, int>{};
    for (var juego in resumen) {
      final nombre = juego['juego'] as String;
      juegosContados[nombre] = (juegosContados[nombre] ?? 0) + 1;
    }
    juegoMasJugado = juegosContados.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;

    final tasasAciertos = <String, double>{};
    final juegos = <String, List<dynamic>>{};
    for (var juego in resumen) {
      final nombre = juego['juego'] as String;
      juegos[nombre] = juegos[nombre] ?? [];
      juegos[nombre]!.add(juego);
    }
    juegos.forEach((nombre, lista) {
      final totalAciertos = lista.fold<int>(
        0,
            (sum, j) => sum + (j['aciertos'] as num).toInt(),
      );
      final totalIntentos = lista.fold<int>(
        0,
            (sum, j) => sum + (j['aciertos'] as num).toInt() + (j['fallos'] as num).toInt(),
      );
      tasasAciertos[nombre] = totalIntentos > 0 ? totalAciertos / totalIntentos : 0.0;
    });
    mejorJuego = tasasAciertos.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;

    juegoAMejorar = tasasAciertos.entries
        .reduce((a, b) => a.value < b.value ? a : b)
        .key;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '📊 Análisis de ${user.childName}',
          style: TextStyle(
            fontSize: (screenWidth * 0.04).clamp(16.0, 22.0),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.teal[50],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Text(
              'Resumen del Rendimiento',
              style: TextStyle(
                fontSize: (screenWidth * 0.045).clamp(18.0, 24.0),
                fontWeight: FontWeight.bold,
                color: Colors.teal[800],
              ),
            ),
            const SizedBox(height: 16),
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '👤 Jugador: ${user.childName} ${user.childLastName}',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    if (juegoMasJugado != null)
                      Text(
                        '🎮 Juego más jugado: $juegoMasJugado',
                        style: const TextStyle(fontSize: 16),
                      ),
                    if (mejorJuego != null)
                      Text(
                        '🏆 Mejor juego: $mejorJuego',
                        style: TextStyle(fontSize: 16, color: Colors.green),
                      ),
                    if (juegoAMejorar != null)
                      Text(
                        '📈 Juego a mejorar: $juegoAMejorar',
                        style: TextStyle(fontSize: 16, color: Colors.red),
                      ),
                    if (resumen.isEmpty)
                      const Text(
                        'No hay datos de juegos disponibles.',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Detalles por Juego',
              style: TextStyle(
                fontSize: (screenWidth * 0.04).clamp(16.0, 20.0),
                fontWeight: FontWeight.w600,
              ),
            ),
            if (resumen.isNotEmpty)
              ...resumen.map((juego) => Card(
                elevation: 2,
                margin: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  title: Text(
                    juego['juego'],
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Aciertos: ${juego['aciertos']}'),
                      Text('Fallos: ${juego['fallos']}'),
                      Text('Nivel estimado: ${juego['nivel_estimado']}'),
                    ],
                  ),
                ),
              ))
            else
              const Card(
                elevation: 2,
                margin: EdgeInsets.symmetric(vertical: 8),
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'No hay detalles disponibles. Juega más partidas para ver el análisis.',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ),
              ),
            const SizedBox(height: 16),
            Text(
              'Mensaje del sistema: $mensaje',
              style: const TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
            ),
          ],
        ),
      ),
    );
  }
}