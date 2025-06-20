import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late UserModel newUser;
  List<String> courses = [];
  final availableCourses = ['Matemáticas', 'Comunicación', 'Ciencia'];

  late AnimationController _textController;
  late Animation<Offset> _textOffsetAnimation;

  @override
  void initState() {
    super.initState();
    newUser = UserModel();

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

  Future<void> mostrarDialogoVerificacionHumana() async {
    bool esHumano = false;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Verificación'),
        content: StatefulBuilder(
          builder: (context, setState) {
            return Row(
              children: [
                Checkbox(
                  value: esHumano,
                  onChanged: (value) {
                    setState(() {
                      esHumano = value ?? false;
                    });
                  },
                ),
                Expanded(child: Text('✅ Confirmo que soy un humano')),
              ],
            );
          },
        ),
        actions: [
          TextButton(
            child: Text('Cancelar'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          TextButton(
            child: Text('Continuar'),
            onPressed: () {
              if (esHumano) {
                Navigator.of(context).pop();
                _realizarRegistro(); // Solo si confirmó
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Debes confirmar que eres humano.')),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      if (courses.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Debes seleccionar al menos un curso.')),
        );
        return;
      }

      _formKey.currentState!.save();
      newUser.courses = List.from(courses);

      await mostrarDialogoVerificacionHumana(); // Mostrar verificación antes de registrar
    }
  }

  void _realizarRegistro() async {
    try {
      final api = ApiService();
      final registeredUser = await api.registerUser(newUser);

      Navigator.pushReplacementNamed(
        context,
        '/login',
        arguments: registeredUser,
      );
    } catch (e) {
      print('❌ Error al registrar: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al registrar: $e')),
      );
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
          'Registro ABJ 🧠',
          style: TextStyle(
            fontSize: (screenWidth * 0.03).clamp(16.0, 24.0),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        actions: [
          TextButton(
            onPressed: () => Navigator.pushNamed(context, '/login'),
            child: Text(
              'Iniciar Sesión',
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
                              '👨‍👩‍👧 Registro Familiar',
                              style: TextStyle(
                                fontSize: (screenWidth * 0.05).clamp(20.0, 28.0),
                                fontWeight: FontWeight.bold,
                                color: Colors.teal,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.025),

                        _seccionTitulo('👩‍🏫 Datos del familiar', '(campos obligatorios)'),
                        _campoTexto('Nombre', (val) => newUser.parentName = val),
                        _campoTexto('Apellido', (val) => newUser.parentLastName = val),
                        _campoTexto('Correo electrónico', (val) => newUser.parentEmail = val,
                            tipo: TextInputType.emailAddress),
                        _campoTexto('Contraseña', (val) => newUser.parentPassword = val, oculto: true),

                        SizedBox(height: 20),

                        _seccionTitulo('🧒 Datos del infante', '(campos obligatorios)'),
                        _campoTexto('Nombre', (val) => newUser.childName = val),
                        _campoTexto('Apellido', (val) => newUser.childLastName = val),

                        SizedBox(height: 20),

                        _seccionTitulo('📚 Cursos preferidos', '(seleccionar un curso como mínimo)'),
                        SizedBox(height: 8),
                        ...availableCourses.map((course) => CheckboxListTile(
                          title: Text(course),
                          value: courses.contains(course),
                          activeColor: Colors.teal,
                          onChanged: (checked) {
                            setState(() {
                              if (checked == true) courses.add(course);
                              else courses.remove(course);
                            });
                          },
                        )),

                        SizedBox(height: 24),
                        Center(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              minimumSize: Size(double.infinity, 50),
                              backgroundColor: Colors.teal,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: _submit,
                            child: Text('Registrar', style: TextStyle(fontSize: 18)),
                          ),
                        ),
                        SizedBox(height: 24),
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

  Widget _campoTexto(String label, Function(String) onSave,
      {bool oculto = false, TextInputType tipo = TextInputType.text}) {
    return TextFormField(
      decoration: InputDecoration(labelText: label),
      obscureText: oculto,
      keyboardType: tipo,
      validator: (val) => val == null || val.isEmpty ? 'Requerido' : null,
      onSaved: (val) => onSave(val!.trim()),
    );
  }

  Widget _seccionTitulo(String titulo, String subtitulo) {
    return Row(
      children: [
        Text(
          titulo,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        SizedBox(width: 8),
        Text(
          subtitulo,
          style: TextStyle(fontSize: 12, color: Colors.red),
        ),
      ],
    );
  }
}