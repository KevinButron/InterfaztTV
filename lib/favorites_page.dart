import 'package:flutter/material.dart';
import 'models/model.dart';
import 'player_page.dart';

class FavoritesPage extends StatefulWidget {
  final List<Model> favoritos;
  final Function(Model) onFavoritoChanged;

  FavoritesPage({required this.favoritos, required this.onFavoritoChanged});

  @override
  _FavoritesPageState createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            Text(
              "Mis Favoritos",
              style: TextStyle(
                fontSize: 20,
                color: Colors.black,
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
      body: widget.favoritos.isEmpty
          ? Center(child: Text("No tienes canales en favoritos"))
          : ListView.builder(
              itemCount: widget.favoritos.length,
              itemBuilder: (context, index) {
                final canal = widget.favoritos[index];
                return ListTile(
                  title: Text(
                    canal.nombre,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  leading: Icon(Icons.live_tv,
                      color: const Color.fromARGB(255, 212, 33, 20)),
                  trailing: IconButton(
                    icon: Icon(Icons.star, color: Colors.amber),
                    onPressed: () {
                      // ⚡ Quitar el favorito
                      widget.onFavoritoChanged(canal);
                      setState(() {}); // refresca la UI
                    },
                  ),
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
                );
              },
            ),
    );
  }
}
