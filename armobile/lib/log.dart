import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'server.dart';
import 'user_id.dart';

class LogPage extends StatefulWidget {
  const LogPage({super.key});

  @override
  State<LogPage> createState() => _LogPageState();
}

class _LogPageState extends State<LogPage> {
  final Dio dio = Dio();
  final String userId = patient;
  late Future<List<dynamic>> notifications;

  @override
  void initState() {
    super.initState();
    notifications = fetchNotifications();
  }

  Future<List<dynamic>> fetchNotifications() async {
    final response = await dio.get('http://$baseUrl/get-notifications/$userId/');
    if (response.statusCode == 200) {
      return response.data; // 데이터가 이미 최신순
    } else {
      throw Exception('알림을 불러오는데 실패했습니다');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('알림 로그', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 2,
      ),
      body: FutureBuilder<List<dynamic>>(
        future: notifications,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                '에러 발생: ${snapshot.error}',
                style: const TextStyle(color: Colors.redAccent, fontSize: 16),
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text('받은 알림이 없습니다.', style: TextStyle(fontSize: 16)),
            );
          }

          final notifications = snapshot.data!;

          return ListView.builder(
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final notification = notifications[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                elevation: 3,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  leading: const Icon(Icons.notifications, color: Colors.blueAccent),
                  title: Text(
                    notification['title'],
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(notification['body']),
                      const SizedBox(height: 4),
                      Text(
                        notification['created_at'],
                        style: const TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      backgroundColor: const Color(0xFFF8F8F8),
    );
  }
}
