import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:news_app/page/news.dart';
import 'package:news_app/page/preferences.dart';
import '../articole_data/articol.dart';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();

  void saveData(String key, bool favorite) async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.setBool(key, favorite);
  }
}

int _currentIndex = 0;
List<Articole> _saved = [];


class _HomePageState extends State<HomePage> {
  List<Widget> page = <Widget>[News(saved: _saved,), Preferences(saved: _saved)];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: _currentIndex == 0 ? Text("News App") : Text("Preferences"),
          centerTitle: true,
        ),
        body: page[_currentIndex],
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() {
            _currentIndex = index;
            // if (index == 1) {
            //   //preferences();
            //   Navigator.push(context,MaterialPageRoute(builder: (context)=> Preferences()));
            // }
          }),
          type: BottomNavigationBarType.fixed,
          selectedItemColor: Colors.grey,
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.newspaper,
                  color: _currentIndex == 0 ? Colors.blue : null),
              label: 'News',

            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.star,
                  color: _currentIndex == 1 ? Colors.amber : null),
              label: 'Favorite news',
            )
          ],
        ));
  }

  void saveData(String key, bool favorite) async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.setBool(key, favorite);
  }
}

