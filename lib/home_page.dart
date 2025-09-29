import 'package:flutter/material.dart';
import 'guia_page.dart';
import 'vivo_page.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  // Aquí defines las pantallas para cada item del navbar
  final List<Widget> _pages = [
    InicioPage(),
    VivoPage(),
    GuiaPage(),
    Center(child: Text("⭐ Favoritos", style: TextStyle(fontSize: 22))),
    Center(child: Text("👤 Perfil", style: TextStyle(fontSize: 22))),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.deepPurple,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Inicio",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.live_tv),
            label: "En vivo",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.tv),
            label: "Guía",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: "Favoritos",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "Perfil",
          ),
        ],
      ),
    );
  }
}

/// Página de inicio
class InicioPage extends StatefulWidget {
  @override
  _InicioPageState createState() => _InicioPageState();
}

class _InicioPageState extends State<InicioPage> {
  int activeIndex = 0;

  final List<String> images = [
    'assets/images/im1.jpg',
    'assets/images/logo.jpg',
  ];

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isLandscape = size.width > size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            Text(
              "Inicio",
              style: TextStyle(
                color: const Color.fromARGB(255, 2, 1, 1),
                fontWeight: FontWeight.bold,
              ),
            ),
            Spacer(),
            Image.asset(
              "assets/images/Logo_inicio.png",
              height: 70,
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(size.width * 0.04),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Barra de búsqueda
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.search, color: Colors.black54),
                  SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: "Buscar contenido",
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),

            // Carousel de imágenes
            CarouselSlider.builder(
              itemCount: images.length,
              itemBuilder: (context, index, realIndex) {
                final img = images[index];
                return ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    img,
                    fit: BoxFit.contain,
                    width: double.infinity,
                  ),
                );
              },
              options: CarouselOptions(
                height: isLandscape ? size.height * 0.5 : size.height * 0.25,
                autoPlay: true,
                enlargeCenterPage: true,
                viewportFraction: 0.9,
                onPageChanged: (index, reason) =>
                    setState(() => activeIndex = index),
              ),
            ),
            SizedBox(height: 12),

            // Indicadores de puntos
            Center(
              child: AnimatedSmoothIndicator(
                activeIndex: activeIndex,
                count: images.length,
                effect: ExpandingDotsEffect(
                  dotHeight: 8,
                  dotWidth: 8,
                  activeDotColor: Colors.deepPurple,
                  dotColor: Colors.grey.shade400,
                ),
              ),
            ),

            SizedBox(height: 20),

            Text(
              "Disfruta de tus programas favoritos",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),

            SizedBox(height: 20),

            // Categorías
            Text(
              "Categorías",
              style: TextStyle(
                  fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
            ),
            SizedBox(height: 15),

            Column(
              children: [
                _categoriaItem("assets/images/deportes.jpg", "⚽ Deportes"),
                SizedBox(height: 15),
                _categoriaItem("assets/images/noticias.jpg", "📰 Noticias"),
                SizedBox(height: 15),
                _categoriaItem("assets/images/peliculas.jpg", "🎬 Películas"),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _categoriaItem(String imgPath, String titulo) {
    return Container(
      height: 160,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              imgPath,
              fit: BoxFit.cover,
            ),
            Container(
              alignment: Alignment.bottomLeft,
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.black.withOpacity(0.6), Colors.transparent],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
              ),
              child: Text(
                titulo,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      color: Colors.black54,
                      blurRadius: 6,
                      offset: Offset(1, 1),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
