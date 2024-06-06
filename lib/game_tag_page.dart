import 'package:flutter/material.dart';
import 'game_list_page.dart';

class GameTagPage extends StatefulWidget {
  @override
  _GameTagPageState createState() => _GameTagPageState();
}

class _GameTagPageState extends State<GameTagPage> {
  final List<String> _tags = [
    'SOLO', 'MULTI', 'Action', 'RPG', 'Indie', 'Adventure', 'Sports',
    'Simulation', 'MMO', 'Free', 'Crafting', 'Open_World', 'Zombies',
    'CASUAL', 'DARK', 'CUTE', 'MUSIC', 'COMEDY', 'HORROR', 'STORYRICH',
    'RELAXING', 'SURVIVE', 'STRATGY', 'PUZZLE', 'FANTASY', 'VIOLENT',
    'SHOOTER', 'RACING', 'FARM'
  ];

  final Set<String> _selectedTags = Set<String>();

  void _onTagSelected(bool selected, String tagName) {
    setState(() {
      if (selected) {
        _selectedTags.add(tagName);
      } else {
        _selectedTags.remove(tagName);
      }
    });
  }

  void _submitTags() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GameListPage(selectedTags: _selectedTags.toList()),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF0A0A0A),
      appBar: AppBar(
        title: Text('Select Tags'),
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
          children: <Widget>[
            Text(
              'Solo or Multi?',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            CheckboxListTile(
              activeColor: Colors.indigo[900],
              checkColor: Colors.white,
              value: _selectedTags.contains('SOLO'),
              title: Text('SOLO', style: TextStyle(color: Colors.white)),
              onChanged: (bool? selected) {
                _onTagSelected(selected!, 'SOLO');
              },
            ),
            CheckboxListTile(
              activeColor: Colors.indigo[900],
              checkColor: Colors.white,
              value: _selectedTags.contains('MULTI'),
              title: Text('MULTI', style: TextStyle(color: Colors.white)),
              onChanged: (bool? selected) {
                _onTagSelected(selected!, 'MULTI');
              },
            ),
            SizedBox(height: 20),
            Text(
              'Select Genres',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            Expanded(
              child: ListView(
                children: _tags.skip(2).map((tag) {
                  return CheckboxListTile(
                    activeColor: Colors.indigo[900],
                    checkColor: Colors.white,
                    value: _selectedTags.contains(tag),
                    title: Text(tag, style: TextStyle(color: Colors.white)),
                    onChanged: (bool? selected) {
                      _onTagSelected(selected!, tag);
                    },
                  );
                }).toList(),
              ),
            ),
            ElevatedButton(
              onPressed: _submitTags,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo[900],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Submit',
                  style: TextStyle(fontSize: 15, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

