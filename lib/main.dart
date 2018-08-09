import 'package:flutter/material.dart';
import 'package:jamaat_timings/home_page.dart';

void main() {
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
          buttonColor: _primaryColor),
    );
  }
}


