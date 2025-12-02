import 'package:app_bitacora/provider/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'bitacoras_list.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  String _username = '';
  String _password = '';
  bool _obscurePassword = true;

  void _submit() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      String? role;
      if (_username == 'admin' && _password == '1234') {
        role = 'admin';
      } else if( _username == 'usuario' && _password == '5678'){
        role = 'user';
      }

      if(role != null){
        final userProvider = Provider.of<UserProvider>(context, listen: false);
        userProvider.loginUser(_username, role);
        
        Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const BitacorasListScreen(),
        ),
      );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Usuario o contraseña incorrectos.',), backgroundColor: Colors.red,),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo o icono superior
              CircleAvatar(
                radius: 48,
                backgroundColor: Colors.deepPurple[100],
                child: const Icon(
                  Icons.lock_outline,
                  size: 48,
                  color: Colors.deepPurple,
                ),
              ),
              const SizedBox(height: 24),
              Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 36,
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          "Iniciar sesión",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.deepPurple,
                            fontSize: 22,
                          ),
                        ),
                        const SizedBox(height: 28),
                        TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Usuario',
                            prefixIcon: const Icon(Icons.person, color: Colors.deepPurple),
                            filled: true,
                            fillColor: Colors.deepPurple[50],
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          validator: (value) =>
                              value == null || value.isEmpty ? 'Ingresa el usuario' : null,
                          onSaved: (value) => _username = value ?? '',
                        ),
                        const SizedBox(height: 18),
                        TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Contraseña',
                            prefixIcon: const Icon(Icons.lock, color: Colors.deepPurple),
                            filled: true,
                            fillColor: Colors.deepPurple[50],
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: Colors.deepPurple,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                          ),
                          obscureText: _obscurePassword,
                          validator: (value) => value == null || value.isEmpty
                              ? 'Ingresa la contraseña'
                              : null,
                          onSaved: (value) => _password = value ?? '',
                        ),
                        const SizedBox(height: 32),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.deepPurple,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 6,
                            ),
                            onPressed: _submit,
                            child: const Text(
                              'Ingresar',
                              style: TextStyle(fontSize: 16, color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                '© 2025 saferfs',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
