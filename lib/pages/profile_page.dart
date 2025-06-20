import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> with TickerProviderStateMixin {
  late UserModel user;
  final _formKey = GlobalKey<FormState>();

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
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '👤 Mi Perfil',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: (screenWidth * 0.04).clamp(16.0, 22.0),
          ),
        ),
        backgroundColor: Colors.teal[50],
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.06,
          vertical: screenHeight * 0.015,
        ),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              SlideTransition(
                position: _titleOffsetAnimation,
                child: Center(
                  child: Text(
                    '👨‍👩‍👧 Datos del familiar',
                    style: TextStyle(
                      fontSize: (screenWidth * 0.045).clamp(18.0, 24.0),
                      fontWeight: FontWeight.bold,
                      color: Colors.teal[800],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 16),

              TextFormField(
                initialValue: user.parentName,
                decoration: InputDecoration(labelText: 'Nombre'),
                onSaved: (val) => user.parentName = val!.trim(),
              ),
              TextFormField(
                initialValue: user.parentLastName,
                decoration: InputDecoration(labelText: 'Apellido'),
                onSaved: (val) => user.parentLastName = val!.trim(),
              ),
              TextFormField(
                initialValue: user.parentEmail,
                decoration: InputDecoration(labelText: 'Correo electrónico'),
                onSaved: (val) => user.parentEmail = val!.trim(),
              ),

              SizedBox(height: 32),
              Text(
                '🧒 Datos del niño/niña',
                style: TextStyle(
                  fontSize: (screenWidth * 0.042).clamp(16.0, 22.0),
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 8),

              TextFormField(
                initialValue: user.childName,
                decoration: InputDecoration(labelText: 'Nombre'),
                onSaved: (val) => user.childName = val!.trim(),
              ),
              TextFormField(
                initialValue: user.childLastName,
                decoration: InputDecoration(labelText: 'Apellido'),
                onSaved: (val) => user.childLastName = val!.trim(),
              ),

              SizedBox(height: 32),
              Text(
                '📚 Cursos suscritos',
                style: TextStyle(
                  fontSize: (screenWidth * 0.042).clamp(16.0, 22.0),
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 8),
              ...user.courses.map((course) => ListTile(
                title: Text('🧠 $course'),
                contentPadding: EdgeInsets.symmetric(horizontal: 0),
              )),

              SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: _saveProfile,
                icon: Icon(Icons.save),
                label: Text('Guardar cambios'),
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 50),
                  backgroundColor: Colors.teal,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  textStyle: TextStyle(fontSize: 18),
                ),
              ),
              SizedBox(height: 16),
            ],
          ),
        ),
      ),
      backgroundColor: Colors.white,
    );
  }
}