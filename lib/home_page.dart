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
  final FocusNode _contentFocusNode = FocusNode(debugLabel: 'Content');

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
    _contentFocusNode.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    if (index == 0) {
      _contentFocusNode.requestFocus();
    } else {
      _navFocusNode.requestFocus();
    }
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
      } else if (key == 'Arrow Down' && _selectedIndex == 0) {
        _contentFocusNode.requestFocus();
      } else if (key == 'Enter' || key == 'Select') {
        _onItemTapped(_selectedIndex);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isTV = MediaQuery.of(context).size.width > 600;
    
    final List<Widget> _pages = [
      InicioPage(
        focusNode: _contentFocusNode,
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
      height: 60,
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
    
    return GestureDetector(
      onTap: () => onTap(index),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? const Color.fromARGB(255, 212, 33, 20) : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          border: isSelected 
              ? Border.all(color: Colors.white, width: 1.5)
              : Border.all(color: Colors.grey.shade600, width: 1),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon, 
              color: isSelected ? Colors.white : Colors.grey.shade400, 
              size: 18
            ),
            SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey.shade400,
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Página de inicio con carousel optimizado para mostrar imágenes completas
class InicioPage extends StatefulWidget {
  final FocusNode focusNode;
  final VoidCallback onNavFocus;
  
  InicioPage({required this.focusNode, required this.onNavFocus});

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

  @override
  void initState() {
    super.initState();
    widget.focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    widget.focusNode.removeListener(_onFocusChange);
    super.dispose();
  }

  void _onFocusChange() {
    if (widget.focusNode.hasFocus && focusedIndex == -1) {
      setState(() {
        focusedIndex = 0;
      });
    }
  }

  void _handleKey(RawKeyEvent event) {
    if (event is RawKeyDownEvent) {
      final key = event.logicalKey.keyLabel;
      final screenSize = MediaQuery.of(context).size;
      final isLandscape = screenSize.width > screenSize.height;
      final totalCategories = 4;

      setState(() {
        switch (key) {
          case 'Arrow Down':
            if (focusedIndex == -1) {
              focusedIndex = 0;
            } else {
              focusedIndex = (focusedIndex + 1) % totalCategories;
            }
            break;

          case 'Arrow Up':
            if (focusedIndex == 0) {
              widget.onNavFocus();
              focusedIndex = -1;
            } else if (focusedIndex > 0) {
              focusedIndex = focusedIndex - 1;
            }
            break;

          case 'Arrow Right':
            if (focusedIndex >= 0) {
              final crossAxisCount = _getCrossAxisCount(context);
              int currentRow = focusedIndex ~/ crossAxisCount;
              int currentCol = focusedIndex % crossAxisCount;
              
              if (currentCol == crossAxisCount - 1) {
                focusedIndex = currentRow * crossAxisCount;
              } else {
                focusedIndex = currentRow * crossAxisCount + (currentCol + 1);
              }
            }
            break;

          case 'Arrow Left':
            if (focusedIndex >= 0) {
              final crossAxisCount = _getCrossAxisCount(context);
              int currentRow = focusedIndex ~/ crossAxisCount;
              int currentCol = focusedIndex % crossAxisCount;
              
              if (currentCol == 0) {
                focusedIndex = currentRow * crossAxisCount + (crossAxisCount - 1);
              } else {
                focusedIndex = currentRow * crossAxisCount + (currentCol - 1);
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

  int _getCrossAxisCount(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isLandscape = screenSize.width > screenSize.height;
    
    if (isLandscape) {
      return 4;
    }
    return 2;
  }

  void _abrirCategoria(int index) {
    final nombres = ["Deportes", "Noticias", "Películas", "Series"];
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Abriendo ${nombres[index]}..."),
        duration: Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isLandscape = screenSize.width > screenSize.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: RawKeyboardListener(
        focusNode: widget.focusNode,
        onKey: _handleKey,
        child: _buildContent(isLandscape),
      ),
    );
  }

  Widget _buildContent(bool isLandscape) {
    return SingleChildScrollView(
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCompactAppBar(isLandscape),
            SizedBox(height: 10),

            // Carousel optimizado para mostrar imágenes completas
            _buildCarousel(isLandscape),
            SizedBox(height: 8),

            _buildIndicators(),
            SizedBox(height: 12),

            _buildDescriptionText(isLandscape),
            SizedBox(height: 12),

            _buildCategoriesTitle(isLandscape),
            SizedBox(height: 8),

            _buildCategoriesGrid(isLandscape),
            
            SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _buildCompactAppBar(bool isLandscape) {
    return Row(
      children: [
        Text(
          "Inicio",
          style: TextStyle(
            fontSize: isLandscape ? 16 : 14,
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        Spacer(),
        Image.asset(
          "assets/images/InterfazTV.png", 
          height: isLandscape ? 28 : 24,
          fit: BoxFit.contain,
        ),
      ],
    );
  }

  Widget _buildCarousel(bool isLandscape) {
    // Altura del carousel optimizada para mostrar imágenes completas
    double carouselHeight = isLandscape ? 200 : 160;
    double viewportFraction = isLandscape ? 0.8 : 0.9;

    return Container(
      width: double.infinity,
      height: carouselHeight,
      child: CarouselSlider.builder(
        itemCount: images.length,
        itemBuilder: (context, index, realIndex) {
          return Container(
            margin: EdgeInsets.symmetric(horizontal: 6),
            decoration: BoxDecoration(
              color: Colors.grey[100], // Fondo por si la imagen no carga
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 6,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                images[index],
                fit: BoxFit.contain, // Cambiado de 'cover' a 'contain' para ver imagen completa
                width: double.infinity,
                height: double.infinity,
              ),
            ),
          );
        },
        options: CarouselOptions(
          height: carouselHeight,
          autoPlay: true,
          enlargeCenterPage: true,
          viewportFraction: viewportFraction,
          enableInfiniteScroll: true,
          autoPlayInterval: Duration(seconds: 5),
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
          dotHeight: 6,
          dotWidth: 6,
          activeDotColor: const Color.fromARGB(255, 212, 33, 20),
          dotColor: Colors.grey.shade400,
        ),
      ),
    );
  }

  Widget _buildDescriptionText(bool isLandscape) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 10),
      child: Text(
        "Disfruta de tus programas favoritos en la mejor calidad",
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: const Color.fromARGB(255, 100, 100, 100),
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildCategoriesTitle(bool isLandscape) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 4),
      child: Text(
        "Categorías",
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
    );
  }

  Widget _buildCategoriesGrid(bool isLandscape) {
    final List<Map<String, String>> categories = [
      {"image": "assets/images/deportes.jpg", "title": "⚽ Deportes"},
      {"image": "assets/images/noticias.jpg", "title": "📰 Noticias"},
      {"image": "assets/images/peliculas.jpg", "title": "🎬 Películas"},
      {"image": "assets/images/series.jpg", "title": "📺 Series"},
    ];

    final crossAxisCount = _getCrossAxisCount(context);

    return Container(
      width: double.infinity,
      child: GridView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          childAspectRatio: isLandscape ? 2.2 : 1.8,
        ),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          return _buildCompactCategoryItem(
            categories[index]["image"]!,
            categories[index]["title"]!,
            index,
            isLandscape: isLandscape,
          );
        },
      ),
    );
  }

  Widget _buildCompactCategoryItem(String imgPath, String titulo, int index, {required bool isLandscape}) {
    final isFocused = focusedIndex == index;
    
    return GestureDetector(
      onTap: () => _abrirCategoria(index),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 150),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isFocused
                ? const Color.fromARGB(255, 212, 33, 20)
                : Colors.transparent,
            width: isFocused ? 2 : 0,
          ),
          boxShadow: [
            if (isFocused)
              BoxShadow(
                color: const Color.fromARGB(255, 212, 33, 20).withOpacity(0.6),
                blurRadius: 8,
                spreadRadius: 1,
                offset: Offset(0, 2),
              )
            else
              BoxShadow(
                color: Colors.black26,
                blurRadius: 3,
                offset: Offset(0, 1),
              ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(
                imgPath, 
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[400],
                    child: Icon(
                      Icons.broken_image, 
                      color: Colors.white, 
                      size: 20
                    ),
                  );
                },
              ),
              
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withOpacity(0.7),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
              
              Align(
                alignment: Alignment.bottomLeft,
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(6),
                  child: Text(
                    titulo,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          color: Colors.black,
                          blurRadius: 4,
                          offset: Offset(1, 1),
                        ),
                      ],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}