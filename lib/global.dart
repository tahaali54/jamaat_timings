import 'package:jamaat_timings/controls.dart';
import 'package:jamaat_timings/models.dart';

abstract class Routes {
  static const String root = '/';
  static const String qr = '/qr';
}

int stationIndex = 0;
bool hasUsedQr = false;

final List<MosqueDetail> details = <MosqueDetail>[
  const MosqueDetail(
      name: 'Askari IV Mosque',
      briefAddr: 'Askari IV',
      imageUrl: 'https://farm1.staticflickr.com/861/42918969875_dab6d2377a.jpg',
      addressLine1: 'Rashid Minhas Rd',
      addressLine2: 'Askari IV, Karachi, Sindh'),
  const MosqueDetail(
      name: 'Jamia Masjid Banglore Town',
      briefAddr: 'Banglore Town',
      imageUrl:
          'https://farm2.staticflickr.com/1797/43104988664_4d3e2d6f02.jpg',
      addressLine1: 'Block A',
      addressLine2: 'Banglore Town, Karachi, Pakistan'),
];
