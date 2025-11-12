import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'models/model.dart';
import 'dart:async';
import 'player_page.dart';

class GuiaPage extends StatefulWidget {
  final List<Model> favoritos;
  final Function(Model) onFavoritoChanged;

  GuiaPage({required this.favoritos, required this.onFavoritoChanged});

  @override
  State<GuiaPage> createState() => _GuiaPageState();
}

class _GuiaPageState extends State<GuiaPage> {
  List<Model> canales = [];
  final ScrollController _horizontalScrollController = ScrollController();
  final ScrollController _verticalScrollController = ScrollController();
  DateTime _currentTime = DateTime.now();
  List<String> _timeSlots = [];
  int _currentHourIndex = 0;
  
  // Variables optimizadas para foco
  final FocusNode _mainFocusNode = FocusNode();
  int _focusedRow = 0;
  bool _isLoading = true;

  // Variables para el doble click
  DateTime? _lastEnterPress;
  Timer? _doublePressTimer;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Restaurar el foco cuando la página vuelve a ser visible
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_mainFocusNode.hasFocus) {
        _mainFocusNode.requestFocus();
      }
    });
  }

  Future<void> _initializeData() async {
    await loadCanales();
    await _getMexicoCityTime();
    _setupFocus();
  }

  void _setupFocus() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _mainFocusNode.requestFocus();
    });
  }

  Future<void> _getMexicoCityTime() async {
    final now = DateTime.now().toUtc();
    final bool isDst = _isMexicoDaylightSavingTime(now);
    final int utcOffset = isDst ? -5 : -6;
    final mexicoTime = now.add(Duration(hours: utcOffset));
    
    setState(() {
      _currentTime = mexicoTime;
      _generateTimeSlots();
      _currentHourIndex = _currentTime.hour - 6;
      if (_currentHourIndex < 0) _currentHourIndex = 0;
      if (_currentHourIndex >= _timeSlots.length) _currentHourIndex = _timeSlots.length - 1;
    });
    
    // Scroll después de que la UI esté lista
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToCurrentTime();
    });
  }

  bool _isMexicoDaylightSavingTime(DateTime date) {
    final year = date.year;
    DateTime dstStart = DateTime(year, 4, 1);
    while (dstStart.weekday != DateTime.sunday) {
      dstStart = dstStart.add(Duration(days: 1));
    }
    DateTime dstEnd = DateTime(year, 10, 31);
    while (dstEnd.weekday != DateTime.sunday) {
      dstEnd = dstEnd.subtract(Duration(days: 1));
    }
    return date.isAfter(dstStart.subtract(Duration(days: 1))) && 
           date.isBefore(dstEnd.add(Duration(days: 1)));
  }

  void _generateTimeSlots() {
    _timeSlots = [];
    DateTime startTime = DateTime(_currentTime.year, _currentTime.month, 
        _currentTime.day, 6, 0);
    DateTime endTime = startTime.add(Duration(hours: 18));

    while (startTime.isBefore(endTime)) {
      final hour = startTime.hour;
      final displayHour = hour > 12 ? hour - 12 : hour;
      final amPm = hour >= 12 ? 'PM' : 'AM';
      _timeSlots.add("${displayHour.toString().padLeft(2, '0')}:00 $amPm");
      startTime = startTime.add(Duration(hours: 1));
    }
  }

  void _scrollToCurrentTime() {
    if (_horizontalScrollController.hasClients) {
      final scrollPosition = _currentHourIndex * 150.0;
      _horizontalScrollController.animateTo(
        scrollPosition,
        duration: Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> loadCanales() async {
    try {
      final String response = await rootBundle.loadString('assets/canales.json');
      final List<dynamic> data = json.decode(response);
      setState(() {
        canales = data.map((json) => Model.fromJson(json)).toList();
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading channels: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _getProgramTime(int progIndex) {
    final startHour = 6 + progIndex;
    final endHour = startHour + 1;
    final startDisplay = startHour > 12 ? startHour - 12 : startHour;
    final endDisplay = endHour > 12 ? endHour - 12 : endHour;
    final startAmPm = startHour >= 12 ? 'PM' : 'AM';
    final endAmPm = endHour >= 12 ? 'PM' : 'AM';
    
    return "${startDisplay.toString().padLeft(2, '0')}:00 $startAmPm - ${endDisplay.toString().padLeft(2, '0')}:00 $endAmPm";
  }

  // Manejo de navegación optimizado con doble press
  void _handleKeyEvent(RawKeyEvent event) {
    if (event is RawKeyDownEvent) {
      switch (event.logicalKey) {
        case LogicalKeyboardKey.arrowDown:
          _moveVertical(1);
          break;
        
        case LogicalKeyboardKey.arrowUp:
          _moveVertical(-1);
          break;
        
        case LogicalKeyboardKey.arrowRight:
          _scrollHorizontal(1);
          break;
        
        case LogicalKeyboardKey.arrowLeft:
          _scrollHorizontal(-1);
          break;
        
        case LogicalKeyboardKey.select:
        case LogicalKeyboardKey.enter:
          _handleEnterPress();
          break;
        
        case LogicalKeyboardKey.contextMenu:
        case LogicalKeyboardKey.keyF:
          _toggleFavorito();
          break;
        
        default:
          break;
      }
    }
  }

  // Manejo de doble press en Enter/Select
  void _handleEnterPress() {
    final now = DateTime.now();
    
    // Si hay un timer activo, cancelarlo y ejecutar como doble press
    if (_doublePressTimer != null && _doublePressTimer!.isActive) {
      _doublePressTimer!.cancel();
      _handleDoubleEnterPress();
    } else {
      // Primer press - iniciar timer
      _lastEnterPress = now;
      _doublePressTimer = Timer(Duration(milliseconds: 500), () {
        // Si el timer expira sin segundo press, ejecutar acción simple
        _handleSingleEnterPress();
      });
    }
  }

  void _handleSingleEnterPress() {
    // Acción normal: reproducir canal
    _selectCanal();
    _doublePressTimer = null;
    _lastEnterPress = null;
  }

  void _handleDoubleEnterPress() {
    // Acción doble press: agregar a favoritos
    _toggleFavoritoWithFeedback();
    _doublePressTimer = null;
    _lastEnterPress = null;
  }

  void _moveVertical(int delta) {
    if (canales.isEmpty) return;
    
    final newRow = (_focusedRow + delta).clamp(0, canales.length - 1);
    if (newRow != _focusedRow) {
      setState(() {
        _focusedRow = newRow;
      });
      
      // Scroll suave sin rebuild
      _verticalScrollController.animateTo(
        _focusedRow * 80.0,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _scrollHorizontal(int direction) {
    if (!_horizontalScrollController.hasClients) return;
    
    final currentPosition = _horizontalScrollController.offset;
    final newPosition = currentPosition + (direction * 300);
    
    _horizontalScrollController.animateTo(
      newPosition.clamp(0.0, _horizontalScrollController.position.maxScrollExtent),
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _selectCanal() {
    if (_focusedRow < canales.length) {
      final canal = canales[_focusedRow];
      
      // Guardar el estado actual antes de navegar
      final currentFocusedRow = _focusedRow;
      
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PlayerPage(
            videoUrl: canal.url,
            canalName: canal.nombre,
          ),
        ),
      ).then((_) {
        // Al regresar, restaurar el foco y el estado
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            setState(() {
              _focusedRow = currentFocusedRow;
            });
            _mainFocusNode.requestFocus();
            
            // También restaurar la posición del scroll
            _verticalScrollController.animateTo(
              _focusedRow * 80.0,
              duration: Duration(milliseconds: 100),
              curve: Curves.easeInOut,
            );
          }
        });
      });
    }
  }

  void _toggleFavorito() {
    if (_focusedRow < canales.length) {
      final canal = canales[_focusedRow];
      widget.onFavoritoChanged(canal);
    }
  }

  void _toggleFavoritoWithFeedback() {
    if (_focusedRow < canales.length) {
      final canal = canales[_focusedRow];
      final wasFavorito = widget.favoritos.any((f) => f.nombre == canal.nombre);
      
      widget.onFavoritoChanged(canal);
      
      // Mostrar feedback visual
      _showFavoritoFeedback(!wasFavorito);
    }
  }

  void _showFavoritoFeedback(bool added) {
    // Feedback visual simple
    final snackBar = SnackBar(
      content: Row(
        children: [
          Icon(
            added ? Icons.star : Icons.star_border,
            color: Colors.amber,
          ),
          SizedBox(width: 8),
          Text(
            added ? 'Agregado a favoritos' : 'Removido de favoritos',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
      backgroundColor: Colors.grey[800],
      duration: Duration(seconds: 1),
    );
    
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  // Widget optimizado para la cabecera de tiempos
  Widget _buildTimeHeader() {
    return Container(
      height: 50,
      color: Colors.black,
      child: Row(
        children: [
          Container(
            width: 120,
            alignment: Alignment.center,
            child: Text(
              "CANALES",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              controller: _horizontalScrollController,
              scrollDirection: Axis.horizontal,
              itemCount: _timeSlots.length,
              itemBuilder: (context, index) {
                final isCurrentHour = index == _currentHourIndex;
                return Container(
                  width: 150,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isCurrentHour ? Color(0xFFD42114) : Colors.transparent,
                    border: Border(right: BorderSide(color: Colors.grey[800]!)),
                  ),
                  child: Text(
                    _timeSlots[index],
                    style: TextStyle(
                      color: isCurrentHour ? Colors.white : Colors.white70,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Widget optimizado para la lista de canales
  Widget _buildChannelsList() {
    return Expanded(
      child: Row(
        children: [
          // Columna de canales
          Container(
            width: 120,
            child: ListView.builder(
              controller: _verticalScrollController,
              itemCount: canales.length,
              itemBuilder: (context, index) {
                return _buildChannelItem(index);
              },
            ),
          ),
          // Programación
          Expanded(
            child: ListView.builder(
              controller: _verticalScrollController,
              itemCount: canales.length,
              itemBuilder: (context, index) {
                return _buildProgramsRow(index);
              },
            ),
          ),
        ],
      ),
    );
  }

  // Widget optimizado para item de canal
  Widget _buildChannelItem(int index) {
    final canal = canales[index];
    final isFocused = index == _focusedRow;
    final isFavorito = widget.favoritos.any((f) => f.nombre == canal.nombre);
    
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: isFocused ? Colors.blue[100] : Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey[300]!),
          right: isFocused ? BorderSide(color: Color(0xFFD42114), width: 3) : BorderSide.none,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: 2,
            right: 2,
            child: Icon(
              isFavorito ? Icons.star : Icons.star_border,
              color: Colors.amber,
              size: 18,
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFFD42114),
                  ),
                  child: Center(
                    child: Text(
                      canal.nombre.substring(0, 1),
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  canal.nombre,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: isFocused ? Color(0xFFD42114) : Colors.black,
                    fontSize: 12,
                    fontWeight: isFocused ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Widget optimizado para fila de programas
  Widget _buildProgramsRow(int index) {
    final canal = canales[index];
    final isFocused = index == _focusedRow;
    
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: isFocused ? Colors.blue[50] : Colors.transparent,
        border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
      ),
      child: ListView.builder(
        controller: _horizontalScrollController,
        scrollDirection: Axis.horizontal,
        itemCount: canal.programas.length,
        itemBuilder: (context, progIndex) {
          return _buildProgramItem(canal, progIndex);
        },
      ),
    );
  }

  // Widget optimizado para item de programa
  Widget _buildProgramItem(Model canal, int progIndex) {
    final programa = canal.programas[progIndex];
    final isCurrentProgram = progIndex == _currentHourIndex;
    
    return Container(
      width: 150,
      margin: EdgeInsets.all(4),
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: _getProgramColor(progIndex),
        borderRadius: BorderRadius.circular(4),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 2,
            offset: Offset(1, 1),
          ),
        ],
        border: isCurrentProgram 
          ? Border.all(color: Colors.white, width: 2) 
          : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            programa,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          SizedBox(height: 4),
          Text(
            _getProgramTime(progIndex),
            style: TextStyle(
              color: Colors.white70,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Colors.grey[900],
        appBar: AppBar(
          title: Text("Guía de TV", style: TextStyle(fontWeight: FontWeight.bold)),
          backgroundColor: Colors.white,
        ),
        body: Center(
          child: CircularProgressIndicator(color: Colors.black),
        ),
      );
    }

    return RawKeyboardListener(
      focusNode: _mainFocusNode,
      autofocus: true,
      onKey: _handleKeyEvent,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Guía de TV", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
                  Text(
                    "Hora CDMX: ${_currentTime.hour.toString().padLeft(2, '0')}:${_currentTime.minute.toString().padLeft(2, '0')}",
                    style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Image.asset(
                "assets/images/InterfazTV.png",
                height: 55,
                errorBuilder: (context, error, stackTrace) => 
                  Icon(Icons.tv, color: Colors.black, size: 40),
              ),
            ),
          ],
        ),
        body: Column(
          children: [
            _buildTimeHeader(),
            _buildChannelsList(),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _scrollToCurrentTime,
          backgroundColor: Color(0xFFD42114),
          child: Icon(Icons.access_time, color: Colors.white),
          tooltip: 'Ir a hora actual',
        ),
      ),
    );
  }

  Color _getProgramColor(int index) {
    List<Color> colors = [
      Colors.black,
      Colors.grey[800]!,
      Colors.grey[600]!,
      Colors.grey[400]!,
      Color(0xFF6823E0),
      Color(0xFF2C83D9),
      Color(0xFF00792E),
      Color(0xFF1F33B9),
      Colors.pink[700]!,
    ];
    return colors[index % colors.length];
  }

  @override
  void dispose() {
    _mainFocusNode.dispose();
    _horizontalScrollController.dispose();
    _verticalScrollController.dispose();
    _doublePressTimer?.cancel();
    super.dispose();
  }
}