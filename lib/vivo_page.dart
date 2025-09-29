import 'package:flutter/material.dart';

class VivoPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isLandscape = size.width > size.height;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text("TV en Vivo"),
        backgroundColor: Colors.deepPurple,
      ),
      body: Center(
        child: Text(
          'Sección TV en Vivo (puedes agregar aquí los canales o streams)',
          style: TextStyle(
            color: Colors.white,
            fontSize: isLandscape ? size.width * 0.035 : size.width * 0.05,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
