import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'favorites_page.dart';

class GameListPage extends StatefulWidget {
  final List<String> selectedTags;

  GameListPage({required this.selectedTags});

  @override
  _GameListPageState createState() => _GameListPageState();
}

class _GameListPageState extends State<GameListPage> {
  List<dynamic> favoriteGames = [];
  late User user;

  @override
  void initState() {
    super.initState();
    user = FirebaseAuth.instance.currentUser!;
    _fetchFavoriteGames();
  }

  Future<void> _fetchFavoriteGames() async {
    final snapshot = await FirebaseFirestore.instance.collection('users').doc(user.email).get();
    if (snapshot.exists) {
      setState(() {
        favoriteGames = snapshot.data()?['favorites'] ?? [];
      });
    }
  }

  Future<void> _saveFavoriteGames() async {
    await FirebaseFirestore.instance.collection('users').doc(user.email).set({
      'favorites': favoriteGames,
    });
  }

  Future<List<dynamic>> fetchGamesByTag(String tag) async {
    final response = await http.get(Uri.parse('https://steamspy.com/api.php?request=tag&tag=$tag'));

    if (response.statusCode == 200) {
      List<dynamic> games = json.decode(response.body).values.toList();

      for (var game in games) {
        final gameDetailsResponse = await http.get(Uri.parse('https://store.steampowered.com/api/appdetails?appids=${game['appid']}'));
        if (gameDetailsResponse.statusCode == 200) {
          var gameDetails = json.decode(gameDetailsResponse.body)['${game['appid']}']['data'];
          if (gameDetails != null) {
            game['image'] = gameDetails['header_image'];
            game['description'] = gameDetails['short_description'];
          }
        }
      }

      return games;
    } else {
      throw Exception('Failed to load games');
    }
  }

  void _toggleFavorite(dynamic game) {
    setState(() {
      if (favoriteGames.any((favGame) => favGame['appid'] == game['appid'])) {
        favoriteGames.removeWhere((favGame) => favGame['appid'] == game['appid']);
      } else {
        favoriteGames.add(game);
      }
    });
    _saveFavoriteGames();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF0A0A0A),
      appBar: AppBar(
        title: Text('Games List'),
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
        backgroundColor: Colors.indigo[900],
        actions: [
          IconButton(
            icon: Icon(Icons.star),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => FavoritesPage(favoriteGames: favoriteGames)),
              );
            },
          ),
        ],
      ),
      body: FutureBuilder<List<dynamic>>(
        future: fetchGamesByTag(widget.selectedTags[0]),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}', style: TextStyle(color: Colors.white)));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No games found for this tag', style: TextStyle(color: Colors.white)));
          } else {
            final games = snapshot.data!;
            return ListView.builder(
              itemCount: games.length,
              itemBuilder: (context, index) {
                final game = games[index];
                final isFavorite = favoriteGames.any((favGame) => favGame['appid'] == game['appid']);
                final gameName = game['name'] ?? 'Unknown';
                final gameImage = game['image'] ?? '';

                return ListTile(
                  leading: gameImage.isNotEmpty
                      ? Image.network(gameImage, width: 50, height: 50, fit: BoxFit.cover)
                      : Icon(Icons.broken_image, color: Colors.white),
                  title: Text(gameName, style: TextStyle(color: Colors.white)),
                  trailing: IconButton(
                    icon: Icon(
                      isFavorite ? Icons.star : Icons.star_border,
                      color: isFavorite ? Colors.yellow : Colors.white,
                    ),
                    onPressed: () => _toggleFavorite(game),
                  ),
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
            );
          }
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

