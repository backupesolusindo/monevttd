import 'package:flutter/material.dart';
import 'package:monitoringobat/util/colors.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:monitoringobat/util/core.dart';
import 'package:lottie/lottie.dart';

class RiwayatKuesioner extends StatefulWidget {
  const RiwayatKuesioner({Key? key}) : super(key: key);

  @override
  State<RiwayatKuesioner> createState() => _RiwayatKuesionerState();
}

class _RiwayatKuesionerState extends State<RiwayatKuesioner> {
  List<Map<String, dynamic>> dataRiwayat = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRiwayat();
  }

  Future<void> _loadRiwayat() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userDataString = prefs.getString('user_data');
      
      if (userDataString == null) {
        throw Exception('Data user tidak ditemukan');
      }

      final userData = json.decode(userDataString);
      final userId = userData['id_user'];

      var uri = Uri.parse('${base_url}api/Question/riwayat')
          .replace(queryParameters: {'id_user': userId.toString()});
      
      var response = await http.get(
        uri,
        headers: {
          'Accept': 'application/json',
        },
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        var jsonResponse = json.decode(response.body);
        if (jsonResponse['message']['status'] == 200) {
          setState(() {
            dataRiwayat = List<Map<String, dynamic>>.from(jsonResponse['response']);
            _isLoading = false;
          });
        } else {
          setState(() {
            dataRiwayat = [];
            _isLoading = false;
          });
        }
      } else {
        throw Exception('Gagal memuat data riwayat');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('Riwayat Kuesioner', 
          style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)
        ),
        backgroundColor: PrimaryColor,
      ),
      body: _isLoading
          ? Container(
              width: double.infinity,
              height: double.infinity,
              color: Colors.white,
              child: Center(
                child: Lottie.asset(
                  'assets/lottie/main_loading.json',
                  width: 200,
                  height: 200,
                ),
              ),
            )
          : Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/bgmonevminumobatbaru.png'),
                  fit: BoxFit.cover,
                ),
              ),
              child: SafeArea(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // Container untuk riwayat
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Text(
                              //   'Riwayat Kuesioner',
                              //   style: TextStyle(
                              //     fontSize: 18, 
                              //     fontWeight: FontWeight.bold,
                              //     color: PrimaryColor
                              //   ),
                              // ),
                              // SizedBox(height: 16),
                              dataRiwayat.isEmpty
                                  ? Container(
                                      width: double.infinity,
                                      padding: EdgeInsets.symmetric(vertical: 32),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Center(
                                        child: Text(
                                          'Belum ada riwayat kuesioner',
                                          style: TextStyle(
                                            fontSize: 16, 
                                            color: Colors.grey[600]
                                          ),
                                        ),
                                      ),
                                    )
                                  : ListView.builder(
                                      shrinkWrap: true,
                                      physics: NeverScrollableScrollPhysics(),
                                      itemCount: dataRiwayat.length,
                                      itemBuilder: (context, index) {
                                        var item = dataRiwayat[index];
                                        return Card(
                                          margin: EdgeInsets.only(bottom: 16),
                                          color: Colors.white,
                                          elevation: 2,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: ExpansionTile(
                                            title: Text(
                                              'Tanggal: ${DateFormat('dd MMMM yyyy').format(DateTime.parse(item['tanggal']))}',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.grey[800],
                                              ),
                                            ),
                                            children: [
                                              ListView.builder(
                                                shrinkWrap: true,
                                                physics: NeverScrollableScrollPhysics(),
                                                itemCount: (item['jawaban'] as List).length,
                                                itemBuilder: (context, jawabanIndex) {
                                                  var jawaban = item['jawaban'][jawabanIndex];
                                                  return Padding(
                                                    padding: EdgeInsets.all(12),
                                                    child: Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Text(
                                                          'Pertanyaan ${jawabanIndex + 1}:',
                                                          style: TextStyle(
                                                            fontWeight: FontWeight.bold,
                                                            color: Colors.black,
                                                          ),
                                                        ),
                                                        SizedBox(height: 4),
                                                        Text(
                                                          jawaban['pertanyaan'],
                                                          style: TextStyle(
                                                            fontSize: 14,
                                                            color: Colors.black87,
                                                          ),
                                                        ),
                                                        SizedBox(height: 4),
                                                        Text(
                                                          'Jawaban: ${jawaban['jawaban']}',
                                                          style: TextStyle(
                                                            fontSize: 14,
                                                            fontWeight: FontWeight.bold,
                                                            color: Colors.black,
                                                          ),
                                                        ),
                                                        if (jawabanIndex < (item['jawaban'] as List).length - 1)
                                                          Divider(height: 24),
                                                      ],
                                                    ),
                                                  );
                                                },
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                            ],
                          ),
                        ),
                      ),
                      // Container kosong di bawah (jika diperlukan)
                      SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
