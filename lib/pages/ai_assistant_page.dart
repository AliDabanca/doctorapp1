import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AIAssistantPage extends StatefulWidget {
  const AIAssistantPage({super.key});

  @override
  State<AIAssistantPage> createState() => _AIAssistantPageState();
}

class _AIAssistantPageState extends State<AIAssistantPage> {
  final TextEditingController _controller = TextEditingController();
  String responseText = '';
  bool isLoading = false;

  Future<void> getAIResponse(String prompt) async {
    setState(() {
      isLoading = true;
      responseText = '';
    });

    const apiKey = ''; // Buraya kendi key'ini yaz
    final url =
        '';

    final body = jsonEncode({
      "contents": [
        {
          "role": "user",
          "parts": [
            {"text": prompt}
          ]
        }
      ]
    });

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
        },
        body: body,
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final text = decoded['candidates']?[0]?['content']?['parts']?[0]?['text'] ?? 'Yanıt alınamadı.';
        setState(() {
          responseText = text;
          isLoading = false;
        });
      } else {
        setState(() {
          responseText = 'Sunucu hatası: ${response.statusCode}';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        responseText = 'Bir hata oluştu: $e';
        isLoading = false;
      });
    }
  }




  void _handleSubmit() {
    final input = _controller.text.trim();
    if (input.isNotEmpty) {
      getAIResponse("Bir doktor olarak, hastanın şu semptomları var: $input. Bu semptomlara göre olası hastalıklar ve öneriler nelerdir?");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("AI Assistant"),
        backgroundColor: Colors.blue.shade700,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Hastanın semptomlarını girin...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Colors.grey[100],
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: isLoading ? null : _handleSubmit,
              icon: const Icon(Icons.chat),
              label: const Text("Yanıtla"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
            const SizedBox(height: 16),
            if (isLoading)
              const CircularProgressIndicator()
            else if (responseText.isNotEmpty)
              Expanded( // 📌 burada expanded ile tüm boş alanı kaplayacak
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(12),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Text(responseText),
                  ),
                ),
              ),
          ],
        ),
      ),

    );
  }
}