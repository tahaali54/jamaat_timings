import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:jamaat_timings/models.dart';
import 'package:jamaat_timings/controls.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:jamaat_timings/update_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  bool _isAdmin;
  bool _isSynced;
  bool _createTable;
  bool _isLoading = false;
  bool _isNetworkConnected;

  //Search related properties
  TextEditingController searchController = new TextEditingController();
  String filter;
  bool _searchOn = false;

  @override
  void initState() {
    super.initState();
    _dbContext = DatabaseManager();
    _mosquesList = <MosqueDetail>[];
    _createTable = true;
    _isSynced = false;
    _isAdmin = false;
    searchController.addListener(() {
      setState(() {
        filter = searchController.text;
      });
    });
    //checking if data from Firestore has been synced previously.
    _initLocalStorage();
    _checkNetworkConnection();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      floatingActionButton: _isAdmin
          ? FloatingActionButton(
              child: Icon(Icons.add),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          UpdatePage(isUpdate: false, pageTitle: 'Create')),
                );
              },
            )
          : null,
      appBar: new AppBar(
        title: new Text("Jamaat Timings"),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              setState(() {
                _searchOn = true;
              });
            },
          )
        ],
        bottom: _searchOn
            ? PreferredSize(
                preferredSize: Size.fromHeight(64.0),
                child: ListTile(
                  contentPadding:
                      EdgeInsets.only(left: 16.0, bottom: 8.0, right: 0.0),
                  title: TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        border: UnderlineInputBorder(),
                        hintText: 'Search'),
                  ),
                  trailing: IconButton(
                      color: Colors.white,
                      icon: Icon(Icons.cancel),
                      onPressed: () {
                        searchController.clear();
                        setState(() {
                          _searchOn = false;
                        });
                      }),
                ),
              )
            : PreferredSize(
                child: Container(),
                preferredSize: Size.fromHeight(0.0),
              ),
      ),
      body: new Container(
        child: StreamBuilder(
            stream: Firestore.instance.collection('mosques').snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData)
                return Center(child: const CircularProgressIndicator());
              else if (!_isSynced && !_isNetworkConnected)
                return Center(child: Text('No Internet. Please re-sync.'));
              else if (_isNetworkConnected) {
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
                _persistentLocalStorage.setBool('isSynced', true);
                _isSynced = true;
                _dbContext.insertDataInDatabase(_mosquesList, _createTable);
                _createTable = false;
                return new MosquesList(
                    mosquesList: filter == null || filter == ""
                        ? _mosquesList
                        : _mosquesList
                            .where((item) =>
                                item.name
                                    .toLowerCase()
                                    .contains(filter.toLowerCase()) ||
                                item.briefAddr
                                    .toLowerCase()
                                    .contains(filter.toLowerCase()) ||
                                item.addressLine1
                                    .toLowerCase()
                                    .contains(filter.toLowerCase()) ||
                                item.addressLine2
                                    .toLowerCase()
                                    .contains(filter.toLowerCase()))
                            .toList(),
                    isAdmin: _isAdmin);
              } else {
                if (_mosquesList.isNotEmpty) {
                  return new MosquesList(
                      mosquesList: filter == null || filter == ""
                          ? _mosquesList
                          : _mosquesList
                              .where((item) =>
                                  item.name
                                      .toLowerCase()
                                      .contains(filter.toLowerCase()) ||
                                  item.briefAddr
                                      .toLowerCase()
                                      .contains(filter.toLowerCase()) ||
                                  item.addressLine1
                                      .toLowerCase()
                                      .contains(filter.toLowerCase()) ||
                                  item.addressLine2
                                      .toLowerCase()
                                      .contains(filter.toLowerCase()))
                              .toList(),
                      isAdmin: _isAdmin);
                } else {
                  return new Center(child: const CircularProgressIndicator());
                }
              }
            }),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    new CircleAvatarWithShadow(),
                  ]),
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
                _checkNetworkConnection();
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
                                new Text('Up to date timings synced.'),
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
              trailing: Switch(
                value: _isAdmin,
                onChanged: (bool _changedValue) {
                  _toggelAdminAccess(context, _changedValue);
                },
              ),
              onTap: () {
                _toggelAdminAccess(context, !_isAdmin);
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

  _toggelAdminAccess(BuildContext context, bool _changedValue) {
    TextEditingController _passwordEditingController =
        new TextEditingController();
    if (_changedValue)
      showDialog(
          context: context,
          builder: (context) => new AlertDialog(
                content: new SingleChildScrollView(
                  child: new ListBody(
                    children: <Widget>[
                      TextField(
                        keyboardType: TextInputType.number,
                        obscureText: true,
                        controller: _passwordEditingController,
                        decoration: InputDecoration(hintText: 'Enter password'),
                      ),
                    ],
                  ),
                ),
                actions: <Widget>[
                  _isNetworkConnected ? StreamBuilder(
                      stream: Firestore.instance
                          .collection('passwords')
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData)
                          return Text('Loading...');
                        return FlatButton(
                            child: Text('Submit'),
                            onPressed: () {      
                              DocumentSnapshot document = snapshot.data.documents[0];
                              if (_passwordEditingController.text == document['password'])
                              {
                                Navigator.pop(context);
                                setState(() {
                                  _isAdmin = _changedValue;
                                });
                              }
                              _passwordEditingController.clear();  
                            },
                          );
                      }) : Container(),
                ],
              ));
    else
      setState(() {
        _isAdmin = _changedValue;
      });
  }

  Future<Null> _initLocalStorage() async {
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

  _checkNetworkConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        print('connected');
        setState(() {
          _isNetworkConnected = true;
        });
      }
    } on SocketException catch (_) {
      setState(() {
        _isNetworkConnected = false;
      });

      print('not connected');
    }
  }
}

class CircleAvatarWithShadow extends StatelessWidget {
  const CircleAvatarWithShadow({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return new Container(
      margin: const EdgeInsets.only(right: 16.0),
      child: new CircleAvatar(
          foregroundColor: Colors.white,
          backgroundColor: Theme.of(context).accentColor,
          radius: 32.0,
          child: new Text(
            'JT',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24.0),
          )),
      decoration: new BoxDecoration(
        boxShadow: [
          new BoxShadow(
            color: Colors.black,
            blurRadius: 10.0,
          ),
        ],
        shape: BoxShape.circle,
      ),
    );
  }
}

class MosquesList extends StatelessWidget {
  const MosquesList(
      {Key key,
      @required List<MosqueDetail> mosquesList,
      @required bool isAdmin})
      : _mosquesList = mosquesList,
        _isAdmin = isAdmin,
        super(key: key);

  final List<MosqueDetail> _mosquesList;
  final bool _isAdmin;

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
              isAdmin: _isAdmin,
            ),
          );
        }).toList());
  }
}
