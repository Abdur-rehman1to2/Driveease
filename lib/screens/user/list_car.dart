import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class AddCar extends StatefulWidget {
  const AddCar({super.key});
  @override
  State<AddCar> createState() => _AddCarScreenState();
}

class _AddCarScreenState extends State<AddCar> {
  // Controllers
  final carNameController = TextEditingController();
  final modelController = TextEditingController();
  final priceController = TextEditingController();
  final locationController = TextEditingController();
  final durationController = TextEditingController();
  
  XFile? _pickedFile;
  final picker = ImagePicker();
  bool isLoading = false;

  Future<void> _pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _pickedFile = pickedFile;
      });
    }
  }

  Future<String?> _uploadToImgBB() async {
    if (_pickedFile == null) return null;
    try {
      const apiKey = 'e2c5f651c0d8f3335227037a2d984204';
      final url = Uri.parse('https://api.imgbb.com/1/upload?key=$apiKey');
      
      var request = http.MultipartRequest('POST', url);
      
      if (kIsWeb) {
        request.files.add(http.MultipartFile.fromBytes(
          'image',
          await _pickedFile!.readAsBytes(),
          filename: _pickedFile!.name,
        ));
      } else {
        request.files.add(await http.MultipartFile.fromPath(
          'image',
          _pickedFile!.path,
        ));
      }

      var response = await request.send();
      if (response.statusCode == 200) {
        var responseData = await response.stream.bytesToString();
        var decodedData = json.decode(responseData);
        return decodedData['data']['url'];
      } else {
        print("ImgBB Upload failed: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("ImgBB Upload error: $e");
      return null;
    }
  }

  void submitData() async {
    String name = carNameController.text.trim();
    String model = modelController.text.trim();
    String price = priceController.text.trim();
    String location = locationController.text.trim();
    String duration = durationController.text.trim();

    if (name.isEmpty || model.isEmpty || price.isEmpty || location.isEmpty || duration.isEmpty || _pickedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all fields and select an image")),
      );
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please login to list a car")));
      return;
    }

    setState(() => isLoading = true);

    try {
      String? imageUrl = await _uploadToImgBB();

      if (imageUrl == null) {
        throw Exception("Failed to upload image to ImgBB");
      }

      await FirebaseFirestore.instance.collection('cars').add({
        'name': name,
        'model': model,
        'price': double.tryParse(price) ?? 0.0,
        'location': location,
        'availability': duration,
        'ownerId': user.uid,
        'isBooked': false,
        'createdAt': FieldValue.serverTimestamp(),
        'imageUrl': imageUrl,
      });

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Car Added Successfully")));

      carNameController.clear();
      modelController.clear();
      priceController.clear();
      locationController.clear();
      durationController.clear();
      setState(() {
        _pickedFile = null;
      });
      
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: ${e.toString()}")));
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Your Car"),
        backgroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(15),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const Text(
                "Turn your idle car into a source of income",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24, fontStyle: FontStyle.italic),
              ),
              const SizedBox(height: 20),
              
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey),
                  ),
                  child: _pickedFile != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: kIsWeb 
                            ? Image.network(_pickedFile!.path, fit: BoxFit.contain)
                            : Image.file(File(_pickedFile!.path), fit: BoxFit.contain),
                        )
                      : const Padding(
                          padding: EdgeInsets.symmetric(vertical: 40),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add_a_photo, size: 50, color: Colors.grey),
                              Text("Upload Car Image", style: TextStyle(color: Colors.grey)),
                            ],
                          ),
                        ),
                ),
              ),
              
              const SizedBox(height: 20),
              TextField(
                controller: carNameController,
                decoration: const InputDecoration(labelText: "Car Name", border: OutlineInputBorder()),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: modelController,
                decoration: const InputDecoration(labelText: "Model", border: OutlineInputBorder()),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: priceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "Price per Day", border: OutlineInputBorder()),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: locationController,
                decoration: const InputDecoration(labelText: "Location", border: OutlineInputBorder()),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: durationController,
                decoration: const InputDecoration(labelText: "Availability Duration", border: OutlineInputBorder()),
              ),
              const SizedBox(height: 25),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isLoading ? null : submitData,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    padding: const EdgeInsets.all(15),
                  ),
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("Submit"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
