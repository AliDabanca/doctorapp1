import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'department_chat_page.dart';

class DepartmentsPage extends StatefulWidget {
  const DepartmentsPage({super.key});

  @override
  State<DepartmentsPage> createState() => _DepartmentsPageState();
}

class _DepartmentsPageState extends State<DepartmentsPage> {
  List<Map<String, dynamic>> departments = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchDepartments();
  }

  Future<void> fetchDepartments() async {
    try {
      final snapshot =
      await FirebaseFirestore.instance.collection('departments').get();
      setState(() {
        departments = snapshot.docs.map((doc) {
          final data = doc.data();
          return {
            'name': data['name'] ?? '',
            'icon': getIconFromString(data['icon']),
          };
        }).toList();
        isLoading = false;
      });
    } catch (e) {
      print('Departmanlar yüklenirken hata oluştu: $e');
      setState(() => isLoading = false);
    }
  }

  final Map<String, IconData> iconMap = {
    'favorite': Icons.favorite,
    'spa': Icons.spa,
    'psychology': Icons.psychology,
    'child_care': Icons.child_care,
    'camera_alt': Icons.camera_alt,
    'healing': Icons.healing,
    'accessibility_new': Icons.accessibility_new,
  };

  IconData getIconFromString(String? iconName) {
    return iconMap[iconName] ?? Icons.help_outline;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text('Departments'),
        backgroundColor: Colors.blue.shade700,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: departments.length,
        itemBuilder: (context, index) {
          final dept = departments[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DepartmentChatPage(
                    department: dept['name'],
                  ),
                ),
              );
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue.shade100, Colors.blue.shade50],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.shade400,
                    blurRadius: 6,
                    offset: const Offset(2, 4),
                  )
                ],
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                    vertical: 12, horizontal: 20),
                leading: CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Icon(dept['icon'], color: Colors.blue),
                ),
                title: Text(
                  dept['name'],
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                trailing: Icon(Icons.arrow_forward_ios,
                    color: Colors.blue.shade300),
              ),
            ),
          );
        },
      ),
    );
  }
}