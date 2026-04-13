import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

// Custom class to store result data
class CoffeeResult {
  final String label;
  final double score;

  CoffeeResult({required this.label, required this.score});
}

Future<String> uploadFile(File file) async {
  const String baseUrl = 'https://yafiazka-coffee-classifier.hf.space/gradio_api';
  final url = Uri.parse('$baseUrl/upload');
  
  var request = http.MultipartRequest('POST', url);
  request.files.add(await http.MultipartFile.fromPath('files', file.path));
  
  var streamedResponse = await request.send().timeout(const Duration(seconds: 15));
  var response = await http.Response.fromStream(streamedResponse);
  
  if (response.statusCode == 200) {
    final List<dynamic> jsonResponse = jsonDecode(response.body);
    if (jsonResponse.isNotEmpty) {
      return jsonResponse[0].toString();
    }
  }
  throw Exception("Gagal mengunggah file. Status: ${response.statusCode}");
}

Future<List<CoffeeResult>> classifyCoffee(File imageFile) async {
  const String baseUrl = 'https://yafiazka-coffee-classifier.hf.space/gradio_api';
  final predictUrl = Uri.parse('$baseUrl/call/predict_coffee');
  
  try {
    // Step 0: Upload File
    final String serverPath = await uploadFile(imageFile);

    // Step 1: POST to initiate prediction
    final postResponse = await http.post(
      predictUrl,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "data": [
          {
            "path": serverPath,
            "orig_name": imageFile.path.split(Platform.pathSeparator).last,
            "meta": {"_type": "gradio.FileData"}
          }
        ]
      }),
    ).timeout(const Duration(seconds: 15));

    if (postResponse.statusCode != 200) {
      throw Exception("Gagal inisiasi prediksi. Status: ${postResponse.statusCode}");
    }

    final eventId = jsonDecode(postResponse.body)['event_id'];
    if (eventId == null) {
      throw Exception("Tidak mendapatkan event_id dari server.");
    }

    // Step 2: GET to listen for results (SSE)
    final streamUrl = Uri.parse('$predictUrl/$eventId');
    
    final client = http.Client();
    final request = http.Request('GET', streamUrl);
    final response = await client.send(request).timeout(const Duration(seconds: 10));

    if (response.statusCode != 200) {
      throw Exception("Gagal mengambil hasil prediksi. Status: ${response.statusCode}");
    }

    // Process the stream
    final stream = response.stream
        .transform(utf8.decoder)
        .transform(const LineSplitter())
        .timeout(const Duration(seconds: 30), onTimeout: (sink) {
          sink.close();
        });
    
    await for (final line in stream) {
      if (line.startsWith('data: ')) {
        final dataStr = line.substring(6);
        if (dataStr == 'null') {
          continue;
        }
        
        try {
          final jsonData = jsonDecode(dataStr);
          
          if (jsonData is List && jsonData.isNotEmpty) {
            final resultData = jsonData[0];
            
            if (resultData is Map && resultData.containsKey('confidences')) {
              final List confidences = resultData['confidences'];
              
              client.close();
              return confidences.map((c) => CoffeeResult(
                label: c['label'].toString(),
                score: (c['confidence'] as num).toDouble(),
              )).toList();
            }
          }
        } catch (e) {
          // Ignore parse errors
        }
      }
    }
    
    client.close();
    return [];
  } catch (e) {
    rethrow;
  }
}



Future<void> callLambda1() async {
  const String baseUrl = 'https://yafiazka-coffee-classifier.hf.space/gradio_api';
  final url = Uri.parse('$baseUrl/call/lambda_1');
  try {
    await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"data": []}),
    );
  } catch (e) {
    // Silence lambda_1 errors
  }
}

Future<bool> checkApiConnection() async {
  final url = Uri.parse('https://yafiazka-coffee-classifier.hf.space/');
  try {
    final response = await http.get(url).timeout(const Duration(seconds: 5));
    if (response.statusCode == 200) {
      // Trigger lambda_1 as part of initial sequence if desired
      await callLambda1();
      return true;
    }
    return false;
  } catch (_) {
    return false;
  }
}

