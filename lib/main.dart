import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_pytorch_lite/flutter_pytorch_lite.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(const CoffeeClassifierApp());
}

// Custom class to store result data
class CoffeeResult {
  final String label;
  final double score;

  CoffeeResult({required this.label, required this.score});
}

class CoffeeClassifierApp extends StatelessWidget {
  const CoffeeClassifierApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Coffee Bean Classifier',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6F4E37), // Coffee brown
          brightness: Brightness.light,
        ),
      ),
      home: const ClassifierPage(),
    );
  }
}

class ClassifierPage extends StatefulWidget {
  const ClassifierPage({super.key});

  @override
  State<ClassifierPage> createState() => _ClassifierPageState();
}

class _ClassifierPageState extends State<ClassifierPage> {
  File? _image;
  Module? _module;
  List<CoffeeResult>? _results;
  bool _isProcessing = false;
  final ImagePicker _picker = ImagePicker();

  // Labels based on the requirement
  final List<String> _labels = ['peaberry', 'longberry', 'premium', 'defect'];

  @override
  void initState() {
    super.initState();
    _loadModel();
  }

  Future<void> _loadModel() async {
    try {
      // flutter_pytorch_lite requires model to be in a file path
      // So we copy from assets to a temp directory
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/coffee_model.ptl';
      
      final byteData = await rootBundle.load("assets/model/coffee_model_flutter.ptl");
      final file = File(filePath);
      await file.writeAsBytes(byteData.buffer.asUint8List());

      _module = await FlutterPytorchLite.load(filePath);
      debugPrint("Model loaded successfully from $filePath");
    } catch (e) {
      debugPrint("Failed to load model: $e");
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    // Request permissions
    if (source == ImageSource.camera) {
      var status = await Permission.camera.request();
      if (!status.isGranted) return;
    }

    final XFile? pickedFile = await _picker.pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
        _results = null;
      });
      _runInference();
    }
  }

  // Softmax function to convert logits to probabilities
  List<double> _softmax(Float32List logits) {
    double maxLogit = logits.reduce(max);
    List<double> exps = logits.map((l) => exp(l - maxLogit)).toList();
    double sumExps = exps.reduce((a, b) => a + b);
    return exps.map((e) => e / sumExps).toList();
  }

  Future<void> _runInference() async {
    if (_image == null || _module == null) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      // 1. Prepare image as Tensor
      // Convert File to ImageProvider then to ui.Image
      final provider = FileImage(_image!);
      final uiImage = await TensorImageUtils.imageProviderToImage(provider);

      // 2. Convert to Tensor [1, 3, 224, 224] (NCHW)
      final tensor = await TensorImageUtils.imageToFloat32Tensor(
        uiImage,
        width: 224,
        height: 224,
      );

      // 3. Run inference
      final input = IValue.from(tensor);
      final outputIValue = await _module!.forward([input]);
      
      // 4. Extract data and process
      final outputTensor = outputIValue.toTensor();
      final Float32List logits = outputTensor.dataAsFloat32List;
      final List<double> probabilities = _softmax(logits);

      // 5. Map to labels and sort
      List<CoffeeResult> unsortedResults = [];
      for (int i = 0; i < min(_labels.length, probabilities.length); i++) {
        unsortedResults.add(CoffeeResult(
          label: _labels[i],
          score: probabilities[i],
        ));
      }

      unsortedResults.sort((a, b) => b.score.compareTo(a.score));

      setState(() {
        _results = unsortedResults;
      });
    } catch (e) {
      debugPrint("Inference error: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e")),
        );
      }
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  void _reset() {
    setState(() {
      _image = null;
      _results = null;
      _isProcessing = false;
    });
  }

  Widget _buildResultItem(String label, double score) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              Text(
                "${(score * 100).toStringAsFixed(2)}%",
                style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.brown),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: score,
              minHeight: 10,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(
                score > 0.5 ? Theme.of(context).colorScheme.primary : Colors.brown.shade300,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "USK Coffee Classifier",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF6F4E37), // Solid Coffee Brown
        elevation: 4,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image Preview Area
            GestureDetector(
              onTap: () => _pickImage(ImageSource.gallery),
              child: Container(
                height: 320,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                  border: Border.all(color: Colors.brown.shade100, width: 2),
                ),
                child: _image != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(23),
                        child: Image.file(_image!, fit: BoxFit.cover),
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.camera_enhance_rounded, size: 70, color: Colors.brown.shade200),
                          const SizedBox(height: 15),
                          Text(
                            "Tap untuk pilih gambar biji kopi",
                            style: TextStyle(color: Colors.brown.shade300, fontSize: 16, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 25),

            // Buttons Area
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isProcessing ? null : () => _pickImage(ImageSource.camera),
                    icon: const Icon(Icons.camera_alt),
                    label: const Text("Ambil Foto"),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      backgroundColor: const Color(0xFF6F4E37),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    ),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _isProcessing ? null : () => _pickImage(ImageSource.gallery),
                    icon: const Icon(Icons.image),
                    label: const Text("Upload"),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      side: const BorderSide(color: Color(0xFF6F4E37)),
                      foregroundColor: const Color(0xFF6F4E37),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),

            // Results Area
            if (_isProcessing)
              const Center(
                child: Column(
                  children: [
                    CircularProgressIndicator(color: Color(0xFF6F4E37)),
                    SizedBox(height: 20),
                    Text("Sedang mengklasifikasi...", style: TextStyle(fontWeight: FontWeight.w500)),
                  ],
                ),
              )
            else if (_results != null && _results!.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Center(
                    child: Text(
                      "──── Hasil Analisis AI ────",
                      style: TextStyle(color: Colors.brown, letterSpacing: 1.2, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Top Prediction Badge
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [const Color(0xFF6F4E37), Colors.brown.shade400],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.brown.withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        const Text("Prediksi Tertinggi:", style: TextStyle(color: Colors.white70, fontSize: 13)),
                        const SizedBox(height: 5),
                        Text(
                          _results![0].label.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w900, // Fixed: Using w900 instead of black
                            color: Colors.white,
                            letterSpacing: 2,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 35),

                  const Text(
                    "Detail Skor Klasifikasi:",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF6F4E37)),
                  ),
                  const SizedBox(height: 15),
                  
                  // Progress Bars
                  ..._results!.map((res) => _buildResultItem(res.label, res.score)).toList(),
                  
                  const SizedBox(height: 40),
                  
                  // Reset Button
                  Center(
                    child: TextButton.icon(
                      onPressed: _reset,
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text("Reset & Scan Lagi", style: TextStyle(fontSize: 16)),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.red.shade700,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      ),
                    ),
                  ),
                ],
              )
            else
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 50.0),
                  child: Column(
                    children: [
                      Icon(Icons.coffee_outlined, size: 50, color: Colors.grey),
                      SizedBox(height: 10),
                      Text(
                        "Pilih foto untuk memulai klasifikasi",
                        style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
