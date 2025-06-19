import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  String email = '';
  String password = '';
  UserModel? loginUser;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)!.settings.arguments;
    if (args is UserModel) loginUser = args;
  }

  void _login() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      try {
        final api = ApiService(); // usa el singleton
        final user = await api.loginUser(email, password); // llamada real al backend

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_email', user.parentEmail);
        print('✅ Sesión iniciada con éxito');

        Navigator.pushReplacementNamed(context, '/dashboard', arguments: user);
      } catch (e) {
        print('❌ Error al iniciar sesión: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Credenciales incorrectas o error de servidor')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Iniciar Sesión')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'Correo'),
                keyboardType: TextInputType.emailAddress,
                onSaved: (val) => email = val!.trim(),
                validator: (val) => val != null && val.contains('@') ? null : 'Correo inválido',
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Contraseña'),
                obscureText: true,
                onSaved: (val) => password = val!.trim(),
                validator: (val) => val != null && val.length >= 6 ? null : 'Mínimo 6 caracteres',
              ),
              SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(minimumSize: Size(double.infinity, 48)),
                onPressed: _login,
                child: Text('Entrar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}