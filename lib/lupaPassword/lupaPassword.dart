import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:monitoringobat/Signup/signup_screen.dart';
import 'package:monitoringobat/components/already_have_an_account_acheck.dart';
import 'package:monitoringobat/components/constants.dart';
import 'package:monitoringobat/dashboard/dashboard.dart';
import 'package:monitoringobat/lupaPassword/inputPasswordBaru.dart';
import 'package:monitoringobat/lupaPassword/lupaPassword.dart';
import 'package:monitoringobat/model/user.dart';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';

import '../util/core.dart';
import '../util/colors.dart';

class Lupa extends StatefulWidget {
  const Lupa({
    Key? key,
  }) : super(key: key);

  @override
  State<Lupa> createState() => _LupaState();
}

class _LupaState extends State<Lupa> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _tglLahirController = TextEditingController();

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
    final String email = _emailController.text;
    final String tglLahir = _tglLahirController.text;

    await getToken(); // Memanggil fungsi getToken untuk mendapatkan token OAuth2

    // Membuat request body
    final Map<String, String> data = {
      "email": email,
      "tgl_lahir": tglLahir,
    };

    // Mengirim permintaan HTTP POST ke API dengan menyertakan token
    final response = await http.post(
      Uri.parse(base_url + 'api/Login/lupaPassword'),
      headers: {
        'Authorization':
            'Bearer $accessToken', // Menyertakan token dalam header
      },
      body: data,
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);

      // Simpan data pengguna ke SharedPreferences

      print(responseData);
      userData = UserData.fromJson(responseData['response']);
      final prefs = await SharedPreferences.getInstance();
      prefs.setString('access_token', accessToken);
      // Simpan data pengguna lainnya jika diperlukan
      prefs.setString('user_data', json.encode(userData.toJson()));

      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => pasBaru(),
          ));
    } else {
      final responseData = json.decode(response.body);

      if (responseData['response'] != null) {
        final errorMessage = 'username atau password salah';
        Fluttertoast.showToast(
          msg: errorMessage,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
      } else {
        print('Gagal masuk: ${response.statusCode}');
        print('Pesan kesalahan: ${response.body}');
      }
    }
  }

  @override
  void initState() {
    super.initState();
    // Ambil token saat halaman login dimuat
    getToken();

    // Periksa apakah token akses sudah ada
    // checkUserSession();
  }

  // Future<void> checkUserSession() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   final savedAccessToken = prefs.getString('access_token');

  //   if (savedAccessToken != null) {
  //     Navigator.pushReplacement(
  //       context,
  //       MaterialPageRoute(builder: (context) => Dashboard()),
  //     );
  //     // Token akses sudah ada, mungkin pengguna sudah masuk
  //     // Anda dapat memeriksa validitas token di sini
  //     // Misalnya, jika token kedaluwarsa, Anda dapat mengarahkan pengguna untuk logout
  //     // atau memperbarui token.
  //   }
  // }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('Lupa Password'),
        titleTextStyle: TextStyle(
            color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        backgroundColor: PrimaryColor,
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/bgmonevminumobatbaru.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              children: [
                SizedBox(height: 80),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  cursorColor: PrimaryColor,
                  decoration: InputDecoration(
                    hintText: "Masukan Email Anda",
                    prefixIcon: Padding(
                      padding: const EdgeInsets.all(defaultPadding),
                      child: Icon(Icons.email, color: PrimaryColor),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: PrimaryColor, width: 1.5),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: PrimaryColor, width: 1.5),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: PrimaryColor, width: 2),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
                SizedBox(height: 16.0),
                TextFormField(
                  controller: _tglLahirController,
                  keyboardType: TextInputType.number,
                  maxLength: 8,
                  cursorColor: PrimaryColor,
                  decoration: InputDecoration(
                    hintText: "Tanggal Lahir: 10122002 (ddmmyyyy)",
                    prefixIcon: Padding(
                      padding: const EdgeInsets.all(defaultPadding),
                      child: Icon(Icons.calendar_today, color: PrimaryColor),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: PrimaryColor, width: 1.5),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: PrimaryColor, width: 1.5),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: PrimaryColor, width: 2),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
                SizedBox(height: 32),
                ElevatedButton(
                  onPressed: _login,
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: PrimaryColor,
                    padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    "Verifikasi".toUpperCase(),
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
