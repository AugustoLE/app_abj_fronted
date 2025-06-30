import 'package:flutter/material.dart';
import 'pages/welcome_page.dart';
import 'pages/register_page.dart';
import 'pages/login_page.dart';
import 'pages/dashboard_page.dart';
import 'pages/profile_page.dart';
import 'pages/auto_login_page.dart';
import 'pages/analysis_page.dart';
import 'games/game_math1.dart';
import 'games/game_math2.dart';
import 'games/game_comm1.dart';
import 'games/game_comm2.dart';
import 'games/game_sci1.dart';
import 'games/game_sci2.dart';
import 'models/user_model.dart';

final Map<String, WidgetBuilder> appRoutes = {
  '/': (_) => WelcomePage(),
  '/register': (_) => RegisterPage(),
  '/login': (_) => LoginPage(),
  '/dashboard': (_) => DashboardPage(),
  '/profile': (_) => ProfilePage(),
  '/autoLogin': (_) => AutoLoginPage(),
  '/analysis': (_) => AnalysisPage(),
  '/game_math1': (context) => MathGame1Page(
    user: ModalRoute.of(context)!.settings.arguments as UserModel,
  ),
  '/game_math2': (context) => MathGame2Page(
    user: ModalRoute.of(context)!.settings.arguments as UserModel,
  ),
  '/game_comm1': (context) => CommGame1Page(
    user: ModalRoute.of(context)!.settings.arguments as UserModel,
  ),
  '/game_comm2': (_) => CommGame2Page(),
  '/game_sci1': (context) => SciGame1Page(
    user: ModalRoute.of(context)!.settings.arguments as UserModel,
  ),
  '/game_sci2': (context) => SciGame2Page(
    user: ModalRoute.of(context)!.settings.arguments as UserModel,
  ),
};