import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

class FanPage extends StatefulWidget {
  const FanPage({super.key});

  @override
  State<FanPage> createState() => _FanPageState();
}

class _FanPageState extends State<FanPage> {
  final Dio dio = Dio();
  final List<TextEditingController> _controllers = List.generate(4, (_) => TextEditingController());
  bool _isLoading = true;
  String? _updateResult;
  Color? _resultColor;

  @override
  void initState() {
    super.initState();
    _fetchButtonTexts();
  }

  Future<void> _fetchButtonTexts() async {
    try {
      final response = await dio.post(
        'http://192.168.1.89:8000/get-button-by-category/',
        data: {
          'user_id': 'patrick',
          'category': '선풍기',
        },
        options: Options(headers: {'Content-Type': 'application/json'}),
      );

      final List<dynamic> data = response.data;
      for (int i = 0; i < 4 && i < data.length; i++) {
        _controllers[i].text = data[i]['button_text'] ?? '';
      }
    } catch (e) {
      debugPrint('에러 발생: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _submitUpdates() async {
    final texts = _controllers.map((controller) => controller.text).toList();

    try {
      final response = await dio.post(
        'http://192.168.1.89:8000/update-button/',
        data: {
          'user_id': 'patrick',
          'button_text': texts,
          'category': '선풍기'
        },
        options: Options(headers: {'Content-Type': 'application/json'}),
      );

      if (response.statusCode == 200) {
        setState(() {
          _updateResult = '변경되었습니다.';
          _resultColor = Colors.blueAccent;
        });
      } else {
        setState(() {
          _updateResult = '다시 시도해주세요';
          _resultColor = Colors.redAccent;
        });
      }
    } catch (e) {
      setState(() {
        _updateResult = '다시 시도해주세요';
        _resultColor = Colors.redAccent;
      });
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('선풍기'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 1,
      ),
      backgroundColor: const Color(0xFFF8F8F8),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ...List.generate(4, (index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: TextField(
                        controller: _controllers[index],
                        decoration: InputDecoration(
                          labelText: '${index + 1}번',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _submitUpdates,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        '완료',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (_updateResult != null)
                    Text(
                      _updateResult!,
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
