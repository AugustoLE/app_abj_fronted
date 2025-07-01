import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../pages/welcome_page.dart';

class DashboardPage extends StatefulWidget {
  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<Offset>> _offsetAnimations;

  final Map<String, String> courseRoutes = {
    'Matemáticas 1': '/game_math1',
    'Matemáticas 2': '/game_math2',
    'Comunicación 1': '/game_comm1',
    'Comunicación 2': '/game_comm2',
    'Ciencia 1': '/game_sci1',
    'Ciencia 2': '/game_sci2',
  };

  final Map<String, String> courseLogos = {
    'Matemáticas': 'assets/Imagenes/imagenes_curso_matematicas/img_matematica_1.png',
    'Comunicación': 'assets/Imagenes/imagenes_curso_comunicacion/img_comunicacion_1.png',
    'Ciencia': 'assets/Imagenes/imagenes_curso_ciencia/img_ciencia_1.png',
  };

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments;
    if (args == null || args is! UserModel) {
      return Scaffold(
        body: Center(child: Text('Sesión expirada. Reinicie la app.')),
      );
    }

    final UserModel user = args;
    final screenWidth = MediaQuery.of(context).size.width;

    final List<MapEntry<String, String>> available = [];
    courseRoutes.forEach((title, route) {
      final course = title.split(' ')[0];
      if (user.courses.contains(course)) {
        available.add(MapEntry(title, route));
      }
    });

    _controllers = List.generate(available.length, (i) {
      return AnimationController(
        vsync: this,
        duration: Duration(milliseconds: 800 + i * 150),
      )..repeat(reverse: true);
    });

    _offsetAnimations = _controllers.map((controller) {
      return Tween<Offset>(
        begin: Offset(0, -0.01),
        end: Offset(0, 0.01),
      ).animate(CurvedAnimation(parent: controller, curve: Curves.easeInOut));
    }).toList();

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        actions: [
          TextButton(
            onPressed: () => Navigator.pushNamed(context, '/profile', arguments: user),
            child: Text('Perfil', style: TextStyle(color: Colors.blue)),
          ),
          TextButton(
            onPressed: () => Navigator.pushNamed(context, '/analysis', arguments: user),
            child: Text('Análisis ML', style: TextStyle(color: Colors.teal)),
          ),
          TextButton(
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.remove('user_email');
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => WelcomePage()),
                    (Route<dynamic> route) => false,
              );
            },
            child: Text('Cerrar sesión', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '🧩 Hola, ${user.childName}. Estos son tus juegos disponibles según tus cursos:',
              style: TextStyle(
                fontSize: (screenWidth * 0.045).clamp(18.0, 24.0),
                fontWeight: FontWeight.bold,
                color: Colors.teal[800],
              ),
            ),
            SizedBox(height: 16),
            Expanded(
              child: GridView.builder(
                itemCount: available.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 3 / 2,
                ),
                itemBuilder: (context, i) {
                  final entry = available[i];
                  final courseName = entry.key.split(' ')[0];
                  final logoPath = courseLogos[courseName] ?? '';

                  return SlideTransition(
                    position: _offsetAnimations[i],
                    child: Card(
                      elevation: 6,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      color: Colors.blue.shade700,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(20),
                        onTap: () => Navigator.pushNamed(context, entry.value, arguments: user),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (logoPath.isNotEmpty)
                                Image.asset(
                                  logoPath,
                                  height: 48,
                                  fit: BoxFit.contain,
                                ),
                              SizedBox(height: 8),
                              Text(
                                entry.key,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: (screenWidth * 0.045).clamp(16.0, 20.0),
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}