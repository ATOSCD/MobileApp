import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'user_id.dart';
import 'server.dart';

class EditCategoryPage extends StatefulWidget {
  const EditCategoryPage({super.key});

  @override
  State<EditCategoryPage> createState() => _EditCategoryPageState();
}

class _EditCategoryPageState extends State<EditCategoryPage> {
  final String userId = patient;

  final List<Map<String, dynamic>> allItems = [
    {'title': '에어컨', 'icon': Icons.ac_unit},
    {'title': '침대', 'icon': Icons.bed},
    {'title': '책', 'icon': Icons.menu_book},
    {'title': '의자', 'icon': Icons.chair},
    {'title': '시계', 'icon': Icons.access_time},
    {'title': '문', 'icon': Icons.door_front_door},
    {'title': '선풍기', 'icon': Icons.air},
    {'title': '노트북', 'icon': Icons.laptop},
    {'title': '머그컵', 'icon': Icons.local_cafe},
    {'title': '체온계', 'icon': Icons.thermostat},
    {'title': '티비', 'icon': Icons.tv},
    {'title': '창문', 'icon': Icons.window},
    {'title': '램프', 'icon': Icons.lightbulb},
    {'title': '휴지', 'icon': Icons.layers},
  ];

  late List<String> selectedCategories;
  late List<String> originalSelectedCategories;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchSelectedCategories();
  }

  Future<void> fetchSelectedCategories() async {
    try {
      final response = await Dio().post(
        'http://$baseUrl/get-selected-category/',
        data: {'user_id': userId},
        options: Options(headers: {'Content-Type': 'application/json'}),
      );

      if (response.statusCode == 200 && response.data is List) {
        setState(() {
          selectedCategories = List<String>.from(response.data);
          originalSelectedCategories = List<String>.from(response.data);
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching categories: $e');
      setState(() {
        selectedCategories = [];
        originalSelectedCategories = [];
        isLoading = false;
      });
    }
  }

  void onConfirm() async {
    try {
      await Dio().post(
        'http://$baseUrl/select-button-category/',
        data: {
          'user_id': userId,
          'category': selectedCategories,
        },
        options: Options(headers: {'Content-Type': 'application/json'}),
      );
      Navigator.pop(context);
    } catch (e) {
      debugPrint('Error sending categories: $e');
    }
  }

  void onCancel() {
    setState(() {
      selectedCategories = List<String>.from(originalSelectedCategories);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('상호작용 목록 편집'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 1,
      ),
      backgroundColor: const Color(0xFFF8F8F8),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: ListView.separated(
                    itemCount: allItems.length,
                    separatorBuilder: (context, index) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final item = allItems[index];
                      String category = item['title'];
                      return CheckboxListTile(
                        secondary: Icon(item['icon'], color: Colors.indigo),
                        title: Text(category, style: const TextStyle(fontSize: 18)),
                        value: selectedCategories.contains(category),
                        onChanged: (bool? value) {
                          setState(() {
                            if (value == true) {
                              selectedCategories.add(category);
                            } else {
                              selectedCategories.remove(category);
                            }
                          });
                        },
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.blue,
                          side: const BorderSide(color: Colors.blue),
                          backgroundColor: Colors.white,
                        ),
                        onPressed: onCancel,
                        child: const Text('취소'),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: onConfirm,
                        child: const Text('확인'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
