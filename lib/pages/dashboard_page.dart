import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../pages/welcome_page.dart';

class DashboardPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments;
    if (args == null || args is! UserModel) {
      return Scaffold(
        body: Center(child: Text('Sesión expirada. Reinicie la app.')),
      );
    }

    final UserModel user = args;
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
        automaticallyImplyLeading: false, // Esto quita la flecha
        title: Text('Bienvenido, ${user.childName}!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pushNamed(context, '/profile', arguments: user),
            child: Text('Perfil', style: TextStyle(color: Colors.blue)),
          ),
          TextButton(
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.remove('user_email'); // cerrar sesión
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => WelcomePage()), // o usa rutas con nombre si prefieres
                    (Route<dynamic> route) => false, // Esto elimina todo el stack
              );
            },
            child: Text('Cerrar sesión', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 3 / 2,
          ),
          itemCount: available.length,
          itemBuilder: (context, i) {
            final entry = available[i];
            return Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 4,
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () => Navigator.pushNamed(context, entry.value),
                child: Center(
                  child: Text(
                    entry.key,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
