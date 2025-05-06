import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;
import 'server.dart';
import 'user_id.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _messages = [
  ];

  late WebSocketChannel _channel;
  final Dio _dio = Dio();
  final ScrollController _scrollController = ScrollController();

  Future<void> getPreviousMessages() async {
    try {
      // POST 요청
      final response = await _dio.get(
        'http://$baseUrl/get-messages/$protector/',
      );
      if (response.statusCode == 200) {
        final List<dynamic> messages = response.data is String
          ? jsonDecode(response.data) // 문자열이면 JSON 파싱
          : response.data; // 이미 List<dynamic>이면 그대로 사용
        setState(() {
        for (var message in messages) {
          // 각 메시지를 _messages 리스트에 추가
          _messages.add({
            'sender': message['user_id'], // JSON의 user_id 필드
            'message': message['content'], // JSON의 message 필드
          });
        }
      });
      } else {
        setState(() {
          _messages.add({'sender': 'error', 'message': 'Error: ${response.statusCode}'});
        });
      }
    } catch (e) {
      // 에러 메시지 출력
      setState(() {
        _messages.add({'sender': 'error', 'message': 'Error: $e'});
      });
    }
  }

  @override
  void initState() {
    super.initState();
    // 웹소켓 채널 초기화
    _channel = WebSocketChannel.connect(
      Uri.parse('ws://$baseUrl/ws/chat?user_id=$protector'),
    );

    //이전 메시지 띄우기
    getPreviousMessages();

    //_scrollController. jumpTo(_scrollController.position.maxScrollExtent);

    // 수신 메시지 처리
    _channel.stream.listen((messageJson) {
      final decodedMessage = jsonDecode(messageJson);
      final message = decodedMessage['message']; // message 부분만 추출
      final sender = decodedMessage['user_id']; // sender 부분만 추출
      setState(() {
        _messages.add({'sender': sender, 'message': message});
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      });
    }, onError: (error) {
      setState(() {
        _messages.add({'sender': "error", 'message': 'Error: $error'});
      });
    });
  }

  Future<void> sendMessage(String message) async {
    if (message.isNotEmpty) {
      // 사용자 메시지 추가
      setState(() {
        //_messages.add({'sender': 'user', 'message': message});
      });

      // 웹소켓으로 메시지 전송
      _channel.sink.add(message);
    }
  }

  @override
  void dispose() {
    // 웹소켓 채널 닫기
    _channel.sink.close(status.normalClosure);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController
      	.jumpTo(_scrollController.position.maxScrollExtent);
    });
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Image.asset(
              'assets/chatting.png',
              width: 100,
              height: 140,
            ),
          ],
        ),
        backgroundColor: Colors.white, // 앱바 배경을 하얀색으로 설정
        elevation: 0,
      ),
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              controller: _scrollController,
              itemBuilder: (context, index) {
                final message = _messages[index];
                final isUser = message['sender'] == protector; 
                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isUser ? Color(0xFF3B3B3B) : Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      message['message'] ?? '',
                      style: TextStyle(
                        color: isUser ? Colors.white : Colors.black,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          // 입력 필드 및 전송 버튼
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: '메시지를 입력하세요',
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        onPressed: () {
                          final message = _controller.text.trim();
                          if (message.isNotEmpty) {
                            sendMessage(message); // 메시지 전송
                            _controller.clear(); // 입력 필드 초기화
                          }
                        },
                        icon: const Icon(
                          Icons.send,
                          color: Colors.grey,
                        ),
                      ),
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
}
