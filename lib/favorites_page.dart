import 'package:flutter/material.dart';

class FavoritesPage extends StatelessWidget {
  final List<dynamic> favoriteGames;

  FavoritesPage({required this.favoriteGames});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF0A0A0A),
      appBar: AppBar(
        title: Text('Favorite Games'),
        backgroundColor: Colors.indigo[900],
      ),
      body: favoriteGames.isEmpty
          ? Center(child: Text('No favorite games added.', style: TextStyle(color: Colors.white)))
          : ListView.builder(
        itemCount: favoriteGames.length,
        itemBuilder: (context, index) {
          final game = favoriteGames[index];
          final gameName = game['name'] ?? 'Unknown';
          final gameImage = game['image'] ?? '';

          return ListTile(
            leading: gameImage.isNotEmpty
                ? Image.network(gameImage, width: 50, height: 50, fit: BoxFit.cover)
                : Icon(Icons.broken_image, color: Colors.white),
            title: Text(gameName, style: TextStyle(color: Colors.white)),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => GameDetailPage(
                    gameName: gameName,
                    gameDescription: game['description'] ?? 'No description available',
                    gameImage: gameImage,
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

class GameDetailPage extends StatelessWidget {
  final String gameName;
  final String gameDescription;
  final String? gameImage;

  GameDetailPage({
    required this.gameName,
    required this.gameDescription,
    this.gameImage,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF0A0A0A),
      appBar: AppBar(
        title: Text(gameName),
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
        backgroundColor: Colors.indigo[900],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            if (gameImage != null)
              Center(
                child: Image.network(gameImage!, height: 200),
              ),
            SizedBox(height: 20),
            Text(
              gameName,
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            Text(
              gameDescription,
              style: TextStyle(
                color: Colors.white70,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}