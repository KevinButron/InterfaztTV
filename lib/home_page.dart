import 'package:flutter/material.dart';
import 'guia_page.dart';
import 'vivo_page.dart';
import 'favorites_page.dart';
import 'profile_page.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'models/model.dart';
import 'package:flutter/services.dart';

class HomePage extends StatefulWidget {
  final String telefonoUsuario;
  HomePage({super.key, required this.telefonoUsuario});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  List<Model> favoritos = [];
  final FocusNode _navFocusNode = FocusNode(debugLabel: 'Navigation');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _navFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _navFocusNode.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _handleNavKey(RawKeyEvent event) {
    if (event is RawKeyDownEvent) {
      final key = event.logicalKey.keyLabel;
      
      if (key == 'Arrow Right') {
        setState(() {
          _selectedIndex = (_selectedIndex + 1) % 5;
        });
      } else if (key == 'Arrow Left') {
        setState(() {
          _selectedIndex = (_selectedIndex - 1) < 0 ? 4 : (_selectedIndex - 1);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isTV = MediaQuery.of(context).size.width > 600;
    
    final List<Widget> _pages = [
      InicioPage(
        onNavFocus: () => _navFocusNode.requestFocus(),
      ),
      VivoPage(),
      GuiaPage(
        favoritos: favoritos,
        onFavoritoChanged: (canal) {
          setState(() {
            if (favoritos.contains(canal)) {
              favoritos.remove(canal);
            } else {
              favoritos.add(canal);
            }
          });
        },
      ),
      FavoritesPage(
        favoritos: favoritos,
        onFavoritoChanged: (canal) {
          setState(() {
            favoritos.remove(canal);
          });
        },
      ),
      PerfilPage(telefonoUsuario: widget.telefonoUsuario),
    ];

    return RawKeyboardListener(
      focusNode: _navFocusNode,
      onKey: _handleNavKey,
      child: Scaffold(
        body: _pages[_selectedIndex],
        bottomNavigationBar: isTV ? _buildTVNavigation() : _buildMobileNavigation(),
      ),
    );
  }

  Widget _buildTVNavigation() {
    return Container(
      height: 70,
      color: Colors.black87,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _TVNavItem(
            icon: Icons.home,
            label: "Inicio",
            index: 0,
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
          ),
          _TVNavItem(
            icon: Icons.live_tv,
            label: "En vivo",
            index: 1,
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
          ),
          _TVNavItem(
            icon: Icons.tv,
            label: "Guía",
            index: 2,
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
          ),
          _TVNavItem(
            icon: Icons.favorite,
            label: "Favoritos",
            index: 3,
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
          ),
          _TVNavItem(
            icon: Icons.person,
            label: "Perfil",
            index: 4,
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
          ),
        ],
      ),
    );
  }

  Widget _buildMobileNavigation() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: _selectedIndex,
      selectedItemColor: const Color.fromARGB(255, 212, 33, 20),
      backgroundColor: Colors.white,
      unselectedItemColor: Colors.black,
      onTap: _onItemTapped,
      items: [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: "Inicio"),
        BottomNavigationBarItem(icon: Icon(Icons.live_tv), label: "En vivo"),
        BottomNavigationBarItem(icon: Icon(Icons.tv), label: "Guía"),
        BottomNavigationBarItem(icon: Icon(Icons.favorite), label: "Favoritos"),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: "Perfil"),
      ],
    );
  }
}

