import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class GameListPage extends StatelessWidget {
  final List<String> selectedTags;

  GameListPage({required this.selectedTags});

  Future<List<dynamic>> fetchGamesByTag(String tag) async {
    final response = await http.get(Uri.parse('https://steamspy.com/api.php?request=tag&tag=$tag'));

    if (response.statusCode == 200) {
      List<dynamic> games = json.decode(response.body).values.toList();

      // Fetch game details including images and descriptions
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
      ),
      body: FutureBuilder<List<dynamic>>(
        future: fetchGamesByTag(selectedTags[0]),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No games found for this tag'));
          } else {
            final games = snapshot.data!;
            return ListView.builder(
              itemCount: games.length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: games[index]['image'] != null
                      ? Image.network(games[index]['image'], width: 50, height: 50)
                      : null,
                  title: Text(games[index]['name'], style: TextStyle(color: Colors.white)),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => GameDetailPage(
                          gameName: games[index]['name'],
                          gameDescription: games[index]['description'],
                          gameImage: games[index]['image'],
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
