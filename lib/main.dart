import 'package:flutter/material.dart';
import 'home_page.dart';

void main() {
  runApp(TVAppDemo());
}

class TVAppDemo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TV App Demo',
      theme: ThemeData.dark(),
      home: SplashScreen(), // primero muestra splash
      debugShowCheckedModeBanner: false, // 👈 oculta el banner DEBUG
    );
  }
}

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    // Espera 3 segundos y navega a HomePage
    Future.delayed(Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );
    });
  }
@override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: Colors.white, // fondo blanco
    body: Center(
      child: Image.asset(
        'assets/images/Logo_inicio.png',
        fit: BoxFit.contain,
        width: MediaQuery.of(context).size.width * 0.7, // 70% del ancho de la pantalla
      ),
    ),
  );
}
}