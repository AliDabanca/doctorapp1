import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'private_chat_page.dart';

class PrivateChatListPage extends StatefulWidget {
  const PrivateChatListPage({super.key});

  @override
  State<PrivateChatListPage> createState() => _PrivateChatListPageState();
}

class _PrivateChatListPageState extends State<PrivateChatListPage> {
  final String? currentUserId = FirebaseAuth.instance.currentUser?.uid;

  @override
  Widget build(BuildContext context) {
    if (currentUserId == null) {
      return const Scaffold(
        body: Center(child: Text("Giriş yapmış kullanıcı bulunamadı.")),
      );
    }

    final chatRef = FirebaseFirestore.instance.collection('private_chats');

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text('Private Chats'),
        backgroundColor: Colors.blue.shade700,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: chatRef.orderBy('updatedAt', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final chatDocs = snapshot.data?.docs ?? [];
          final myChats = chatDocs.where((doc) {
            final users = (doc.data() as Map<String, dynamic>)['users'] ?? [];
            return users.contains(currentUserId);
          }).toList();

          if (myChats.isEmpty) {
            return Center(
              child: Text(
                "You have not got a message yet.",
                style: TextStyle(color: Colors.grey.shade600),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: myChats.length,
            itemBuilder: (context, index) {
              final data = myChats[index].data() as Map<String, dynamic>;
              final users = data['users'];
              final otherUserId = users.firstWhere((uid) => uid != currentUserId);

              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance.collection('doctors').doc(otherUserId).get(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData || !snapshot.data!.exists) {
                    return const SizedBox();
                  }

                  final userData = snapshot.data!.data() as Map<String, dynamic>;
                  final name = userData['name'] ?? 'Unknown';
                  final lastMessage = data['lastMessage'] ?? '';

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: Colors.blue,
                        child: Icon(Icons.person, color: Colors.white),
                      ),
                      title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(
                        lastMessage,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.chat_bubble_outline, color: Colors.blue),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => PrivateChatPage(
                                    doctorId: otherUserId,
                                    doctorName: name,
                                  ),
                                ),
                              );
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline, color: Colors.red),
                            onPressed: () async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text("Delete Chat"),
                                  content: const Text("Are you sure you want to delete this chat?"),
                                  actions: [
                                    TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel")),
                                    TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("Delete")),
                                  ],
                                ),
                              );

                              if (confirm == true) {
                                await FirebaseFirestore.instance
                                    .collection('private_chats')
                                    .doc(myChats[index].id)
                                    .delete();
                              }
                            },
                          ),
                        ],
                      ),

                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PrivateChatPage(
                              doctorId: otherUserId,
                              doctorName: name,
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              );
            },
          );
        },
      ),

      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.blue,
        icon: const Icon(Icons.add),
        label: const Text("New Chat"),
        onPressed: () {
          showSearch(
            context: context,
            delegate: DoctorSearchDelegate(currentUserId!),
          );
        },
      ),
    );
  }
}

class DoctorSearchDelegate extends SearchDelegate {
  final String currentUserId;

  DoctorSearchDelegate(this.currentUserId);

  @override
  String? get searchFieldLabel => 'Enter a name';

  @override
  List<Widget> buildActions(BuildContext context) {
    return [IconButton(icon: const Icon(Icons.clear), onPressed: () => query = '')];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => close(context, null));
  }

  @override
  Widget buildResults(BuildContext context) {
    return buildDoctorList();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return buildDoctorList();
  }

  Widget buildDoctorList() {
    final doctorRef = FirebaseFirestore.instance
        .collection('doctors')
        .where(FieldPath.documentId, isNotEqualTo: currentUserId);

    return FutureBuilder<QuerySnapshot>(
      future: doctorRef.get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

        final results = snapshot.data!.docs.where((doc) {
          final name = (doc.data() as Map<String, dynamic>)['name'] ?? '';
          return name.toLowerCase().contains(query.toLowerCase());
        }).toList();

        if (results.isEmpty) {
          return const Center(child: Text("Doktor bulunamadı."));
        }

        return ListView(
          children: results.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final id = doc.id;
            final name = data['name'] ?? '';
            final department = data['department'] ?? '';

            return ListTile(
              leading: const Icon(Icons.person),
              title: Text(name),
              subtitle: Text(department),
              onTap: () {
                close(context, null);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PrivateChatPage(
                      doctorId: id,
                      doctorName: name,
                    ),
                  ),
                );
              },
            );
          }).toList(),
        );
      },
    );
  }
}
