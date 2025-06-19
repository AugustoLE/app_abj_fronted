import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late UserModel user;
  final _formKey = GlobalKey<FormState>();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    user = ModalRoute.of(context)!.settings.arguments as UserModel;
  }

  void _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      try {
        final api = ApiService();
        final updatedUser = await api.updateUser(user);

        setState(() {
          user = updatedUser;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('✅ Perfil actualizado con éxito')),
        );
      } catch (e) {
        print('❌ Error al actualizar: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al guardar cambios')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Mi Perfil')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                initialValue: user.parentName,
                decoration: InputDecoration(labelText: 'Nombre del padre/madre'),
                onSaved: (val) => user.parentName = val!.trim(),
              ),
              TextFormField(
                initialValue: user.parentLastName,
                decoration: InputDecoration(labelText: 'Apellido del padre/madre'),
                onSaved: (val) => user.parentLastName = val!.trim(),
              ),
              TextFormField(
                initialValue: user.parentEmail,
                decoration: InputDecoration(labelText: 'Correo'),
                onSaved: (val) => user.parentEmail = val!.trim(),
              ),
              Divider(height: 32),
              TextFormField(
                initialValue: user.childName,
                decoration: InputDecoration(labelText: 'Nombre del niño/niña'),
                onSaved: (val) => user.childName = val!.trim(),
              ),
              TextFormField(
                initialValue: user.childLastName,
                decoration: InputDecoration(labelText: 'Apellido del niño/niña'),
                onSaved: (val) => user.childLastName = val!.trim(),
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Text('Cursos suscritos', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
              ...user.courses.map((course) => ListTile(title: Text(course))).toList(),
              SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(minimumSize: Size(double.infinity, 48)),
                onPressed: _saveProfile,
                child: Text('Guardar cambios'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}