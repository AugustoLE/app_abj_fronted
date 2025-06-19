import 'package:flutter/material.dart';

// Páginas principales
import 'pages/welcome_page.dart';
import 'pages/register_page.dart';
import 'pages/login_page.dart';
import 'pages/dashboard_page.dart';
import 'pages/profile_page.dart';
import 'pages/auto_login_page.dart'; // Nueva ruta para AutoLoginPage'

// Juegos por curso
import 'games/game_math1.dart';
import 'games/game_math2.dart';
import 'games/game_comm1.dart';
import 'games/game_comm2.dart';
import 'games/game_sci1.dart';
import 'games/game_sci2.dart';

final Map<String, WidgetBuilder> appRoutes = {
  '/': (_) => WelcomePage(),
  '/register': (_) => RegisterPage(),
  '/login': (_) => LoginPage(),
  '/dashboard': (_) => DashboardPage(),
  '/profile': (_) => ProfilePage(),
  '/autoLogin': (_) => AutoLoginPage(), // Nueva ruta para AutoLoginPage'

  // Juegos Matemáticas
  '/game_math1': (_) => MathGame1Page(),
  '/game_math2': (_) => MathGame2Page(),

  // Juegos Comunicación
  '/game_comm1': (_) => CommGame1Page(),
  '/game_comm2': (_) => CommGame2Page(),

  // Juegos Ciencia
  '/game_sci1': (_) => SciGame1Page(),
  '/game_sci2': (_) => SciGame2Page(),
};
