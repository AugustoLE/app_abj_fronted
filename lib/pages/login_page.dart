import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  String email = '';
  String password = '';
  UserModel? loginUser;

  late AnimationController _textController;
  late Animation<Offset> _textOffsetAnimation;

  @override
  void initState() {
    super.initState();

    _textController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 800),
    );

    _textOffsetAnimation = Tween<Offset>(
      begin: Offset(0.0, -1.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _textController, curve: Curves.easeOut));

    _textController.forward();
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

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
        final api = ApiService();
        final user = await api.loginUser(email, password);

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
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          'Iniciar Sesión 🔐',
          style: TextStyle(
            fontSize: (screenWidth * 0.03).clamp(16.0, 24.0),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        actions: [
          TextButton(
            onPressed: () => Navigator.pushNamed(context, '/register'),
            child: Text(
              'Registrarse',
              style: TextStyle(
                color: Colors.blue,
                fontSize: (screenWidth * 0.03).clamp(14.0, 18.0),
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.06,
              vertical: screenHeight * 0.015,
            ),
            child: Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.only(bottom: bottomInset + 20),
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: 600),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SlideTransition(
                          position: _textOffsetAnimation,
                          child: Center(
                            child: Text(
                              '👋 ¡Hola de nuevo!',
                              style: TextStyle(
                                fontSize: (screenWidth * 0.05).clamp(20.0, 28.0),
                                fontWeight: FontWeight.bold,
                                color: Colors.teal,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.03),

                        Text(
                          'Por favor, inicia sesión para continuar 🎮',
                          style: TextStyle(
                            fontSize: (screenWidth * 0.04).clamp(16.0, 20.0),
                            color: Colors.grey[700],
                          ),
                        ),
                        SizedBox(height: 16),

                        TextFormField(
                          decoration: InputDecoration(labelText: 'Correo electrónico'),
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

                        SizedBox(height: 32),
                        Center(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              minimumSize: Size(double.infinity, 50),
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: _login,
                            child: Text('Entrar', style: TextStyle(fontSize: 18)),
                          ),
                        ),
                        SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      backgroundColor: Colors.white,
    );
  }
}
