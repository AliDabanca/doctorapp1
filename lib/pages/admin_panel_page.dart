import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AdminPanelPage extends StatefulWidget {
  const AdminPanelPage({super.key});

  @override
  State<AdminPanelPage> createState() => _AdminPanelPageState();
}

class _AdminPanelPageState extends State<AdminPanelPage> {
  List<Map<String, dynamic>> doctors = [];
  bool isLoading = true;
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    fetchDoctors();
  }

  Future<void> fetchDoctors() async {
    try {
      final snapshot = await FirebaseFirestore.instance.collection('doctors').get();

      setState(() {
        doctors = snapshot.docs
            .where((doc) =>
        doc.data().containsKey('role') &&
            (doc['role'] as String).toLowerCase() == 'doctor')
            .map((doc) {
          final data = doc.data();
          return {
            'id': doc.id,
            'name': data['name'] ?? '',
            'email': data['email'] ?? '',
            'department': data['department'] ?? '',
            'phone': data['phone'] ?? '',
            'age': data['age'] ?? '',
            'specialty': data['specialty'] ?? '',
          };
        }).toList();
        isLoading = false;
      });
    } catch (e) {
      print('Doktorlar yüklenirken hata oluştu: $e');
      setState(() => isLoading = false);
    }
  }

  void showDoctorDetails(Map<String, dynamic> doctor) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(doctor['name']),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Email: ${doctor['email']}'),
            Text('Phone: ${doctor['phone']}'),
            Text('Department: ${doctor['department']}'),
            Text('Specialty: ${doctor['specialty']}'),
            Text('Age: ${doctor['age']}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredDoctors = doctors.where((doc) {
      final name = doc['name'].toString().toLowerCase();
      return name.contains(searchQuery.toLowerCase());
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Panel - Doctors'),
        backgroundColor: Colors.blue.shade700,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search doctor by name...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
              },
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredDoctors.length,
              padding: const EdgeInsets.all(16),
              itemBuilder: (context, index) {
                final doctor = filteredDoctors[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    title: Text(doctor['name']),
                    subtitle: Text('${doctor['department']}\n${doctor['email']}'),
                    isThreeLine: true,
                    trailing: IconButton(
                      icon: const Icon(Icons.info_outline, color: Colors.blue),
                      onPressed: () => showDoctorDetails(doctor),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}