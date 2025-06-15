import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'create_appointment_page.dart';

class DoctorAgendaPage extends StatefulWidget {
  const DoctorAgendaPage({super.key});

  @override
  State<DoctorAgendaPage> createState() => _DoctorAgendaPageState();
}

class _DoctorAgendaPageState extends State<DoctorAgendaPage> {
  DateTime selectedDate = DateTime.now();
  final userId = FirebaseAuth.instance.currentUser?.uid;

  Future<List<Map<String, dynamic>>> getAppointmentsForDate(DateTime date) async {
    final formattedDate = DateFormat('yyyy-MM-dd').format(date);
    final query = await FirebaseFirestore.instance
        .collection('appointments')
        .where('userId', isEqualTo: userId)
        .where('date', isEqualTo: formattedDate)
        .get();

    return query.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return data;
    }).toList();
  }

  void _selectDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  Future<void> markAsDone(String id) async {
    await FirebaseFirestore.instance.collection('appointments').doc(id).update({
      'done': true,
    });
    setState(() {});
  }

  Future<void> deleteAppointment(String id) async {
    await FirebaseFirestore.instance.collection('appointments').doc(id).delete();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final dayLabel = DateFormat('d MMMM y').format(selectedDate);
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text('My Agenda'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: _selectDate,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Yeni hali:
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => CreateAppointmentPage(selectedDate: selectedDate),
            ),
          ).then((_) => setState(() {}));
        },
        label: const Text("New Appointment"),
        icon: const Icon(Icons.add),
        backgroundColor: Colors.blue[800],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              dayLabel,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: getAppointmentsForDate(selectedDate),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Opacity(
                            opacity: 0.1,
                            child: Image.asset(
                              'lib/images/logo2.png',
                              width: 200,
                              height: 200,
                            ),
                          ),
                          const Text(
                            "No appointments for this day.",
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    );


                  }

                  final appointments = snapshot.data!;
                  final notDone = appointments.where((a) => a['done'] != true).toList();
                  final done = appointments.where((a) => a['done'] == true).toList();

                  return ListView(
                    children: [
                      ...notDone.map((a) => appointmentCard(a, false)).toList(),
                      if (done.isNotEmpty) ...[
                        const Padding(
                          padding: const EdgeInsets.only(top: 16.0, bottom: 8),
                          child: Row(
                            children: const [
                              Icon(Icons.check_circle, color: Colors.green),
                              SizedBox(width: 8),
                              Text(
                                " Done",
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),

                        ...done.map((a) => appointmentCard(a, true)).toList(),
                      ],
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget appointmentCard(Map<String, dynamic> a, bool isDone) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isDone ? Colors.green[100] : Colors.blue[100],
          child: Icon(
            isDone ? Icons.check : Icons.access_time,
            color: isDone ? Colors.green : Colors.blue[700],
          ),
        ),
        title: Text(
          '${a['time']} - ${a['patient']}',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(a['notes'] ?? ''),
        trailing: isDone
            ? null
            : Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.check_circle, color: Colors.green),
              onPressed: () => markAsDone(a['id']),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => deleteAppointment(a['id']),
            ),
          ],
        ),
      ),
    );
  }
}
