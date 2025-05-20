import 'package:flutter/material.dart';
import 'register_protector.dart';
import 'register_patient.dart';

class RegisterEntryPage extends StatelessWidget {
  const RegisterEntryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('회원가입'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 1,
      ),
      backgroundColor: const Color(0xFFF5F7FA),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 40),
            const Text(
              '회원 유형을 선택하세요',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 60),
            _buildOptionButton(
              context,
              label: '🏠 보호자용 회원가입',
              color: Colors.indigoAccent,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const RegisterProtectorPage()),
              ),
            ),
            const SizedBox(height: 20),
            _buildOptionButton(
              context,
              label: '🧑‍🦼 환자용 회원가입',
              color: Colors.teal,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const RegisterPatientPage()),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionButton(BuildContext context,
      {required String label, required Color color, required VoidCallback onTap}) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: color,
        elevation: 3,
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 18, color: Colors.white),
      ),
    );
  }
}
