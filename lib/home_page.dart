import 'dart:async';

import 'package:flutter/material.dart';
import 'package:jamaat_timings/controls.dart';
import 'package:jamaat_timings/global.dart';
import 'package:jamaat_timings/models.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomePage extends StatefulWidget {
  @override
  HomePageState createState() {
    return new HomePageState();
  }
}

class HomePageState extends State<HomePage> {
  bool _isLoading = false;
  SharedPreferences prefs;
  bool _isSynced;

  Future<Null> getSharedPrefs() async {
    prefs = await SharedPreferences.getInstance();
    _isSynced = prefs.get('isSynced' ?? false);
  }

  @override
  void initState() {
    super.initState();
    _isSynced = false;
    //getSharedPrefs();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(title: new Text("Jamaat Timings")),
      body: new Container(
        child: StreamBuilder(
            stream: Firestore.instance.collection('mosques').snapshots(),
            builder: (context, snapshot) {
              List<MosqueDetail> mosqueDetails = <MosqueDetail>[];
              if (!snapshot.hasData) return const Text('Loading...');
              else {
                for (int i = 0; i < snapshot.data.documents.length; i++) {
                  DocumentSnapshot document = snapshot.data.documents[i];
                  mosqueDetails.add(MosqueDetail(
                      name: document['name'],
                      briefAddr: document['briefAddr'],
                      imageUrl: document['image'],
                      addressLine1: document['addressLine1'],
                      addressLine2: document['addressLine2']));
                }
                //prefs.setBool('isSynced', true);
                return new ListView(
                  itemExtent: MosquesListItem.height,
                  padding:
                      const EdgeInsets.only(top: 8.0, left: 8.0, right: 8.0),
                  children: mosqueDetails.map((MosqueDetail detail) {
                    return new Container(
                      margin: const EdgeInsets.only(bottom: 8.0),
                      child: new MosquesListItem(
                        mosqueDetail: detail,
                      ),
                    );
                  }).toList());
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
                  _isLoading ? _isLoading = false : _isLoading = true;
                });
                //Navigator.pop(context);
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

  _fetchPreferences() async {
    prefs = await SharedPreferences.getInstance();
  }
}
