import 'package:flutter/material.dart';
import 'game_list_page.dart';

class GameTagPage extends StatefulWidget {
  @override
  _GameTagPageState createState() => _GameTagPageState();
}

class _GameTagPageState extends State<GameTagPage> {
  final List<String> tags = [
    'Action', 'RPG', 'Indie', 'Adventure', 'Sports', 'Simulation',
    'MMO', 'Free', 'Crafting', 'Open_World', 'Zombies', 'SOLO',
    'MULTI', 'CASUAL', 'DARK', 'CUTE', 'MUSIC', 'COMEDY',
    'HORROR', 'STORYRICH', 'RELAXING', 'SURVIVE', 'STRATGY',
    'PUZZLE', 'FANTASY', 'VIOLENT', 'SHOOTER', 'RACING', 'FARM',
  ];

  String? selectedTag;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Game Tag'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: tags.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(tags[index]),
                  onTap: () {
                    setState(() {
                      selectedTag = tags[index];
                    });
                  },
                  selected: tags[index] == selectedTag,
                );
              },
            ),
          ),
          ElevatedButton(
            onPressed: () {
              if (selectedTag != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => GameListPage(tag: selectedTag!),
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Please select a tag'))
                );
              }
            },
            child: Text('Show Games'),
          ),
        ],
      ),
    );
  }
}
