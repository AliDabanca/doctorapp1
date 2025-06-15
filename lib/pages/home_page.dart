import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'agenda_page.dart';
import 'ai_assistant_page.dart';
import 'admin_panel_page.dart';
import 'community_page.dart';
import 'department_chat_page.dart';
import 'my_profile.dart';
import 'private_chat_list_page.dart';
import 'welcome_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? role;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchUserRole();
  }

  Future<void> fetchUserRole() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      final userDoc =
      await FirebaseFirestore.instance.collection('doctors').doc(userId).get();
      setState(() {
        role = userDoc.data()?['role'] ?? 'doctor';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentTime = TimeOfDay.now();

    return Scaffold(
      backgroundColor: const Color(0xFFE6F0FA),
      body: SafeArea(
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 🔷 Üst Mavi Bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(30),
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                        child: Stack(
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                // 🔹 Logo
                                Image.asset(
                                  'lib/images/logo2.png',
                                  width: 70,
                                  height: 70,
                                  fit: BoxFit.contain,
                                ),
                                const SizedBox(width: 12),

                                // 🔹 Yazılar
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        "Medical Park",
                                        style: TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.blue[800],
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Wednesday - ${currentTime.format(context)}',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.blue[800],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // 🔹 Logout icon
                                IconButton(
                                  icon: const Icon(Icons.logout, color: Colors.blue),
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: const Text("Exit"),
                                        content: const Text("Do you want to quit?"),
                                        actions: [
                                          TextButton(
                                            child: const Text("No"),
                                            onPressed: () => Navigator.pop(context),
                                          ),
                                          TextButton(
                                            child: const Text("Yes"),
                                            onPressed: () {
                                              Navigator.pushAndRemoveUntil(
                                                context,
                                                MaterialPageRoute(builder: (_) => const WelcomePage()),
                                                    (route) => false,
                                              );
                                            },
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                    ),
                  ),
                  const SizedBox(height: 30),

                  // Ana butonlar
                  Expanded(
                    child: GridView.count(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      children: [
                        HomeButton(
                          title: 'My Profile',
                          icon: Icons.person,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const DoctorProfilePage(),
                              ),
                            );
                          },
                        ),

                        if (role == 'doctor')
                          HomeButton(
                            title: 'Agenda',
                            icon: Icons.calendar_month,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const DoctorAgendaPage(),
                                ),
                              );
                            },
                          ),

                        if (role == 'admin')
                          HomeButton(
                            title: 'Admin Panel',
                            icon: Icons.admin_panel_settings,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => const AdminPanelPage()),
                              );
                            },
                          ),

                        HomeButton(
                          title: 'Community',
                          icon: Icons.forum,
                          onTap: () async {
                            final userId = FirebaseAuth.instance.currentUser?.uid;
                            if (userId == null) return;

                            final userDoc = await FirebaseFirestore.instance
                                .collection('doctors')
                                .doc(userId)
                                .get();

                            final department = userDoc['department'];

                            if (department == null || department.toString().trim().isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("Departman bilgisi bulunamadı")),
                              );
                              return;
                            }

                            if (role == 'admin') {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const DepartmentsPage()),
                              );
                            } else {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => DepartmentChatPage(department: department),
                                ),
                              );
                            }
                          },
                        ),

                        HomeButton(
                          title: 'Private Chat',
                          icon: Icons.chat,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const PrivateChatListPage(),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Alt ortada AI Assistant
            Positioned(
              bottom: 30,
              left: 0,
              right: 0,
              child: Center(
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AIAssistantPage(),
                      ),
                    );
                  },
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.blue[600],
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.shade300,
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.smart_toy,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HomeButton extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  const HomeButton({
    super.key,
    required this.title,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              offset: Offset(2, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: Colors.blue[700]),
            const SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                color: Colors.blue[900],
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
