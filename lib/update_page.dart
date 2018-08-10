import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class UpdatePage extends StatelessWidget {
  const UpdatePage({
    Key key,
    @required String pageTitle,
  })  : _pageTitle = pageTitle,
        super(key: key);

  final String _pageTitle;

  @override
  Widget build(BuildContext context) {
    Iterable<Widget> listItems = ListTile.divideTiles(
        context: context,
        tiles: populateData(),
        color: Theme.of(context).accentColor);
    return new Scaffold(
      appBar: new AppBar(title: new Text(_pageTitle)),
      body: ListView(
        children: listItems.toList(),
      ),
    );
  }

  Iterable<Widget> populateData() {
    TextEditingController _fajarController = TextEditingController();
    TextEditingController _zuharController = TextEditingController();
    TextEditingController _asarController = TextEditingController();
    TextEditingController _maghribController = TextEditingController();
    TextEditingController _ishaController = TextEditingController();
    return <Widget>[
      ListTile(
        leading: ImageIcon(AssetImage("assets/ic_dawn.png")),
        title: TextField(
          keyboardType: TextInputType.text,
          obscureText: true,
          controller: _fajarController,
          decoration: InputDecoration(hintText: 'fajar'),
        ),
      ),
      ListTile(
        leading: ImageIcon(AssetImage("assets/ic_sun.png")),
        title: TextField(
          keyboardType: TextInputType.text,
          obscureText: true,
          controller: _zuharController,
          decoration: InputDecoration(hintText: 'zuhar'),
        ),
      ),
      ListTile(
        leading: ImageIcon(AssetImage("assets/ic_cloudy.png")),
        title: TextField(
          keyboardType: TextInputType.text,
          obscureText: true,
          controller: _asarController,
          decoration: InputDecoration(hintText: 'asar'),
        ),
      ),
      ListTile(
        leading: ImageIcon(AssetImage("assets/ic_sunset.png")),
        title: TextField(
          keyboardType: TextInputType.text,
          obscureText: true,
          controller: _maghribController,
          decoration: InputDecoration(hintText: 'maghrib'),
        ),
      ),
      ListTile(
        leading: ImageIcon(AssetImage("assets/ic_moon.png")),
        title: TextField(
          keyboardType: TextInputType.text,
          obscureText: true,
          controller: _ishaController,
          decoration: InputDecoration(hintText: 'isha'),
        ),
      ),
    ];
  }
}
