import 'dart:convert';
// import 'dart:io';

// import 'package:api_call_for_login_screen/admin_dashboard_screen.dart';
import 'package:api_call_for_login_screen/dashboard.dart';
import 'package:api_call_for_login_screen/model.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Employee_screen extends StatefulWidget {
  const Employee_screen({super.key, required this.data});
  final Data data;

  @override
  State<Employee_screen> createState() => _Employee_screenState();
}

class _Employee_screenState extends State<Employee_screen> {
  String? _sessionId;
  List<Map<String, dynamic>> _data = [];
  bool _isLoading = true;
  String loginUrl = "https://apis.siddhios.com/";

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _sessionId = prefs.getString('sessionId');
    if (_sessionId == null) {
      // Handle session ID not found
      return;
    }

    String apiUrl = "https://apis.siddhios.com/employee";
    var response = await http.get(
      Uri.parse(apiUrl),
      headers: {"Session-Id": _sessionId!},
    );

    if (response.statusCode == 200) {
      var responseData = jsonDecode(response.body) as List;
      setState(() {
        _data = responseData.map((data) => data as Map<String, dynamic>).toList();
        _isLoading = false;
      });
    } else {
      // Handle API request failure
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 141, 151, 156),
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          textAlign: TextAlign.center,
          'EMP   MGT   SYSTEM',
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.only(top: 4.0, left: 10, right: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Card.outlined(
                    color: const Color.fromARGB(255, 61, 52, 70),
                    shadowColor: Colors.blueGrey,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Container(
                      height: 40,
                      width: 120,
                      child: const Center(
                        child: Text(
                          'DASHBOARD',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              letterSpacing: 3.0,
                              color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _data.length,
                      itemBuilder: (context, index) {
                        var item = _data[index];
                        return EmployeeCard(
                          avatarUrl: loginUrl + (item['img'] ?? ''),
                          employeeName: item['userid'] ?? '',
                          designation: item['deg'] ?? '',
                          employeeID: item['eid'] ?? '',
                          type: item['type'] ?? '',
                          dateofJoining: item['doj'] ?? '',
                          salary: item['salary'] ?? '',
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}