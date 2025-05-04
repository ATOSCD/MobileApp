import 'package:flutter/material.dart';

class ListPage extends StatelessWidget {
  const ListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('리스트 페이지')),
      body: const Center(
        child: Text(
          '여기는 빈 리스트 페이지입니다.',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}