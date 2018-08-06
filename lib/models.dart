import 'dart:async';

import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

class MosqueDetail {
  const MosqueDetail(
      {this.name,
      this.imageUrl,
      this.briefAddr,
      this.addressLine1,
      this.addressLine2,
      this.fajr,
      this.zuhar,
      this.asar,
      this.maghrib,
      this.isha,
      this.extra});

  final String name;
  final String imageUrl;
  final String briefAddr;
  final String addressLine1;
  final String addressLine2;
  final String fajr;
  final String zuhar;
  final String asar;
  final String maghrib;
  final String isha;
  final String extra;
}

class DatabaseManager {
  DatabaseManager() {
    //_initDatabase();
  }
  String _databasePath;
  Database database;

  _initDatabase() async {
    var _platformSpecificDatabaseDirectory = await getDatabasesPath();
    _databasePath =
        join(_platformSpecificDatabaseDirectory, 'jamaatTimings.db');

    database = await openDatabase(_databasePath, version: 1);
  }

  insertDataInDatabase(
      List<MosqueDetail> _mosquesList, bool createTable) async {
    try {
      await _initDatabase();
      if (createTable)
       {
        database.execute('CREATE TABLE Mosques (id INTEGER PRIMARY KEY, ' +
            'name TEXT, imageUrl TEXT, briefAddr TEXT, addressLine1 TEXT, addressLine2 TEXT, ' +
            'fajr TEXT, zuhar TEXT, asar TEXT, maghrib TEXT, isha TEXT, extra TEXT)');
        SharedPreferences _persistentLocalStorage =
            await SharedPreferences.getInstance();
        _persistentLocalStorage.setBool('createTable', false);
      }
      //each time we sync previously populated data must be deleted.
      await database.rawDelete('DELETE FROM Mosques WHERE name IS NOT NULL');
    } on Exception catch (e) {
      //do nothing when db not found.
      print(e);
    }
    _mosquesList.forEach((item) async {
      await database.transaction((txn) async {
        int id = await txn.rawInsert(
            'INSERT INTO Mosques ' +
                '(name, imageUrl, briefAddr, addressLine1, addressLine2, fajr, zuhar, asar, maghrib, isha, extra) ' +
                'VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
            [
              item.name,
              item.imageUrl,
              item.briefAddr,
              item.addressLine1,
              item.addressLine2,
              item.fajr,
              item.zuhar,
              item.asar,
              item.maghrib,
              item.isha,
              item.extra
            ]);
        print("inserted: $id");
      });
    });
  }

  Future<List<MosqueDetail>> getDataFromDatabase() async {
    await _initDatabase();
    List<MosqueDetail> _mosquesList = <MosqueDetail>[];
    List<Map> list = await database.rawQuery('SELECT * FROM Mosques');
    list.forEach((item) 
    {
      _mosquesList.add(MosqueDetail(
          name: item['name'],
          imageUrl: item['imageUrl'],
          briefAddr: item['briefAddr'],
          addressLine1: item['addressLine1'],
          addressLine2: item['addressLine2'],
          fajr: item['fajr'],
          zuhar: item['zuhar'],
          asar: item['asar'],
          maghrib: item['maghrib'],
          isha: item['isha'],
          extra: item['extra']));
    });
    //await database.close();
    return _mosquesList;
  }
}
