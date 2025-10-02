import 'package:flutter/material.dart';

class VivoPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isLandscape = size.width > size.height;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            Text(
              "TV en Vivo",
              style: TextStyle(
                fontSize: 20,
                color: const Color.fromARGB(255, 2, 1, 1),
                fontWeight: FontWeight.bold,
              ),
            ),
            Spacer(),
            Image.asset(
              "assets/images/InterfazTV.png",
              height: 55,
            ),
          ],
        ),
      ),
      body: Center(
        child: Text(
          'Sección TV en Vivo'
          '(puedes agregar aquí los canales o streams)',
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
