import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  late UserModel newUser;
  List<String> courses = [];
  final availableCourses = ['Matemáticas', 'Comunicación', 'Ciencia'];

  @override
  void initState() {
    super.initState();
    newUser = UserModel();
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      newUser.courses = List.from(courses);

      try {
        final api = ApiService(); // Usa el singleton
        final registeredUser = await api.registerUser(newUser);

        // Navega al login con los datos del usuario registrado
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
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Registro'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pushNamed(context, '/login'),
              child: Text('Iniciar Sesión', style: TextStyle(color: Colors.blue)),
            ),
          ],
        ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'Nombre del padre/madre'),
                onSaved: (val) => newUser.parentName = val!.trim(),
                validator: (val) => val == null || val.isEmpty ? 'Requerido' : null,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Apellido del padre/madre'),
                onSaved: (val) => newUser.parentLastName = val!.trim(),
                validator: (val) => val == null || val.isEmpty ? 'Requerido' : null,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Correo'),
                keyboardType: TextInputType.emailAddress,
                onSaved: (val) => newUser.parentEmail = val!.trim(),
                validator: (val) => val != null && val.contains('@') ? null : 'Correo inválido',
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Contraseña'),
                obscureText: true,
                onSaved: (val) => newUser.parentPassword = val!.trim(),
                validator: (val) => val != null && val.length >= 6 ? null : 'Mínimo 6 caracteres',
              ),
              Divider(height: 32),
              TextFormField(
                decoration: InputDecoration(labelText: 'Nombre del niño/niña'),
                onSaved: (val) => newUser.childName = val!.trim(),
                validator: (val) => val == null || val.isEmpty ? 'Requerido' : null,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Apellido del niño/niña'),
                onSaved: (val) => newUser.childLastName = val!.trim(),
                validator: (val) => val == null || val.isEmpty ? 'Requerido' : null,
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Text('Cursos a suscribirse', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
              ...availableCourses.map((course) => CheckboxListTile(
                title: Text(course),
                value: courses.contains(course),
                onChanged: (checked) {
                  setState(() {
                    if (checked == true) courses.add(course);
                    else courses.remove(course);
                  });
                },
              )),
              SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(minimumSize: Size(double.infinity, 48)),
                onPressed: _submit,
                child: Text('Registrar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}