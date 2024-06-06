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
    final snapshot = await FirebaseFirestore.instance.collection('users').doc(user.uid).collection('favorites').get();
    if (snapshot.docs.isNotEmpty) {
      setState(() {
        favoriteGames = snapshot.docs.map((doc) => doc.data()).toList();
      });
    }
  }

  Future<void> _saveFavoriteGames() async {
    final userDoc = FirebaseFirestore.instance.collection('users').doc(user.uid);
    final batch = FirebaseFirestore.instance.batch();

    // Clear existing favorites collection
    final favoritesCollection = userDoc.collection('favorites');
    final favoritesSnapshot = await favoritesCollection.get();
    for (var doc in favoritesSnapshot.docs) {
      batch.delete(doc.reference);
    }

    // Add updated favorites
    for (var game in favoriteGames) {
      final newDoc = favoritesCollection.doc(game['appid'].toString());
      batch.set(newDoc, game);
    }

    await batch.commit();
  }

  Future<List<dynamic>> fetchGamesByTags(List<String> tags) async {
    List<dynamic> allGames = [];

    for (String tag in tags) {
      final games = await fetchGamesByTag(tag);
      allGames.addAll(games);
    }

    // Remove duplicates
    Map<int, dynamic> uniqueGames = { for (var game in allGames) game['appid']: game };
    allGames = uniqueGames.values.toList();

    // Sort games by positive reviews in descending order and take top 100
    allGames.sort((a, b) => (b['positive'] ?? 0).compareTo(a['positive'] ?? 0));
    allGames = allGames.take(100).toList();

    return allGames;
  }

  Future<List<dynamic>> fetchGamesByTag(String tag) async {
    final response = await http.get(Uri.parse('https://steamspy.com/api.php?request=tag&tag=$tag'));

    if (response.statusCode == 200) {
      Map<String, dynamic> gamesMap = json.decode(response.body);
      List<dynamic> games = gamesMap.values.toList();
      return games;
    } else {
      throw Exception('Failed to load games');
    }
  }

  Future<Map<String, dynamic>> fetchGameDetails(int appid) async {
    final response = await http.get(Uri.parse('https://store.steampowered.com/api/appdetails?appids=$appid'));

    if (response.statusCode == 200) {
      Map<String, dynamic> gameDetailsMap = json.decode(response.body);
      Map<String, dynamic> gameDetails = gameDetailsMap['$appid']['data'];
      return gameDetails;
    } else {
      throw Exception('Failed to load game details');
    }
  }

  void _toggleFavorite(dynamic game) async {
    final userDoc = FirebaseFirestore.instance.collection('users').doc(user.uid).collection('favorites');

    if (favoriteGames.any((favGame) => favGame['appid'] == game['appid'])) {
      setState(() {
        favoriteGames.removeWhere((favGame) => favGame['appid'] == game['appid']);
      });
      await userDoc.doc(game['appid'].toString()).delete();
    } else {
      final gameDetails = await fetchGameDetails(game['appid']);
      final gameToAdd = {
        'appid': game['appid'],
        'name': game['name'],
        'image': 'https://steamcdn-a.akamaihd.net/steam/apps/${game['appid']}/capsule_184x69.jpg',
        'description': gameDetails['short_description'] ?? 'No description available'
      };
      setState(() {
        favoriteGames.add(gameToAdd);
      });
      await userDoc.doc(game['appid'].toString()).set(gameToAdd);
    }
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
            icon: Icon(Icons.star, color: Colors.yellow),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => FavoritesPage(favoriteGames: favoriteGames, onFavoriteRemoved: _removeFavorite)),
              );
            },
          ),
        ],
      ),
      body: FutureBuilder<List<dynamic>>(
        future: fetchGamesByTags(widget.selectedTags),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}', style: TextStyle(color: Colors.white)));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No games found for these tags', style: TextStyle(color: Colors.white)));
          } else {
            final games = snapshot.data!;
            return ListView.builder(
              itemCount: games.length,
              itemBuilder: (context, index) {
                final game = games[index];
                final isFavorite = favoriteGames.any((favGame) => favGame['appid'] == game['appid']);
                final gameName = game['name'] ?? 'Unknown';
                final gameImage = 'https://steamcdn-a.akamaihd.net/steam/apps/${game['appid']}/capsule_184x69.jpg';

                return ListTile(
                  leading: Image.network(gameImage, width: 50, height: 50, fit: BoxFit.cover, errorBuilder: (context, error, stackTrace) {
                    return Icon(Icons.broken_image, color: Colors.white);
                  }),
                  title: Text(gameName, style: TextStyle(color: Colors.white)),
                  trailing: IconButton(
                    icon: Icon(
                      isFavorite ? Icons.star : Icons.star_border,
                      color: isFavorite ? Colors.yellow : Colors.white,
                    ),
                    onPressed: () => _toggleFavorite(game),
                  ),
                  onTap: () async {
                    final gameDetails = await fetchGameDetails(game['appid']);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => GameDetailPage(
                          gameName: gameDetails['name'] ?? 'Unknown',
                          gameDescription: gameDetails['short_description'] ?? 'No description available',
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

  void _removeFavorite(dynamic game) {
    setState(() {
      favoriteGames.removeWhere((favGame) => favGame['appid'] == game['appid']);
    });
    _saveFavoriteGames();
  }
}

class GameDetailPage extends StatelessWidget {
  final String gameName;
  final String gameDescription;
  final String gameImage;

  GameDetailPage({
    required this.gameName,
    required this.gameDescription,
    required this.gameImage,
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
            Center(
              child: Image.network(gameImage, height: 200, errorBuilder: (context, error, stackTrace) {
                return Icon(Icons.broken_image, color: Colors.white, size: 200);
              }),
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

class FavoritesPage extends StatefulWidget {
  final List<dynamic> favoriteGames;
  final Function(dynamic) onFavoriteRemoved;

  FavoritesPage({required this.favoriteGames, required this.onFavoriteRemoved});

  @override
  _FavoritesPageState createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  List<dynamic> favoriteGames = [];

  @override
  void initState() {
    super.initState();
    favoriteGames = widget.favoriteGames;
  }

  void _removeFavorite(dynamic game) {
    setState(() {
      favoriteGames.removeWhere((favGame) => favGame['appid'] == game['appid']);
    });
    widget.onFavoriteRemoved(game);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF0A0A0A),
      appBar: AppBar(
        title: Text('Favorite Games'),
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
        backgroundColor: Colors.indigo[900],
      ),
      body: ListView.builder(
        itemCount: favoriteGames.length,
        itemBuilder: (context, index) {
          final game = favoriteGames[index];
          final gameName = game['name'] ?? 'Unknown';
          final gameImage = game['image'] ?? '';
          final gameDescription = game['description'] ?? 'No description available';

          return ListTile(
            leading: gameImage.isNotEmpty
                ? Image.network(gameImage, width: 50, height: 50, fit: BoxFit.cover)
                : Icon(Icons.broken_image, color: Colors.white),
            title: Text(gameName, style: TextStyle(color: Colors.white)),
            trailing: IconButton(
              icon: Icon(Icons.delete, color: Colors.red),
              onPressed: () async {
                final shouldRemove = await showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('Remove Favorite'),
                      content: Text('Do you want to remove this game from favorites?'),
                      actions: <Widget>[
                        TextButton(
                          child: Text('No'),
                          onPressed: () {
                            Navigator.of(context).pop(false);
                          },
                        ),
                        TextButton(
                          child: Text('Yes'),
                          onPressed: () {
                            Navigator.of(context).pop(true);
                          },
                        ),
                      ],
                    );
                  },
                );

                if (shouldRemove == true) {
                  _removeFavorite(game);
                }
              },
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => GameDetailPage(
                    gameName: gameName,
                    gameDescription: gameDescription,
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
