import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'server.dart';
import 'start.dart';

class RegisterPatientPage extends StatefulWidget {
  const RegisterPatientPage({super.key});

  @override
  State<RegisterPatientPage> createState() => _RegisterPatientPageState();
}

class _RegisterPatientPageState extends State<RegisterPatientPage> {
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _pwController = TextEditingController();
  final Dio _dio = Dio();

  bool _isLoading = false;

  Future<void> _submit() async {
    final String userId = _idController.text.trim();
    final String name = _nameController.text.trim();
    final String password = _pwController.text;

    if (userId.isEmpty || name.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('모든 항목을 입력해주세요.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await _dio.post(
        'http://$baseUrl/add-user/',
        data: {
          'user_id': userId,
          'name': name,
          'password': password,
          'patient': 2, // 환자
        },
        options: Options(
          headers: {'Content-Type': 'application/json'},
        ),
      );

      if (response.statusCode == 200) {
        // ✅ 회원가입 성공 → 초기 버튼 설정
        List<Map<String, dynamic>> initialRequests = [
          {"category": "노트북", "requests": ["노트북 켜주세요", "노트북 꺼주세요", "노트북 가져다 주세요", "노트북 치워 주세요"]},
          {"category": "램프", "requests": ["램프 켜주세요", "램프 꺼주세요", "램프 밝기 낮춰주세요", "램프 밝기 높여주세요"]},
          {"category": "머그컵", "requests": ["따뜻한 물 주세요", "시원한 물 주세요", "음료수 주세요", "미지근한 물 주세요"]},
          {"category": "문", "requests": ["문 열어주세요", "문 닫아주세요", "문 조금만 열어주세요", "문이 삐걱거려요"]},
          {"category": "선풍기", "requests": ["선풍기 켜주세요", "선풍기 꺼주세요", "바람 세게 해주세요", "바람 약하게 해주세요"]},
          {"category": "시계", "requests": ["오늘 스케쥴 알려주세요", "알람 맞춰주세요", "밥 먹고싶어요", "약 먹을 시간이예요"]},
          {"category": "에어컨", "requests": ["온도를 높여주세요", "온도를 낮춰주세요", "에어컨 켜주세요", "에어컨 꺼주세요"]},
          {"category": "의자", "requests": ["의자에 앉고 싶어요", "의자 치워주세요", "의자 치워주세요", "의자 치워주세요"]},
          {"category": "창문", "requests": ["창문 열어주세요", "창문 닫아주세요", "커튼 닫아주세요", "산책 나가고 싶어요"]},
          {"category": "책", "requests": ["책 읽어주세요", "책 그만 읽고 싶어요", "다른 책 읽어주세요", "책 치워주세요"]},
          {"category": "체온계", "requests": ["열 나는거 같아요", "머리 아파요", "다리가 아파요", "배가 아파요"]},
          {"category": "침대", "requests": ["침대로 가고 싶어요", "이불을 덮어주세요", "눕고 싶어요", "앉고 싶어요"]},
          {"category": "휴지", "requests": ["화장실 가고 싶어요", "코 풀고 싶어요", "침 닦아 주세요", "휴지 주세요"]},
        ];

        for (var category in initialRequests) {
          try {
            final buttonResponse = await _dio.post(
              'http://$baseUrl/update-button/',
              data: {
                'user_id': userId,
                'button_text': category['requests'],
                'category': category['category'],
              },
              options: Options(headers: {'Content-Type': 'application/json'}),
            );

            if (buttonResponse.statusCode == 200) {
              debugPrint('✅ 초기 버튼 ${category['category']} 등록 성공');
            } else {
              debugPrint('❌ 초기 버튼 ${category['category']} 등록 실패');
            }
          } catch (e) {
            debugPrint('❌ 초기 버튼 ${category['category']} 오류: $e');
          }
        }

        // ✅ 회원가입 후 StartPage로 이동
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ 회원가입에 성공했습니다.')),
        );
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const StartPage()),
          (Route<dynamic> route) => false,
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ 오류 발생: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('환자 회원가입'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 1,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 40),
            const Text(
              '환자 정보를 입력해주세요',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 40),
            _buildTextField(_idController, '아이디', Icons.person_outline),
            const SizedBox(height: 20),
            _buildTextField(_nameController, '이름', Icons.badge_outlined),
            const SizedBox(height: 20),
            _buildTextField(_pwController, '비밀번호', Icons.lock_outline, obscure: true),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                icon: const Icon(Icons.check_circle_outline, color: Colors.white),
                label: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('회원가입', style: TextStyle(fontSize: 18, color: Colors.white)),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String labelText, IconData icon,
      {bool obscure = false}) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      decoration: InputDecoration(
        labelText: labelText,
        prefixIcon: Icon(icon, color: Colors.teal),
        filled: true,
        fillColor: Colors.white,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.teal, width: 2),
        ),
      ),
    );
  }
}
