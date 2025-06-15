import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'edit_profile_page.dart';

class DoctorProfilePage extends StatefulWidget {
  const DoctorProfilePage({super.key});

  @override
  State<DoctorProfilePage> createState() => _DoctorProfilePageState();
}

class _DoctorProfilePageState extends State<DoctorProfilePage> {
  final userId = FirebaseAuth.instance.currentUser?.uid;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.grey.shade100,
        appBar: AppBar(
          title: const Text('Doctor Profile'),
          backgroundColor: Colors.blue.shade700,
          elevation: 4,
        ),
        body: userId == null
            ? const Center(child: Text('No user found'))
            : FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('doctors')
        .doc(userId)
        .get(),
    builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
    return const Center(child: CircularProgressIndicator());
    }
    if (!snapshot.hasData || !snapshot.data!.exists) {
    return const Center(child: Text('User data not found.'));
    }
    final data = snapshot.data!.data() as Map<String, dynamic>;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          CircleAvatar(
            radius: 60,
            backgroundColor: Colors.blue.shade100,
            child: Icon(
              Icons.person,
              size: 60,
              color: Colors.blue.shade700,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '${data['name'] ?? 'N/A'}',
            style: const TextStyle(
                fontSize: 24, fontWeight: FontWeight.bold),
          ),
          Text(
            '${data['department'] ?? ''} Department',
            style: TextStyle(
                fontSize: 16, color: Colors.grey.shade700),
          ),
          const SizedBox(height: 24),
          buildInfoTile('Specialty', data['specialty'] ?? ''),
          buildInfoTile('Email', data['email'] ?? ''),
          buildInfoTile('Phone', data['phone'] ?? ''),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      EditProfilePage(userData: data),
                ),
              );
            },
            icon: const Icon(Icons.edit, color: Colors.white), // 🔵 İkon rengi beyaz
            label: const Text(
              'Edit Profile',
              style: TextStyle(color: Colors.white), // 🔵 Yazı rengi beyaz
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade600,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),

          )
        ],
      ),
    );
    },
        ),
    );
  }

  Widget buildInfoTile(String title, String value) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: const Icon(Icons.info_outline, color: Colors.blue),
        title: Text(title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        subtitle: Text(value, style: const TextStyle(fontSize: 15)),
      ),
    );
  }
}