import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'chat.dart';
import 'list.dart';
import 'log.dart';
//import 'connect.dart';
import 'server.dart';
import 'user_id.dart';
import 'edit_category.dart';
import 'package:vibration/vibration.dart';
//import 'register_entry.dart';
import 'start.dart';
import 'menupoup.dart';

// 로컬 알림 플러그인 인스턴스
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // 긴 진동 패턴 채널 추가
  AndroidNotificationChannel warningChannel = AndroidNotificationChannel(
    'warning_channel', // 채널 ID
    'Warning Notifications', // 채널 이름
    description: 'Channel for long vibration warnings',
    importance: Importance.max,
    vibrationPattern: Int64List.fromList([500, 1000, 500, 2000]), // 진동 패턴
    enableVibration: true,
  );

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(warningChannel);

  // 로컬 알림 초기화
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'UtopiAR',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true
      ),
      home: const StartPage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _MyAppState();
}

class _MyAppState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    _initFCM();
    _fetchPatientInfo();
  }

  Future<void> _fetchPatientInfo() async {
    if (protector == null) return;

    try {
      final response = await Dio().post(
        'http://$baseUrl/get-nok/',
        data: {'user_id': protector},
        options: Options(headers: {'Content-Type': 'application/json'}),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        patient = data['nok_id'];
        patientName = data['nok_name'];
        debugPrint('👤 환자 ID: $patient, 이름: $patientName');
        setState(() {}); // 필요 시 UI 갱신
      } else {
        debugPrint('❌ 환자 정보 요청 실패: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ 오류 발생: $e');
    }
  }

  Future<void> _initFCM() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    Dio dio = Dio(); // Dio 인스턴스 생성

    // 알림 권한 요청 (iOS, Android 13 이상 필수)
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      debugPrint('알림 권한 허용됨');

      // FCM 토큰 얻기
      String? token = await messaging.getToken();
      try {
      // POST 요청
      final response = await dio.post(
        'http://$baseUrl/register-token/',
        data: {
          'user_id': protector, // 사용자 ID (예시)
          'token': token, // FCM 토큰
        },
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
        ),
      );
      if (response.statusCode == 200) {
        
      } else {
        setState(() {
          debugPrint('Error: ${response.statusCode}');
        });
      }
    } catch (e) {
      // 에러 메시지 출력
      setState(() {
        debugPrint('Error: $e');
      });
    }

      // 포그라운드 알림 수신 설정
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        _showLocalNotification(message);
      });

      // 알림 클릭해서 앱 열었을 때 처리
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        _handleMessage(message);
      });

      // 앱 종료 상태에서 클릭해서 열었을 때
      RemoteMessage? initialMessage = await messaging.getInitialMessage();
      if (initialMessage != null) {
        _handleMessage(initialMessage);
      }
    } else {
      debugPrint('알림 권한 거부됨');
    }
  }

  void _showLocalNotification(RemoteMessage message) {
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;

    if (notification != null && android != null) {
      // 제목이 "⚠️⚠️⚠️"인 경우에만 진동
      if (notification.title == "⚠️⚠️⚠️") {
        Vibration.vibrate(pattern: [500, 1000, 500, 2000]);
      }
      flutterLocalNotificationsPlugin.show(
        notification.hashCode,
        notification.title,
        notification.body,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'high_importance_channel', // 채널 ID
            'High Importance Notifications', // 채널 이름
            channelDescription: 'This channel is used for important notifications.',
            importance: Importance.max,
            priority: Priority.high,
            showWhen: true,
          ),
        ),
      );
    }
  }

  void _handleMessage(RemoteMessage message) {
    // 알림 클릭해서 앱 열었을 때 원하는 행동 정의
    debugPrint('알림 클릭함: ${message.data}');
    // 예를 들어 특정 화면 이동도 가능
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('UtopiAR'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 1,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MenuPopupPage()),
              );
            },
          ),
        ],
      ),
      backgroundColor: const Color(0xFFF8F8F8),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView(
                children: [
                  _buildMenuCard(
                    context,
                    title: '채팅방으로 이동',
                    icon: Icons.chat_bubble_outline,
                    color: Colors.deepPurpleAccent,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ChatPage())),
                  ),
                  const SizedBox(height: 16),
                  _buildMenuCard(
                    context,
                    title: '상호작용 목록 제어',
                    icon: Icons.sync_alt,
                    color: Colors.indigoAccent,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ListPage())),
                  ),
                  const SizedBox(height: 16),
                  _buildMenuCard(
                    context,
                    title: '알림 목록 보기',
                    icon: Icons.notifications_none,
                    color: Colors.teal,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LogPage())),
                  ),
                  const SizedBox(height: 16),
                  _buildMenuCard(
                    context,
                    title: '상호작용 목록 편집',
                    icon: Icons.edit,
                    color: Colors.redAccent,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const EditCategoryPage()),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Colors.grey[300]!)),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withAlpha((0.2 * 255).toInt()),  // 최신 코드 (정확한 alpha 값)
                  blurRadius: 5,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: Colors.indigo),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    (patientName != null && patientName!.isNotEmpty)
                        ? '현재 $patientName 님과 연결되어 있습니다.'
                        : '현재 환자와 연결되어 있지 않습니다.',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuCard(BuildContext context,
      {required String title, required IconData icon, required Color color, required VoidCallback onTap}) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          height: 100,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: color,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Icon(icon, size: 32, color: Colors.white),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
              const Icon(Icons.arrow_forward_ios, color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }

}
