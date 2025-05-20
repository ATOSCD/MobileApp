import 'package:flutter/material.dart';
import 'airconditioner.dart';
import 'bed.dart';
import 'book.dart';
import 'chair.dart';
import 'clock.dart';
import 'door.dart';
import 'fan.dart';
import 'lamp.dart';
import 'laptop.dart';
import 'mug.dart';
import 'thermometer.dart';
import 'tissue.dart';
import 'window.dart';
import 'user_id.dart';

class ListPage extends StatelessWidget {
  const ListPage({super.key});

  final List<Map<String, dynamic>> items = const [
    {'title': '에어컨', 'icon': Icons.ac_unit, 'route': '/airconditioner'},
    {'title': '침대', 'icon': Icons.bed, 'route': '/bed'},
    {'title': '책', 'icon': Icons.menu_book, 'route': '/book'},
    {'title': '의자', 'icon': Icons.chair, 'route': '/chair'},
    {'title': '시계', 'icon': Icons.access_time, 'route': '/clock'},
    {'title': '문', 'icon': Icons.door_front_door, 'route': '/door'},
    {'title': '선풍기', 'icon': Icons.air, 'route': '/fan'},
    {'title': '노트북', 'icon': Icons.laptop, 'route': '/laptop'},
    {'title': '머그컵', 'icon': Icons.local_cafe, 'route': '/mug'},
    {'title': '체온계', 'icon': Icons.thermostat, 'route': '/thermometer'},
    {'title': '창문', 'icon': Icons.window, 'route': '/window'},
    {'title': '램프', 'icon': Icons.lightbulb, 'route': '/lamp'},
    {'title': '휴지', 'icon': Icons.layers, 'route': '/tissue'}, // 대체 아이콘
  ];

  @override
  Widget build(BuildContext context) {

    if (patient == null) { // protector를 쓴다면 protector == null로 변경
      return Scaffold(
        appBar: AppBar(
          title: const Text('사물 목록'),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          elevation: 1,
        ),
        body: const Center(
          child: Text('환자 정보가 없습니다.', style: TextStyle(fontSize: 16)),
        ),
        backgroundColor: const Color(0xFFF8F8F8),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('사물 목록'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 1,
      ),
      backgroundColor: const Color(0xFFF8F8F8),
      body: ListView.separated(
        itemCount: items.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final item = items[index];
          return ListTile(
            leading: Icon(item['icon'], color: Colors.indigo),
            title: Text(
              item['title'],
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            tileColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
            onTap: () {
              switch (item['route']) {
                case '/airconditioner':
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const AirConditionerPage()));
                  break;
                case '/bed':
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const BedPage()));
                  break;
                case '/book':
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const BookPage()));
                  break;
                case '/chair':
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const ChairPage()));
                  break;
                case '/clock':
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const ClockPage()));
                  break;
                case '/door':
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const DoorPage()));
                  break;
                case '/fan':
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const FanPage()));
                  break;
                case '/laptop':
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const LaptopPage()));
                  break;
                case '/mug':
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const MugPage()));
                  break;
                case '/thermometer':
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const ThermometerPage()));
                  break;
                case '/window':
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const WindowPage()));
                  break;
                case '/lamp':
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const LampPage()));
                  break;
                case '/tissue':
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const TissuePage()));
                  break;
              }
            },
          );
        },
        padding: const EdgeInsets.all(8),
      ),
    );
  }
}
