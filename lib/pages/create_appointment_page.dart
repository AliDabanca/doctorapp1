import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CreateAppointmentPage extends StatefulWidget {
  final DateTime selectedDate;

  const CreateAppointmentPage({super.key, required this.selectedDate});

  @override
  State<CreateAppointmentPage> createState() => _CreateAppointmentPageState();
}

class _CreateAppointmentPageState extends State<CreateAppointmentPage> {
  final TextEditingController patientController = TextEditingController();
  final TextEditingController timeController = TextEditingController();
  final TextEditingController notesController = TextEditingController();

  bool isLoading = false;

  Future<void> saveAppointment() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;
    final patient = patientController.text.trim();
    final time = timeController.text.trim();
    final notes = notesController.text.trim();
    final date = DateFormat('yyyy-MM-dd').format(widget.selectedDate);

    if (patient.isEmpty || time.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill in all required fields.")),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      await FirebaseFirestore.instance.collection('appointments').add({
        'userId': userId,
        'date': date,
        'time': time,
        'patient': patient,
        'notes': notes,
        'createdAt': Timestamp.now(),
      });

      if (context.mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error saving: $e")),
      );
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text('New Appointment'),
        backgroundColor: Colors.blue[800],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          bottom: MediaQuery
              .of(context)
              .viewInsets
              .bottom + 24,
          top: 24,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Create a new appointment",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0D47A1),
              ),
            ),
            const SizedBox(height: 24),
            _buildInputField(
              controller: patientController,
              label: 'Patient Name',
              icon: Icons.person,
            ),
            const SizedBox(height: 16),
            _buildInputField(
              controller: timeController,
              label: 'Time (e.g. 14:00)',
              icon: Icons.access_time,
            ),
            const SizedBox(height: 16),
            _buildInputField(
              controller: notesController,
              label: 'Notes',
              icon: Icons.notes,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: isLoading ? null : saveAppointment,
                icon: const Icon(Icons.save, color: Colors.white), // 👈 Icon rengi beyaz
                label: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                  'Save Appointment',
                  style: TextStyle(color: Colors.white), // 👈 Yazı rengi beyaz
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[800],
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  textStyle: const TextStyle(fontSize: 16),
                ),
              ),

            ),
          ],
        ),
      ),
    );
  }

// 🔹 Özel input builder
  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.blue[700]),
        labelStyle: TextStyle(color: Colors.blue[800]),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.blue),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.blue.shade100),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.blue.shade700, width: 2),
        ),
      ),
    );
  }
}
