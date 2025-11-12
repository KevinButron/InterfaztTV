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

  // Lista de FocusNodes para los elementos navegables
  final List<FocusNode> _focusNodes = [];
  int _focusedIndex = 0;
  late FocusNode _pageFocusNode;

  @override
  void initState() {
    super.initState();
    _pageFocusNode = FocusNode(debugLabel: 'PerfilPage');
    
    // Inicializar focus nodes para cada elemento navegable
    for (int i = 0; i < 7; i++) { // 6 cards + 1 botón
      _focusNodes.add(FocusNode(debugLabel: 'PerfilItem$i'));
    }
    
    cargarUsuario();
    
    // Enfocar el primer elemento después de construir
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _pageFocusNode.requestFocus();
      _focusNodes.first.requestFocus();
    });
  }

  @override
  void dispose() {
    _pageFocusNode.dispose();
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
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

  // Navegación por teclado o control remoto - MEJORADA
  void _handleKeyEvent(RawKeyEvent event) {
    if (event is RawKeyDownEvent) {
      final key = event.logicalKey;

      switch (key) {
        case LogicalKeyboardKey.arrowDown:
          _moveFocus(1);
          break;
        
        case LogicalKeyboardKey.arrowUp:
          _moveFocus(-1);
          break;
        
        case LogicalKeyboardKey.arrowRight:
          // Navegación horizontal si es necesario
          break;
        
        case LogicalKeyboardKey.arrowLeft:
          // Navegación horizontal si es necesario
          break;
        
        case LogicalKeyboardKey.enter:
        case LogicalKeyboardKey.select:
          _executeAction();
          break;
        
        case LogicalKeyboardKey.backspace:
        case LogicalKeyboardKey.escape:
          Navigator.pop(context);
          break;
        
        default:
          break;
      }
    }
  }

  void _moveFocus(int direction) {
    setState(() {
      _focusedIndex = (_focusedIndex + direction).clamp(0, _focusNodes.length - 1);
    });
    
    // Usar un pequeño delay para asegurar que el foco se establezca correctamente
    Future.delayed(Duration(milliseconds: 10), () {
      _focusNodes[_focusedIndex].requestFocus();
    });
  }

  void _executeAction() {
    // Ejecutar acción según el elemento enfocado
    switch (_focusedIndex) {
      case 5: // Botón cerrar sesión (último elemento)
        Navigator.pop(context);
        break;
      default:
        // Para las otras opciones, podrías mostrar un diálogo o navegar a otra página
        _mostrarMensajeAccion(_focusedIndex);
        break;
    }
  }

  void _mostrarMensajeAccion(int index) {
    final mensajes = [
      "Mi plan",
      "Dispositivos activos", 
      "Editar perfil",
      "Idioma de la app",
      "Notificaciones"
    ];
    
    if (index < mensajes.length) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Abriendo: ${mensajes[index]}"),
          duration: Duration(seconds: 1),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: usuario == null
          ? const Center(child: CircularProgressIndicator())
          : RawKeyboardListener(
              focusNode: _pageFocusNode,
              autofocus: true,
              onKey: _handleKeyEvent,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Encabezado
                    _buildHeader(),
                    const SizedBox(height: 20),

                    // Avatar y información
                    _buildUserInfo(),
                    const SizedBox(height: 30),

                    // Sección Cuenta
                    _buildAccountSection(),
                    const SizedBox(height: 25),

                    // Sección Configuración
                    _buildSettingsSection(),
                    const SizedBox(height: 30),

                    // Botón Cerrar sesión
                    _buildLogoutButton(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          "Perfil",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        Image.asset("assets/images/InterfazTV.png", height: 55),
      ],
    );
  }

  Widget _buildUserInfo() {
    return Column(
      children: [
        CircleAvatar(
          radius: 60,
          backgroundColor: Colors.grey[300],
          child: Text(
            usuario!['nombre'][0],
            style: const TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.bold,
              color: Colors.black
            ),
          ),
        ),
        const SizedBox(height: 15),
        Text(
          usuario!['nombre'],
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.black
          ),
        ),
        const SizedBox(height: 5),
        Text(
          "${usuario!['telefono']}",
          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _buildAccountSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle("Cuenta"),
        const SizedBox(height: 10),
        _buildNavigableCard(
          icon: Icons.video_library,
          title: "Mi plan",
          subtitle: "Plan Básico",
          focusIndex: 0,
        ),
        _buildNavigableCard(
          icon: Icons.devices,
          title: "Dispositivos activos", 
          subtitle: "2 dispositivos",
          focusIndex: 1,
        ),
      ],
    );
  }

  Widget _buildSettingsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle("Configuración"),
        const SizedBox(height: 10),
        _buildNavigableCard(
          icon: Icons.person_outline,
          title: "Editar perfil",
          focusIndex: 2,
        ),
        _buildNavigableCard(
          icon: Icons.language,
          title: "Idioma de la app",
          focusIndex: 3,
        ),
        _buildNavigableCard(
          icon: Icons.notifications_none,
          title: "Notificaciones",
          focusIndex: 4,
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16, 
          fontWeight: FontWeight.bold, 
          color: Colors.black87
        ),
      ),
    );
  }

  Widget _buildNavigableCard({
    required IconData icon,
    required String title,
    String? subtitle,
    required int focusIndex,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Focus(
        focusNode: _focusNodes[focusIndex],
        child: Builder(
          builder: (context) {
            final isFocused = _focusNodes[focusIndex].hasFocus;
            
            return AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
              decoration: BoxDecoration(
                color: isFocused ? Colors.blue[50] : Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
                border: isFocused 
                    ? Border.all(color: const Color.fromARGB(255, 212, 33, 20), width: 2)
                    : Border.all(color: Colors.transparent, width: 0),
                boxShadow: isFocused
                    ? [
                        BoxShadow(
                          color: const Color.fromARGB(255, 212, 33, 20).withOpacity(0.3),
                          blurRadius: 8,
                          spreadRadius: 1,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 2,
                          offset: const Offset(0, 1),
                        ),
                      ],
              ),
              child: Row(
                children: [
                  Icon(
                    icon, 
                    color: isFocused 
                        ? const Color.fromARGB(255, 212, 33, 20)
                        : Colors.black54, 
                    size: 28
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: 16, 
                            fontWeight: FontWeight.w500,
                            color: isFocused ? const Color.fromARGB(255, 212, 33, 20) : Colors.black87,
                          ),
                        ),
                        if (subtitle != null)
                          Text(
                            subtitle,
                            style: TextStyle(
                              fontSize: 14, 
                              color: isFocused ? Colors.grey[700] : Colors.grey[600]
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (isFocused)
                    const Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: Color.fromARGB(255, 212, 33, 20),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildLogoutButton() {
    return Focus(
      focusNode: _focusNodes[5],
      child: Builder(
        builder: (context) {
          final isFocused = _focusNodes[5].hasFocus;
          
          return AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: double.infinity,
            decoration: BoxDecoration(
              color: isFocused
                  ? const Color.fromARGB(255, 180, 30, 15)
                  : const Color.fromARGB(255, 212, 33, 20),
              borderRadius: BorderRadius.circular(12),
              border: isFocused
                  ? Border.all(color: Colors.white, width: 2)
                  : null,
              boxShadow: isFocused
                  ? [
                      BoxShadow(
                        color: const Color.fromARGB(255, 180, 30, 15).withOpacity(0.6),
                        blurRadius: 10,
                        spreadRadius: 1,
                        offset: const Offset(0, 3),
                      ),
                    ]
                  : [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  child: Center(
                    child: Text(
                      'Cerrar sesión',
                      style: TextStyle(
                        fontSize: 18, 
                        color: Colors.white,
                        fontWeight: isFocused ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}