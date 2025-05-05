import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

class ConnectPage extends StatefulWidget {
  const ConnectPage({super.key});

  @override
  State<ConnectPage> createState() => _ConnectPageState();
}

class _ConnectPageState extends State<ConnectPage> {
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _pwController = TextEditingController();
  final Dio dio = Dio();
  String? _resultMessage;
  Color? _resultColor;

  @override
  void dispose() {
    _idController.dispose();
    _pwController.dispose();
    super.dispose();
  }

  Future<void> _findAndConnectPatient() async {
    final userId = _idController.text;
    final password = _pwController.text;

    try {
      final response = await dio.post(
        'http://192.168.1.89:8000/find-patient/',
        data: {
          'user_id': userId,
          'password': password,
        },
        options: Options(headers: {
          'Content-Type': 'application/json',
        }),
      );

      if (response.statusCode == 200 && response.data != null) {
        // 사용자 존재하므로 set-nok 호출
        final setResponse = await dio.post(
          'http://192.168.1.89:8000/set-nok/',
          data: {
            'user_id': 'spongebob',
            'nok_id': userId,
          },
          options: Options(headers: {
            'Content-Type': 'application/json',
          }),
        );

        if (setResponse.statusCode == 200) {
          setState(() {
            _resultMessage = '연결에 성공했습니다.';
            _resultColor = Colors.blueAccent;
          });
        } else {
          setState(() {
            _resultMessage = '연결에 실패했습니다.';
            _resultColor = Colors.redAccent;
          });
        }
      } else {
        setState(() {
          _resultMessage = '사용자 ID를 찾을 수 없습니다.';
          _resultColor = Colors.redAccent;
        });
      }
    } catch (e) {
      setState(() {
        _resultMessage = '오류 발생.';
        _resultColor = Colors.redAccent;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('환자 연결'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 1,
      ),
      backgroundColor: const Color(0xFFF8F8F8),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '환자 ID와 비밀번호를 입력하세요',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _idController,
              decoration: InputDecoration(
                hintText: '예: patient1234',
                prefixIcon: const Icon(Icons.person),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _pwController,
              obscureText: true,
              decoration: InputDecoration(
                hintText: '비밀번호',
                prefixIcon: const Icon(Icons.lock),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _findAndConnectPatient,
                icon: const Icon(Icons.link),
                label: const Text(
                  '연결하기',
                  style: TextStyle(fontSize: 16),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (_resultMessage != null)
              Text(
                _resultMessage!,
                style: TextStyle(
                  color: _resultColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
