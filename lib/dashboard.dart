import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EmployeeCard extends StatefulWidget {
  final String? employeeName;
  final String? employeePosition;
  final String? employeeID;
  final String? avatarUrl;
  final String? designation;
  final String? salary;
  final String? type;
  final String? dateofJoining;

  const EmployeeCard({
    super.key,
    required this.employeeName,
    this.employeePosition,
    this.employeeID,
    this.avatarUrl,
    this.designation,
    this.salary,
    this.type,
    this.dateofJoining,
  });

  @override
  State<EmployeeCard> createState() => _EmployeeCardState();
}

class _EmployeeCardState extends State<EmployeeCard> {
  final ImagePicker _picker = ImagePicker();
  XFile? _image;
  File? image;
  String? _errorMessage;
  String? _employeeId;
  String? _userId;
  String? _designation;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchDataFromApi();
  }

  Future<void> fetchDataFromApi() async {
    String apiUrl = "https://apis.siddhios.com/dashboard";

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        Map<String, dynamic> data = jsonDecode(response.body);
        setState(() {
          _employeeId = data['employeeId'];
          _userId = data['userId'];
          _designation = data['designation'];
        });
      } else {
        throw Exception('Failed to load data: ${response.statusCode}');
      }
    } catch (error) {
      print('Error fetching data: $error');
    }
  }

  Future<void> _pickImage() async {
    final XFile? pickedImage = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      final file = File(pickedImage.path);
      final fileSize = await file.length();
      const int maxSizeInBytes = 2 * 1024 * 1024; // 2 MB in bytes

      if (fileSize <= maxSizeInBytes) {
        setState(() {
          _image = pickedImage;
          _errorMessage = null;
        });
        _uploadImage(file);
      } else {
        setState(() {
          _image = null;
          _errorMessage = 'Image should not be more than 2 MB. Please provide an image which is less than 2 MB.';
        });
      }
    }
  }

  Future<void> _uploadImage(File image) async {
    final uri = Uri.parse('https://apis.siddhios.com/uploadImg');
    final request = http.MultipartRequest('POST', uri)
      ..files.add(await http.MultipartFile.fromPath('file', image.path));
    
    SharedPreferences pref = await SharedPreferences.getInstance();
    String? sessionId = pref.getString('sessionId');
    String? deviceId = pref.getString('deviceId');
    if (sessionId != null && deviceId != null) {
      request.headers['Device-Id'] = deviceId;
      request.headers['Session-Id'] = sessionId;
    }

    final response = await request.send();

    if (response.statusCode == 200) {
      print('Image uploaded successfully.');
    } else {
      print('Image upload failed with status: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      shadowColor: Colors.blueGrey,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      elevation: 5,
      child: Container(
        height: 400,
        width: double.maxFinite,
        padding: const EdgeInsets.only(top: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () {
                _pickImage();
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundImage: _image != null ? FileImage(File(_image!.path)) : null,
                    child: _image == null
                        ? widget.avatarUrl != null
                            ? Image.network(widget.avatarUrl!)
                            : const Icon(Icons.person, size: 50)
                        : null,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  Text(
                    widget.employeeName ?? '',
                    style: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'ID: ${_employeeId ?? widget.employeeID ?? ''}',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color.fromARGB(255, 32, 32, 32)),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'TYPE: ${widget.type ?? ''}',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color.fromARGB(255, 32, 32, 32)),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _designation ?? widget.designation ?? '',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color.fromARGB(255, 32, 32, 32)),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'DOJ: ${widget.dateofJoining ?? ''}',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color.fromARGB(255, 32, 32, 32)),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'SALARY: ₹ ${widget.salary ?? ''}',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color.fromARGB(255, 32, 32, 32)),
                  ),
                ],
              ),
            ),
            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.red, fontSize: 16),
                ),
              ),
          ],
        ),
      ),
    );
  }
}