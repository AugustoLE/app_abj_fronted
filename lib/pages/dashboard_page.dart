import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../pages/welcome_page.dart';

class DashboardPage extends StatefulWidget {
  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> with TickerProviderStateMixin {
  late AnimationController _titleController;
  late Animation<Offset> _titleOffsetAnimation;

  @override
  void initState() {
    super.initState();

    _titleController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 700),
    );

    _titleOffsetAnimation = Tween<Offset>(
      begin: Offset(0.0, -1.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _titleController, curve: Curves.easeOut));

    _titleController.forward();
  }

  @override
  void dispose() {
    _titleController.dispose();
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

    final Map<String, String> courseRoutes = {
      'Matemáticas 1': '/game_math1',
      'Matemáticas 2': '/game_math2',
      'Comunicación 1': '/game_comm1',
      'Comunicación 2': '/game_comm2',
      'Ciencia 1': '/game_sci1',
      'Ciencia 2': '/game_sci2',
    };

    final available = <MapEntry<String, String>>[];
    courseRoutes.forEach((title, route) {
      final course = title.split(' ')[0];
      if (user.courses.contains(course)) {
        available.add(MapEntry(title, route));
      }
    });

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          '¡Hola, ${user.childName}! 🎮',
          style: TextStyle(
            fontSize: (screenWidth * 0.03).clamp(16.0, 24.0),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.teal[50],
        actions: [
          TextButton(
            onPressed: () => Navigator.pushNamed(context, '/profile', arguments: user),
            child: Text('Perfil', style: TextStyle(color: Colors.blue)),
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
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SlideTransition(
              position: _titleOffsetAnimation,
              child: Text(
                '🧩 Juegos disponibles según tus cursos:',
                style: TextStyle(
                  fontSize: (screenWidth * 0.045).clamp(18.0, 24.0),
                  fontWeight: FontWeight.bold,
                  color: Colors.teal[800],
                ),
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
                  return Card(
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    color: Colors.teal[100],
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () => Navigator.pushNamed(context, entry.value),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Center(
                          child: Text(
                            entry.key,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: (screenWidth * 0.045).clamp(16.0, 20.0),
                              fontWeight: FontWeight.bold,
                              color: Colors.teal[900],
                            ),
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
      backgroundColor: Colors.white,
    );
  }
}
