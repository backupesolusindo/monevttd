import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:monitoringobat/Signup/signup_screen.dart';
import 'package:monitoringobat/components/constants.dart';
import 'package:monitoringobat/dashboard/dashboard.dart';
import 'package:monitoringobat/lupaPassword/lupaPassword.dart';
import 'package:monitoringobat/model/user.dart';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../util/colors.dart';
import '../../util/core.dart';
import 'package:monitoringobat/util/alarm_service.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({
    Key? key,
  }) : super(key: key);

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscureText = true;
  bool _isLoading = false;
  String clientId = "PKL2023";
  String clientSecret = "PKLSERU";
  String tokenUrl = base_url + "api/Token/token";

  String accessToken = "";
  late UserData userData;

  Future<void> getToken() async {
    try {
      var response = await http.post(
        Uri.parse(tokenUrl),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'grant_type': 'client_credentials',
          'client_id': clientId,
          'client_secret': clientSecret,
        },
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> tokenData = jsonDecode(response.body);
        accessToken = tokenData['access_token'];
        print('Token Akses: $accessToken');
      } else {
        print('Gagal mendapatkan token: ${response.statusCode}');
      }
    } catch (e) {
      print('Gagal mendapatkan token: $e');
    }
  }

Future<void> _login() async {
  setState(() {
    _isLoading = true; 
  });

  final String username = _usernameController.text;
  final String password = _passwordController.text;

  await getToken();

  final Map<String, String> data = {
    "username": username,
    "password": password,
  };

  try {
    final response = await http.post(
      Uri.parse(base_url + 'api/Login/Login'),
      headers: {
        'Authorization': 'Bearer $accessToken',
      },
      body: data,
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      print(responseData);
      final prefs = await SharedPreferences.getInstance();
      prefs.setString('access_token', accessToken);

      if (responseData['response'] != null) {
        userData = UserData.fromJson(responseData['response']);
        prefs.setString('user_data', json.encode(userData.toJson()));

        await AlarmService.syncAlarmsFromApi();

        if (!mounted) return;
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => Dashboard(),
            ));
        return;
      } else {
        final errorMessage =
            responseData['message']['message'] ?? 'Terjadi kesalahan';
        Fluttertoast.showToast(
          msg: errorMessage,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.TOP,
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
      }
    } else {
      final responseData = json.decode(response.body);

      if (responseData['response'] != null) {
        final errorMessage = 'username atau password salah';
        Fluttertoast.showToast(
          msg: errorMessage,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.TOP_RIGHT,
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
      } else {
        print('Gagal masuk: ${response.statusCode}');
        print('Pesan kesalahan: ${response.body}');
      }
    }
  } catch (e) {
    print('Terjadi kesalahan: $e');
  } finally {
    if (mounted) {
      setState(() {
        _isLoading = false; 
      });
    }
  }
}

  @override
  void initState() {
    super.initState();
    getToken();

    checkUserSession();
  }

  Future<void> checkUserSession() async {
    final prefs = await SharedPreferences.getInstance();
    final savedAccessToken = prefs.getString('access_token');

    if (savedAccessToken != null) {
      await AlarmService.syncAlarmsFromApi();

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Dashboard()),
      );
    }
  }

  InputDecoration _pillInputDecoration({
    required String hint,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey.shade500),
      prefixIcon: Icon(icon, color: PrimaryColor),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: Colors.white,
      contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: BorderSide(color: Colors.grey.shade200, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: BorderSide(color: PrimaryColor, width: 1.5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
                    SizedBox(height: 16),

          TextFormField(
            controller: _usernameController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            cursorColor: PrimaryColor,
            decoration: _pillInputDecoration(
              hint: "Masukkan username",
              icon: Icons.email_outlined,
            ),
          ),
          SizedBox(height: 16),

          TextFormField(
            controller: _passwordController,
            textInputAction: TextInputAction.done,
            obscureText: _obscureText,
            cursorColor: PrimaryColor,
            decoration: _pillInputDecoration(
              hint: "Masukkan password",
              icon: Icons.lock_outline,
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureText ? Icons.visibility_off : Icons.visibility,
                  color: Colors.grey.shade600,
                ),
                onPressed: () {
                  setState(() {
                    _obscureText = !_obscureText;
                  });
                },
              ),
            ),
          ),
          SizedBox(height: 12),

          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Lupa(),
                  ),
                );
              },
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                'Lupa Password?',
                style: TextStyle(
                  color: PrimaryColor,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          SizedBox(height: 24),

         // Login button (gradient)
Container(
  height: 54,
  decoration: BoxDecoration(
    borderRadius: BorderRadius.circular(30),
    gradient: LinearGradient(
      colors: [
        PrimaryColor,
        PrimaryColor.withOpacity(0.7),
      ],
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
    ),
    boxShadow: [
      BoxShadow(
        color: PrimaryColor.withOpacity(0.35),
        blurRadius: 12,
        offset: Offset(0, 6),
      ),
    ],
  ),
  child: ElevatedButton(
    onPressed: _isLoading ? null : _login, // <-- cegah klik ganda saat loading
    style: ElevatedButton.styleFrom(
      foregroundColor: Colors.white,
      backgroundColor: Colors.transparent,
      shadowColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30),
      ),
    ),
    child: _isLoading
        ? SizedBox(
            height: 22,
            width: 22,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          )
        : Text(
            "Login",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
  ),
),
          SizedBox(height: 24),

          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Belum punya akun? ",
                  style: TextStyle(color: Colors.grey.shade700, fontSize: 14),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) {
                          return SignUpScreen();
                        },
                      ),
                    );
                  },
                  child: Text(
                    "Daftar Sekarang",
                    style: TextStyle(
                      color: PrimaryColor,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 20),

          // Terms
          
        ],
      ),
    );
  }
}