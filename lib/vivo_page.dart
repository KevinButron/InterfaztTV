import 'package:flutter/material.dart';
import 'models/model.dart';
import 'player_page.dart';
import 'dart:convert';
import 'package:flutter/services.dart';

class VivoPage extends StatefulWidget {
  const VivoPage({Key? key}) : super(key: key);

  @override
  State<VivoPage> createState() => _VivoPageState();
}

class _VivoPageState extends State<VivoPage> {
  List<Model> canales = [];
  int canalActual = 0;

  @override
  void initState() {
    super.initState();
    _cargarCanales();
  }

  Future<void> _cargarCanales() async {
    final String response = await rootBundle.loadString('assets/canales.json');
    final List<dynamic> data = json.decode(response);

    setState(() {
      canales = data.map((json) => Model.fromJson(json)).toList();
    });
  }

  void _canalSiguiente() {
    setState(() {
      canalActual = (canalActual + 1) % canales.length;
    });
  }

  void _canalAnterior() {
    setState(() {
      canalActual = (canalActual - 1 + canales.length) % canales.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (canales.isEmpty) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: const Center(
          child: CircularProgressIndicator(color: Colors.red),
        ),
      );
    }

    final canal = canales[canalActual];

    // Detectar pantalla grande (TV) o pequeña (telefono)
    final isTV = MediaQuery.of(context).size.width > 600; // ajusta si quieres

    if (isTV) {
      // TV Box / control remoto
      return Scaffold(
        backgroundColor: Colors.black,
        body: RawKeyboardListener(
          focusNode: FocusNode()..requestFocus(),
          onKey: (RawKeyEvent event) {
            if (event is RawKeyDownEvent) {
              switch (event.logicalKey.keyId) {
                case 0x100070052: // Flecha derecha
                  _canalSiguiente();
                  break;
                case 0x100070050: // Flecha izquierda
                  _canalAnterior();
                  break;
                default:
                  break;
              }
            }
          },
          child: PlayerPage(
            key: ValueKey(canal.url),
            videoUrl: canal.url,
            canalName: canal.nombre,
          ),
        ),
      );
    } else {
      // Telefono / touch -> fullscreen con botones sobre el video
      return Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            Positioned.fill(
              child: PlayerPage(
                key: ValueKey(canal.url),
                videoUrl: canal.url,
                canalName: canal.nombre,
              ),
            ),
            // Botones sobre el video
            Positioned(
              left: 20,
              bottom: 40,
              child: FloatingActionButton(
                backgroundColor: Colors.red.withOpacity(0.7),
                onPressed: _canalAnterior,
                child: const Icon(Icons.skip_previous),
              ),
            ),
            Positioned(
              right: 20,
              bottom: 40,
              child: FloatingActionButton(
                backgroundColor: Colors.red.withOpacity(0.7),
                onPressed: _canalSiguiente,
                child: const Icon(Icons.skip_next),
              ),
            ),
          ],
        ),
      );
    }
  }
}
