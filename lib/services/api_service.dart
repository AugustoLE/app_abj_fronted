// lib/services/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;

  final String baseUrl = 'http://127.0.0.1:8000'; // Cambiar si usas dispositivo físico
  //final String baseUrl = 'https://app-abj-backend.onrender.com/';

  ApiService._internal();

  /// Registrar nuevo usuario
  Future<UserModel> registerUser(UserModel user) async {
    final response = await http.post(
      Uri.parse('$baseUrl/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'parentName': user.parentName,
        'parentLastName': user.parentLastName,
        'parentEmail': user.parentEmail,
        'parentPassword': user.parentPassword,
        'childName': user.childName,
        'childLastName': user.childLastName,
        'courses': user.courses,
      }),
    );
    if (response.statusCode == 201) {
      return UserModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Error al registrar: ${response.body}');
    }
  }

  /// Iniciar sesión
  Future<UserModel> loginUser(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    if (response.statusCode == 200) {
      return UserModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Error al iniciar sesión: ${response.body}');
    }
  }

  /// Obtener perfil por email
  Future<UserModel> fetchProfile(String email) async {
    final response = await http.get(Uri.parse('$baseUrl/users/$email'));
    if (response.statusCode == 200) {
      return UserModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Error al obtener perfil: ${response.body}');
    }
  }

  /// Actualizar perfil del usuario
  Future<UserModel> updateUser(UserModel user) async {
    final response = await http.put(
      Uri.parse('$baseUrl/users/${user.parentEmail}'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'parentName': user.parentName,
        'parentLastName': user.parentLastName,
        'childName': user.childName,
        'childLastName': user.childLastName,
        'courses': user.courses,
      }),
    );
    if (response.statusCode == 200) {
      return UserModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Error al actualizar perfil: ${response.body}');
    }
  }
}
