import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

// Custom class to store result data
class CoffeeResult {
  final String label;
  final double score;

  CoffeeResult({required this.label, required this.score});
}

Future<List<CoffeeResult>> classifyCoffee(File imageFile) async {
  final url = Uri.parse('https://yafiazka-coffee-classifier.hf.space/api/predict');
  
  try {
    final bytes = await imageFile.readAsBytes();
    final base64Image = base64Encode(bytes);

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "data": [
          "data:image/jpeg;base64," + base64Image
        ]
      }),
    );

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      
      // Standard Gradio output parsing
      // Usually: {"data": [{"label": "top_label", "confidences": [{"label": "L1", "confidence": 0.9}, ...]}]}
      if (jsonResponse['data'] != null && jsonResponse['data'].isNotEmpty) {
        final data = jsonResponse['data'][0];
        
        if (data is Map && data.containsKey('confidences')) {
          final List confidences = data['confidences'];
          return confidences.map((c) => CoffeeResult(
            label: c['label'].toString(),
            score: (c['confidence'] as num).toDouble(),
          )).toList();
        } else if (data is Map) {
          // Alternative format: {"data": [{"label1": 0.9, "label2": 0.1}]}
          List<CoffeeResult> results = [];
          data.forEach((key, value) {
            if (value is num && key != 'label') {
               results.add(CoffeeResult(label: key.toString(), score: value.toDouble()));
            }
          });
          results.sort((a, b) => b.score.compareTo(a.score));
          return results;
        }
      }
      return [];
    } else {
      throw Exception("Gagal menghubungi server. Status code: ${response.statusCode}");
    }
  } catch (e) {
    print("Terjadi kesalahan: $e");
    rethrow;
  }
}