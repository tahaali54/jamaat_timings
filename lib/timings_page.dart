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
    Iterable<Widget> listItems = ListTile.divideTiles(
        context: context,
        tiles: populateCardData(),
        color: Theme.of(context).accentColor);
    return new Scaffold(
      appBar: new AppBar(title: new Text(_mosqueDetails.name)),
      body: Container(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          child: ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.all(8.0),
            children: listItems.toList(),
          ),
        ),
      ),
    );
  }

  Iterable<Widget> populateCardData() {
    return <Widget>[
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
  }
}
