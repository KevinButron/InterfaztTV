import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'home_page.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController telefonoController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final FocusNode telefonoFocus = FocusNode();
  final FocusNode passwordFocus = FocusNode();
  final FocusNode botonFocus = FocusNode();

  List<dynamic> usuarios = [];
  int currentFocusIndex = 0;
  List<FocusNode> focusNodes = [];

  @override
  void initState() {
    super.initState();
    cargarUsuarios();
    focusNodes = [telefonoFocus, passwordFocus, botonFocus];
    
    // Inicialmente enfocar el primer campo
    WidgetsBinding.instance.addPostFrameCallback((_) {
      telefonoFocus.requestFocus();
    });
  }

  // Manejar las teclas del control remoto
  void _handleKeyEvent(RawKeyEvent event) {
    if (event is RawKeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
        // Mover hacia abajo
        _moveFocus(1);
      } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
        // Mover hacia arriba
        _moveFocus(-1);
      } else if (event.logicalKey == LogicalKeyboardKey.enter ||
                 event.logicalKey == LogicalKeyboardKey.select) {
        // Presionar OK/Enter
        _handleSelect();
      }
    }
  }

  void _moveFocus(int direction) {
    setState(() {
      currentFocusIndex = (currentFocusIndex + direction) % focusNodes.length;
      if (currentFocusIndex < 0) {
        currentFocusIndex = focusNodes.length - 1;
      }
      focusNodes[currentFocusIndex].requestFocus();
    });
  }

  void _handleSelect() {
    if (focusNodes[currentFocusIndex] == botonFocus) {
      // Si está en el botón, ejecutar login
      login();
    } else {
      // Si está en un campo de texto, abrir teclado
      abrirTeclado(focusNodes[currentFocusIndex]);
    }
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
          builder: (context) =>
              HomePage(telefonoUsuario: usuario['telefono']),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color.fromARGB(255, 212, 33, 20),
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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

  void abrirTeclado(FocusNode focusNode) {
    focusNode.requestFocus();
    SystemChannels.textInput.invokeMethod('TextInput.show');
  }

  @override
  Widget build(BuildContext context) {
    return RawKeyboardListener(
      focusNode: FocusNode(),
      onKey: _handleKeyEvent,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: FocusTraversalGroup(
              policy: WidgetOrderTraversalPolicy(),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/InterfazTV.png',
                    height: 120,
                    fit: BoxFit.contain,
                  ),
                  SizedBox(height: 35),
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

                  // Campo teléfono
                  FocusTraversalOrder(
                    order: NumericFocusOrder(1),
                    child: Builder(
                      builder: (context) {
                        return TextField(
                          controller: telefonoController,
                          focusNode: telefonoFocus,
                          keyboardType: TextInputType.text,
                          textInputAction: TextInputAction.next,
                          readOnly: false,
                          showCursor: true,
                          style: TextStyle(color: Colors.black),
                          decoration: InputDecoration(
                            labelText: "Número de teléfono",
                            prefixIcon: Icon(Icons.phone, color: Colors.grey[700]),
                            filled: true,
                            fillColor: telefonoFocus.hasFocus 
                                ? Color.fromARGB(255, 255, 245, 245)
                                : Colors.grey[100],
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: telefonoFocus.hasFocus
                                    ? Color.fromARGB(255, 212, 33, 20)
                                    : Colors.grey.shade400,
                                width: telefonoFocus.hasFocus ? 2.0 : 1.0,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: Color.fromARGB(255, 212, 33, 20),
                                width: 2.0,
                              ),
                            ),
                          ),
                          onTap: () {
                            currentFocusIndex = 0;
                            abrirTeclado(telefonoFocus);
                          },
                          onEditingComplete: () {
                            currentFocusIndex = 1;
                            passwordFocus.requestFocus();
                          },
                        );
                      },
                    ),
                  ),
                  SizedBox(height: 20),

                  // Campo contraseña
                  FocusTraversalOrder(
                    order: NumericFocusOrder(2),
                    child: Builder(
                      builder: (context) {
                        return TextField(
                          controller: passwordController,
                          focusNode: passwordFocus,
                          obscureText: true,
                          keyboardType: TextInputType.text,
                          textInputAction: TextInputAction.done,
                          readOnly: false,
                          showCursor: true,
                          style: TextStyle(color: Colors.black),
                          decoration: InputDecoration(
                            labelText: "Contraseña",
                            prefixIcon: Icon(Icons.lock_outline, color: Colors.grey[700]),
                            filled: true,
                            fillColor: passwordFocus.hasFocus 
                                ? Color.fromARGB(255, 255, 245, 245)
                                : Colors.grey[100],
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: passwordFocus.hasFocus
                                    ? Color.fromARGB(255, 212, 33, 20)
                                    : Colors.grey.shade400,
                                width: passwordFocus.hasFocus ? 2.0 : 1.0,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: Color.fromARGB(255, 212, 33, 20),
                                width: 2.0,
                              ),
                            ),
                          ),
                          onTap: () {
                            currentFocusIndex = 1;
                            abrirTeclado(passwordFocus);
                          },
                          onEditingComplete: () {
                            currentFocusIndex = 2;
                            botonFocus.requestFocus();
                          },
                        );
                      },
                    ),
                  ),
                  SizedBox(height: 35),

                  // Botón Entrar
                  FocusTraversalOrder(
                    order: NumericFocusOrder(3),
                    child: Builder(
                      builder: (context) {
                        return ElevatedButton.icon(
                          focusNode: botonFocus,
                          onPressed: login,
                          icon: Icon(Icons.login, color: Colors.white),
                          label: Text("Entrar",
                              style: TextStyle(fontSize: 18, color: Colors.white)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: botonFocus.hasFocus
                                ? Color.fromARGB(255, 180, 28, 17)
                                : Color.fromARGB(255, 212, 33, 20),
                            padding:
                                EdgeInsets.symmetric(horizontal: 70, vertical: 16),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14)),
                            elevation: botonFocus.hasFocus ? 8 : 6,
                            shadowColor: botonFocus.hasFocus
                                ? Color.fromARGB(255, 212, 33, 20)
                                : Colors.black,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    telefonoController.dispose();
    passwordController.dispose();
    telefonoFocus.dispose();
    passwordFocus.dispose();
    botonFocus.dispose();
    super.dispose();
  }
}