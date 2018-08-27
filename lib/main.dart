import 'package:flutter/material.dart';
import 'package:jamaat_timings/home_page.dart';
import 'package:map_view/map_view.dart';

const API_KEY = "AIzaSyA3zwlbCmgQda_dCPDteQUMeNz4gelmMdg";

void main() {
  MapView.setApiKey(API_KEY);
  runApp(new JamaatTimings());
}

class JamaatTimings extends StatelessWidget {
  Color _primaryColor = Color.fromARGB(255, 76, 27, 83);
  Color _accentColor = Color.fromARGB(255, 227, 171, 120);

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: "Jamaat Timings",
      home: new HomePage(),
      routes: {
        //Routes.qr: (context) => new QrScanPage(),
      },
      theme: new ThemeData(
          primaryColor: _primaryColor,
          accentColor: _accentColor,
          buttonColor: _primaryColor, 
          inputDecorationTheme: InputDecorationTheme(border: OutlineInputBorder())),
    );
  }
}