class _TVNavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final int index;
  final int currentIndex;
  final Function(int) onTap;

  const _TVNavItem({
    required this.icon,
    required this.label,
    required this.index,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool isSelected = currentIndex == index;
    
    return Focus(
      autofocus: isSelected,
      child: GestureDetector(
        onTap: () => onTap(index),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? const Color.fromARGB(255, 212, 33, 20) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: isSelected 
                ? Border.all(color: Colors.white, width: 2)
                : Border.all(color: Colors.grey.shade600, width: 1),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon, 
                color: isSelected ? Colors.white : Colors.grey.shade400, 
                size: 22
              ),
              SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.grey.shade400,
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Página de inicio con NAVEACIÓN COMPLETAMENTE FUNCIONAL
class InicioPage extends StatefulWidget {
  final VoidCallback onNavFocus;
  
  InicioPage({required this.onNavFocus});

  @override
  _InicioPageState createState() => _InicioPageState();
}

class _InicioPageState extends State<InicioPage> {
  int activeIndex = 0;
  int focusedIndex = -1;
  final List<String> images = [
    'assets/images/im1.jpg',
    'assets/images/logo.jpg',
  ];
  final FocusNode _focusNode = FocusNode(debugLabel: 'HomeContent');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  void _handleKey(RawKeyEvent event) {
    if (event is RawKeyDownEvent) {
      final key = event.logicalKey.keyLabel;
      final isTV = MediaQuery.of(context).size.width > 600;
      final totalCategories = 6;

      setState(() {
        switch (key) {
          case 'Arrow Down':
            if (focusedIndex == -1) {
              focusedIndex = 0;
            } else {
              // Navegación vertical simple - todas las categorías
              focusedIndex = (focusedIndex + 1) % totalCategories;
            }
            break;

          case 'Arrow Up':
            if (focusedIndex == 0) {
              widget.onNavFocus();
              focusedIndex = -1;
            } else {
              focusedIndex = (focusedIndex - 1) % totalCategories;
            }
            break;

          case 'Arrow Right':
            if (isTV && focusedIndex >= 0) {
              // Navegación horizontal SIMPLIFICADA - solo cambia entre columnas
              int currentRow = focusedIndex ~/ 3;
              int currentCol = focusedIndex % 3;
              
              if (currentCol == 2) {
                // Última columna - ir a primera columna
                focusedIndex = currentRow * 3;
              } else {
                // Avanzar a siguiente columna
                focusedIndex = currentRow * 3 + (currentCol + 1);
              }
            }
            break;

          case 'Arrow Left':
            if (isTV && focusedIndex >= 0) {
              // Navegación horizontal SIMPLIFICADA - solo cambia entre columnas
              int currentRow = focusedIndex ~/ 3;
              int currentCol = focusedIndex % 3;
              
              if (currentCol == 0) {
                // Primera columna - ir a última columna
                focusedIndex = currentRow * 3 + 2;
              } else {
                // Retroceder a columna anterior
                focusedIndex = currentRow * 3 + (currentCol - 1);
              }
            }
            break;

          case 'Enter':
          case 'Select':
            if (focusedIndex >= 0) {
              _abrirCategoria(focusedIndex);
            }
            break;

          case 'Backspace':
          case 'Escape':
            widget.onNavFocus();
            focusedIndex = -1;
            break;
        }
      });
    }
  }

  void _abrirCategoria(int index) {
    final nombres = ["Deportes", "Noticias", "Películas", "Series", "Infantil", "Documentales"];
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Abriendo ${nombres[index]}..."),
        duration: Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTV = size.width > 600;

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
                fontSize: isTV ? 24 : 20,
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            Spacer(),
            Image.asset("assets/images/InterfazTV.png", 
                height: isTV ? 50 : 45),
          ],
        ),
      ),
      body: RawKeyboardListener(
        focusNode: _focusNode,
        onKey: _handleKey,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(isTV ? 16 : 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSearchBar(isTV),
              SizedBox(height: isTV ? 20 : 16),

              // Carousel más grande
              _buildCarousel(isTV),
              SizedBox(height: isTV ? 16 : 10),

              _buildIndicators(),
              SizedBox(height: isTV ? 20 : 16),

              _buildDescriptionText(isTV),
              SizedBox(height: isTV ? 20 : 16),

              _buildCategoriesTitle(isTV),
              SizedBox(height: isTV ? 16 : 12),

              // Grid de categorías con navegación garantizada
              _buildCategoriesGrid(isTV),
              
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar(bool isTV) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: isTV ? 16 : 10),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(isTV ? 12 : 10),
      ),
      child: Row(
        children: [
          Icon(Icons.search, color: Colors.black54, size: isTV ? 22 : 20),
          SizedBox(width: isTV ? 12 : 8),
          Expanded(
            child: TextField(
              style: TextStyle(
                fontSize: isTV ? 16 : 14,
                color: const Color.fromARGB(255, 60, 60, 60),
              ),
              decoration: InputDecoration(
                hintText: "Buscar contenido",
                hintStyle: TextStyle(
                  fontSize: isTV ? 16 : 14,
                  color: const Color.fromARGB(255, 60, 60, 60),
                ),
                border: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCarousel(bool isTV) {
    double carouselHeight = isTV ? 220 : 170; // Más grande

    return Container(
      height: carouselHeight,
      child: CarouselSlider.builder(
        itemCount: images.length,
        itemBuilder: (context, index, realIndex) {
          return Container(
            margin: EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(isTV ? 12 : 8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(isTV ? 12 : 8),
              child: Image.asset(
                images[index],
                fit: BoxFit.cover, // Cambiado a cover para mejor visualización
                width: double.infinity,
              ),
            ),
          );
        },
        options: CarouselOptions(
          height: carouselHeight,
          autoPlay: true,
          enlargeCenterPage: true,
          viewportFraction: isTV ? 0.8 : 0.85,
          enableInfiniteScroll: true,
          autoPlayInterval: Duration(seconds: 4),
          autoPlayAnimationDuration: Duration(milliseconds: 800),
          onPageChanged: (index, reason) => setState(() => activeIndex = index),
        ),
      ),
    );
  }

  Widget _buildIndicators() {
    return Center(
      child: AnimatedSmoothIndicator(
        activeIndex: activeIndex,
        count: images.length,
        effect: ExpandingDotsEffect(
          dotHeight: 8,
          dotWidth: 8,
          activeDotColor: const Color.fromARGB(255, 212, 33, 20),
          dotColor: Colors.grey.shade400,
        ),
      ),
    );
  }

  Widget _buildDescriptionText(bool isTV) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isTV ? 8 : 4),
      child: Text(
        "Disfruta de tus programas favoritos",
        style: TextStyle(
          fontSize: isTV ? 16 : 14,
          fontWeight: FontWeight.w500,
          color: const Color.fromARGB(255, 121, 121, 121),
        ),
      ),
    );
  }

  Widget _buildCategoriesTitle(bool isTV) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isTV ? 8 : 4),
      child: Text(
        "Categorías",
        style: TextStyle(
          fontSize: isTV ? 22 : 18,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
    );
  }

  Widget _buildCategoriesGrid(bool isTV) {
    final List<Map<String, String>> categories = [
      {"image": "assets/images/deportes.jpg", "title": "⚽ Deportes"},
      {"image": "assets/images/noticias.jpg", "title": "📰 Noticias"},
      {"image": "assets/images/peliculas.jpg", "title": "🎬 Películas"},
      {"image": "assets/images/series.jpg", "title": "📺 Series"},
      {"image": "assets/images/infantil.jpg", "title": "🧸 Infantil"},
      {"image": "assets/images/documentales.jpg", "title": "🌍 Documentales"},
    ];

    if (isTV) {
      // Grid 2x3 con navegación GARANTIZADA
      return GridView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 16 / 9,
        ),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          return _buildCategoryItem(
            categories[index]["image"]!,
            categories[index]["title"]!,
            index,
            isTV: true,
          );
        },
      );
    } else {
      // Lista vertical para móvil
      return Column(
        children: [
          for (int i = 0; i < categories.length; i++) ...[
            _buildCategoryItem(
              categories[i]["image"]!,
              categories[i]["title"]!,
              i,
              isTV: false,
            ),
            if (i < categories.length - 1) SizedBox(height: 12),
          ],
        ],
      );
    }
  }

  Widget _buildCategoryItem(String imgPath, String titulo, int index, {required bool isTV}) {
    final isFocused = focusedIndex == index;
    
    return Focus(
      focusNode: FocusNode(), // Cada item tiene su propio FocusNode
      autofocus: isFocused,
      child: Builder(
        builder: (context) {
          return AnimatedContainer(
            duration: Duration(milliseconds: 150),
            height: isTV ? 100 : 110,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(isTV ? 10 : 12),
              border: Border.all(
                color: isFocused
                    ? const Color.fromARGB(255, 212, 33, 20)
                    : Colors.transparent,
                width: isTV ? 3 : 2,
              ),
              boxShadow: [
                if (isFocused)
                  BoxShadow(
                    color: const Color.fromARGB(255, 212, 33, 20).withOpacity(0.6),
                    blurRadius: 12,
                    spreadRadius: 2,
                    offset: Offset(0, 3),
                  )
                else
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 6,
                    offset: Offset(0, 2),
                  ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => _abrirCategoria(index),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(isTV ? 10 : 12),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.asset(
                        imgPath, 
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey[300],
                            child: Icon(Icons.error, color: Colors.grey, size: 30),
                          );
                        },
                      ),
                      Container(
                        alignment: Alignment.bottomLeft,
                        padding: EdgeInsets.all(isTV ? 10 : 8),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.black.withOpacity(0.7), Colors.transparent],
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                          ),
                        ),
                        child: Text(
                          titulo,
                          style: TextStyle(
                            fontSize: isTV ? 14 : 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            shadows: [
                              Shadow(
                                color: Colors.black,
                                blurRadius: 6,
                                offset: Offset(2, 2),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
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