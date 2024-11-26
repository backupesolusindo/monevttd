import 'package:flutter/material.dart';
import 'package:monitoringobat/util/colors.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:monitoringobat/util/core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lottie/lottie.dart';

class Kuesioner extends StatefulWidget {
  final String tipe;
  
  const Kuesioner({Key? key, required this.tipe}) : super(key: key);
  
  @override
  _KuesionerPageState createState() => _KuesionerPageState();
}

class _KuesionerPageState extends State<Kuesioner> {
  bool _isLoading = true;
  List<Map<String, dynamic>> pertanyaanList = [];
  List<String?> selectedJawaban = [];
  final List<String> jawaban = ["Sangat Sering", "Sering", "Kadang-kadang", "Tidak pernah"];

  @override
  void initState() {
    super.initState();
    _loadPertanyaan();
  }

  Future<void> _loadPertanyaan() async {
    try {
      var uri = Uri.parse('${base_url}api/Question/Pertanyaan');
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
        if (jsonResponse['status'] == 200) {
          setState(() {
            pertanyaanList = (jsonResponse['response'] as List).map((item) => {
              'id_pertanyaan': int.parse(item['id_pertanyaan'].toString()),
              'pertanyaan': item['pertanyaan'].toString(),
              'is_answer': item['is_answer'].toString(),
            }).toList();
            selectedJawaban = List.filled(pertanyaanList.length, null);
            _isLoading = false;
          });
        } else {
          throw Exception(jsonResponse['message']);
        }
      } else {
        throw Exception('Gagal memuat pertanyaan');
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

  Future<void> _submitJawaban() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userDataString = prefs.getString('user_data');
      
      if (userDataString == null) {
        throw Exception('Data user tidak ditemukan');
      }

      final userData = json.decode(userDataString);
      final userId = userData['id_user'];

      List<Map<String, dynamic>> formattedJawaban = [];
      for (int i = 0; i < pertanyaanList.length; i++) {
        formattedJawaban.add({
          'id_pertanyaan': pertanyaanList[i]['id_pertanyaan'],
          'jawaban': selectedJawaban[i]
        });
      }

      var uri = Uri.parse('${base_url}api/Question/submit');
      var response = await http.post(
        uri,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json'
        },
        body: json.encode({
          'id_user': userId,
          'tipe': widget.tipe,
          'jawaban': formattedJawaban
        })
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      var jsonResponse = json.decode(response.body);
      if (jsonResponse['message']['status'] == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Jawaban berhasil disimpan')),
        );
        Navigator.pop(context);
      } else {
        throw Exception(jsonResponse['message']['message']);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll('Exception: ', '')),
          backgroundColor: Colors.red,
        ),
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
        title: Text(
          widget.tipe == 'sebelum' 
              ? 'Kuesioner Sebelum Menggunakan Aplikasi'
              : 'Kuesioner Sesudah Menggunakan Aplikasi',
          style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)
        ),
        backgroundColor: PrimaryColor,
      ),
      body: _isLoading 
          ? Container(
              color: Colors.white,
              child: Center(
                child: Container(
                  width: 200,
                  height: 200,
                  child: Lottie.asset(
                    'assets/lottie/main_loading.json',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            )
          : Container(
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
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: pertanyaanList.length,
                          itemBuilder: (context, index) {
                            return Card(
                              elevation: 0,
                              margin: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                              color: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Padding(
                                padding: EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Pertanyaan ${index + 1}:',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold, 
                                        fontSize: 16, 
                                        color: PrimaryColor
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      pertanyaanList[index]['pertanyaan'],
                                      style: TextStyle(fontSize: 16),
                                    ),
                                    SizedBox(height: 8),
                                    ...jawaban.map((j) => RadioListTile<String>(
                                      title: Text(j, style: TextStyle(fontSize: 16)),
                                      value: j,
                                      groupValue: selectedJawaban[index],
                                      onChanged: (value) {
                                        setState(() {
                                          selectedJawaban[index] = value;
                                        });
                                      },
                                      activeColor: PrimaryColor,
                                      contentPadding: EdgeInsets.zero,
                                      dense: true,
                                      visualDensity: VisualDensity(horizontal: 0, vertical: -4),
                                    )).toList(),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      SizedBox(height: 16),
                      ElevatedButton(
                        child: Text('Simpan Jawaban', 
                          style: TextStyle(fontSize: 16)
                        ),
                        onPressed: () {
                          bool adaPertanyaanBelumDijawab = selectedJawaban.contains(null);
                          
                          if (adaPertanyaanBelumDijawab) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Mohon jawab semua pertanyaan sebelum menyimpan.'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          } else {
                            _submitJawaban();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: PrimaryColor,
                          padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
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
