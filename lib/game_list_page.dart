import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class GameListPage extends StatelessWidget {
  final String tag;

  GameListPage({required this.tag});

  Future<List<dynamic>> fetchGamesByTag(String tag) async {
    final response = await http.get(Uri.parse('https://steamspy.com/api.php?request=tag&tag=$tag'));

    if (response.statusCode == 200) {
      return json.decode(response.body).values.toList();
    } else {
      throw Exception('Failed to load games');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Games List for $tag'),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: fetchGamesByTag(tag),
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
                  title: Text(games[index]['name']),
                  subtitle: Text('ID: ${games[index]['appid']}'),
                );
              },
            );
          }
        },
      ),
    );
  }
}
