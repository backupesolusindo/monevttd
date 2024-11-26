import 'package:flutter/material.dart';
import 'package:monitoringobat/util/colors.dart';
import 'package:monitoringobat/util/core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:monitoringobat/model/user.dart';
import 'package:intl/intl.dart';

class LaporanBBTBHBPage extends StatefulWidget {
  @override
  _LaporanBBTBHBPageState createState() => _LaporanBBTBHBPageState();
}

class _LaporanBBTBHBPageState extends State<LaporanBBTBHBPage> {
  final _formKey = GlobalKey<FormState>();
  final _bbController = TextEditingController();
  final _tbController = TextEditingController();
  final _hbController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _bbController.dispose();
    _tbController.dispose();
    _hbController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final prefs = await SharedPreferences.getInstance();
        var userDataString = prefs.getString('user_data');
        var accessToken = prefs.getString('access_token');

        if (userDataString == null || accessToken == null) {
          throw Exception('User data atau token tidak ditemukan');
        }

        final userData = UserData.fromJson(json.decode(userDataString));

        // Validasi nilai numerik
        double bb = double.parse(_bbController.text);
        double tb = double.parse(_tbController.text);
        double hb = double.parse(_hbController.text);

        if (bb <= 0 || tb <= 0 || hb <= 0) {
          throw Exception('Nilai pengukuran harus lebih dari 0');
        }

        String currentDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

        var uri = Uri.parse('${base_url}api/LaporanBBTBHB/tambah');
        var response = await http.post(
          uri,
          headers: {
            'Authorization': 'Bearer $accessToken',
            'Accept': 'application/json',
            'Content-Type': 'application/x-www-form-urlencoded',
          },
          body: {
            'id_user': userData.idUser.toString(),
            'tanggal': currentDate,
            'berat_badan': bb.toString(),
            'tinggi_badan': tb.toString(),
            'hemoglobin': hb.toString(),
          },
        );

        print('Response status: ${response.statusCode}');
        print('Response body: ${response.body}');

        var jsonResponse = json.decode(response.body);
        
        if (jsonResponse['message']['status'] == 200) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green),
                    SizedBox(width: 10),
                    Text('Berhasil'),
                  ],
                ),
                content: Text(jsonResponse['message']['message']),
                actions: [
                  TextButton(
                    child: Text('OK'),
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).pop(true);
                    },
                  ),
                ],
              );
            },
          );
        } else {
          throw Exception(jsonResponse['message']['message']);
        }
      } catch (e) {
        print('Error: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  InputDecoration _buildInputDecoration(String hintText) {
    return InputDecoration(
      hintText: hintText,
      filled: true,
      fillColor: Colors.white,
      contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15.0),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15.0),
        borderSide: BorderSide(color: Colors.grey.shade200, width: 1.0),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15.0),
        borderSide: BorderSide(color: PrimaryColor, width: 2.0),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('BB, TB & HB', 
          style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)
        ),
        backgroundColor: PrimaryColor,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/bgmonevminumobatbaru.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: EdgeInsets.all(16),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildInputField('Berat Badan (kg)', _bbController),
                            SizedBox(height: 16),
                            _buildInputField('Tinggi Badan (cm)', _tbController),
                            SizedBox(height: 16),
                            _buildInputField('Hemoglobin (g/dL)', _hbController),
                            SizedBox(height: 32),
                            Center(
                              child: ElevatedButton(
                                child: _isLoading 
                                  ? CircularProgressIndicator(color: Colors.white)
                                  : Text('Simpan Laporan', style: TextStyle(color: Colors.white)),
                                onPressed: _isLoading ? null : _submitForm,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: PrimaryColor,
                                  padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 30),
                            Divider(color: PrimaryColor),
                            SizedBox(height: 20),
                            Text(
                              'Kadar Hemoglobin Normal:',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: PrimaryColor,
                              ),
                            ),
                            // SizedBox(height: 10),
                            Text(
                              'Kadar hemoglobin (Hb) normal dalam darah:\n'
                              '• Pria dewasa: 13–17 g/dL\n'
                              '• Wanita dewasa: 12–15 g/dL\n'
                              '• Wanita hamil: Di atas 11 g/dL\n'
                              '• Bayi: 11 g/dL\n'
                              '• Anak-anak usia 1–6 tahun: 11,5 g/dL\n'
                              '• Anak hingga remaja usia 6–18 tahun: 12 g/dL',
                              style: TextStyle(fontSize: 16, color: Colors.black87),
                            ),
                            // SizedBox(height: 20),
                            Text(
                              'Catatan: Nilai di atas adalah panduan umum. Konsultasikan dengan dokter untuk interpretasi yang lebih akurat sesuai kondisi Anda.',
                              style: TextStyle(
                                fontSize: 14,
                                fontStyle: FontStyle.italic,
                                color: PrimaryColor,
                              ),
                            ),
                            SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputField(String label, TextEditingController controller) {
    return TextFormField(
      controller: controller,
      decoration: _buildInputDecoration(label),
      keyboardType: TextInputType.numberWithOptions(decimal: true),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Mohon isi $label';
        }
        try {
          double val = double.parse(value);
          if (val <= 0) {
            return '$label harus lebih dari 0';
          }
        } catch (e) {
          return 'Masukkan angka yang valid';
        }
        return null;
      },
    );
  }
}
