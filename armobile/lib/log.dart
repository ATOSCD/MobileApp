import 'package:flutter/material.dart';

class LogPage extends StatelessWidget {
  const LogPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('로그 페이지')),
      body: const Center(
        child: Text(
          '여기는 빈 로그 페이지입니다.',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}