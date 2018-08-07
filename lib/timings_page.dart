import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:jamaat_timings/models.dart';

class TimingsPage extends StatelessWidget {
  const TimingsPage({
    Key key,
    @required MosqueDetail mosqueDetails,
  })  : _mosqueDetails = mosqueDetails,
        super(key: key);

  final MosqueDetail _mosqueDetails;

  @override
  Widget build(BuildContext context) {
    List<ListTile> listItems = <ListTile>[
      ListTile(
          leading: ImageIcon(AssetImage("assets/ic_dawn.png")),
          title: Text('Fajr'),
          trailing: Text(_mosqueDetails.fajr)),
      ListTile(
          leading: ImageIcon(AssetImage("assets/ic_sun.png")),
          title: Text('Zuhar'),
          trailing: Text(_mosqueDetails.zuhar)),
      ListTile(
          leading: ImageIcon(AssetImage("assets/ic_cloudy.png")),
          title: Text('Asar'),
          trailing: Text(_mosqueDetails.asar)),
      ListTile(
          leading: ImageIcon(AssetImage("assets/ic_sunset.png")),
          title: Text('Maghrib'),
          trailing: Text(_mosqueDetails.maghrib)),
      ListTile(
          leading: ImageIcon(AssetImage("assets/ic_moon.png")),
          title: Text('Isha'),
          trailing: Text(_mosqueDetails.isha)),
    ];
    var x = ListTile.divideTiles(context: context, tiles: listItems, color: Theme.of(context).accentColor).toList();
    return new Scaffold(
      appBar: new AppBar(title: new Text(_mosqueDetails.name)),
      body: ListView(
        children: x,
      ),
    );
  }
}
