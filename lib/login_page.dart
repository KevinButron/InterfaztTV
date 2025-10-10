import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'home_page.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController telefonoController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  List<dynamic> usuarios = [];

  @override
  void initState() {
    super.initState();
    cargarUsuarios();
  }

  Future<void> cargarUsuarios() async {
    final String data = await rootBundle.loadString('assets/usuarios.json');
    setState(() {
      usuarios = json.decode(data);
    });
  }

  void login() {
    final telefono = telefonoController.text.trim();
    final password = passwordController.text.trim();

    final usuario = usuarios.firstWhere(
      (u) => u['telefono'] == telefono && u['password'] == password,
      orElse: () => null,
    );

    if (usuario != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HomePage(
            telefonoUsuario: usuario['telefono'], // 📌 pasamos el teléfono
          ),
        ),
      );
    } else {
      // 👇 SnackBar con icono y texto en negrita
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color.fromARGB(255, 212, 33, 20),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          content: Row(
            children: [
              Icon(Icons.error_outline, color: Colors.white, size: 20),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  "Número o contraseña incorrectos",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 🖼️ Logo
              Image.asset(
                'assets/images/InterfazTV.png',
                height: 120,
                fit: BoxFit.contain,
              ),
              SizedBox(height: 35),

              // 🔤 Título
              Text(
                "Iniciar Sesión",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                  letterSpacing: 1.1,
                ),
              ),
              SizedBox(height: 40),

              // 📱 Campo teléfono
              TextField(
                controller: telefonoController,
                keyboardType: TextInputType.phone,
                style: TextStyle(color: Colors.black),
                decoration: InputDecoration(
                  labelText: "Número de teléfono",
                  labelStyle: TextStyle(color: Colors.grey[600]),
                  prefixIcon: Icon(Icons.phone, color: Colors.grey[700]),
                  filled: true,
                  fillColor: Colors.grey[100],
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade400),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        BorderSide(color: const Color.fromARGB(255, 212, 33, 20)),
                  ),
                ),
              ),
              SizedBox(height: 20),

              // 🔒 Campo contraseña
              TextField(
                controller: passwordController,
                obscureText: true,
                style: TextStyle(color: Colors.black),
                decoration: InputDecoration(
                  labelText: "Contraseña",
                  labelStyle: TextStyle(color: Colors.grey[600]),
                  prefixIcon: Icon(Icons.lock_outline, color: Colors.grey[700]),
                  filled: true,
                  fillColor: Colors.grey[100],
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade400),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        BorderSide(color: const Color.fromARGB(255, 212, 33, 20)),
                  ),
                ),
              ),
              SizedBox(height: 35),

              // 🔘 Botón de entrada
              ElevatedButton.icon(
                onPressed: login,
                icon: Icon(Icons.login, color: Colors.white),
                label: Text(
                  "Entrar",
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 212, 33, 20),
                  padding: EdgeInsets.symmetric(horizontal: 70, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 6,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
