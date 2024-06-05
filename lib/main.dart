import 'dart:convert';
// import 'package:api_call_for_login_screen/admin_dashboard_screen.dart';
// import 'package:api_call_for_login_screen/admin_dashboard_screen.dart';
// import 'package:api_call_for_login_screen/dashboard.dart';
import 'package:api_call_for_login_screen/admin_dashboard.dart';
import 'package:api_call_for_login_screen/employee_dashboard.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:api_call_for_login_screen/model.dart';

void main() {
  runApp(const MyApplication());
}

class MyApplication extends StatelessWidget {
  const MyApplication({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Login_Screen',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const LoginScreen(),
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool isLoading = false;
  String? deviceId;
  String? sessionId;

  String loginUrl = "https://apis.siddhios.com/";

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (timeStamp) {
        getDeviceId();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'Login',
                style: TextStyle(fontSize: 45, color: Colors.blue[300]),
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: 'Username',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(31),
                  ),
                  prefixIcon: const Icon(Icons.person),
                  fillColor: Colors.grey[200],
                  filled: true,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your username';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(31),
                  ),
                  prefixIcon: const Icon(Icons.lock),
                  fillColor: Colors.grey[200],
                  filled: true,
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.blue[300],
                  borderRadius: BorderRadius.circular(31),
                ),
                child: ElevatedButton(
                  onPressed: _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                  ),
                  child: isLoading
                      ? CircularProgressIndicator(color: Colors.white)
                      : const Text('SUBMIT', style: TextStyle(fontSize: 22, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> sendRequest() async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    if (deviceId != null) {
      var response = await http.post(
        Uri.parse(loginUrl),
        headers: {"Device-Id": deviceId!},
      );

      if (response.statusCode == 511) {
        var responseHeader = (response.headers);
        String sessionId = responseHeader['session-id'] ?? '';
        await pref.setString('sessionId', sessionId);
        String? sessionIds = await pref.getString('sessionId');
        print("sessionId == $sessionIds");
      } else {
        print("Initial Request Failed: ${response.statusCode}");
      }
    }
  }

  Future<void> getDeviceId() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    deviceId = prefs.getString('deviceId');

    if (deviceId == null) {
      if (Theme.of(context).platform == TargetPlatform.android) {
        AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
        deviceId = androidInfo.id;
      } else if (Theme.of(context).platform == TargetPlatform.iOS) {
        IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
        deviceId = iosInfo.identifierForVendor!;
      } else {
        throw UnsupportedError('Unsupported platform');
      }
      await prefs.setString('deviceId', deviceId!);
    }
    print('Device id == $deviceId');
    sendRequest();
  }

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        isLoading = true;
      });
      await LoginRequest();
    }
  }

  Future<void> LoginRequest() async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    String? deviceId = pref.getString('deviceId');
    String? sessionId = pref.getString('sessionId');

    try {
      var loginResponse = await http.post(
        Uri.parse(loginUrl),
        body: jsonEncode({
          "user": _usernameController.text,
          "pass": _passwordController.text,
        }),
        headers: {
          "Content-Type": "application/json",
          if (sessionId != null) "Session-Id": sessionId,
          "Device-Id": deviceId!,
        },
      );
// print('s1');
      if (loginResponse.statusCode == 200) {
        // print('sai');
        var loginResponseBody = loginmodel.fromJson(jsonDecode(loginResponse.body));
        if (loginResponseBody.status == 1) {
          var logindata = loginResponseBody.data![0];
          if (logindata.type == "employee") {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => Employee_screen(data: logindata),
              ),
            );
          } else {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => admin_dashboard( data: logindata,),
              ),
            );
          }
          _showSnackBar('Login successful', Colors.green);
        } else {
          _showSnackBar('Please enter valid details', Colors.red);
        }
      } else {
        print("HTTP Error: ${loginResponse.statusCode}");
      }
    } catch (e) {
      print("Error during login: $e");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _showSnackBar(String message, Color? color) {
    final snackBar = SnackBar(
      content: Text(message),
      backgroundColor: color,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}