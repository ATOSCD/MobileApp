import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'chat.dart';

// 로컬 알림 플러그인 인스턴스
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

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
      title: 'FCM 알림 예제',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true
      ),
      home: const HomePage(),
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
        'http://192.168.1.45:8000/register-token/',
        data: {
          'user_id': 'jichan2', // 사용자 ID (예시)
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
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('FCM 알림 예제')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('FCM 알림을 수신하세요!'),
              SizedBox(height: 20),
              TextButton(onPressed: (){
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ChatPage()),
                );
              }, child: Text('채팅방으로 이동')),
            ],
          ),
        ),
        
      ),
    );
  }
}
