import 'package:flutter/material.dart';
import 'game_tag_page.dart';

class LoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login Page'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            // Perform login validation here...

            // On successful login
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Login Successful'))
            );
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => GameTagPage(),
              ),
            );
          },
          child: Text('Login'),
        ),
      ),
    );
  }
}
