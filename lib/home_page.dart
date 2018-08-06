import 'dart:async';
import 'package:flutter/material.dart';
import 'package:jamaat_timings/models.dart';
import 'package:jamaat_timings/controls.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:jamaat_timings/global.dart';

class HomePage extends StatefulWidget {
  @override
  HomePageState createState() {
    return new HomePageState();
  }
}

class HomePageState extends State<HomePage> {
  DatabaseManager _dbContext;
  SharedPreferences _persistentLocalStorage;
  List<MosqueDetail> _mosquesList;
  bool _isSynced;
  bool _createTable;
  bool _rePopulate;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _dbContext = DatabaseManager();
    _mosquesList = <MosqueDetail>[];
    _createTable = true;
    _isSynced = false;
    _rePopulate = true;
    //checking if data from Firestore has been synced previously.
    getSharedPrefs();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(title: new Text("Jamaat Timings")),
      body: new Container(
        child: StreamBuilder(
            stream: Firestore.instance.collection('mosques').snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData)
                return Center(child: const CircularProgressIndicator());
              else if (!_isSynced) {
                _mosquesList.clear();
                for (int i = 0; i < snapshot.data.documents.length; i++) {
                  DocumentSnapshot document = snapshot.data.documents[i];
                  _mosquesList.add(MosqueDetail(
                      name: document['name'],
                      imageUrl: document['image'],
                      briefAddr: document['briefAddr'],
                      addressLine1: document['addressLine1'],
                      addressLine2: document['addressLine2'],
                      fajr: document['fajr'],
                      zuhar: document['zuhar'],
                      asar: document['asar'],
                      maghrib: document['maghrib'],
                      isha: document['isha'],
                      extra: document['extra']));
                }
                _dbContext.insertDataInDatabase(_mosquesList, _createTable);
                _persistentLocalStorage.setBool('isSynced', true);
                return new MosquesList(mosquesList: _mosquesList);
              } else {
                if (_mosquesList.isNotEmpty) {
                  return new MosquesList(mosquesList: _mosquesList);
                } else {
                  return new Center(child: const CircularProgressIndicator());
                }

                // return new FutureBuilder(
                //   future: _dbContext.getDataFromDatabase(),
                //   builder: (BuildContext context, AsyncSnapshot snapshot)
                //   {
                //     return snapshot.hasData
                //         ? new MosquesList(mosquesList: snapshot.data)
                //         : new CircularProgressIndicator();
                //   },
                // );
              }
            }),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              child: null,
              decoration: BoxDecoration(
                image: new DecorationImage(
                  image: new AssetImage("assets/img_background.jpg"),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            ListTile(
              leading: new Icon(Icons.sync),
              title: Text('Sync'),
              trailing: SizedBox(
                  height: 18.0,
                  width: 18.0,
                  child: _isLoading
                      ? const CircularProgressIndicator()
                      : new Container()),
              onTap: () {
                setState(() {
                  _isLoading = true;
                  _persistentLocalStorage.setBool('isSynced', false);
                  _isSynced = false;
                });
                showDialog(
                    context: context,
                    builder: (context) => new AlertDialog(
                          title: Text('Success'),
                          content: new SingleChildScrollView(
                            child: new ListBody(
                              children: <Widget>[
                                new Text('Up to date jamaat timings synced.'),
                              ],
                            ),
                          ),
                          actions: <Widget>[
                            FlatButton(
                              child: Text('Ok'),
                              onPressed: () {
                                Navigator.pop(context);
                                setState(() {
                                  _isLoading = false;
                                });
                              },
                            )
                          ],
                        ));
              },
            ),
            ListTile(
              leading: new Icon(Icons.map),
              title: Text('Locator'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: new Icon(Icons.supervised_user_circle),
              title: Text('Administrator Access'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            Divider(),
            ListTile(
              leading: new Icon(Icons.info),
              title: Text('About'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<Null> getSharedPrefs() async {
    _persistentLocalStorage = await SharedPreferences.getInstance();
    _createTable = _persistentLocalStorage.getBool('createTable');
    _isSynced = _persistentLocalStorage.getBool('isSynced');
    if (_createTable == null) {
      _persistentLocalStorage.setBool('createTable', true);
      _createTable = true;
    }
    //if this is the first time app is launching the bool '_isSynced' will be set as null.
    if (_isSynced == null) {
      _persistentLocalStorage.setBool('isSynced', false);
      _isSynced = false;
    }
    if (_isSynced) {
      var x = await _dbContext.getDataFromDatabase();
      setState(() {
        _mosquesList.clear();
        _mosquesList = x;
      });
    }
  }
}

class MosquesList extends StatelessWidget {
  const MosquesList({
    Key key,
    @required List<MosqueDetail> mosquesList,
  })  : _mosquesList = mosquesList,
        super(key: key);

  final List<MosqueDetail> _mosquesList;

  @override
  Widget build(BuildContext context) {
    return new ListView(
        itemExtent: MosquesListItem.height,
        padding: const EdgeInsets.only(top: 8.0, left: 8.0, right: 8.0),
        children: _mosquesList.map((MosqueDetail detail) {
          return new Container(
            margin: const EdgeInsets.only(bottom: 8.0),
            child: new MosquesListItem(
              mosqueDetail: detail,
            ),
          );
        }).toList());
  }
}
