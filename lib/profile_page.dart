import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart';

class PerfilPage extends StatefulWidget {
  final String telefonoUsuario;
  const PerfilPage({super.key, required this.telefonoUsuario});

  @override
  State<PerfilPage> createState() => _PerfilPageState();
}

class _PerfilPageState extends State<PerfilPage> {
  Map<String, dynamic>? usuario;

  @override
  void initState() {
    super.initState();
    cargarUsuario();
  }

  Future<void> cargarUsuario() async {
    final String data = await rootBundle.loadString('assets/usuarios.json');
    final List<dynamic> usuarios = jsonDecode(data);

    final usuarioLogeado = usuarios.firstWhere(
      (u) => u['telefono'] == widget.telefonoUsuario,
      orElse: () => null,
    );

    setState(() {
      usuario = usuarioLogeado;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            const Text(
              "Perfil",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const Spacer(),
            Image.asset(
              "assets/images/InterfazTV.png",
              height: 55,
            ),
          ],
        ),
      ),
      body: usuario == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Avatar
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.grey[300],
                    backgroundImage: null, // Aquí puedes poner un NetworkImage si tienes avatar
                    child: Text(
                      usuario!['nombre'][0],
                      style: const TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          color: Colors.black),
                    ),
                  ),
                  const SizedBox(height: 15),

                  // Nombre y correo (correo lo generamos temporal con ejemplo)
                  Text(
                    usuario!['nombre'],
                    style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    "${usuario!['telefono']}",
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 30),

                  // Sección Cuenta
                  _seccionTitulo("Cuenta"),
                  const SizedBox(height: 10),
                  _opcionCard(Icons.video_library, "Mi plan", "Plan Básico"),
                  const SizedBox(height: 10),
                  _opcionCard(Icons.devices, "Dispositivos activos", "2 dispositivos"),

                  const SizedBox(height: 25),

                  // Sección Configuración
                  _seccionTitulo("Configuración"),
                  const SizedBox(height: 10),
                  _opcionCard(Icons.person_outline, "Editar perfil"),
                  const SizedBox(height: 10),
                  _opcionCard(Icons.language, "Idioma de la app"),
                  const SizedBox(height: 10),
                  _opcionCard(Icons.notifications_none, "Notificaciones"),

                  const SizedBox(height: 30),

                  // Botón Cerrar Sesión
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 212, 33, 20),
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        Navigator.pop(context); // vuelve al login
                      },
                      child: const Text(
                        'Cerrar sesión',
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    ),
                  )
                ],
              ),
            ),
    );
  }

  Widget _seccionTitulo(String titulo) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        titulo,
        style: const TextStyle(
            fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
      ),
    );
  }

  Widget _opcionCard(IconData icon, String titulo, [String? subtitulo]) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.black54, size: 28),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(titulo,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w500)),
              if (subtitulo != null)
                Text(subtitulo,
                    style: TextStyle(fontSize: 14, color: Colors.grey[600])),
            ],
          ),
        ],
      ),
    );
  }
}
