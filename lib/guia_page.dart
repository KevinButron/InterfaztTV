import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'models/model.dart';
import 'dart:async';
import 'player_page.dart';

class  GuiaPageholder extends StatelessWidget { //class  GuiaPage extends StatelessWidget
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
              "Guía de TV",
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
 

  @override
  void initState() {
    super.initState();
    loadCanales();
    _getMexicoCityTime();
    _setupScrollSync();
  }

  void _setupScrollSync() {
    _horizontalScrollController.addListener(() {
      // Sincronizar scroll horizontal si es necesario
    });
    
    _verticalScrollController.addListener(() {
      // Sincronizar scroll vertical si es necesario
    });
  }

  Future<void> _getMexicoCityTime() async {
    // Obtener la hora actual de la Ciudad de México (UTC-6 o UTC-5 según horario de verano)
    final now = DateTime.now().toUtc();
    
    // Determinar si está en horario de verano (generalmente primer domingo de abril a último domingo de octubre)
    final bool isDst = _isMexicoDaylightSavingTime(now);
    final int utcOffset = isDst ? -5 : -6;
    
    // Ajustar la hora según el offset de México
    final mexicoTime = now.add(Duration(hours: utcOffset));
    
    setState(() {
      _currentTime = mexicoTime;
      _generateTimeSlots();
      
      // Calcular el índice de la hora actual para scroll automático
      _currentHourIndex = _currentTime.hour - 6;
      if (_currentHourIndex < 0) _currentHourIndex = 0;
      if (_currentHourIndex >= _timeSlots.length) _currentHourIndex = _timeSlots.length - 1;
    });
    
    // Scroll automático a la hora actual después de un breve delay
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(Duration(milliseconds: 300), () {
        _scrollToCurrentTime();
      });
    });
  }

  bool _isMexicoDaylightSavingTime(DateTime date) {
    // El horario de verano en México generalmente va del primer domingo de abril al último domingo de octubre
    final year = date.year;
    
    // Encontrar el primer domingo de abril
    DateTime dstStart = DateTime(year, 4, 1);
    while (dstStart.weekday != DateTime.sunday) {
      dstStart = dstStart.add(Duration(days: 1));
    }
    
    // Encontrar el último domingo de octubre
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
        _currentTime.day, 6, 0); // Comienza a las 6:00 AM
    DateTime endTime = startTime.add(Duration(hours: 18)); // Hasta media noche

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
    final String response = await rootBundle.loadString('assets/canales.json');
    final List<dynamic> data = json.decode(response);
    setState(() {
      canales = data.map((json) => Model.fromJson(json)).toList();
    });
  }

  String _getProgramTime(int progIndex) {
    final startHour = 6 + progIndex; // Comienza a las 6:00 AM
    final endHour = startHour + 1;
    
    final startDisplay = startHour > 12 ? startHour - 12 : startHour;
    final endDisplay = endHour > 12 ? endHour - 12 : endHour;
    
    final startAmPm = startHour >= 12 ? 'PM' : 'AM';
    final endAmPm = endHour >= 12 ? 'PM' : 'AM';
    
    return "${startDisplay.toString().padLeft(2, '0')}:00 $startAmPm - ${endDisplay.toString().padLeft(2, '0')}:00 $endAmPm";
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    if (canales.isEmpty) {
      return Scaffold(
        backgroundColor: Colors.grey[900],
        appBar: AppBar(
          title: Text("Guía de TV", style: TextStyle(fontWeight: FontWeight.bold)),
          backgroundColor: Colors.white,
          elevation: 0,
        ),
        body: Center(
          child: CircularProgressIndicator(color: Colors.black),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color.fromARGB(250, 255, 255, 255),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
          title: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Guía de TV", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
                Text(
                  "Hora CDMX: ${_currentTime.hour.toString().padLeft(2, '0')}:${_currentTime.minute.toString().padLeft(2, '0')}",
                  style: TextStyle(fontSize: 12, color: const Color.fromARGB(255, 65, 65, 65)),
                ),
              ],
            ),
            const SizedBox(width: 8), // espacio entre texto y íconos
            IconButton(
              icon: Icon(Icons.calendar_today, size: 20, color: Colors.black),
              onPressed: () {
                // Acción para cambiar fecha
              },
            ),
            IconButton(
              icon: Icon(Icons.filter_list, size: 20, color: Colors.black),
              onPressed: () {
                // Acción para filtrar
              },
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12), // espacio a la derecha
            child: Image.asset(
              "assets/images/InterfazTV.png",
              height: 55,
            ),
          ),
        ],
      ),

      body: Column(
        children: [
          // Cabecera con franjas horarias
          Container(
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
                      color: const Color.fromARGB(240, 255, 255, 255),
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
                          color: isCurrentHour ? const Color.fromARGB(255, 212, 33, 20): Colors.transparent,
                          border: Border(right: BorderSide(color: Colors.black!)),
                        ),
                        child: Text(
                          _timeSlots[index],
                          style: TextStyle(
                            color: isCurrentHour ? Colors.white : const Color.fromARGB(240, 255, 255, 255),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          // Lista de canales y programas
          Expanded(
            child: Row(
              children: [
                // Columna de nombres de canales
                Container(
                  width: 120,
                  child: ListView.builder(
                    controller: _verticalScrollController,
                    itemCount: canales.length,
                    itemBuilder: (context, index) {
                      final canal = canales[index];
                      return Container(
                        height: 80,
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(235, 255, 255, 255),
                          border: Border(
                            bottom: BorderSide(color: const Color.fromARGB(205, 225, 225, 225)!)
                          ),
                        ),
                        child: Stack(
                          children: [
                            Positioned(
                              top: 2,
                              right: 0.5,
                              child: IconButton(
                                //padding: EdgeInsets.zero,
                                constraints: BoxConstraints(),
                                icon: Icon(
                                  //widget.favoritos.contains(canal) ? Icons.star : Icons.star_border,
                                  widget.favoritos.any((f) => f.nombre == canal.nombre) 
                                    ? Icons.star 
                                    : Icons.star_border,
                                  color: Colors.amber,
                                  size: 18,
                                ),
                                onPressed: () {
                                  //widget.onFavoritoChanged(canal);
                                  //setState(() {});
                                  if (widget.favoritos.any((f) => f.nombre == canal.nombre)) {
                                    widget.onFavoritoChanged(canal); // quitar
                                  } else {
                                    widget.onFavoritoChanged(canal); // agregar
}
                                },
                              ),
                            ),

                            Center(
                              child:Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 36,
                                    height: 36,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: const Color.fromARGB(255, 212, 33, 20),
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
                                  Text(
                                    canal.nombre,
                                    textAlign: TextAlign.center,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                  },),
                ),
                // Programación
                Expanded(
                  child: ListView.builder(
                    controller: _verticalScrollController,
                    itemCount: canales.length,
                    itemBuilder: (context, index) {
                      final canal = canales[index];
                      return Container(
                        height: 80,
                        decoration: BoxDecoration(
                          border: Border(bottom: BorderSide(color: const Color.fromARGB(255, 225, 225, 225)!)),
                        ),
                        child: ListView.builder(
                          controller: _horizontalScrollController,
                          scrollDirection: Axis.horizontal,
                          itemCount: canal.programas.length,
                          itemBuilder: (context, progIndex) {
                            final programa = canal.programas[progIndex];
                            final isCurrentProgram = progIndex == _currentHourIndex;
                            
                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => PlayerPage(
                                      videoUrl: canal.url,
                                      canalName: canal.nombre,
                                    ),
                                  ),
                                );
                              },
                              child: Container(
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
                                  border: isCurrentProgram ? Border.all(color: Colors.grey, width: 2) : null,
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
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _scrollToCurrentTime,
        backgroundColor: const Color.fromARGB(255, 212, 33, 20),
        child: Icon(Icons.access_time, color: Colors.white),
        tooltip: 'Ir a hora actual',
      ),
    );
  }

  Color _getProgramColor(int index) {
    List<Color> colors = [
      const Color.fromARGB(255, 0, 0, 0),
      const Color.fromARGB(205, 50, 50, 50),
      const Color.fromARGB(205, 100, 100, 100),
      const Color.fromARGB(205, 150, 150, 150),
      const Color.fromARGB(255, 104, 35, 224),
      const Color.fromARGB(255, 44, 131, 217)!,
      const Color.fromARGB(255, 0, 121, 46)!,
      const Color.fromARGB(255, 31, 51, 185)!,
      Colors.pink[700]!,
    ];
    return colors[index % colors.length];
  }
} 